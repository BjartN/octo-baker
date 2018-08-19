Import-Module ./ci-tools
#This script assumes variables have been set

Set-AWSCredential -AccessKey $awsAccessKey -SecretKey $awsSecretKey -StoreAs $awsProfile

$reservation = Get-EC2Instance -Filter @{name = 'tag:Name'; values = $ec2InstanceName} -ProfileName $awsProfile -Region $awsRegion
$instance = $reservation.instances[0]

Write-Host "Found instance $($instance.InstanceId)"
Write-InstanceStatus $instance

# Create the AMI, rebooting the instance in the process
$amiId = New-EC2Image `
    -InstanceId $instance.InstanceId `
    -Name "ami-$($ec2InstanceName)" `
    -Description  $tagDesc `
    -NoReboot $false `
    -ProfileName $awsProfile `
    -Region $awsRegion

Write-Host "AMI created with id $($amiId)"
