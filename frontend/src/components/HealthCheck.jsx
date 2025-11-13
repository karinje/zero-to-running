import { useState, useEffect } from 'react';
import apiService from '../services/api.service';

function HealthCheck() {
  const [health, setHealth] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchHealth = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await apiService.checkHealth();
        setHealth(data);
      } catch (err) {
        setError(err.message || 'Failed to fetch health status');
        setHealth(null);
      } finally {
        setLoading(false);
      }
    };

    fetchHealth();
    
    // Poll every 5 seconds
    const interval = setInterval(fetchHealth, 5000);
    
    return () => clearInterval(interval);
  }, []);

  if (loading && !health) {
    return (
      <div className="card">
        <h3>Backend Health Status</h3>
        <div className="status-item">
          <span>Status</span>
          <span className="status-badge loading">Loading...</span>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="card">
        <h3>Backend Health Status</h3>
        <div className="status-item">
          <span>Status</span>
          <span className="status-badge unhealthy">Unhealthy</span>
        </div>
        <p style={{ marginTop: '1rem', color: '#ef4444' }}>{error}</p>
      </div>
    );
  }

  const isHealthy = health?.status === 'ok';
  const services = health?.services || {};

  return (
    <div className="card">
      <h3>Backend Health Status</h3>
      <div className="status-item">
        <span>Overall Status</span>
        <span className={`status-badge ${isHealthy ? 'healthy' : 'unhealthy'}`}>
          {isHealthy ? 'Healthy' : 'Unhealthy'}
        </span>
      </div>
      {services.database && (
        <div className="status-item">
          <span>Database</span>
          <span className={`status-badge ${services.database === 'healthy' ? 'healthy' : 'unhealthy'}`}>
            {services.database}
          </span>
        </div>
      )}
      {services.redis && (
        <div className="status-item">
          <span>Redis</span>
          <span className={`status-badge ${services.redis === 'healthy' ? 'healthy' : 'unhealthy'}`}>
            {services.redis}
          </span>
        </div>
      )}
      {health?.timestamp && (
        <div className="status-item">
          <span>Last Check</span>
          <span style={{ fontSize: '0.875rem' }}>
            {new Date(health.timestamp).toLocaleTimeString()}
          </span>
        </div>
      )}
    </div>
  );
}

export default HealthCheck;

