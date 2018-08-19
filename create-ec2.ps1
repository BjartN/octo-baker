Import-Module ./ci-tools

#Before starting 
#   1) Start powershell as Adminstrator
#   2) Set-ExecutionPolicy RemoteSigned
#   3) Install-Module -Name AwsPowerShell
#   4) You can find your AWS credentials under the IAM User in the AWS Console
$isOctopus = ![string]::IsNullOrEmpty($ec2InstanceName) 

$variablesFile = "./set-variables-secret.ps1"
if (Test-Path $variablesFile) {
    . $variablesFile
}

$keyName = $ec2InstanceName
$keyFolder = "c:\keys\"
$fullKeyPath = "$($keyFolder)$($keyName).pem"
$awsProfile = "MyProfile"
$userDataFile = "$(Get-Location)\install-tentacle.ps1"

Write-Host "Variables are"
Write-Host "`tInstance Name: $($ec2InstanceName)"
Write-Host "`tAccessKey: $($awsAccessKey)"
Write-Host "`tSecret Key: $($awsSecretKey)"
Write-Host "`tSecurity Group: $($awsExistingSecurityGroup)"  
Write-Host "`tAMI: $($awsAmi)"
Write-Host "`tRegion: $($awsRegion)"

Write-Host "Reading and encoding user data"
$ec2UserData = Get-FromVariableOrFile $ec2UserData $userDataFile
$userData = Format-UserData $ec2UserData $octopusApiKey $octopusServerUrl $ec2InstanceName $octopusTenant

Write-Host "Setting AWS Credentials"
Set-AWSCredential -AccessKey $awsAccessKey -SecretKey $awsSecretKey -StoreAs $awsProfile
 
Write-Host "Creating Key Pair"

if ($isOctopus) {
    Set-KeyPairOctopus $awsRegion $awsProfile $keyName
}
else {
    Set-KeyPairFileSystem $awsRegion $awsProfile $keyName $fullKeyPath
}

Write-Host "Creating EC2 Instance and adding name tag"
$instanceId = New-Ec2InstanceWithNameTag `
    $awsRegion `
    $awsProfile `
    $awsAmi `
    $awsExistingSecurityGroup `
    $keyName `
    $userData `
    $ec2InstanceName

if ($isOctopus) {
    Write-Host "Setting output variable Ec2InstanceId=$($instanceId)"
    Set-OctopusVariable -name "Ec2InstanceId" -value $instanceId
}

Write-Host "Done. UserData log file can be found in the created instance at c:\ProgramData\Amazon\EC2-Windows\Launch\Log"

