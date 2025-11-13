# Security Hardening & Best Practices

This document outlines security measures and best practices for the Zero-to-Running Developer Environment.

## Secret Management

### Secret Scanning

Scan for accidentally committed secrets:

```bash
./scripts/scan-secrets.sh
```

Or via Makefile (when integrated):

```bash
make scan-secrets
```

### Secret Baseline

The `.secrets.baseline` file tracks known false positives. Update it when legitimate secrets are detected:

```bash
# After reviewing and confirming false positives
git add .secrets.baseline
```

### Pre-commit Secret Scanning

Secrets are automatically scanned before commits (via Husky pre-commit hook).

## Docker Security

### Non-Root Users

Services run as non-root users where possible. Check `docker-compose.yml` for `user:` directives.

### Network Isolation

- Services communicate via internal Docker network
- Only necessary ports are exposed to host
- No unnecessary network access

### Resource Limits

Memory and CPU limits are configured for each service to prevent resource exhaustion.

## Dependency Security

### Vulnerability Scanning

Check for known vulnerabilities:

```bash
# Backend
cd backend && npm audit

# Frontend
cd frontend && npm audit

# Full audit
./scripts/security-audit.sh
```

### Automated Scanning

Run security audit:

```bash
make security-audit
```

## Environment Variables

### .env File Security

- Never commit `.env` files
- Use `.env.example` for templates
- Rotate passwords regularly
- Use strong passwords in production

### Validation

Environment variables are validated on startup:

```bash
make validate-env
```

## Security Checklist

- [ ] No secrets in code
- [ ] `.env` files gitignored
- [ ] Dependencies up to date
- [ ] No high-severity vulnerabilities
- [ ] Non-root users configured
- [ ] Network isolation enabled
- [ ] Resource limits set
- [ ] SSL enabled for production-like testing

## Best Practices

1. **Never commit secrets** - Use environment variables
2. **Rotate credentials** - Change default passwords
3. **Keep dependencies updated** - Regular `npm audit`
4. **Use strong passwords** - Especially in production
5. **Limit network access** - Only expose necessary ports
6. **Monitor logs** - Watch for suspicious activity
7. **Regular audits** - Run security audits periodically

## Reporting Security Issues

If you discover a security vulnerability:

1. **Do not** create a public issue
2. Contact the maintainers privately
3. Provide detailed information
4. Allow time for fix before disclosure

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)

