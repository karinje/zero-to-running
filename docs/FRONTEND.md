# Frontend Development Guide

## Overview

The frontend is a React 18 application built with Vite, providing a fast development experience with hot module replacement (HMR).

## Technology Stack

- **React 18.2.0**: Modern React with hooks
- **Vite 5.0**: Fast build tool and dev server
- **React Router 6.20**: Client-side routing
- **Axios 1.6.2**: HTTP client for API calls

## Project Structure

```
frontend/
├── public/              # Static assets
│   └── vite.svg
├── src/
│   ├── components/      # Reusable React components
│   │   ├── Header.jsx
│   │   └── HealthCheck.jsx
│   ├── config/          # Configuration files
│   │   └── api.js       # API endpoint configuration
│   ├── pages/           # Page components
│   │   ├── Home.jsx
│   │   └── NotFound.jsx
│   ├── services/        # API service layer
│   │   └── api.service.js
│   ├── utils/           # Utility functions
│   │   └── helpers.js
│   ├── App.jsx          # Main app component
│   ├── App.css          # App styles
│   ├── index.css        # Global styles
│   └── main.jsx         # Entry point
├── .dockerignore
├── .eslintrc.cjs        # ESLint configuration
├── Dockerfile
├── index.html           # HTML template
├── package.json
└── vite.config.js       # Vite configuration
```

## Development

### Running Locally (without Docker)

```bash
cd frontend
npm install
npm run dev
```

The app will be available at http://localhost:3000

### Running in Docker

The frontend runs automatically when you start all services:

```bash
make dev
```

Or start just the frontend:

```bash
docker-compose up frontend
```

## Hot Reload

Hot reload is configured to work in Docker. When you edit files in `frontend/src/`, changes will be reflected immediately in the browser without a full page reload.

### How It Works

1. **Volume Mounts**: Source code is mounted as a volume in Docker
2. **Vite Watch**: Vite watches for file changes
3. **HMR**: Vite sends updates to the browser via WebSocket
4. **Polling**: File system polling is enabled for Docker compatibility

## Environment Variables

Frontend environment variables are prefixed with `VITE_` and are available at build time:

```bash
VITE_API_URL=http://localhost:4000      # Backend API URL
VITE_APP_NAME=Wander Dev Environment     # App name
```

Access in code:

```javascript
const apiUrl = import.meta.env.VITE_API_URL;
const appName = import.meta.env.VITE_APP_NAME;
```

## API Integration

### API Service

The frontend uses a centralized API service (`src/services/api.service.js`) to communicate with the backend:

```javascript
import apiService from './services/api.service';

// Check backend health
const health = await apiService.checkHealth();

// Get API info
const info = await apiService.getApiInfo();
```

### API Configuration

API endpoints are configured in `src/config/api.js`:

```javascript
import { API_CONFIG, API_ENDPOINTS } from './config/api';

// Use endpoints
const healthUrl = `${API_CONFIG.baseURL}${API_ENDPOINTS.health}`;
```

## Components

### Header

Navigation header component with app name and links.

### HealthCheck

Real-time backend health status component that:
- Polls the backend health endpoint every 5 seconds
- Displays database and Redis status
- Shows loading and error states

## Pages

### Home

Main landing page showing:
- Welcome message
- Backend health status
- API information
- Quick links

### NotFound

404 page for unmatched routes.

## Routing

React Router is configured in `App.jsx`:

```javascript
<Routes>
  <Route path="/" element={<Home />} />
  <Route path="*" element={<NotFound />} />
</Routes>
```

## Styling

- **Global Styles**: `src/index.css` - Base styles and CSS variables
- **App Styles**: `src/App.css` - App-specific styles
- **Component Styles**: Inline styles or CSS modules (can be added)

The app supports both light and dark color schemes via CSS media queries.

## Building for Production

```bash
cd frontend
npm run build
```

The production build will be in `frontend/dist/`.

## Linting

```bash
cd frontend
npm run lint
```

ESLint is configured with React and React Hooks plugins.

## Troubleshooting

### Hot Reload Not Working

1. Check that volumes are mounted correctly in `docker-compose.yml`
2. Verify `vite.config.js` has `watch.usePolling: true`
3. Ensure port 3000 is not blocked
4. Check browser console for WebSocket connection errors

### API Calls Failing

1. Verify `VITE_API_URL` is set correctly in `.env`
2. Check that backend is running and accessible
3. Check browser console for CORS errors
4. Verify backend CORS configuration allows frontend origin

### Build Errors

1. Clear `node_modules` and reinstall: `rm -rf node_modules && npm install`
2. Check Node.js version (should be 18+)
3. Verify all dependencies are installed
4. Check for TypeScript errors if using TypeScript

## Next Steps

- Add more pages and routes
- Implement authentication
- Add state management (Redux, Zustand, etc.)
- Add UI component library (Material-UI, Ant Design, etc.)
- Set up testing (Vitest, React Testing Library)
- Add TypeScript for type safety

