    $filename = $MyInvocation.MyCommand.Name.Replace('.Tests.ps1', '')

$targetInstances = @($SqlInstance)
if (-not $targetInstances -or $targetInstances.Count -eq 0) {
    $targetInstances = @(Get-DbcConfigValue app.sqlinstance)
}

$targetInstances = @($targetInstances | Where-Object { $_ -and "$_".Trim() -ne '' })
$expectedPreference = Get-DbcConfigValue policy.hadr.automatedbackuppreference

Describe 'AG Backup Preference' -Tags 'AGConfig' {

    foreach ($instance in $targetInstances) {
        $ags = @()
        try {
            $ags = @(Get-DbaAvailabilityGroup -SqlInstance $instance -SqlCredential $SqlCredential -WarningAction SilentlyContinue)
        }
        catch {
            $ags = @()
        }

        $primaryAgs = @($ags | Where-Object { $_.LocalReplicaRole -eq 'Primary' })

        foreach ($ag in $primaryAgs) {
            It "AG [$($ag.AvailabilityGroup)] primary [$instance] should prefer [$expectedPreference] for backups" {
                $ag.AutomatedBackupPreference | Should -Be $expectedPreference
            }
        }
    }
}



