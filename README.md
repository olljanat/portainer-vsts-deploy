# portainer-vsts-deploy
Portainer.io extension for Azure DevOps.

Currently supported features:
- Deploy stack (automatically detects if that need to be created or updated)
- Deploy service (automatically detects if that need to be created or updated)

Roadmap:
- Support for configs on service deployment
- Support for secrets on service deployment

# Build
Pre-requirements:
- NodeJS
- ```npm i -g tfx-cli```

Build using:
```
tfx extension create --rev-version --manifest-globs vss-extension.json
```
