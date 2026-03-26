# scripts/fix-sql3-name.ps1
Set-DbatoolsInsecureConnection -SessionOnly

$sec  = ConvertTo-SecureString 'dbatools.IO' -AsPlainText -Force
$cred = [pscredential]::new('sqladmin', $sec)

Invoke-DbaQuery -SqlInstance sql3 -SqlCredential $cred -Database master -Query @"
IF @@SERVERNAME <> 'sql3'
BEGIN
    EXEC sp_dropserver 'mssql2';
    EXEC sp_addserver 'sql3', 'local';
END
"@


#
docker restart sql3