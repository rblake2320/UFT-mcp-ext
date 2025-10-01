# UFT-mcp-ext

UFT/LeanFT (UFT Developer) extension scaffold for MCP (Model Context Protocol) integrations.

## Features

- ✅ Build script packages a `.dxt` UFT extension bundle
- ✅ GitHub Actions CI: lint, test, package, and upload artifact
- ✅ Idempotent PowerShell tooling
- ✅ Automatic release creation with `.dxt` artifacts
- ✅ Compatible with UFT One 15.0+ and UFT Developer

## Quick Start

```powershell
# Build the extension
pwsh tools/build.ps1 -Clean

# Run tests
pwsh tools/test.ps1

# The .dxt bundle will be created in artifacts/
```

## Installation

1. Build the extension using the commands above
2. Locate the `.dxt` file in the `artifacts/` folder
3. In UFT One:
   - Open UFT One
   - Go to Tools → Options → GUI Testing → Add-ins
   - Click "Install Extension" and browse to the `.dxt` file
   - Restart UFT One to activate the extension

## Project Structure

```
UFT-mcp-ext/
├── src/
│   └── extension/
│       ├── manifest.json    # UFT extension metadata
│       ├── extension.js     # Entry JS for custom add-ins or keywords
│       └── extension.css    # Optional UI styling
├── META/
│   └── package.json         # Tooling only (eslint/jest if needed)
├── tools/
│   ├── build.ps1           # Packages .dxt
│   └── test.ps1            # Placeholder for unit/integration tests
├── .github/
│   └── workflows/
│       └── ci.yml          # CI pipeline
├── docs/
│   └── design.md           # Notes/specs
├── README.md               # This file
├── LICENSE                 # MIT License
└── .gitignore             # Git exclusions
```

## Development

### Prerequisites

- Windows OS (for UFT compatibility)
- PowerShell 7+ (comes with Windows or install from [Microsoft Store](https://apps.microsoft.com/store/detail/powershell/9MZ1SNWT0N5D))
- Git
- UFT One 15.0+ or UFT Developer (for testing)

### Building from Source

```powershell
# Clone the repository
git clone https://github.com/rblake2320/UFT-mcp-ext.git
cd UFT-mcp-ext

# Build the extension
pwsh tools/build.ps1 -Clean

# The .dxt file will be in artifacts/
```

### Custom Keywords

The extension registers custom keywords that can be used in UFT tests. Currently implemented:

- **MCP_Ping**: A simple test keyword that reports execution status

Example usage in a UFT test:
```vbscript
' In your UFT test script
MCP_Ping "test_parameter"
```

### Adding New Keywords

To add new keywords, edit `src/extension/extension.js`:

```javascript
const MyNewKeyword = {
  name: "MyKeyword_Name",
  run: function(args) {
    // Your implementation here
    UFT.Reporter.ReportEvent("Done", "MyKeyword executed", JSON.stringify(args));
    return true;
  }
};

UFT.CustomKeywords.Register(MyNewKeyword.name, MyNewKeyword.run);
```

## CI/CD

The project uses GitHub Actions for continuous integration:

- **On Push/PR**: Build, test, and upload artifacts
- **On Tag**: Create a GitHub Release with the `.dxt` file attached

### Creating a Release

```powershell
# Tag the version
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions will automatically:
# 1. Build the extension
# 2. Run tests
# 3. Create a GitHub Release
# 4. Attach the .dxt file to the release
```

## Versioning

The project follows semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes to the extension API
- **MINOR**: New features or keywords added
- **PATCH**: Bug fixes and minor improvements

The version is defined in `src/extension/manifest.json` and should be updated before creating a new release tag.

## Troubleshooting

### Build Issues

If the build fails:

1. Ensure PowerShell 7+ is installed: `pwsh --version`
2. Check that all files in manifest.json exist in src/extension
3. Run with verbose output: `pwsh tools/build.ps1 -Verbose`

### Extension Not Loading in UFT

1. Verify UFT version compatibility (15.0+ required)
2. Check Windows Event Viewer for UFT-related errors
3. Ensure the .dxt file isn't corrupted (it's a ZIP file, try opening it)
4. Restart UFT One after installation

### CI Pipeline Failures

1. Check the Actions tab on GitHub for detailed logs
2. Ensure the repository has Actions enabled in Settings
3. Verify the Windows runner is available

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Test locally: `pwsh tools/build.ps1 && pwsh tools/test.ps1`
5. Commit: `git commit -am 'Add new feature'`
6. Push: `git push origin feature/my-feature`
7. Create a Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details

## Support

- **Issues**: [GitHub Issues](https://github.com/rblake2320/UFT-mcp-ext/issues)
- **Discussions**: [GitHub Discussions](https://github.com/rblake2320/UFT-mcp-ext/discussions)

## Roadmap

- [ ] Add more MCP integration keywords
- [ ] Support for UFT Mobile extensions
- [ ] Integration with popular MCP providers
- [ ] Extended documentation and examples
- [ ] Unit test framework integration
- [ ] Code signing support for enterprise deployments

## Acknowledgments

- UFT/LeanFT development team at Micro Focus/OpenText
- MCP community for protocol specifications
- Contributors and testers

---

**Note**: This extension is a community project and is not officially supported by Micro Focus, OpenText, or the MCP project maintainers.