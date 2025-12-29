# Manual AWS Deployment Guide (No Docker)

This guide covers how to deploy the SareeLive application manually to an AWS EC2 instance using SSH, Nginx, and system services (Systemd/PM2). It also covers setting up Route 53 for your domain.

---

## 1. Local Development (How to run locally)

Before deploying, ensure the app works on your machine.

### Prerequisites

- Node.js (v18+)
- Python (v3.10+)
- MongoDB (running locally)
- Redis (running locally)

### Step 1: Run Backend

1.  Open a terminal in `backend/`.
2.  Create/Activate virtual environment:
    ```bash
    python -m venv venv
    # Windows: .\venv\Scripts\activate
    # Mac/Linux: source venv/bin/activate
    ```
3.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
4.  Start Server:
    ```bash
    python -m uvicorn server:app --reload --port 8001
    ```

### Step 2: Run Realtime Service

1.  Open a terminal in `realtime-service/`.
2.  Install dependencies:
    ```bash
    npm install
    ```
3.  Start Service:
    ```bash
    npm run dev
    ```

### Step 3: Run Frontend

1.  Open a terminal in `frontend/`.
2.  Install dependencies:
    ```bash
    npm install
    ```
3.  Start React App:
    ```bash
    npm run dev
    ```
    (Opens http://localhost:5173 or similar)

---

## 2. Preparing the Build (Artifacts)

We will build the frontend locally to save resources on the server.

1.  **Frontend Build**:
    Open `frontend/` terminal and run:

    ```bash
    # Linux/Mac
    export VITE_BACKEND_URL=http://www.sattikaclothing.com/api
    npm run build

    # Windows (PowerShell)
    $env:VITE_BACKEND_URL="http://www.sattikaclothing.com/api"
    npm run build
    ```

    This creates a `dist` folder inside `frontend/`.

---

## 3. Connecting to AWS via SSH

You need your `.pem` key file (e.g., `dtpair.pem`) and the Public IP (e.g., `44.202.233.232`).

**Command:**

```bash
ssh -i "dtpair.pem" ubuntu@44.202.233.232
```

_Note: If you get a "Permission denied" error on the key file, run `chmod 400 dtpair.pem` (Mac/Linux) or check permissions in Windows._

---

## 4. Setting up the Server (One-Time Setup)

SSH into your server and run these commands to install necessary software.

### 4.1 Update & Install Basics

```bash
sudo apt-get update
sudo apt-get install -y python3-pip python3-venv nodejs npm nginx mongodb redis-server git acl
```

### 4.2 Install PM2 (Process Manager for Node)

```bash
sudo npm install -g pm2
```

### 4.3 Configure MongoDB & Redis

- **MongoDB**: `sudo systemctl start mongodb` (or `mongod`).
- **Redis**: `sudo systemctl start redis-server`.

---

## 5. Deployment Steps (Copy & Run)

### 5.1 Copy Files to Server

From your **LOCAL** machine (Git Bash or PowerShell), copy the code.

```bash
# Create directory on server
ssh -i "dtpair.pem" ubuntu@44.202.233.232 "mkdir -p ~/app"

# Copy Backend
scp -i "dtpair.pem" -r backend ubuntu@44.202.233.232:~/app/

# Copy Realtime Service
scp -i "dtpair.pem" -r realtime-service ubuntu@44.202.233.232:~/app/

# Copy Frontend DIST folder only (not the whole source)
scp -i "dtpair.pem" -r frontend/dist ubuntu@44.202.233.232:~/app/frontend-dist
```

### 5.2 Setup Backend (Python) on Server

SSH into server:

```bash
cd ~/app/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install gunicorn uvloop httptools

# Run with PM2 (keeps it running)
pm2 start "gunicorn -k uvicorn.workers.UvicornWorker server:app --bind 0.0.0.0:8001" --name backend
```

### 5.3 Setup Realtime Service (Node) on Server

```bash
cd ~/app/realtime-service
npm install --production

# Run with PM2
pm2 start server.js --name realtime --port 8002
```

### 5.4 Configure Nginx (Web Server & Proxy)

We use Nginx to serve the React files and forward API calls to Python.

1.  **Create Config**:

    ```bash
    sudo nano /etc/nginx/sites-available/sattika
    ```

2.  **Paste Content**:

    ```nginx
    server {
        listen 80;
        server_name www.sattikaclothing.com 44.202.233.232;

        # Frontend (Static Files)
        root /home/ubuntu/app/frontend-dist;
        index index.html;

        location / {
            try_files $uri $uri/ /index.html;
        }

        # Backend API Proxy
        location /api/ {
            proxy_pass http://127.0.0.1:8001;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }

        # Realtime Service Proxy
        location /realtime/ {
            proxy_pass http://127.0.0.1:8002/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
        }
    }
    ```

3.  **Enable Site**:
    ```bash
    sudo ln -s /etc/nginx/sites-available/sattika /etc/nginx/sites-enabled/
    sudo rm /etc/nginx/sites-enabled/default  # Remove default if exists
    sudo nginx -t                             # Test config
    sudo systemctl restart nginx
    ```

---

## 6. Route 53 Configuration (Domain Name)

To make `www.sattikaclothing.com` point to your AWS instance:

1.  Login to **AWS Console** -> **Route 53**.
2.  Go to **Hosted Zones**.
3.  Click your domain (`sattikaclothing.com`).
4.  **Create Record**:
    - **Record Name**: `www`
    - **Record Type**: `A`
    - **Value**: `44.202.233.232` (Your EC2 Public IP)
    - **TTL**: `300` (or default)
5.  Click **Create records**.

Wait a few minutes for DNS to propagate.

---

## 7. Troubleshooting

- **Check Backend Logs**: `pm2 logs backend`
- **Check Realtime Logs**: `pm2 logs realtime`
- **Check Nginx Logs**: `sudo tail -f /var/log/nginx/error.log`
- **Restart Everything**: `pm2 restart all && sudo systemctl restart nginx`
