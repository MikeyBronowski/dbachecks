Import-Module dbatools
Import-Module pester
import-module PSFramework
Import-Module /workspaces/dbachecks/dbachecks.psd1 -Force; Invoke-DbcCheck -SqlInstance $instances -SqlCredential $cred -Check AGConfig


Set-DbatoolsInsecureConnection -SessionOnly


Get-DbaAgReplica -SqlInstance sql1 -SqlCredential $cred | 
    Select-Object SqlInstance, Name, Role, AvailabilityMode, FailoverMode, BackupPriority, ConnectionModeInSecondaryRole | ft


Get-DbaAvailabilityGroup -SqlInstance sql1 -SqlCredential $cred |
    Select-Object AvailabilityGroup, AutomatedBackupPreference, ClusterType, PrimaryReplica    | ft



