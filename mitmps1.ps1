## Construct the header
$PlainUsername = "tstad\tstusr"
$PlainPassword = "P@ssw0rd2013"
$RemoteComputer = "w8.tst.com"

$DomainName = (Get-ADDomain).DNSRoot
$AllDCs = (Get-ADForest).GlobalCatalogs

# Validate $PlainUsername, $PlainPassword will auth to $AddDCs
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')

if(Test-Connection -ComputerName $RemoteComputer -Count 1 -Quiet) {
    if([bool](Test-WSMan -ComputerName $RemoteComputer -ErrorAction SilentlyContinue)) {
        if($DS.ValidateCredentials($PlainUsername, $PlainPassword)) {
            $password = ConvertTo-SecureString $PlainPassword -AsPlainText -Force
            $secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force
            $creds = New-Object System.Management.Automation.PSCredential -ArgumentList ($PlainUsername, $password)
            
            Write-Host "Results of Invoke-Commands on $RemoteComputer"
            
            # Retrieve information from $RemoteComputer
            Invoke-Command -ComputerName $RemoteComputer -Credential $creds -ScriptBlock { 
                Write-Host "Logged on User:`t`t`t"(Get-WMIObject -class Win32_ComputerSystem).username
                Write-Host "Hostname:`t`t`t $env:computerName"
                Write-Host "FQDN:`t`t`t`t"([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname 
                Write-Host "IP Address:`t`t`t" ([System.Net.Dns]::GetHostByName(($env:computerName))).AddressList[0]
            }

        } else {
            Write-Host "Cannot authenticate using $PlainUsername using $PlainPassword against $AllDCs"
        }
    } else {
        Write-Host "$RemoteComputer WsMan appears to be down"
    }
} else {
    Write-Host "$RemoteComputer appears to be down"
}
