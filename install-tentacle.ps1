<powershell>


# Enable Windows Features
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-LoggingLibraries
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestMonitor
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpTracing
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security
Enable-WindowsOptionalFeature -Online -FeatureName IIS-URLAuthorization
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -Online -FeatureName IIS-IPSecurity
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionDynamic
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementScriptingTools
Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Metabase
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HostableWebCore
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CertProvider
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DigestAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ClientCertificateMappingAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-IISCertificateMappingAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ODBCLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DirectoryBrowsing
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebDAV
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASP
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CGI
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ServerSideIncludes
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CustomLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementService
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WMICompatibility
Enable-WindowsOptionalFeature -Online -FeatureName IIS-LegacyScripts
Enable-WindowsOptionalFeature -Online -FeatureName IIS-LegacySnapIn

# Install Chocolatey
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install dotnetcore-windowshosting -y
choco install dotnetcore-sdk --version 2.1.200 -y
choco install octopusdeploy.tentacle -y

# Define variables
$octopusApiKey = "{OCTOPUS_API_KEY}" 
$octopusServerUrl = "{OCTOPUS_SERVER_URL}" 
$tentacleHomeDirectory = "c:\Octopus"
$tentacleAppDirectory = "c:\Octopus\Applications"
$tentacleConfigPath = "C:\Octopus\Tentacle.config"
$tentacleInstance = "Tentacle"
$role1 = "--role=web-server"
$role2 = "--role=frontend-server"
$tentacleEnvironment = "--environment=Test"
$tentacleName = "{TENTACLE_NAME}"

# Keep original working path
$originalWorkingPath = (Get-Item -Path ".\" -Verbose).FullName

# Configure tentacle, see https://octopus.com/docs/api-and-integration/tentacle.exe-command-line 
# and https://octopus.com/docs/infrastructure/windows-targets/automating-tentacle-installation
Write-Output "Configuring and registering Tentacle"
  
# Change directory to where tentacle.exe is located
Set-Location "${env:ProgramFiles}\Octopus Deploy\Tentacle"

& .\Tentacle.exe create-instance --instance $tentacleInstance --config $tentacleConfigPath --console
& .\Tentacle.exe new-certificate --instance $tentacleInstance --if-blank --console
& .\Tentacle.exe configure --instance $tentacleInstance --reset-trust --console
& .\Tentacle.exe configure `
    --instance $tentacleInstance `
    --home $tentacleHomeDirectory `
    --app $tentacleAppDirectory `
    --noListen "True" `
    --console
& .\Tentacle.exe register-with  `
    --instance "Tentacle" `
    --server $octopusServerUrl `
    --name $tentacleName `
    --apiKey $octopusApiKey `
    --comms-style "TentacleActive" `
    --server-comms-port "10943" `
    --force `
    $tentacleEnvironment `
    $role1 `
    $role2 `
    --console
& .\Tentacle.exe service --instance $tentacleInstance --install --start --console
# Reset working path
Set-Location $originalWorkingPath

</powershell>