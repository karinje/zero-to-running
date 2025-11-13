import { Link } from 'react-router-dom';

function Header() {
  const appName = import.meta.env.VITE_APP_NAME || 'Wander Dev Environment';

  return (
    <header style={{
      padding: '1rem 2rem',
      borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
      backgroundColor: 'rgba(0, 0, 0, 0.2)',
    }}>
      <nav style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        maxWidth: '1200px',
        margin: '0 auto',
      }}>
        <Link to="/" style={{
          fontSize: '1.5rem',
          fontWeight: 'bold',
          color: '#646cff',
          textDecoration: 'none',
        }}>
          {appName}
        </Link>
        <div>
          <Link to="/" style={{
            marginLeft: '1rem',
            color: 'inherit',
            textDecoration: 'none',
          }}>
            Home
          </Link>
        </div>
      </nav>
    </header>
  );
}

export default Header;

