# UFT MCP Extension - Design Documentation

## Overview

The UFT MCP Extension is a custom extension for UFT One (Unified Functional Testing) that provides integration with the Model Context Protocol (MCP). This extension enables UFT test scripts to interact with MCP-compatible services and AI models.

## Architecture

### Component Overview

```
┌─────────────────────────────────────────┐
│           UFT One Environment            │
├─────────────────────────────────────────┤
│         UFT MCP Extension (.dxt)         │
├──────────────┬──────────────────────────┤
│ manifest.json│  Extension Metadata       │
├──────────────┼──────────────────────────┤
│ extension.js │  Core Logic & Keywords    │
├──────────────┼──────────────────────────┤
│ extension.css│  UI Styling              │
└──────────────┴──────────────────────────┘
```

### Extension Structure

The extension follows UFT's standard extension architecture:

1. **Manifest (manifest.json)**: Declares the extension metadata, dependencies, and entry points
2. **JavaScript Core (extension.js)**: Implements custom keywords and MCP integration logic
3. **Styles (extension.css)**: Provides styling for any UI elements added by the extension

## Key Features

### Custom Keywords

The extension registers the following UFT custom keywords:

| Keyword | Purpose | Parameters |
|---------|---------|------------|
| `MCP_Ping` | Test connectivity | `{message: string}` |
| `MCP_SendRequest` | Send MCP request | `{endpoint: string, method?: string, data?: object}` |
| `MCP_ValidateResponse` | Validate MCP response | `{response: object}` |
| `MCP_SetContext` | Set MCP context | `{context: object}` |
| `MCP_GetContext` | Get current context | None |
| `MCP_ExecutePrompt` | Execute MCP prompt | `{prompt: string, parameters?: object}` |

### Event Handlers

The extension hooks into UFT lifecycle events:

- **OnTestStart**: Initializes MCP context
- **OnTestEnd**: Cleanup and reporting

## MCP Integration

### Protocol Support

The extension is designed to support MCP (Model Context Protocol) features:

1. **Context Management**: Maintain context across test executions
2. **Prompt Execution**: Send prompts to MCP-compatible services
3. **Response Validation**: Validate responses from MCP services

### Data Flow

```
UFT Test Script
    ↓
MCP Custom Keyword
    ↓
Extension.js Handler
    ↓
MCP Service Request
    ↓
Response Processing
    ↓
UFT Reporter
```

## Build Process

### Development Workflow

1. **Source Files**: Located in `src/extension/`
2. **Build Script**: `tools/build.ps1` validates and packages the extension
3. **Output**: Creates `.dxt` bundle in `artifacts/`

### Build Steps

1. Validate manifest.json structure
2. Check file references
3. Copy sources to dist/
4. Normalize line endings (CRLF for Windows)
5. Create ZIP archive
6. Rename to .dxt extension

## Testing Strategy

### Unit Tests

- Manifest validation
- JavaScript syntax checking
- File structure verification

### Integration Tests

- Extension loading in UFT
- Keyword registration
- Event handler functionality

### Test Script (tools/test.ps1)

Performs the following validations:

1. Project structure integrity
2. Manifest completeness
3. JavaScript syntax validity
4. Build artifact verification
5. Documentation presence

## CI/CD Pipeline

### GitHub Actions Workflow

The CI/CD pipeline (``.github/workflows/ci.yml`) automates:

1. **Build Stage**
   - Validate project structure
   - Run build script
   - Execute tests
   - Upload artifacts

2. **Release Stage** (on version tags)
   - Create GitHub release
   - Attach .dxt bundle
   - Generate release notes

3. **Validation Stage**
   - Verify .dxt structure
   - Check manifest integrity

## Installation Process

### Manual Installation

1. Download the `.dxt` file from releases
2. Open UFT One
3. Navigate to: Tools → Options → GUI Testing → Add-ins
4. Click "Install Extension"
5. Browse to the `.dxt` file
6. Restart UFT One

### Automated Deployment

For enterprise deployments, the extension can be:

1. Distributed via package managers
2. Deployed through GPO
3. Installed via command-line scripts

## Compatibility

### UFT Versions

- UFT One 15.0 and later
- UFT Developer (LeanFT) - compatible with modifications
- UFT Mobile - not currently supported

### Operating Systems

- Windows 10/11
- Windows Server 2016/2019/2022

## Security Considerations

### Code Signing

Future versions will support code signing for:

- Extension integrity verification
- Enterprise security compliance

### Permissions

The extension operates within UFT's sandbox:

- No direct file system access
- Network requests through UFT APIs only
- Limited to UFT Reporter for output

## Future Enhancements

### Planned Features

1. **Extended MCP Support**
   - Streaming responses
   - Batch operations
   - Advanced context management

2. **UI Components**
   - MCP configuration panel
   - Real-time status display
   - Context visualization

3. **Integration Improvements**
   - ALM/QC integration
   - Jenkins plugin support
   - REST API endpoints

4. **Performance Optimizations**
   - Request caching
   - Connection pooling
   - Async operations

### Roadmap

- **v0.2.0**: Add streaming support
- **v0.3.0**: UI configuration panel
- **v0.4.0**: ALM integration
- **v1.0.0**: Production-ready release

## Troubleshooting

### Common Issues

1. **Extension Not Loading**
   - Verify UFT version compatibility
   - Check Windows Event Log
   - Ensure .dxt file integrity

2. **Keywords Not Available**
   - Restart UFT after installation
   - Check extension enabled in Add-ins Manager
   - Verify manifest.json syntax

3. **MCP Connection Failures**
   - Validate endpoint configuration
   - Check network connectivity
   - Review UFT Reporter logs

## Contributing

### Development Setup

```powershell
# Clone repository
git clone https://github.com/rblake2320/UFT-mcp-ext.git
cd UFT-mcp-ext

# Build extension
pwsh tools/build.ps1 -Clean

# Run tests
pwsh tools/test.ps1
```

### Submission Guidelines

1. Follow existing code style
2. Add tests for new features
3. Update documentation
4. Create descriptive pull requests

## References

- [UFT One Documentation](https://admhelp.microfocus.com/uft/)
- [Model Context Protocol Spec](https://mcp.run)
- [GitHub Repository](https://github.com/rblake2320/UFT-mcp-ext)

## License

MIT License - See LICENSE file for details

---

*Last Updated: 2025*