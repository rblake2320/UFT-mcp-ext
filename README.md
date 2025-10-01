# UFT MCP Server

[![Node.js CI](https://github.com/rblake2320/UFT-mcp-ext/actions/workflows/ci.yml/badge.svg)](https://github.com/rblake2320/UFT-mcp-ext/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![npm version](https://badge.fury.io/js/uft-mcp-server.svg)](https://www.npmjs.com/package/uft-mcp-server)

A professional Model Context Protocol (MCP) server for UFT (Unified Functional Testing) automation, providing comprehensive test management, execution, and analysis capabilities.

## Overview

The UFT MCP Server enables AI assistants like Claude to interact with UFT automation tools through the Model Context Protocol. It provides a comprehensive suite of tools for creating, executing, analyzing, and managing UFT test automation.

### Key Features

- **Test Creation**: Generate UFT test scripts with actions and verifications
- **Test Execution**: Run tests and test suites with configurable parameters
- **Results Analysis**: Analyze test results and generate reports in multiple formats
- **Object Repository Management**: Manage UFT object repositories programmatically
- **Test Data Generation**: Create test data in various formats (Excel, CSV, XML)
- **Application Object Capture**: Automatically capture and identify UI objects
- **Test Suite Management**: Organize and configure test suites
- **Scheduling**: Schedule automated test execution
- **Documentation Generation**: Auto-generate test documentation
- **Debug Assistance**: Analyze failures and suggest fixes

## Installation

### Prerequisites

- Node.js >= 18.0.0
- npm or yarn
- UFT (for actual test execution)

### Install from npm

```bash
npm install -g uft-mcp-server
```

### Install from source

```bash
git clone https://github.com/rblake2320/UFT-mcp-ext.git
cd UFT-mcp-ext
npm install
npm run build
npm link
```

## Configuration

### Claude Desktop Configuration

Add the server to your Claude Desktop configuration file:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`

**Windows**: `%APPDATA%/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "uft": {
      "command": "uft-mcp-server"
    }
  }
}
```

### Custom Configuration

You can pass environment variables or configuration options:

```json
{
  "mcpServers": {
    "uft": {
      "command": "uft-mcp-server",
      "env": {
        "UFT_INSTALLATION_PATH": "C:\\Program Files\\UFT",
        "DEFAULT_TIMEOUT": "30000"
      }
    }
  }
}
```

## Available Tools

### 1. create_uft_test

Create a new UFT test script with specified actions.

**Parameters:**
- `testName` (required): Name of the test
- `testDescription`: Description of the test
- `applicationUnderTest`: Application type (web, desktop, mobile)
- `actions` (required): Array of test actions

**Example:**
```json
{
  "testName": "LoginTest",
  "testDescription": "Verify user login functionality",
  "applicationUnderTest": "web",
  "actions": [
    {
      "type": "click",
      "object": "Browser(\"MyApp\").Page(\"Login\").WebButton(\"Submit\")",
      "description": "Click login button"
    }
  ]
}
```

### 2. execute_uft_test

Execute a UFT test or test suite.

**Parameters:**
- `testPath` (required): Path to the test
- `parameters`: Runtime parameters
- `resultPath`: Output path for results

### 3. analyze_test_results

Analyze test execution results and generate reports.

**Parameters:**
- `resultPath` (required): Path to test results
- `reportFormat`: Output format (html, xml, json, summary)

### 4. manage_object_repository

Manage UFT object repositories.

**Parameters:**
- `action` (required): add, update, query, delete, list
- `repositoryPath`: Path to repository file
- `objectName`: Name of the object
- `objectProperties`: Object identification properties

### 5. generate_test_data

Generate test data for data-driven testing.

**Parameters:**
- `dataType` (required): excel, csv, xml, database
- `schema` (required): Data schema definition
- `recordCount` (required): Number of records
- `outputPath`: Output file path

### 6. capture_application_objects

Capture objects from running applications.

**Parameters:**
- `applicationPath` (required): Path to application
- `captureMode`: manual, automatic, smart
- `outputRepository`: Output repository path

### 7. create_test_suite

Create and organize test suites.

**Parameters:**
- `suiteName` (required): Suite name
- `tests` (required): Array of test paths
- `executionOrder`: sequential, parallel, priority
- `configuration`: Suite configuration

### 8. schedule_test_execution

Schedule automated test execution.

**Parameters:**
- `testOrSuite` (required): Path to test/suite
- `schedule` (required): Schedule configuration
- `notifications`: Notification settings

### 9. generate_test_documentation

Generate test documentation.

**Parameters:**
- `testPath` (required): Path to test
- `documentationType` (required): detailed, summary, technical, user-guide
- `outputFormat`: html, pdf, word, markdown
- `includeScreenshots`: Include screenshots

### 10. debug_test_failure

Analyze test failures and suggest fixes.

**Parameters:**
- `failedTestPath` (required): Path to failed test
- `errorLogs`: Error log content
- `screenshots`: Array of screenshot paths

## Usage Examples

### Creating a Test

```typescript
// Ask Claude:
"Create a UFT test named 'CheckoutTest' that:
1. Opens the shopping cart
2. Verifies item count
3. Clicks checkout button
4. Fills shipping information
5. Completes purchase"
```

### Executing Tests

```typescript
// Ask Claude:
"Execute the LoginTest and generate an HTML report"
```

### Analyzing Results

```typescript
// Ask Claude:
"Analyze the test results in C:\\Results\\LastRun and create a summary"
```

## Development

### Project Structure

```
UFT-mcp-ext/
├── src/
│   ├── index.ts          # Main server implementation
│   └── tools/            # Tool implementations (future)
├── dist/                 # Compiled JavaScript
├── tests/                # Test files
├── .github/
│   └── workflows/        # CI/CD workflows
├── package.json
├── tsconfig.json
└── README.md
```

### Building

```bash
npm run build
```

### Development Mode

```bash
npm run dev
```

### Testing

```bash
npm test
npm run test:coverage
```

### Linting and Formatting

```bash
npm run lint
npm run format
```

## CI/CD

The project includes GitHub Actions workflows for:

- **Continuous Integration**: Run tests on every push/PR
- **Publishing**: Automated npm package publishing
- **Security**: Dependency scanning and security checks

## Security

This project follows security best practices:

- No hardcoded credentials
- Input validation on all tool calls
- Secure handling of file paths
- Regular dependency updates
- Security vulnerability scanning

See [SECURITY.md](SECURITY.md) for reporting vulnerabilities.

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting

### Common Issues

**Server not connecting:**
- Verify Claude Desktop configuration path
- Check that uft-mcp-server is in PATH
- Review Claude Desktop logs

**Tool execution errors:**
- Ensure UFT is properly installed
- Verify test paths are correct
- Check file permissions

**Build failures:**
- Clear node_modules and reinstall: `rm -rf node_modules && npm install`
- Ensure Node.js version >= 18.0.0

## Roadmap

- [ ] Real UFT integration (currently mock implementation)
- [ ] Enhanced error handling and logging
- [ ] Support for additional test frameworks
- [ ] Web dashboard for test management
- [ ] Advanced reporting features
- [ ] Integration with CI/CD platforms

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with the [Model Context Protocol SDK](https://github.com/anthropics/model-context-protocol)
- Inspired by the UFT automation community
- Thanks to all contributors

## Support

- **Issues**: [GitHub Issues](https://github.com/rblake2320/UFT-mcp-ext/issues)
- **Discussions**: [GitHub Discussions](https://github.com/rblake2320/UFT-mcp-ext/discussions)
- **Email**: rblake2320@github.com

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

---

Made with ❤️ by [rblake2320](https://github.com/rblake2320)
