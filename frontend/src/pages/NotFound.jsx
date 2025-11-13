import { Link } from 'react-router-dom';

function NotFound() {
  return (
    <div style={{ textAlign: 'center', padding: '4rem 2rem' }}>
      <h1 style={{ fontSize: '6rem', marginBottom: '1rem' }}>404</h1>
      <h2 style={{ marginBottom: '1rem' }}>Page Not Found</h2>
      <p style={{ marginBottom: '2rem', color: 'rgba(255, 255, 255, 0.7)' }}>
        The page you're looking for doesn't exist.
      </p>
      <Link to="/">
        <button>Go Home</button>
      </Link>
    </div>
  );
}

export default NotFound;

