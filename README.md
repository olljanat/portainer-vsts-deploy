# portainer-vsts-deploy
Portainer.io extension for Visual Studio Team Services.

Currently supported features:
- Deploy stack (automatically detects if that need to be created or updated)
- Deploy service (automatically detects if that need to be created or updated)

Requirements:
- VSTS agent running on Windows node (because based on PowerShell)

Roadmap:
- Support for configs on service deployment
- Support for secrets on service deployment
- Support for Linux VSTS agents (after VSTS agent supports PowerShell Core)

# Build
Pre-requirements:
- NodeJS
- ```npm i -g tfx-cli```

Build using:
```
tfx extension create --rev-version --manifest-globs vss-extension.json
```
