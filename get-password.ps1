. ./set-variables.ps1

Set-AWSCredential -AccessKey $accessKey -SecretKey $secretKey -StoreAs $awsProfile

Write-Host "Looing for key $($fullKeyPath)"
$password = Get-EC2PasswordData `
    -Region $region `
    -ProfileName $awsProfile `
    -InstanceId $instanceId `
    -PemFile $fullKeyPath `
    -Decrypt 
Write-Host "Password is $($password)"