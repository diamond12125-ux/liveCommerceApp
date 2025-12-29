# Deploying to AWS EC2 (Ubuntu)

## Prerequisites

1.  **Key File**: Ensure `dtpair.pem` is in this folder (`c:\Users\snehal\liveCommerceApp`).
2.  **Permissions**: Run PowerShell as Administrator if needed (though not strictly required for this script).

## One-Click Deployment

I have created an automated PowerShell script that:

1.  Zips your project (excluding `node_modules`).
2.  Copies it to the server.
3.  Installs Docker & Docker Compose on the server.
4.  Builds and starts the application.

**Run this command in PowerShell:**

```powershell
./deploy_ec2.ps1
```

## Manual Deployment Steps (If script fails)

1.  **SSH into Server**:

    ```bash
    ssh -i "dtpair.pem" ubuntu@44.202.233.232
    ```

2.  **Clone/Copy Files**:
    Since we have custom Dockerfiles not in GitHub, it's best to copy files from your machine.

    ```powershell
    # On your local machine
    scp -i "dtpair.pem" -r docker-compose.yml setup_ec2.sh backend frontend realtime-service ubuntu@44.202.233.232:/home/ubuntu/app
    ```

3.  **Run Setup on Server**:
    ```bash
    cd /home/ubuntu/app
    sudo ./setup_ec2.sh
    sudo docker-compose up -d --build
    ```

## Verify

Visit: http://44.202.233.232
