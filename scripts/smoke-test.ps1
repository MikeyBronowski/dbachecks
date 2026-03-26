# scripts/smoke-test.ps1

$ErrorActionPreference = 'Stop'
Set-DbatoolsInsecureConnection -SessionOnly

$sec  = ConvertTo-SecureString 'dbatools.IO' -AsPlainText -Force
$cred = [pscredential]::new('sqladmin', $sec)

'sql1','sql2','sql3' | ForEach-Object {
    Invoke-DbaQuery -SqlInstance $_ -SqlCredential $cred -Query "SELECT @@SERVERNAME AS ServerName, @@VERSION AS Version;"
}

Get-DbaAvailabilityGroup -SqlInstance sql1 -SqlCredential $cred
Get-DbaAgReplica -SqlInstance sql1 -SqlCredential $cred