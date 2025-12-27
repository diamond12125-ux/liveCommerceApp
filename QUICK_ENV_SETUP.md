# Quick Reference: Add These to Your .env Files

## Backend (.env file in `backend/` folder)

Add these exact lines to your `backend/.env` file:

```env
# YouTube OAuth Configuration
YOUTUBE_API_KEY=""
YOUTUBE_CLIENT_ID=""
YOUTUBE_CLIENT_SECRET=""
YOUTUBE_REDIRECT_URI="http://localhost:3000/oauth/youtube/callback"
YOUTUBE_OAUTH_SCOPE="https://www.googleapis.com/auth/youtube https://www.googleapis.com/auth/youtube.force-ssl"
```

**After getting credentials from Google Cloud Console**, fill in the values:
```env
YOUTUBE_CLIENT_ID="123456789-abc.apps.googleusercontent.com"
YOUTUBE_CLIENT_SECRET="GOCSPX-abc123xyz"
```

---

## Frontend (.env file in `frontend/` folder)

Add these exact lines to your `frontend/.env` file:

```env
# YouTube OAuth Configuration
REACT_APP_YOUTUBE_CLIENT_ID=""
REACT_APP_YOUTUBE_OAUTH_SCOPE="https://www.googleapis.com/auth/youtube https://www.googleapis.com/auth/youtube.force-ssl"

# Backend URL
REACT_APP_BACKEND_URL=http://localhost:8000
```

**After getting credentials from Google Cloud Console**, fill in the Client ID:
```env
REACT_APP_YOUTUBE_CLIENT_ID="123456789-abc.apps.googleusercontent.com"
```

---

## ⚠️ Important Notes

1. **Same Client ID**: Use the SAME Client ID in both backend and frontend
2. **Restart Required**: After adding/changing .env values, restart both servers
3. **No Quotes in Values**: Don't use quotes around the actual values when you fill them in
4. **Get Credentials**: Follow `YOUTUBE_OAUTH_SETUP.md` to get your credentials from Google Cloud Console

---

## Example with Real Values

**Backend:**
```env
YOUTUBE_CLIENT_ID=123456789-abcdefg.apps.googleusercontent.com
YOUTUBE_CLIENT_SECRET=GOCSPX-1234567890abcdefg
YOUTUBE_REDIRECT_URI=http://localhost:3000/oauth/youtube/callback
```

**Frontend:**
```env
REACT_APP_YOUTUBE_CLIENT_ID=123456789-abcdefg.apps.googleusercontent.com
REACT_APP_BACKEND_URL=http://localhost:8000
```

---

## What's Already Done ✅

The code has been updated to:
- ✅ Support `YOUTUBE_CLIENT_ID` and `YOUTUBE_CLIENT_SECRET` in backend
- ✅ Support `REACT_APP_YOUTUBE_CLIENT_ID` in frontend  
- ✅ Support `REACT_APP_YOUTUBE_OAUTH_SCOPE` for custom scopes
- ✅ Add error messages if credentials are missing
- ✅ Work with both old (`GOOGLE_CLIENT_ID`) and new naming

You just need to:
1. Get credentials from Google Cloud Console (see `YOUTUBE_OAUTH_SETUP.md`)
2. Add them to your `.env` files
3. Restart both servers
