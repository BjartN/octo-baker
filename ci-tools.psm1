
Function Get-FromVariableOrFile($variable, $file) {
    # .SYNOPSIS
    # Get value from variable if it exists, if not, read from file

    if ([string]::IsNullOrEmpty($variable)) {
        return Get-Content -Raw $file
    }
    else {
        return $variable
    }
}

Function Format-UserData($ec2UserData, $octopusApiKey, $octopusServerUrl, $ec2InstanceName) {
    # .SYNOPSIS
    # Replace content in user data with the correct variables and encode

    $ec2UserData = $ec2UserData -replace "{OCTOPUS_API_KEY}", $octopusApiKey
    $ec2UserData = $ec2UserData -replace "{OCTOPUS_SERVER_URL}", $octopusServerUrl
    $ec2UserData = $ec2UserData -replace "{TENTACLE_NAME}", $ec2InstanceName
    $userData = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($ec2UserData))

    return $userData
}

Function Set-KeyPairFileSystem($awsRegion, $awsProfile, $keyName, $keyPath) {
    $keyPair = New-EC2KeyPair `
        -Region $awsRegion `
        -ProfileName $awsProfile `
        -KeyName  $keyName 
    
    $keyPair.KeyMaterial | Out-File -Encoding ascii $keyPath
    Write-Host "Key written to $($keyPath)"
}


Function Set-KeyPairOctopus($awsRegion, $awsProfile, $keyName) {
    $keyPair = New-EC2KeyPair `
        -Region $awsRegion `
        -ProfileName $awsProfile `
        -KeyName  $keyName 
    
    $keyPair.KeyMaterial | Out-File -Encoding ascii ./key.pem
    New-OctopusArtifact -Path ./key.pem -Name "key.pem"
    Write-Host "Key written as artifact"
}

Function New-Ec2InstanceWithNameTag(
    $awsRegion, 
    $awsProfile, 
    $awsAmi,
    $awsExistingSecurityGroup,
    $keyName, 
    $userData,
    $ec2InstanceName) {

    $instance = New-EC2Instance `
        -Region $awsRegion `
        -ProfileName $awsProfile `
        -ImageId $awsAmi `
        -SecurityGroupId $awsExistingSecurityGroup `
        -InstanceType t2.micro `
        -KeyName $keyName `
        -UserData $userData
    Write-Host "`t$($instance.RunningInstance.instanceid)"

    $tag = New-Object Amazon.EC2.Model.Tag
    $tag.Key = "Name"
    $tag.Value = $ec2InstanceName
    New-EC2Tag  `
        -Region $awsRegion `
        -ProfileName $awsProfile `
        -Resource $instance.RunningInstance.instanceid  `
        -Tag $tag

    return $instance.RunningInstance.instanceid
}
Function Write-InstanceStatus($instance) {
    switch ($instance.state.code) {
        0 {
            Write-Host "Status is pending"
        }
        16 {
            Write-Host "Status is running"
        }
        32 {
            Write-Host "Status is shutting-down"
        }
        48 {
            Write-Host "Status is terminated"
        }
        64 {
            Write-Host "Status is stopping"
        }
        80 {
            Write-Host "Status is stopped"
        }
        default {
            Write-Error "No valid states detected for any of the instances associated with the specified name tag."
        }
    }
}