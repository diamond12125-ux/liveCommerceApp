# YouTube OAuth Setup Guide

This guide will help you set up Google OAuth 2.0 credentials for YouTube integration in your Live Commerce App.

## Prerequisites

- Google account
- Access to [Google Cloud Console](https://console.cloud.google.com/)
- 10-15 minutes

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click on the project dropdown at the top
3. Click **"New Project"**
4. Enter project details:
   - **Project name**: `LiveCommerceApp` (or your preferred name)
   - **Organization**: Leave as default (No organization)
5. Click **"Create"**
6. Wait for the project to be created (takes ~30 seconds)

## Step 2: Enable YouTube Data API v3

1. In the Google Cloud Console, ensure your new project is selected
2. Go to **"APIs & Services"** → **"Library"** (from the left sidebar)
3. Search for **"YouTube Data API v3"**
4. Click on **"YouTube Data API v3"**
5. Click **"Enable"**
6. Wait for the API to be enabled

## Step 3: Configure OAuth Consent Screen

1. Go to **"APIs & Services"** → **"OAuth consent screen"**
2. Select **"External"** user type
3. Click **"Create"**
4. Fill in the required fields:
   - **App name**: `LiveCommerceApp`
   - **User support email**: Your email address
   - **Developer contact information**: Your email address
5. Click **"Save and Continue"**
6. On the **Scopes** page, click **"Add or Remove Scopes"**
7. Search and add these scopes:
   - `https://www.googleapis.com/auth/youtube`
   - `https://www.googleapis.com/auth/youtube.force-ssl`
8. Click **"Update"** then **"Save and Continue"**
9. On **Test users** page, click **"Add Users"**
10. Add your email address (and any other testers)
11. Click **"Save and Continue"**
12. Review and click **"Back to Dashboard"**

## Step 4: Create OAuth 2.0 Credentials

1. Go to **"APIs & Services"** → **"Credentials"**
2. Click **"+ Create Credentials"** at the top
3. Select **"OAuth client ID"**
4. Choose **"Web application"** as the application type
5. Configure the OAuth client:
   - **Name**: `LiveCommerceApp Web Client`
   - **Authorized JavaScript origins**: 
     - `http://localhost:3000`
     - `http://localhost:8000`
   - **Authorized redirect URIs**:
     - `http://localhost:3000/oauth/youtube/callback`
     - `http://localhost:8000/api/social/oauth/youtube/callback`
6. Click **"Create"**
7. A popup will appear with your credentials:
   - **Client ID**: Copy this (looks like: `123456789-abc.apps.googleusercontent.com`)
   - **Client Secret**: Copy this (looks like: `GOCSPX-abc123xyz`)
8. Click **"OK"**

> **Important**: Keep these credentials secure! Never commit them to version control.

## Step 5: Update Backend Environment Variables

1. Open `backend/.env` file
2. Add/update these lines:

```env
# Google OAuth for YouTube
GOOGLE_CLIENT_ID=YOUR_CLIENT_ID_HERE.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=YOUR_CLIENT_SECRET_HERE
YOUTUBE_REDIRECT_URI=http://localhost:3000/oauth/youtube/callback
```

3. Replace `YOUR_CLIENT_ID_HERE` and `YOUR_CLIENT_SECRET_HERE` with the values from Step 4
4. Save the file

## Step 6: Update Frontend Environment Variables

1. Open `frontend/.env` file
2. Add/update this line:

```env
REACT_APP_GOOGLE_CLIENT_ID=YOUR_CLIENT_ID_HERE.apps.googleusercontent.com
REACT_APP_BACKEND_URL=http://localhost:8000
```

3. Replace `YOUR_CLIENT_ID_HERE` with the Client ID from Step 4
4. Save the file

## Step 7: Restart Servers

After updating environment variables, you must restart both servers:

### Backend
```bash
# Stop the current backend server (Ctrl+C)
# Then restart:
cd backend
python -m uvicorn server:app --reload --host 0.0.0.0 --port 8000
```

### Frontend
```bash
# Stop the current frontend server (Ctrl+C)
# Then restart:
cd frontend
npm start
```

## Step 8: Test the Integration

1. Open your browser and go to `http://localhost:3000`
2. Navigate to **Connect Accounts** page
3. Click **"Connect YouTube Channel"** button
4. You should be redirected to Google's OAuth consent screen
5. Select your Google account
6. Review the permissions requested
7. Click **"Allow"**
8. You should be redirected back to your app with a success message

## Troubleshooting

### Error: "The OAuth client was not found"

**Cause**: The Client ID in your environment variables doesn't match the one in Google Cloud Console.

**Solution**: 
- Double-check that you copied the correct Client ID
- Ensure there are no extra spaces or characters
- Restart both servers after updating `.env` files

### Error: "redirect_uri_mismatch"

**Cause**: The redirect URI in your code doesn't match what's configured in Google Cloud Console.

**Solution**:
- Go to Google Cloud Console → Credentials
- Edit your OAuth client
- Ensure `http://localhost:3000/oauth/youtube/callback` is in the Authorized redirect URIs
- Save changes and try again

### Error: "Access blocked: This app's request is invalid"

**Cause**: OAuth consent screen is not properly configured.

**Solution**:
- Go to Google Cloud Console → OAuth consent screen
- Ensure you've added the required scopes
- Add your email as a test user
- Save changes

### Error: "This app isn't verified"

**Cause**: Your app is in testing mode (normal for development).

**Solution**:
- This is expected during development
- Click **"Advanced"** → **"Go to LiveCommerceApp (unsafe)"**
- This warning won't appear for users you've added as test users

## Production Deployment

When deploying to production:

1. Update Authorized JavaScript origins and redirect URIs in Google Cloud Console with your production domain
2. Update environment variables with production URLs
3. Consider publishing your OAuth consent screen (requires verification for public apps)
4. Use environment-specific configuration files

## Additional Resources

- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [YouTube Data API Documentation](https://developers.google.com/youtube/v3)
- [OAuth 2.0 Scopes for Google APIs](https://developers.google.com/identity/protocols/oauth2/scopes)

## Security Best Practices

1. **Never commit `.env` files** to version control (they're already in `.gitignore`)
2. **Use different credentials** for development and production
3. **Rotate credentials** if they're ever exposed
4. **Limit OAuth scopes** to only what your app needs
5. **Add only trusted test users** during development
