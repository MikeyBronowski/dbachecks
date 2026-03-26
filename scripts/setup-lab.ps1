# scripts/setup-lab.ps1


# Install-Module dbatools -Scope CurrentUser -Force

$ErrorActionPreference = 'Stop'

# Lab-only: avoid TLS/cert issues in the Codespace
Set-DbatoolsInsecureConnection -SessionOnly

$sec  = ConvertTo-SecureString 'dbatools.IO' -AsPlainText -Force
$cred = [pscredential]::new('sqladmin', $sec)

$instances = 'sql1','sql2','sql3'

Write-Host "Waiting for SQL instances..."
foreach ($instance in $instances) {
    $connected = $false
    foreach ($try in 1..60) {
        try {
            Invoke-DbaQuery -SqlInstance $instance -SqlCredential $cred -Query "SELECT @@SERVERNAME" -EnableException | Out-Null
            $connected = $true
            Write-Host "$instance is ready"
            break
        }
        catch {
            Start-Sleep -Seconds 5
        }
    }

    if (-not $connected) {
        throw "Instance $instance did not come online in time."
    }
}

Write-Host "Checking SQL Agent..."
foreach ($instance in $instances) {
    Invoke-DbaQuery -SqlInstance $instance -SqlCredential $cred -Query "
        SELECT servicename, startup_type_desc, status_desc
        FROM sys.dm_server_services
        WHERE servicename LIKE 'SQL Server Agent%';
    "
}

Write-Host "Creating demo database on primary..."
Invoke-DbaQuery -SqlInstance sql1 -SqlCredential $cred -Query @"
IF DB_ID('pubs') IS NULL
BEGIN
    CREATE DATABASE pubs;
END
"@

Write-Host "Creating availability group..."
$params = @{
    Primary                = 'sql1'
    PrimarySqlCredential   = $cred
    Secondary              = 'sql2','sql3'
    SecondarySqlCredential = $cred
    Name                   = 'ag1'
    Database               = 'pubs'
    ClusterType            = 'None'
    SeedingMode            = 'Automatic'
    FailoverMode           = 'Manual'
    Confirm                = $false
}

New-DbaAvailabilityGroup @params

Write-Host "Validating AG..."
Get-DbaAvailabilityGroup -SqlInstance sql1 -SqlCredential $cred


Invoke-DbaQuery -SqlInstance sql1 -SqlCredential $cred -Query "SELECT @@SERVERNAME AS ServerName, SERVERPROPERTY('MachineName') AS MachineName"
Invoke-DbaQuery -SqlInstance sql2 -SqlCredential $cred -Query "SELECT @@SERVERNAME AS ServerName, SERVERPROPERTY('MachineName') AS MachineName"
Invoke-DbaQuery -SqlInstance sql3 -SqlCredential $cred -Query "SELECT @@SERVERNAME AS ServerName, SERVERPROPERTY('MachineName') AS MachineName"