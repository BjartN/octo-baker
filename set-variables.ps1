# Make sure the ami you specify exsists in the region
# you specifiy
$isOctopus = "false"
$ec2InstanceName = "name-of-new-instance"
$awsAccessKey = "your-aws-access-key";
$awsSecretKey = "your-aws-secret-key"
$awsAmi = 'ami-9bb358fc' 
$awsRegion = 'eu-west-2' 
$awsExistingSecurityGroup = 'some-existing-security-group'
$octopusApiKey = "API-******************" 
$octopusServerUrl = "https://******.octopus.app" 
$ec2InstanceType = "t2.micro"
$octopusTenant = "Tenant to register with tentacle"