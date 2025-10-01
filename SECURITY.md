# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to:

- **Email**: rblake2320@github.com
- **Subject**: [SECURITY] UFT MCP Server - Brief Description

Please include the following information:

1. **Description**: A clear description of the vulnerability
2. **Impact**: The potential impact of the vulnerability
3. **Steps to Reproduce**: Detailed steps to reproduce the issue
4. **Affected Versions**: Which versions are affected
5. **Suggested Fix**: If you have a suggested fix, please include it

## Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 5 business days
- **Status Updates**: Weekly until resolution
- **Fix Release**: Varies by severity (Critical: 7 days, High: 14 days, Medium: 30 days)

## Security Best Practices

When using this MCP server:

1. **Never hardcode credentials** in test scripts or configuration
2. **Use environment variables** for sensitive information
3. **Validate all inputs** from external sources
4. **Keep dependencies updated** using `npm audit`
5. **Follow the principle of least privilege** for test execution
6. **Review code** before running untrusted test scripts
7. **Isolate test environments** from production systems

## Known Security Considerations

- This server executes test automation code. Ensure test scripts come from trusted sources.
- File system operations are performed during test execution. Ensure proper permissions.
- Test data generation may contain sensitive information. Handle appropriately.

## Security Updates

Security updates will be released as patch versions and announced via:

- GitHub Security Advisories
- Release notes
- Email to registered users (if applicable)

## Contact

For general security questions or concerns:
- Open a GitHub Discussion
- Email: rblake2320@github.com

## Acknowledgments

We appreciate the security research community's efforts to responsibly disclose vulnerabilities.

Contributors who report valid security issues will be acknowledged in our release notes (unless they prefer to remain anonymous).
