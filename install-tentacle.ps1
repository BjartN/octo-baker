<powershell>

# Supress nasty progress bar
$progressPreference = 'silentlyContinue' 

# Enable Windows Features
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-WebServerRole -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-WebServer -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-CommonHttpFeatures -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-HttpErrors -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-HttpRedirect -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-ApplicationDevelopment -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-NetFxExtensibility45 -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-HealthAndDiagnostics -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-HttpLogging -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-LoggingLibraries -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-RequestMonitor -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-HttpTracing -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-Security -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-RequestFiltering -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-Performance -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-HttpCompressionDynamic -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-WebServerManagementTools -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-ManagementScriptingTools -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-IIS6ManagementCompatibility -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-Metabase -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-WindowsAuthentication -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-StaticContent -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-DefaultDocument -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-DirectoryBrowsing -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-WebDAV -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-WebSockets -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-ApplicationInit -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-ASPNET45 -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-ISAPIExtensions -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-ISAPIFilter -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-CustomLogging -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-HttpCompressionStatic -All
Enable-WindowsOptionalFeature -LogLevel 2 -Online -FeatureName IIS-ManagementConsole -All

# Install Chocolatey
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install dotnetcore-windowshosting -y
choco install dotnetcore-sdk --version 2.1.200 -y
choco install octopusdeploy.tentacle -y
choco install iis-arr -y

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
$tenacleTenant = "{OCTOPUS_TENANT}"

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
    --tenant $tenacleTenant `
    --force `
    $tentacleEnvironment `
    $role1 `
    $role2 `
    --console
& .\Tentacle.exe service --instance $tentacleInstance --install --start --console
# Reset working path
Set-Location $originalWorkingPath

</powershell>