# Environment Variables Configuration Guide

This document lists all required environment variables for the LiveCommerceApp.

## Backend Environment Variables (`backend/.env`)

Create a file named `.env` in the `backend` directory with the following variables:

### MongoDB Configuration
```env
MONGO_URL=mongodb://localhost:27017
DB_NAME=saree_live
```

### JWT Configuration
```env
SECRET_KEY=your-secret-key-change-this-in-production-use-strong-random-string
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### YouTube OAuth Configuration
```env
YOUTUBE_API_KEY=""
YOUTUBE_CLIENT_ID=""
YOUTUBE_CLIENT_SECRET=""
YOUTUBE_REDIRECT_URI="http://localhost:3000/oauth/youtube/callback"
YOUTUBE_OAUTH_SCOPE="https://www.googleapis.com/auth/youtube https://www.googleapis.com/auth/youtube.force-ssl"
```

**Note**: The backend code also supports `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` for backward compatibility.

### Facebook OAuth Configuration
```env
FACEBOOK_APP_ID=""
FACEBOOK_APP_SECRET=""
FACEBOOK_REDIRECT_URI="http://localhost:3000/oauth/facebook/callback"
```

### Instagram OAuth Configuration
```env
INSTAGRAM_CLIENT_ID=""
INSTAGRAM_CLIENT_SECRET=""
INSTAGRAM_REDIRECT_URI="http://localhost:3000/oauth/instagram/callback"
```

### WhatsApp Business (Gupshup)
```env
GUPSHUP_API_KEY=""
GUPSHUP_APP_NAME=""
```

### Payment Gateways

#### Razorpay
```env
RAZORPAY_KEY_ID=""
RAZORPAY_KEY_SECRET=""
```

#### Cashfree
```env
CASHFREE_APP_ID=""
CASHFREE_SECRET_KEY=""
```

### Redis Configuration
```env
REDIS_URL=redis://localhost:6379
```

### Server Configuration
```env
HOST=0.0.0.0
PORT=8000
```

---

## Frontend Environment Variables (`frontend/.env`)

Create a file named `.env` in the `frontend` directory with the following variables:

### Backend API URL
```env
REACT_APP_BACKEND_URL=http://localhost:8000
```

### YouTube OAuth Configuration
```env
REACT_APP_YOUTUBE_CLIENT_ID=""
REACT_APP_YOUTUBE_OAUTH_SCOPE="https://www.googleapis.com/auth/youtube https://www.googleapis.com/auth/youtube.force-ssl"
```

**Note**: The frontend code also supports `REACT_APP_GOOGLE_CLIENT_ID` for backward compatibility.

### Facebook OAuth Configuration
```env
REACT_APP_FACEBOOK_APP_ID=""
```

### Instagram OAuth Configuration
```env
REACT_APP_INSTAGRAM_CLIENT_ID=""
```

---

## How to Add Your YouTube OAuth Credentials

### Step 1: Get Credentials from Google Cloud Console

Follow the instructions in [`YOUTUBE_OAUTH_SETUP.md`](./YOUTUBE_OAUTH_SETUP.md) to:
1. Create a Google Cloud project
2. Enable YouTube Data API v3
3. Create OAuth 2.0 credentials
4. Get your Client ID and Client Secret

### Step 2: Update Backend `.env`

In `backend/.env`, add your credentials:
```env
YOUTUBE_CLIENT_ID="123456789-abc.apps.googleusercontent.com"
YOUTUBE_CLIENT_SECRET="GOCSPX-abc123xyz"
YOUTUBE_REDIRECT_URI="http://localhost:3000/oauth/youtube/callback"
```

### Step 3: Update Frontend `.env`

In `frontend/.env`, add your Client ID:
```env
REACT_APP_YOUTUBE_CLIENT_ID="123456789-abc.apps.googleusercontent.com"
```

### Step 4: Restart Servers

After updating environment variables, restart both servers:

**Backend:**
```bash
# Stop with Ctrl+C, then:
cd backend
python -m uvicorn server:app --reload --host 0.0.0.0 --port 8000
```

**Frontend:**
```bash
# Stop with Ctrl+C, then:
cd frontend
npm start
```

---

## Security Best Practices

1. **Never commit `.env` files** to version control (already in `.gitignore`)
2. **Use different credentials** for development and production
3. **Rotate credentials** if they're ever exposed
4. **Use strong, random SECRET_KEY** for JWT tokens
5. **Keep API keys secure** and never share them publicly

---

## Troubleshooting

### Environment Variables Not Loading

**Problem**: Changes to `.env` files don't take effect

**Solution**: 
- Restart both backend and frontend servers
- Ensure `.env` files are in the correct directories (`backend/.env` and `frontend/.env`)
- Check for typos in variable names

### OAuth Errors

**Problem**: Getting "invalid_client" or "redirect_uri_mismatch" errors

**Solution**:
- Verify credentials are correctly copied from Google Cloud Console
- Ensure redirect URIs in Google Cloud Console match exactly: `http://localhost:3000/oauth/youtube/callback`
- Check that environment variables are loaded (add console.log or print statements)

### MongoDB Connection Issues

**Problem**: Backend fails to start with MongoDB errors

**Solution**:
- Ensure MongoDB is running locally or use MongoDB Atlas cloud connection string
- Update `MONGO_URL` with correct connection string
- Check MongoDB service status
