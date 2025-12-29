# SareeLive Deployment Guide for AWS

This guide provides step-by-step instructions to deploy the SareeLive application on AWS using modern, scalable, and easy-to-manage services.

## Architecture Overview

*   **Frontend**: Hosted on **AWS Amplify** (Automatic CI/CD, CDN).
*   **Backend API**: Dockerized and hosted on **AWS App Runner** (Serverless container runner).
*   **Realtime Service**: Dockerized and hosted on **AWS App Runner**.
*   **Database**: **MongoDB Atlas** (Managed MongoDB).
*   **Cache/Locks**: **AWS ElastiCache** for Redis (Managed Redis).

## Prerequisites

1.  **AWS Account**: You need an active AWS account.
2.  **AWS CLI**: Installed and configured (`aws configure`).
3.  **Docker**: Installed and running locally.
4.  **GitHub/GitLab/Bitbucket**: Your code should be pushed to a repository.

---

## Step 1: Database Setup (MongoDB Atlas)

1.  Create an account on [MongoDB Atlas](https://www.mongodb.com/cloud/atlas).
2.  Create a new **Cluster** (The free tier M0 is sufficient for testing).
3.  **Network Access**: Allow access from anywhere (`0.0.0.0/0`) for simplicity, or configure VPC peering for better security.
4.  **Database Access**: Create a database user (username/password).
5.  **Get Connection String**:
    *   Click "Connect" -> "Connect your application".
    *   Copy the string (e.g., `mongodb+srv://<user>:<password>@cluster0.mongodb.net/?retryWrites=true&w=majority`).
    *   **Save this string** for later.

## Step 2: Redis Setup (AWS ElastiCache) - Optional

*If you want to skip this for a simple test, the application handles missing Redis gracefully (without inventory locking).*

1.  Go to the AWS Console -> **ElastiCache**.
2.  Create a **Redis** cluster.
3.  Choose **Serverless** or **Design your own** (t3.micro is cheap).
4.  Ensure it is in a **VPC** and Security Group allows traffic from your App Runner services (usually port 6379).
5.  **Save the Primary Endpoint** (e.g., `redis-xxx.cache.amazonaws.com`).

---

## Step 3: Deploy Backend Services (AWS App Runner)

We will use **AWS ECR** to store our Docker images and **AWS App Runner** to run them.

### 3.1 Create ECR Repositories

Run these commands in your terminal:

```bash
aws ecr create-repository --repository-name sareelive-backend
aws ecr create-repository --repository-name sareelive-realtime
```

### 3.2 Build and Push Images

Login to ECR (replace `region` and `account-id`):
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

**Build and Push Backend:**
```bash
docker build -t sareelive-backend ./backend
docker tag sareelive-backend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/sareelive-backend:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/sareelive-backend:latest
```

**Build and Push Realtime Service:**
```bash
docker build -t sareelive-realtime ./realtime-service
docker tag sareelive-realtime:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/sareelive-realtime:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/sareelive-realtime:latest
```

### 3.3 Create App Runner Service for Backend

1.  Go to **AWS App Runner** console.
2.  **Create Service**.
3.  **Source**: Container Registry -> Amazon ECR.
4.  **Image URI**: Select the `sareelive-backend` image you just pushed.
5.  **Deployment settings**: Automatic (optional) or Manual.
6.  **Configuration**:
    *   **Port**: `8001`
    *   **Environment Variables**:
        *   `MONGO_URL`: Your MongoDB Atlas connection string.
        *   `DB_NAME`: `saree_live`
        *   (Add other secrets from your local `.env`)
7.  **Create & Deploy**.
8.  **Copy the Default Domain** (e.g., `https://xyz.us-east-1.awsapprunner.com`). This is your **Backend URL**.

### 3.4 Create App Runner Service for Realtime Service

1.  Repeat the steps above for `sareelive-realtime` image.
2.  **Configuration**:
    *   **Port**: `8002`
    *   **Environment Variables**:
        *   `MONGO_URL`: Same as backend.
        *   `BACKEND_URL`: The **Backend URL** from Step 3.3.
        *   `REDIS_HOST`: Your Redis endpoint (if set up).
        *   `REDIS_PORT`: `6379`
3.  **Create & Deploy**.

---

## Step 4: Deploy Frontend (AWS Amplify)

1.  Push your code to a Git repository (GitHub, GitLab, etc.).
2.  Go to **AWS Amplify** console.
3.  **Create new app** -> **Host web app**.
4.  Connect your repository and select the branch (e.g., `main`).
5.  **Build settings**:
    *   Amplify usually detects the React app automatically.
    *   Ensure `baseDirectory` is set to `build` (for Create React App).
    *   **Important**: Edit the **monorepo** settings if needed. Point the "App root" to `frontend`.
6.  **Environment Variables** (Advanced Settings):
    *   `REACT_APP_BACKEND_URL`: The **Backend URL** from Step 3.3.
    *   `REACT_APP_REALTIME_URL`: The **Realtime URL** from Step 3.4 (if your frontend uses it).
7.  **Save and Deploy**.

Amplify will build your frontend and deploy it to a global CDN. You will get a URL like `https://main.d123.amplifyapp.com`.

## Step 5: Final Configuration

1.  Once the Frontend is live, go back to your **Backend App Runner service**.
2.  Update the **CORS** settings (if you hardcoded origins in `server.py`) to allow your new Amplify domain.
    *   *Note: Your `server.py` currently allows `["*"]`, so it should work immediately.*

## Troubleshooting

*   **Logs**: Check CloudWatch Logs (linked from App Runner console) for startup errors.
*   **Connectivity**: Ensure MongoDB Atlas IP whitelist allows connections from AWS (0.0.0.0/0 is easiest for testing).
*   **Health Check**: Visit `YOUR_BACKEND_URL/api/health` to verify the backend is running.
