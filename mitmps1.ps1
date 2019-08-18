## Construct the header
$PlainUsername = "tstad\tstusr"
$PlainPassword = "P@ssw0rd2013"
$RemoteComputer = "w8.tst.com"

$DomainName = (Get-ADDomain).DNSRoot
$AllDCs = (Get-ADForest).GlobalCatalogs 

$WsManStatus = [bool](Test-WSMan -ComputerName $RemoteComputer -ErrorAction SilentlyContinue)

# Validate $PlainUsername, $PlainPassword will auth to $AddDCs
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
$ADStatus = $DS.ValidateCredentials($PlainUsername, $PlainPassword)

if($WsManStatus) {
    if($ADStatus) {
        $password = ConvertTo-SecureString $PlainPassword -AsPlainText -Force
        $secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force
        $creds = New-Object System.Management.Automation.PSCredential -ArgumentList ($PlainUsername, $password)
    } else {
        Write-Host "Cannot authenticate using $PlainUsername using $PlainPassword against $AllDCs"
    }

    Write-Host "Results of Invoke-Commands on $RemoteComputer"
    Invoke-Command -ComputerName $RemoteComputer -Credential $creds -ScriptBlock { Write-Host "Logged on User:`t`t`t"(Get-WMIObject -class Win32_ComputerSystem).username
                                                                                   Write-Host "Hostname:`t`t`t $env:computerName"
                                                                                   #Display Fully Qualified Domain Name for local computer
                                                                                   Write-Host "FQDN:`t`t`t`t"([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname 
                                                                                   Write-Host "IP Address:`t`t`t" ([System.Net.Dns]::GetHostByName(($env:computerName))).AddressList[0]
                                                                                   #Test-NetConnection w12srvrutil.tst.com -TraceRoute 
                                                                                 }

} else {
    Write-Host "$RemoteComputer WsMan appears to be down"
}
