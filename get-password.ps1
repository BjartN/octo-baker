. ./set-variables.ps1

Set-AWSCredential -AccessKey $awsAccessKey -SecretKey $awsSecretKey -StoreAs $awsProfile

Write-Host "Looing for key $($fullKeyPath)"
$instanceId = Read-Host -Prompt 'Input Instance Id'
$keyName = $ec2InstanceName
$keyFolder = "c:\keys\"
$fullKeyPath = "$($keyFolder)$($keyName).pem"

$password = Get-EC2PasswordData `
    -Region $awsRegion `
    -ProfileName $awsProfile `
    -InstanceId $instanceId `
    -PemFile $fullKeyPath `
    -Decrypt 
Write-Host "Password is $($password)"