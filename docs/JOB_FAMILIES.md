# Job Family-Based Service Configuration

The Zero-to-Running Developer Environment supports job family-based configuration, allowing developers to select their role and automatically install relevant services.

## Available Job Families

### Full-Stack
**Components**: postgres, redis, backend, frontend  
**Description**: Full-stack web development with all services

### Backend Engineer
**Components**: postgres, redis, backend  
**Description**: Backend API development

### Frontend Engineer
**Components**: frontend, backend  
**Description**: Frontend development with API access

### ML Engineer
**Components**: postgres, redis, jupyter, python  
**Description**: Machine learning and data science

### Data Engineer
**Components**: postgres, redis, jupyter  
**Description**: Data engineering and ETL

### API Developer
**Components**: postgres, redis, backend  
**Description**: REST/GraphQL API development

## Usage

### Start with Job Family

```bash
# Use a job family
make dev JOB_FAMILY=ml-engineer

# Job family with exclusions
make dev JOB_FAMILY=ml-engineer NO_REDIS=true

# Multiple exclusions
make dev JOB_FAMILY=full-stack NO_REDIS=true NO_FRONTEND=true
```

### List Available Families

```bash
make list-families
```

### Show Family Components

```bash
make show-family JOB_FAMILY=ml-engineer
```

## Component Exclusions

You can exclude specific components using `NO_*` flags:

```bash
# Exclude Redis
make dev JOB_FAMILY=full-stack NO_REDIS=true

# Exclude multiple components
make dev JOB_FAMILY=full-stack NO_REDIS=true NO_FRONTEND=true
```

Available exclusion flags:
- `NO_POSTGRES=true`
- `NO_REDIS=true`
- `NO_BACKEND=true`
- `NO_FRONTEND=true`
- `NO_JUPYTER=true`
- `NO_PYTHON=true`

## Examples

### ML Engineer Setup

```bash
# Full ML engineer setup
make dev JOB_FAMILY=ml-engineer

# ML engineer without Redis
make dev JOB_FAMILY=ml-engineer NO_REDIS=true
```

### Frontend Developer Setup

```bash
# Frontend with backend API
make dev JOB_FAMILY=frontend-engineer

# Frontend only (no backend)
make dev JOB_FAMILY=frontend-engineer NO_BACKEND=true
```

### Custom Configuration

```bash
# Start with specific components
make dev JOB_FAMILY=full-stack NO_REDIS=true NO_FRONTEND=true
```

## Component Resolution

The system resolves components in this order:
1. Job family components are selected
2. Exclusions (`NO_*` flags) are applied
3. Dependencies are validated
4. Services are started

## Adding Custom Job Families

Edit `config/job-families.yml`:

```yaml
job_families:
  my-custom-family:
    components:
      - postgres
      - backend
    description: "My custom job family"
```

Then use it:
```bash
make dev JOB_FAMILY=my-custom-family
```

## Notes

- Job families are defined in `config/job-families.yml`
- Component resolution handles dependencies automatically
- Invalid combinations are prevented
- Default behavior (no JOB_FAMILY) installs all services

