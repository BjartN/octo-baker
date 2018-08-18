
$instanceName = Read-Host -Prompt 'Input Name of new Instance (Lower case letters and dashes)'
$accessKey = Read-Host -Prompt 'Input AWS Access Key'
$secretKey = Read-Host -Prompt 'Input AWS Secret Key' 
$ami = Read-Host -Prompt 'Input AMI Id'
$region = Read-Host -Prompt 'Region'
$existingSecurityGroup = Read-Host -Prompt 'Input Name of Existing Security Group'
$octopusApiKey = Read-Host -Prompt 'Input Octopus API Key'
$octopusServerUrl = Read-Host -Prompt 'Input Octopus server full url, i.e. https://your-server.octopus.app'

$keyName = $instanceName
$keyFolder = "c:\keys\"
$fullKeyPath = "$($keyFolder)$($keyName).pem"
$awsProfile = "MyProfile"
$userDataFile = "$(Get-Location)\install-tentacle.ps1"