# SareeLive - Live Commerce Platform

A full-stack live commerce platform specifically designed for Saree selling, featuring real-time video streaming, comment-based ordering, and social media integration (Facebook, YouTube, Instagram).

## 🏗 Architecture

The platform consists of three main services:
- **Frontend**: React.js application for buyers and sellers.
- **Backend**: FastAPI (Python) server handling core business logic, database, and auth.
- **Realtime Service**: Node.js/Socket.io service for handling high-concurrency comments and stream events.

---

## 🚀 Local Development Guide

### Prerequisites
- Node.js (v18+)
- Python (v3.9+)
- MongoDB (running locally on port 27017)
- Redis (running locally on port 6379)

### 1. Clone Repository
```bash
git clone https://github.com/diamond12125-ux/liveCommerceApp.git
cd liveCommerceApp
```

### 2. Backend Setup
```bash
cd backend
# Create virtual environment
python -m venv venv

# Activate venv
# Windows:
.\venv\Scripts\activate
# Mac/Linux:
# source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env  # Or create new one based on guides
# Update .env with your credentials

# Run Server
python -m uvicorn server:app --reload
```
*Backend runs on: `http://localhost:8000`*

### 3. Frontend Setup
```bash
cd frontend
# Install dependencies
npm install --legacy-peer-deps

# Create .env file
# Ensure you have REACT_APP_BACKEND_URL=http://localhost:8000

# Run Application
npm start
```
*Frontend runs on: `http://localhost:3000`*

### 4. Realtime Service Setup
```bash
cd realtime-service
npm install
node server.js
```
