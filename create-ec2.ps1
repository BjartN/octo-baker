#Before starting 
#   1) Start powershell as Adminstrator
#   2) Set-ExecutionPolicy RemoteSigned
#   3) Install-Module -Name AwsPowerShell
#   4) You can find your AWS credentials under the IAM User in the AWS Console
$isOctopus = ![string]::IsNullOrEmpty($EC2_INSTANCENAME) 

$variablesFile = "./set-variables.ps1"
$customVariablesFile = "./set-variables-custom.ps1"
if ($isOctopus) {
    $instanceName = $EC2_INSTANCENAME
    $accessKey = $AWS_ACCESS_KEY
    $secretKey = $AWS_SECRET_KEY
    $ami = $AWS_AMI
    $region = $AWS_REGION
    $existingSecurityGroup = $AWS_EXISTING_SECURITY_GROUP
    $octopusApiKey = $OCTOPUS_API_KEY
    $octopusServerUrl = $OCTOPUS_SERVER_URL
    $userDataRaw = $EC2_USER_DATA

    $keyName = $instanceName
    $keyFolder = "c:\keys\"
    $fullKeyPath = "$($keyFolder)$($keyName).pem"
    $awsProfile = "MyProfile"
    $userDataFile = "$(Get-Location)\install-tentacle.ps1"
}
elseif (Test-Path $customVariablesFile) {
    #ask for variables
    . $customVariablesFile
}
elseif (Test-Path $variablesFile) {
    #pre-defined variables
    . $variablesFile
}

Write-Host "Variables are"
Write-Host "`tInstance Name: $($instanceName)"
Write-Host "`tAccessKey: $($accessKey)"
Write-Host "`tSecret Key: $($secretKey)"
Write-Host "`tSecurity Group: $($existingSecurityGroup)"  
Write-Host "`tAMI: $($ami)"
Write-Host "`tRegion: $($region)"
Write-Host "Reading and encoding user data file from $($userDataFile)"

if (!$isOctopus) {
    $userDataRaw = Get-Content -Raw $userDataFile
}

$userDataRaw = $userDataRaw -replace "{OCTOPUS_API_KEY}", $octopusApiKey
$userDataRaw = $userDataRaw -replace "{OCTOPUS_SERVER_URL}", $octopusServerUrl
$userDataRaw = $userDataRaw -replace "{TENTACLE_NAME}", $instanceName
$userData = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($userDataRaw))

Write-Host "Setting AWS Credentials"
Set-AWSCredential -AccessKey $accessKey -SecretKey $secretKey -StoreAs $awsProfile
 
Write-Host "Creating key pair"
$keyPair = New-EC2KeyPair `
    -Region $region `
    -ProfileName $awsProfile `
    -KeyName  $keyName 

if ($isOctopus) {
    # Write-Host "<key>"
    # Write-Host $keyPair.KeyMaterial
    # Write-Host "</key>"
    $keyPair.KeyMaterial | Out-File -Encoding ascii ./key.pem
    New-OctopusArtifact -Path ./key.pem -Name "key.pem"
    Write-Host "Key written as artifact"
}
else {
    $keyPair.KeyMaterial | Out-File -Encoding ascii $fullKeyPath
    Write-Host "`t$($fullKeyPath)"
}

Write-Host "Creating EC2 Instance"
$instance = New-EC2Instance `
    -Region $region `
    -ProfileName $awsProfile `
    -ImageId $ami `
    -SecurityGroupId $existingSecurityGroup `
    -InstanceType t2.micro `
    -KeyName $keyName `
    -UserData $userData
Write-Host "`t$($instance.RunningInstance.instanceid)"

Write-Host "Creating Tag Name=$($instanceName)"
$tag = New-Object Amazon.EC2.Model.Tag
$tag.Key = "Name"
$tag.Value = $instanceName
New-EC2Tag  `
    -Region $region `
    -ProfileName $awsProfile `
    -Resource $instance.RunningInstance.instanceid  `
    -Tag $tag

Write-Host "Done. UserData log file can be found in the created instance at c:\ProgramData\Amazon\EC2-Windows\Launch\Log"

