# Portainer.io deploy
Portainer.io extension for Visual Studio Team Services.

Currently supported features:
- Deploy stack (automatically detects if that need to be created or updated)
- Deploy service (automatically detects if that need to be created or updated)

Requirements:
- VSTS agent running on Windows node (because based on PowerShell)


# Configuring
Setup service endpoint(s). You need at least one service endpoint per Portainer endpoint but you can also have multiple service endpoint for one Portainer endpoint (example if you have multiple teams on Portainer).

![Service endpoint](images/service-endpoint.png)

# Stack deployment
Store stack file to GIT repository and create build/release definition.

![Stack deloyment](images/stack-deployment.png)

# Service deployment
Create build/release definition.

![Service deployment](images/service-deployment.png)
