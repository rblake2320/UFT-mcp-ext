# Contributing to UFT MCP Server

First off, thank you for considering contributing to UFT MCP Server! It's people like you that make this tool better for everyone.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Environment details** (OS, Node version, UFT version)
- **Code samples or test cases** if applicable
- **Screenshots or logs** if relevant

### Suggesting Enhancements

Enhancement suggestions are welcome! Include:

- **Clear description** of the proposed feature
- **Use cases** explaining why it would be useful
- **Possible implementation** approach (if you have ideas)
- **Impact** on existing functionality

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the coding standards** outlined below
3. **Add tests** for new functionality
4. **Update documentation** as needed
5. **Ensure tests pass** by running `npm test`
6. **Follow commit message conventions**

## Development Setup

### Prerequisites

- Node.js >= 18.0.0
- npm or yarn
- Git

### Setup Steps

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/UFT-mcp-ext.git
cd UFT-mcp-ext

# Install dependencies
npm install

# Build the project
npm run build

# Run tests
npm test

# Run in development mode
npm run dev
```

## Coding Standards

### TypeScript Guidelines

- Use TypeScript for all new code
- Enable strict type checking
- Avoid `any` types when possible
- Document complex types and interfaces

### Code Style

We use ESLint and Prettier for code formatting:

```bash
# Check linting
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format

# Check formatting
npm run format:check
```

### Naming Conventions

- **Variables and functions**: camelCase
- **Classes and interfaces**: PascalCase
- **Constants**: UPPER_SNAKE_CASE
- **Files**: kebab-case for scripts, PascalCase for classes

### Documentation

- Add JSDoc comments for public APIs
- Include usage examples in function documentation
- Update README.md for new features
- Add inline comments for complex logic

## Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

### Examples

```
feat(tools): Add support for parameterized test execution

Implements the ability to pass runtime parameters to UFT tests,
enabling data-driven test scenarios.

Closes #123
```

```
fix(object-repo): Resolve object identification issue

Fixed a bug where objects with special characters in names
were not being properly identified in the repository.
```

## Testing

### Writing Tests

- Write tests for all new features
- Ensure tests are isolated and repeatable
- Use descriptive test names
- Follow the AAA pattern (Arrange, Act, Assert)

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

### Test Structure

```typescript
describe("ToolName", () => {
  describe("methodName", () => {
    it("should do something specific", () => {
      // Arrange
      const input = createTestInput();

      // Act
      const result = methodName(input);

      // Assert
      expect(result).toBe(expected);
    });
  });
});
```

## Project Structure

```
UFT-mcp-ext/
├── src/
│   ├── index.ts          # Main server entry point
│   ├── tools/            # Tool implementations
│   └── utils/            # Utility functions
├── tests/                # Test files
├── docs/                 # Additional documentation
├── .github/
│   └── workflows/        # CI/CD pipelines
└── dist/                 # Compiled output
```

## Release Process

1. Update version in `package.json`
2. Update `CHANGELOG.md`
3. Create a git tag: `git tag v1.0.0`
4. Push the tag: `git push origin v1.0.0`
5. Create a GitHub release
6. CI/CD will automatically publish to npm

## Need Help?

- **Documentation**: Check the [README](README.md) and [docs/](docs/) folder
- **Issues**: Browse [existing issues](https://github.com/rblake2320/UFT-mcp-ext/issues)
- **Discussions**: Join [GitHub Discussions](https://github.com/rblake2320/UFT-mcp-ext/discussions)
- **Email**: Contact rblake2320@github.com

## Recognition

Contributors will be recognized in:
- The project README
- Release notes
- The GitHub contributors page

Thank you for contributing! 🎉
