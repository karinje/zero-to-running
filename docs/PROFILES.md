# Environment Profiles

The Zero-to-Running Developer Environment supports multiple environment profiles for different use cases.

## Available Profiles

### Development (dev) - Default
- **Hot reload**: Enabled for immediate code changes
- **Logging**: Debug level for detailed information
- **Authentication**: Disabled for easy testing
- **Sample data**: Pre-loaded for quick start
- **Use case**: Daily development work

### Staging (staging)
- **Hot reload**: Enabled
- **Logging**: Info level for production-like behavior
- **Authentication**: Enabled
- **Sample data**: Minimal for testing
- **Use case**: Testing production-like scenarios locally

### Production-Local (prod)
- **Hot reload**: Disabled
- **Logging**: Error level only
- **Authentication**: Enabled
- **Sample data**: None
- **Use case**: Local production simulation

## Usage

### Start with a specific profile

```bash
# Development (default)
make dev
# or explicitly
make dev-dev

# Staging
make dev-staging

# Production
make dev-prod
```

### Switch profiles

```bash
# Switch to staging profile
make profile-switch PROFILE=staging

# Check current profile
make profile-status
```

### Profile-specific configuration

Each profile uses its own environment file:
- `.env.dev` - Development configuration
- `.env.staging` - Staging configuration
- `.env.prod` - Production configuration

When you switch profiles, the appropriate `.env` file is copied to `.env`.

## Profile Differences

| Feature | Dev | Staging | Prod |
|---------|-----|---------|------|
| Log Level | debug | info | error |
| Hot Reload | ✅ | ✅ | ❌ |
| Sample Data | ✅ | Minimal | ❌ |
| Authentication | ❌ | ✅ | ✅ |
| Debug Tools | ✅ | Limited | ❌ |

## Running Multiple Profiles

You can run multiple profiles simultaneously by using different ports:

1. Start dev profile (default ports: 3000, 4000)
2. Modify `.env.staging` to use different ports (e.g., 3001, 4001)
3. Start staging profile with modified ports

## Validation

Validate a profile configuration:

```bash
./scripts/validate-profile.sh dev
./scripts/validate-profile.sh staging
./scripts/validate-profile.sh prod
```

## Creating Custom Profiles

1. Copy an existing profile file:
   ```bash
   cp .env.dev .env.custom
   ```

2. Create a docker-compose override:
   ```bash
   cp docker-compose.dev.yml docker-compose.custom.yml
   ```

3. Modify the files for your needs

4. Use with:
   ```bash
   make dev PROFILE=custom
   ```

## Notes

- Profile files (`.env.*`) are gitignored for security
- Always validate profiles before switching
- Production profile uses stronger passwords - change them immediately
- Profile status is stored in `.env.current`

