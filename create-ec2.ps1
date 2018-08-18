#Before starting 
#   1) Start powershell as Adminstrator
#   2) Set-ExecutionPolicy RemoteSigned
#   3) Install-Module -Name AwsPowerShell
#   4) You can find your AWS credentials under the IAM User in the AWS Console
 
#. ./set-variables.ps1
. ./set-variables.ps1

write-host "Variables are"
write-host "`tInstance Name: $($instanceName)"
write-host "`tAccessKey: $($accessKey)"
write-host "`tSecret Key: $($secretKey)"
write-host "`tSecurity Group: $($existingSecurityGroup)"  
write-host "`tAMI: $($ami)"
write-host "`tRegion: $($region)"

Write-Host "Reading and encoding user data file from $($userDataFile)"
$userDataRaw = Get-Content -Raw $userDataFile
$userDataRaw = $userDataRaw -replace "{OCTOPUS_API_KEY}", $octopusApiKey
$userDataRaw = $userDataRaw -replace "{OCTOPUS_SERVER_URL}", $octopusServerUrl
$userData = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($userDataRaw))

Write-Host "Setting AWS Credentials"
Set-AWSCredential -AccessKey $accessKey -SecretKey $secretKey -StoreAs $awsProfile
 
Write-Host "Creating key pair"
$keyPair = New-EC2KeyPair `
    -Region $region `
    -ProfileName $awsProfile `
    -KeyName  $keyName 
$keyPair.KeyMaterial | Out-File -Encoding ascii $fullKeyPath
Write-Host "`t$($fullKeyPath)"

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

