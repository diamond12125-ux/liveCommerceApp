$EC2_HOST = "44.202.233.232"
$EC2_USER = "ubuntu"
$KEY_PATH = "dtpair.pem" 

# Check if key exists
if (-not (Test-Path $KEY_PATH)) {
    Write-Error "Key file '$KEY_PATH' not found in current directory! Please copy it here."
    exit 1
}

Write-Host "Preparing deployment for $EC2_HOST..."

# 1. Create a deployment archive
Write-Host "Creating deployment package..."
$exclude = @("node_modules", ".git", ".env", "build", "dist", "*.pem", "frontend-legacy")
Compress-Archive -Path "backend", "frontend", "realtime-service", "docker-compose.yml", "setup_ec2.sh" -DestinationPath "deploy_package.zip" -Force

# 2. Copy files to EC2
Write-Host "Copying package to EC2..."
# PowerShell variable expansion requires ${} for variables with special characters or in specific contexts, but simple $VAR works in strings.
# The issue was likely the : after the variable without braces in the previous tool call, or strict mode.
# We will use explicit string formatting for safety.
$remoteDest = "${EC2_USER}@${EC2_HOST}:/home/${EC2_USER}/"
scp -i $KEY_PATH -o StrictHostKeyChecking=no deploy_package.zip $remoteDest

# 3. Execute commands on EC2
Write-Host "Executing remote commands..."

# PowerShell doesn't support bash-style heredocs (<< EOF). We must use a String variable passed to SSH.
$commands = @"
    # Install unzip if needed
    sudo apt-get update
    sudo apt-get install -y unzip

    # --------------------------------------------------------
    # CRITICAL: Stop and Disable Host Nginx to free port 80
    # --------------------------------------------------------
    echo "Stopping Host Nginx..."
    sudo systemctl stop nginx
    sudo systemctl disable nginx
    
    # Cleanup old app
    rm -rf app
    mkdir -p app
    
    # Unzip
    unzip -o deploy_package.zip -d app
    cd app
    
    # Make setup script executable and run it
    chmod +x setup_ec2.sh
    sudo ./setup_ec2.sh
    
    # Stop existing containers
    echo "Stopping old containers..."
    sudo docker-compose down
    
    # Prune old images to save space
    sudo docker system prune -f
    
    # Build and Start
    echo "Building and Starting services..."
    sudo docker-compose up -d --build
    
    # Show status
    sudo docker-compose ps
    
    # Check logs if frontend fails
    echo "Checking Frontend Logs..."
    sleep 5
    sudo docker-compose logs --tail=20 frontend
"@

# Pass the command string to SSH
ssh -i $KEY_PATH -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} $commands

# Cleanup local zip
Remove-Item "deploy_package.zip"

Write-Host "Deployment complete! Visit http://$EC2_HOST"
Write-Host "If you still see 'nginx/1.24.0 (Ubuntu)', try clearing your browser cache or wait a moment."
