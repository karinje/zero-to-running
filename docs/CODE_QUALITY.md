# Code Quality & Pre-commit Hooks

This project uses automated code quality checks via Git hooks to ensure consistent code style and prevent common issues.

## Pre-commit Hooks

### What Runs on Commit

1. **Linting** - ESLint checks for JavaScript/JSX files
2. **Formatting** - Prettier automatically formats code
3. **Staged Files Only** - Only modified files are checked (via lint-staged)

### Commit Message Validation

Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `revert`: Revert a previous commit
- `build`: Build system changes
- `ci`: CI/CD changes

**Examples:**
```bash
feat(backend): add user authentication endpoint
fix(frontend): resolve CORS error in API calls
docs: update README with new setup instructions
chore: update dependencies
```

### Pre-push Checks

Before pushing to remote:
- Merge conflict markers are detected
- Branch name validation (optional warning)

## Bypassing Hooks

In emergency situations, you can bypass hooks:

```bash
# Skip pre-commit hook
git commit --no-verify -m "emergency fix"

# Skip pre-push hook
git push --no-verify
```

⚠️ **Warning**: Only bypass hooks when absolutely necessary. Bypassed commits may be rejected during code review.

## Code Formatting

### Prettier Configuration

The project uses Prettier with the following settings:
- Single quotes
- Semicolons
- 100 character line width
- 2 space indentation
- LF line endings

### Auto-formatting

Code is automatically formatted on commit. You can also format manually:

```bash
# Format all files
npx prettier --write .

# Format specific files
npx prettier --write "src/**/*.js"
```

## Linting

### ESLint

ESLint is configured for both backend and frontend:

```bash
# Lint backend
cd backend && npm run lint

# Lint frontend
cd frontend && npm run lint

# Auto-fix issues
npm run lint -- --fix
```

## Installation

Hooks are automatically installed when you run:

```bash
npm install
```

Or manually:

```bash
npm run prepare
```

## Troubleshooting

### Hooks not running

1. Ensure Husky is installed: `npm install`
2. Check hooks are executable: `ls -la .husky/`
3. Reinstall hooks: `npm run prepare`

### Commit message rejected

Check the error message and ensure your commit follows the format:
```
type(scope): subject
```

### Prettier conflicts

If Prettier and ESLint conflict:
1. Prettier handles formatting
2. ESLint handles code quality
3. Both run automatically on commit

## Configuration Files

- `.prettierrc` - Prettier formatting rules
- `.prettierignore` - Files to skip formatting
- `.commitlintrc.js` - Commit message rules
- `package.json` - lint-staged configuration
- `.husky/` - Git hooks directory

## Best Practices

1. **Commit often** - Small commits are easier to review
2. **Follow conventions** - Use conventional commit format
3. **Let hooks format** - Don't manually format, let Prettier handle it
4. **Fix lint errors** - Address ESLint warnings before committing
5. **Write clear messages** - Good commit messages help future you

