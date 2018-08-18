<powershell>

# Install Octopus Tentacle
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install octopusdeploy.tentacle -y

# Define variables
$octopusApiKey = "YOUR API KEY" 
$octopusServerUrl = "https://YOUR-SERVER-URL.octopus.app" 
$tentacleHomeDirectory = "c:\Octopus"
$tentacleAppDirectory = "c:\Octopus\Applications"
$tentacleConfigPath = "C:\Octopus\Tentacle.config"
$tentacleInstance = "Tentacle"
$role1 = "--role=web-server"
$role2 = "--role=frontend-server"
$tentacleEnvironment = "--environment=Test"
$tentacleName = "Test Tentacle 1,2,3"

# Keep original working path
$originalWorkingPath = (Get-Item -Path ".\" -Verbose).FullName

# Configure tentacle, see https://octopus.com/docs/api-and-integration/tentacle.exe-command-line 
# and https://octopus.com/docs/infrastructure/windows-targets/automating-tentacle-installation
Write-Output "Configuring and registering Tentacle"
  
# Change directory to where tentacle.exe is located
cd "${env:ProgramFiles}\Octopus Deploy\Tentacle"

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
cd $originalWorkingPath

</powershell>