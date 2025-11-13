# SSL Certificates

This directory contains SSL certificates for local HTTPS development.

## Generating Certificates

Run the certificate generation script:

```bash
make generate-certs
```

Or directly:

```bash
./scripts/generate-certs.sh
```

This will create:
- `localhost-cert.pem` - SSL certificate
- `localhost-key.pem` - Private key

## Trusting Certificates

### macOS

```bash
make trust-cert
```

Or manually:

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain certs/localhost-cert.pem
```

### Linux

```bash
sudo cp certs/localhost-cert.pem /usr/local/share/ca-certificates/localhost.crt
sudo update-ca-certificates
```

### Windows

1. Double-click `localhost-cert.pem`
2. Click "Install Certificate"
3. Select "Local Machine"
4. Select "Place all certificates in the following store"
5. Browse to "Trusted Root Certification Authorities"
6. Click "Next" and "Finish"

## Certificate Renewal

Certificates are valid for 1 year. To renew:

```bash
make generate-certs
make trust-cert
```

## Security Note

These are self-signed certificates for local development only. Do not use in production.

