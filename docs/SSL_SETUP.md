# SSL/HTTPS Setup for Local Development

This guide explains how to enable HTTPS for local development, which is useful for testing OAuth flows, secure cookies, and mobile device testing.

## Quick Start

1. Generate certificates:
   ```bash
   make generate-certs
   ```

2. Trust the certificate:
   ```bash
   make trust-cert
   ```

3. Enable SSL in `.env`:
   ```bash
   ENABLE_SSL=true
   ```

4. Restart services:
   ```bash
   make dev
   ```

## Why Use HTTPS Locally?

- **OAuth flows** - Many OAuth providers require HTTPS
- **Secure cookies** - Test secure cookie behavior
- **Mobile testing** - Test on mobile devices on your network
- **Production parity** - Match production environment
- **Service workers** - Required for some PWA features

## Certificate Generation

### Automatic (Recommended)

```bash
make generate-certs
```

This creates:
- `certs/localhost-cert.pem` - SSL certificate
- `certs/localhost-key.pem` - Private key

Certificates are valid for 1 year and include:
- `localhost`
- `*.localhost`
- `127.0.0.1`
- `::1` (IPv6)

### Manual Generation

```bash
openssl req -x509 -newkey rsa:4096 -nodes \
  -keyout certs/localhost-key.pem \
  -out certs/localhost-cert.pem \
  -days 365 \
  -subj "/C=US/ST=State/L=City/O=Development/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1,IP:::1"
```

## Trusting Certificates

### macOS

```bash
make trust-cert
```

Or manually:
```bash
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain \
  certs/localhost-cert.pem
```

### Linux

```bash
sudo cp certs/localhost-cert.pem /usr/local/share/ca-certificates/localhost.crt
sudo update-ca-certificates
```

### Windows

1. Double-click `certs/localhost-cert.pem`
2. Click "Install Certificate"
3. Select "Local Machine"
4. Select "Place all certificates in the following store"
5. Browse to "Trusted Root Certification Authorities"
6. Click "Next" and "Finish"

## Configuration

### Environment Variables

Add to `.env`:

```bash
# Enable SSL
ENABLE_SSL=true

# Certificate paths (optional, defaults shown)
SSL_CERT_PATH=./certs/localhost-cert.pem
SSL_KEY_PATH=./certs/localhost-key.pem
```

### Backend HTTPS

The backend automatically uses HTTPS when `ENABLE_SSL=true`:
- HTTP: `http://localhost:4000`
- HTTPS: `https://localhost:4000`

### Frontend HTTPS

The frontend (Vite) automatically uses HTTPS when `ENABLE_SSL=true`:
- HTTP: `http://localhost:3000`
- HTTPS: `https://localhost:3000`

## Usage

### With SSL Enabled

```bash
# Generate and trust certificates
make generate-certs
make trust-cert

# Enable SSL in .env
echo "ENABLE_SSL=true" >> .env

# Start services
make dev

# Access via HTTPS
# Frontend: https://localhost:3000
# Backend: https://localhost:4000
```

### Without SSL (Default)

```bash
# Just start services (HTTP)
make dev

# Access via HTTP
# Frontend: http://localhost:3000
# Backend: http://localhost:4000
```

## Browser Warnings

After generating certificates, browsers will show a security warning until you trust the certificate. This is normal for self-signed certificates.

### Chrome/Edge

1. Click "Advanced"
2. Click "Proceed to localhost (unsafe)"

### Firefox

1. Click "Advanced"
2. Click "Accept the Risk and Continue"

### Safari

1. Click "Show Details"
2. Click "visit this website"
3. Click "Visit Website"

After trusting the certificate, these warnings will disappear.

## Certificate Renewal

Certificates expire after 1 year. To renew:

```bash
make generate-certs
make trust-cert
make restart
```

## Troubleshooting

### Certificate Not Found

**Error**: `SSL certificates not found`

**Solution**:
```bash
make generate-certs
```

### Certificate Not Trusted

**Error**: Browser shows security warning

**Solution**:
```bash
make trust-cert
```

Then refresh the browser.

### Port Conflicts

If ports 3000/4000 are in use with HTTPS, ensure HTTP services are stopped:

```bash
make down
make dev
```

### Docker Volume Issues

If certificates aren't accessible in containers, check volume mounts in `docker-compose.yml`:

```yaml
volumes:
  - ./certs:/app/certs:ro
```

## Security Notes

⚠️ **Important**:
- These are **self-signed certificates** for local development only
- **Never use in production**
- Certificates are stored in `certs/` directory (gitignored)
- Private keys should never be committed to Git

## Advanced Configuration

### Custom Certificate Paths

```bash
SSL_CERT_PATH=/path/to/cert.pem
SSL_KEY_PATH=/path/to/key.pem
```

### Different Ports

Modify ports in `.env`:
```bash
BACKEND_PORT=4443  # HTTPS port
FRONTEND_PORT=3443  # HTTPS port
```

## Verification

Test HTTPS endpoints:

```bash
# Backend health check
curl -k https://localhost:4000/health

# Frontend
curl -k https://localhost:3000
```

The `-k` flag skips certificate verification (useful for testing).

