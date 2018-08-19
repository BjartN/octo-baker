Import-Module ./ci-tools

# Read variables from file if it exstings, otherwise we assume the variables 
# are available in the environment
$variablesFile = "./set-variables-secret.ps1"
if (Test-Path $variablesFile) {
    . $variablesFile
}
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

# # Wait until it done
# Start-Sleep -Seconds 60 

# # Get Amazon.EC2.Model.Image
# $amiProperties = Get-EC2Image -ImageIds $amiId
  
# # Get Amazon.Ec2.Model.BlockDeviceMapping
# $amiBlockDeviceMapping = $amiProperties.BlockDeviceMapping 

# # Add tags to snapshots associated with the AMI using Amazon.EC2.Model.EbsBlockDevice
# $amiBlockDeviceMapping.ebs | `
#     ForEach-Object -Process {New-EC2Tag -Resources $_.SnapshotID -Tags @{ Key = "Name" ; Value = $amiName} }