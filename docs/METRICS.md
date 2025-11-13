# Onboarding Metrics & Feedback System

The Zero-to-Running Developer Environment includes optional metrics collection and feedback system to measure onboarding success and identify pain points.

## Metrics Collection

### Automatic Collection

Metrics are automatically collected during setup (opt-in):

```bash
./scripts/collect-metrics.sh
```

### Collected Metrics

Anonymous metrics include:
- **OS**: Operating system (macOS, Linux, Windows)
- **Architecture**: CPU architecture (x86_64, arm64, etc.)
- **Docker Version**: Docker version in use
- **Setup Success**: Whether setup completed successfully
- **Timestamp**: When metrics were collected

### Privacy

- All metrics are **anonymous**
- No personally identifiable information (PII) is collected
- Metrics are stored locally in `.metrics/` directory
- Metrics are **not** automatically sent anywhere
- You can delete metrics at any time

## Feedback System

### Submit Feedback

Provide feedback about your experience:

```bash
make feedback
```

Or directly:

```bash
./scripts/submit-feedback.sh
```

### Feedback Questions

1. How would you rate the setup process? (1-5)
2. Did you encounter any errors? (yes/no)
3. How long did setup take? (minutes)
4. Was the documentation helpful? (1-5)
5. Would you recommend this to a teammate? (yes/no)
6. Any additional comments (optional)

### Viewing Metrics

View your local metrics:

```bash
make metrics-view
```

Or directly:

```bash
cat .metrics/metrics.json
cat .metrics/feedback.json
```

## Makefile Commands

```bash
# Submit feedback
make feedback

# View metrics
make metrics-view

# Clear metrics
make metrics-clear
```

## Metrics Location

All metrics are stored in `.metrics/` directory:
- `metrics.json` - Setup metrics
- `feedback.json` - User feedback

This directory is gitignored for privacy.

## Disabling Metrics

Metrics collection is opt-in. To disable:

1. Don't run `collect-metrics.sh`
2. Delete `.metrics/` directory if it exists

## Contributing Metrics

If you'd like to share metrics (anonymously):

1. Review metrics in `.metrics/`
2. Remove any personal information
3. Share via issue or pull request (optional)

## Privacy Policy

- **No tracking**: No external tracking services
- **Local only**: All data stays on your machine
- **Optional**: You choose to collect and share
- **Anonymous**: No PII collected
- **Deletable**: Remove anytime

## Future Enhancements

Potential future features:
- Aggregate metrics dashboard
- Trend analysis
- Pain point identification
- Setup time optimization

