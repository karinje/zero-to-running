import { useState, useEffect } from 'react';
import HealthCheck from '../components/HealthCheck';
import apiService from '../services/api.service';

function Home() {
  const [apiInfo, setApiInfo] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchApiInfo = async () => {
      try {
        const data = await apiService.getApiInfo();
        setApiInfo(data);
      } catch (err) {
        console.error('Failed to fetch API info:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchApiInfo();
  }, []);

  return (
    <div>
      <div className="hero">
        <h1>Welcome to Wander</h1>
        <p>Zero-to-Running Developer Environment</p>
      </div>

      <div className="status-grid">
        <HealthCheck />
        
        <div className="card">
          <h3>API Information</h3>
          {loading ? (
            <p>Loading...</p>
          ) : apiInfo ? (
            <>
              <div className="status-item">
                <span>Version</span>
                <span>{apiInfo.version || 'N/A'}</span>
              </div>
              <div className="status-item">
                <span>Environment</span>
                <span>{apiInfo.environment || 'N/A'}</span>
              </div>
              {apiInfo.timestamp && (
                <div className="status-item">
                  <span>Timestamp</span>
                  <span style={{ fontSize: '0.875rem' }}>
                    {new Date(apiInfo.timestamp).toLocaleString()}
                  </span>
                </div>
              )}
            </>
          ) : (
            <p style={{ color: '#ef4444' }}>Failed to load API information</p>
          )}
        </div>

        <div className="card">
          <h3>Quick Links</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
            <a href="http://localhost:4000/health" target="_blank" rel="noopener noreferrer">
              Backend Health Endpoint
            </a>
            <a href="http://localhost:4000/api/v1" target="_blank" rel="noopener noreferrer">
              Backend API Endpoint
            </a>
            <a href="/docs" target="_blank" rel="noopener noreferrer">
              Documentation
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Home;

