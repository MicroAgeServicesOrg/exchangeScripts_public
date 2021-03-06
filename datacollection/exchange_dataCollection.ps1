<#

.Requires -version 2 - Runs in Exchange Management Shell or Open Powershell and Connect to Office365

.SYNOPSIS
.\MailboxSizeReport.ps1 - It Can Display all the Mailbox Size with Item Count,Database,Server Details

Or It can Export to a CSV file

Or You can Enter WildCard to Display or Export


Example 1

[PS] C:\>.\MailboxSizeReport.ps1


Mailbox Size Report
----------------------------

1.Display in Exchange Management Shell

2.Export to CSV File

3.Enter the Mailbox Name with Wild Card (Export)

4.Enter the Mailbox Name with Wild Card (Display)

5.Export to CSV File (OFFICE 365)

6.Enter the Mailbox Name with Wild Card (Export) (OFFICE 365)


Mailbox Size Report
----------------------------

1.Display in Exchange Management Shell

2.Export to CSV File

3.Enter the Mailbox Name with Wild Card (Export)

4.Enter the Mailbox Name with Wild Card (Display)

5.Export to CSV File (OFFICE 365)

6.Enter the Mailbox Name with Wild Card (Export) (OFFICE 365)

Choose The Task: 2
Enter the Path of CSV file (Eg. C:\Report.csv): C:\MailboxReport.csv


#>

Write-host "

Mailbox Size Report
----------------------------

1.Display in Exchange Management Shell

2.Export to CSV File

3.Export to CSV File (Specific to Database)

4.Enter the Mailbox Name with Wild Card (Export)

5.Enter the Mailbox Name with Wild Card (Display)

6.Export to CSV File (OFFICE 365)

7.Enter the Mailbox Name with Wild Card (Export) (OFFICE 365)

8.Run Report against input CSV file (Specific Users)" -ForeGround "Cyan"

#----------------
# Script
#----------------

Write-Host "               "

$number = Read-Host "Choose The Task"
$output = @()
switch ($number) 
{

1 {

$AllMailbox = Get-mailbox -resultsize unlimited

Foreach($Mbx in $AllMailbox)

{

$Stats = Get-mailboxStatistics -Identity $Mbx.distinguishedname -WarningAction SilentlyContinue

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "Display Name" -Value $mbx.displayname
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $mbx.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "TotalItemSize" -Value $Stats.TotalItemSize
$userObj | Add-Member NoteProperty -Name "ItemCount" -Value $Stats.ItemCount

Write-Output $Userobj

}

;Break}

2 {
$i = 0 

$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\Report.csv)"

$AllMailbox = Get-mailbox -resultsize unlimited

Foreach($Mbx in $AllMailbox)

{

$Stats = Get-mailboxStatistics -Identity $Mbx.distinguishedname -WarningAction SilentlyContinue
$AdUserLastLogon = Get-ADUser -Identity $Mbx.DistinguishedName -Properties LastLogonTimeStamp | Select-Object @{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd_hh:mm:ss')}}




if (($Mbx.UseDatabaseQuotaDefaults -eq $true) -and (Get-MailboxDatabase $mbx.Database).ProhibitSendReceiveQuota.value -eq $null)
{
$ProhibitSendReceiveQuota = "Unlimited"
}
if (($Mbx.UseDatabaseQuotaDefaults -eq $true) -and (Get-MailboxDatabase $mbx.Database).ProhibitSendReceiveQuota.value -ne $null)
{
$ProhibitSendReceiveQuota = (Get-MailboxDatabase $mbx.Database).ProhibitSendReceiveQuota.Value.ToMB()
}
if (($Mbx.UseDatabaseQuotaDefaults -eq $false) -and ($mbx.ProhibitSendReceiveQuota.value -eq $null))
{
$ProhibitSendReceiveQuota = "Unlimited"
}
if (($Mbx.UseDatabaseQuotaDefaults -eq $false) -and ($mbx.ProhibitSendReceiveQuota.value -ne $null))
{
$ProhibitSendReceiveQuota = $Mbx.ProhibitSendReceiveQuota.Value.ToMB()
}
if ($Mbx.ArchiveName.count -eq "0")
{
$ArchiveTotalItemSize = $null
$ArchiveTotalItemCount = $null
}
if ($Mbx.ArchiveName -ge "1")
{
$MbxArchiveStats = Get-mailboxstatistics $Mbx.distinguishedname -Archive -WarningAction SilentlyContinue
$ArchiveTotalItemSize = $MbxArchiveStats.TotalItemSize
$ArchiveTotalItemCount = $MbxArchiveStats.BigFunnelMessageCount
}

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "Display Name" -Value $mbx.displayname
$userObj | Add-Member NoteProperty -Name "Alias" -Value $Mbx.Alias
$userObj | Add-Member NoteProperty -Name "SamAccountName" -Value $Mbx.SamAccountName
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $Mbx.RecipientTypeDetails
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $Mbx.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $Mbx.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Email Addresses" -Value ($Mbx.EmailAddresses.smtpaddress -join ";")
$userObj | Add-Member NoteProperty -Name "Office" -Value $mbx.Office
$userObj | Add-Member NoteProperty -Name "Database" -Value $mbx.Database
$userObj | Add-Member NoteProperty -Name "ServerName" -Value $mbx.ServerName
$userObj | Add-Member NoteProperty -Name "Disabled" -Value $mbx.ExchangeUserAccountControl
$userObj | Add-Member NoteProperty -Name "LitHold" -Value $mbx.LitigationHoldEnabled
if($Stats)
{
$userObj | Add-Member NoteProperty -Name "TotalItemSize" -Value $Stats.TotalItemSize.Value.ToMB()
$userObj | Add-Member NoteProperty -Name "ItemCount" -Value $Stats.ItemCount
$userObj | Add-Member NoteProperty -Name "DeletedItemCount" -Value $Stats.DeletedItemCount
$userObj | Add-Member NoteProperty -Name "TotalDeletedItemSize" -Value $Stats.TotalDeletedItemSize.Value.ToMB()
}
$userObj | Add-Member NoteProperty -Name "ProhibitSendReceiveQuota-In-MB" -Value $ProhibitSendReceiveQuota
$userObj | Add-Member NoteProperty -Name "UseDatabaseQuotaDefaults" -Value $Mbx.UseDatabaseQuotaDefaults
$userObj | Add-Member NoteProperty -Name "LastLogonTime" -Value $Stats.LastLogonTime
$userObj | Add-Member NoteProperty -Name "LastLogonTime(AD)" -Value $AdUserLastLogon.Stamp
$userObj | Add-Member NoteProperty -Name "ArchiveName" -Value ($Mbx.ArchiveName -join ";")
$userObj | Add-Member NoteProperty -Name "ArchiveStatus" -Value $Mbx.ArchiveStatus
$userObj | Add-Member NoteProperty -Name "ArchiveState" -Value $Mbx.ArchiveState 
$userObj | Add-Member NoteProperty -Name "ArchiveQuota" -Value $Mbx.ArchiveQuota
$userObj | Add-Member NoteProperty -Name "ArchiveTotalItemSize" -Value $ArchiveTotalItemSize
$userObj | Add-Member NoteProperty -Name "ArchiveTotalItemCount" -Value $ArchiveTotalItemCount




$output += $UserObj  
# Update Counters and Write Progress
$i++
if ($AllMailbox.Count -ge 1)
{
Write-Progress -Activity "Scanning Mailboxes . . ." -Status "Scanned: $i of $($AllMailbox.Count)" -PercentComplete ($i/$AllMailbox.Count*100)
}
}


$output | Export-csv -Path $CSVfile -NoTypeInformation -Encoding UTF8

;Break}

3 {
$i = 0 

$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\Report.csv)" 
$Database = Read-Host "Enter the DatabaseName (Eg. Database 01)" 

$AllMailbox = Get-mailbox -resultsize unlimited -Database "$Database"

Foreach($Mbx in $AllMailbox)

{

$Stats = Get-mailboxStatistics -Identity $Mbx.distinguishedname -WarningAction SilentlyContinue

if (($Mbx.UseDatabaseQuotaDefaults -eq $true) -and (Get-MailboxDatabase $mbx.Database).ProhibitSendReceiveQuota.value -eq $null)
{
$ProhibitSendReceiveQuota = "Unlimited"
}
if (($Mbx.UseDatabaseQuotaDefaults -eq $true) -and (Get-MailboxDatabase $mbx.Database).ProhibitSendReceiveQuota.value -ne $null)
{
$ProhibitSendReceiveQuota = (Get-MailboxDatabase $mbx.Database).ProhibitSendReceiveQuota.Value.ToMB()
}
if (($Mbx.UseDatabaseQuotaDefaults -eq $false) -and ($mbx.ProhibitSendReceiveQuota.value -eq $null))
{
$ProhibitSendReceiveQuota = "Unlimited"
}
if (($Mbx.UseDatabaseQuotaDefaults -eq $false) -and ($mbx.ProhibitSendReceiveQuota.value -ne $null))
{
$ProhibitSendReceiveQuota = $Mbx.ProhibitSendReceiveQuota.Value.ToMB()
}
if ($Mbx.ArchiveName.count -eq "0")
{
$ArchiveTotalItemSize = $null
$ArchiveTotalItemCount = $null
}
if ($Mbx.ArchiveName -ge "1")
{
$MbxArchiveStats = Get-mailboxstatistics $Mbx.distinguishedname -Archive -WarningAction SilentlyContinue
$ArchiveTotalItemSize = $MbxArchiveStats.TotalItemSize
$ArchiveTotalItemCount = $MbxArchiveStats.BigFunnelMessageCount
}

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "Display Name" -Value $mbx.displayname
$userObj | Add-Member NoteProperty -Name "Alias" -Value $Mbx.Alias
$userObj | Add-Member NoteProperty -Name "SamAccountName" -Value $Mbx.SamAccountName
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $Mbx.RecipientTypeDetails
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $Mbx.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $Mbx.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Email Addresses" -Value ($Mbx.EmailAddresses.smtpaddress -join ";")
$userObj | Add-Member NoteProperty -Name "Database" -Value $mbx.Database
$userObj | Add-Member NoteProperty -Name "ServerName" -Value $mbx.ServerName
if($Stats)
{
$userObj | Add-Member NoteProperty -Name "TotalItemSize" -Value $Stats.TotalItemSize.Value.ToMB()
$userObj | Add-Member NoteProperty -Name "ItemCount" -Value $Stats.ItemCount
$userObj | Add-Member NoteProperty -Name "DeletedItemCount" -Value $Stats.DeletedItemCount
$userObj | Add-Member NoteProperty -Name "TotalDeletedItemSize" -Value $Stats.TotalDeletedItemSize.Value.ToMB()
}
$userObj | Add-Member NoteProperty -Name "ProhibitSendReceiveQuota-In-MB" -Value $ProhibitSendReceiveQuota
$userObj | Add-Member NoteProperty -Name "UseDatabaseQuotaDefaults" -Value $Mbx.UseDatabaseQuotaDefaults
$userObj | Add-Member NoteProperty -Name "LastLogonTime" -Value $Stats.LastLogonTime
$userObj | Add-Member NoteProperty -Name "ArchiveName" -Value ($Mbx.ArchiveName -join ";")
$userObj | Add-Member NoteProperty -Name "ArchiveStatus" -Value $Mbx.ArchiveStatus
$userObj | Add-Member NoteProperty -Name "ArchiveState" -Value $Mbx.ArchiveState 
$userObj | Add-Member NoteProperty -Name "ArchiveQuota" -Value $Mbx.ArchiveQuota
$userObj | Add-Member NoteProperty -Name "ArchiveTotalItemSize" -Value $ArchiveTotalItemSize
$userObj | Add-Member NoteProperty -Name "ArchiveTotalItemCount" -Value $ArchiveTotalItemCount

$output += $UserObj  
# Update Counters and Write Progress
$i++
if ($AllMailbox.Count -ge 1)
{
Write-Progress -Activity "Scanning Mailboxes . . ." -Status "Scanned: $i of $($AllMailbox.Count)" -PercentComplete ($i/$AllMailbox.Count*100)
}
}


$output | Export-csv -Path $CSVfile -NoTypeInformation -Encoding UTF8

;Break}

4 {
$i = 0 
$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\DG.csv)" 

$MailboxName = Read-Host "Enter the Mailbox name or Range (Eg. Mailboxname , Mi*,*Mik)"

$AllMailbox = Get-mailbox $MailboxName -resultsize unlimited

Foreach($Mbx in $AllMailbox)

{

$Stats = Get-mailboxStatistics -Identity $Mbx.distinguishedname -WarningAction SilentlyContinue



if (($Mbx.UseDatabaseQuotaDefaults -eq $true) -and (Get-MailboxDatabase $mbx.Database).ProhibitSendReceiveQuota.value -eq $null)
{
$ProhibitSendReceiveQuota = "Unlimited"
}
if (($Mbx.UseDatabaseQuotaDefaults -eq $true) -and (Get-MailboxDatabase $mbx.Database).ProhibitSendReceiveQuota.value -ne $null)
{
$ProhibitSendReceiveQuota = (Get-MailboxDatabase $mbx.Database).ProhibitSendReceiveQuota.Value.ToMB()
}
if (($Mbx.UseDatabaseQuotaDefaults -eq $false) -and ($mbx.ProhibitSendReceiveQuota.value -eq $null))
{
$ProhibitSendReceiveQuota = "Unlimited"
}
if (($Mbx.UseDatabaseQuotaDefaults -eq $false) -and ($mbx.ProhibitSendReceiveQuota.value -ne $null))
{
$ProhibitSendReceiveQuota = $Mbx.ProhibitSendReceiveQuota.Value.ToMB()
}
if ($Mbx.ArchiveName.count -eq "0")
{
$ArchiveTotalItemSize = $null
$ArchiveTotalItemCount = $null
}
if ($Mbx.ArchiveName -ge "1")
{
$MbxArchiveStats = Get-mailboxstatistics $Mbx.distinguishedname -Archive -WarningAction SilentlyContinue
$ArchiveTotalItemSize = $MbxArchiveStats.TotalItemSize
$ArchiveTotalItemCount = $MbxArchiveStats.BigFunnelMessageCount
}


$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "Display Name" -Value $mbx.displayname
$userObj | Add-Member NoteProperty -Name "Alias" -Value $Mbx.Alias
$userObj | Add-Member NoteProperty -Name "SamAccountName" -Value $Mbx.SamAccountName
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $Mbx.RecipientTypeDetails
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $Mbx.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $Mbx.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Email Addresses" -Value ($Mbx.EmailAddresses.smtpaddress -join ";")
$userObj | Add-Member NoteProperty -Name "Database" -Value $mbx.Database
$userObj | Add-Member NoteProperty -Name "ServerName" -Value $mbx.ServerName
if($Stats)
{
$userObj | Add-Member NoteProperty -Name "TotalItemSize" -Value $Stats.TotalItemSize.Value.ToMB()
$userObj | Add-Member NoteProperty -Name "ItemCount" -Value $Stats.ItemCount
$userObj | Add-Member NoteProperty -Name "DeletedItemCount" -Value $Stats.DeletedItemCount
$userObj | Add-Member NoteProperty -Name "TotalDeletedItemSize" -Value $Stats.TotalDeletedItemSize.Value.ToMB()
}
$userObj | Add-Member NoteProperty -Name "ProhibitSendReceiveQuota-In-MB" -Value $ProhibitSendReceiveQuota
$userObj | Add-Member NoteProperty -Name "UseDatabaseQuotaDefaults" -Value $Mbx.UseDatabaseQuotaDefaults
$userObj | Add-Member NoteProperty -Name "LastLogonTime" -Value $Stats.LastLogonTime
$userObj | Add-Member NoteProperty -Name "ArchiveName" -Value ($Mbx.ArchiveName -join ";")
$userObj | Add-Member NoteProperty -Name "ArchiveStatus" -Value $Mbx.ArchiveStatus
$userObj | Add-Member NoteProperty -Name "ArchiveState" -Value $Mbx.ArchiveState 
$userObj | Add-Member NoteProperty -Name "ArchiveQuota" -Value $Mbx.ArchiveQuota
$userObj | Add-Member NoteProperty -Name "ArchiveTotalItemSize" -Value $ArchiveTotalItemSize
$userObj | Add-Member NoteProperty -Name "ArchiveTotalItemCount" -Value $ArchiveTotalItemCount

$output += $UserObj  
# Update Counters and Write Progress
$i++
if ($AllMailbox.Count -ge 1)
{
Write-Progress -Activity "Scanning Mailboxes . . ." -Status "Scanned: $i of $($AllMailbox.Count)" -PercentComplete ($i/$AllMailbox.Count*100)
}
}

$output | Export-csv -Path $CSVfile -NoTypeInformation -Encoding UTF8

;Break}

5 {

$MailboxName = Read-Host "Enter the Mailbox name or Range (Eg. Mailboxname , Mi*,*Mik)"

$AllMailbox = Get-mailbox $MailboxName -resultsize unlimited

Foreach($Mbx in $AllMailbox)

{

$Stats = Get-mailboxStatistics -Identity $Mbx.distinguishedname -WarningAction SilentlyContinue

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "Display Name" -Value $mbx.displayname
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $mbx.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "TotalItemSize" -Value $Stats.TotalItemSize
$userObj | Add-Member NoteProperty -Name "ItemCount" -Value $Stats.ItemCount

Write-Output $Userobj

}

;Break}

6 {
$i = 0 
$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\Report.csv)" 

$AllMailbox = Get-mailbox -resultsize unlimited

Foreach($Mbx in $AllMailbox)

{

$Stats = Get-mailboxStatistics -Identity $Mbx.distinguishedname -WarningAction SilentlyContinue

if ($Mbx.ArchiveName.count -eq "0")
{
$ArchiveTotalItemSize = $null
$ArchiveTotalItemCount = $null
}
if ($Mbx.ArchiveName -ge "1")
{
$MbxArchiveStats = Get-mailboxstatistics $Mbx.distinguishedname -Archive -WarningAction SilentlyContinue
$ArchiveTotalItemSize = $MbxArchiveStats.TotalItemSize
$ArchiveTotalItemCount = $MbxArchiveStats.BigFunnelMessageCount
}

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "Display Name" -Value $mbx.displayname
$userObj | Add-Member NoteProperty -Name "Alias" -Value $Mbx.Alias
$userObj | Add-Member NoteProperty -Name "SamAccountName" -Value $Mbx.SamAccountName
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $Mbx.RecipientTypeDetails
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $Mbx.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $Mbx.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Email Addresses" -Value ($Mbx.EmailAddresses -join ";")
$userObj | Add-Member NoteProperty -Name "Database" -Value $Stats.Database
$userObj | Add-Member NoteProperty -Name "ServerName" -Value $Stats.ServerName
$userObj | Add-Member NoteProperty -Name "TotalItemSize" -Value $Stats.TotalItemSize
$userObj | Add-Member NoteProperty -Name "ItemCount" -Value $Stats.ItemCount
$userObj | Add-Member NoteProperty -Name "DeletedItemCount" -Value $Stats.DeletedItemCount
$userObj | Add-Member NoteProperty -Name "TotalDeletedItemSize" -Value $Stats.TotalDeletedItemSize
$userObj | Add-Member NoteProperty -Name "ProhibitSendReceiveQuota-In-MB" -Value $Mbx.ProhibitSendReceiveQuota
$userObj | Add-Member NoteProperty -Name "UseDatabaseQuotaDefaults" -Value $Mbx.UseDatabaseQuotaDefaults
$userObj | Add-Member NoteProperty -Name "LastLogonTime" -Value $Stats.LastLogonTime
$userObj | Add-Member NoteProperty -Name "ArchiveName" -Value ($Mbx.ArchiveName -join ";")
$userObj | Add-Member NoteProperty -Name "ArchiveStatus" -Value $Mbx.ArchiveStatus
$userObj | Add-Member NoteProperty -Name "ArchiveState" -Value $Mbx.ArchiveState 
$userObj | Add-Member NoteProperty -Name "ArchiveQuota" -Value $Mbx.ArchiveQuota
$userObj | Add-Member NoteProperty -Name "ArchiveTotalItemSize" -Value $ArchiveTotalItemSize
$userObj | Add-Member NoteProperty -Name "ArchiveTotalItemCount" -Value $ArchiveTotalItemCount

$output += $UserObj  
# Update Counters and Write Progress
$i++
if ($AllMailbox.Count -ge 1)
{
Write-Progress -Activity "Scanning Mailboxes . . ." -Status "Scanned: $i of $($AllMailbox.Count)" -PercentComplete ($i/$AllMailbox.Count*100)
}
}

$output | Export-csv -Path $CSVfile -NoTypeInformation -Encoding UTF8

;Break}

7 {
$i = 0
$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\DG.csv)" 

$MailboxName = Read-Host "Enter the Mailbox name or Range (Eg. Mailboxname , Mi*,*Mik)"

$AllMailbox = Get-mailbox $MailboxName -resultsize unlimited

Foreach($Mbx in $AllMailbox)

{

$Stats = Get-mailboxStatistics -Identity $Mbx.distinguishedname -WarningAction SilentlyContinue

if ($Mbx.ArchiveName.count -eq "0")
{
$ArchiveTotalItemSize = $null
$ArchiveTotalItemCount = $null
}
if ($Mbx.ArchiveName -ge "1")
{
$MbxArchiveStats = Get-mailboxstatistics $Mbx.distinguishedname -Archive -WarningAction SilentlyContinue
$ArchiveTotalItemSize = $MbxArchiveStats.TotalItemSize
$ArchiveTotalItemCount = $MbxArchiveStats.BigFunnelMessageCount
}

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "Display Name" -Value $mbx.displayname
$userObj | Add-Member NoteProperty -Name "Alias" -Value $Mbx.Alias
$userObj | Add-Member NoteProperty -Name "SamAccountName" -Value $Mbx.SamAccountName
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $Mbx.RecipientTypeDetails
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $Mbx.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $Mbx.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Email Addresses" -Value ($Mbx.EmailAddresses -join ";")
$userObj | Add-Member NoteProperty -Name "Database" -Value $Stats.Database
$userObj | Add-Member NoteProperty -Name "ServerName" -Value $Stats.ServerName
$userObj | Add-Member NoteProperty -Name "TotalItemSize" -Value $Stats.TotalItemSize
$userObj | Add-Member NoteProperty -Name "ItemCount" -Value $Stats.ItemCount
$userObj | Add-Member NoteProperty -Name "DeletedItemCount" -Value $Stats.DeletedItemCount
$userObj | Add-Member NoteProperty -Name "TotalDeletedItemSize" -Value $Stats.TotalDeletedItemSize
$userObj | Add-Member NoteProperty -Name "ProhibitSendReceiveQuota-In-MB" -Value $Mbx.ProhibitSendReceiveQuota
$userObj | Add-Member NoteProperty -Name "UseDatabaseQuotaDefaults" -Value $Mbx.UseDatabaseQuotaDefaults
$userObj | Add-Member NoteProperty -Name "LastLogonTime" -Value $Stats.LastLogonTime
$userObj | Add-Member NoteProperty -Name "ArchiveName" -Value ($Mbx.ArchiveName -join ";")
$userObj | Add-Member NoteProperty -Name "ArchiveStatus" -Value $Mbx.ArchiveStatus
$userObj | Add-Member NoteProperty -Name "ArchiveState" -Value $Mbx.ArchiveState 
$userObj | Add-Member NoteProperty -Name "ArchiveQuota" -Value $Mbx.ArchiveQuota
$userObj | Add-Member NoteProperty -Name "ArchiveTotalItemSize" -Value $ArchiveTotalItemSize
$userObj | Add-Member NoteProperty -Name "ArchiveTotalItemCount" -Value $ArchiveTotalItemCount

$output += $UserObj  
# Update Counters and Write Progress
$i++
if ($AllMailbox.Count -ge 1)
{
Write-Progress -Activity "Scanning Mailboxes . . ." -Status "Scanned: $i of $($AllMailbox.Count)" -PercentComplete ($i/$AllMailbox.Count*100) -ErrorAction SilentlyContinue
}
}

$output | Export-csv -Path $CSVfile -NoTypeInformation -Encoding UTF8

;Break}

8 {
    $i = 0
    
    $inputCSVFile = Read-Host "Enter the Path of CSV file containing the users (Eg. C:\inputUsers.csv)"
    $outputCSVFile = Read-Host "Enter the Path of CSV file (Eg. C:\Report.csv)"
    
    $AllMailbox = Import-Csv -Path $inputCSVFile
    
    Foreach($user in $allUsers)
    
    {
    
    $Mbx = Get-mailbox $user.logonName -resultsize unlimited
    $Stats = Get-mailboxStatistics -Identity $user.logonName -WarningAction SilentlyContinue
    $AdUserLastLogon = Get-ADUser -Identity $user.logonName -Properties LastLogonTimeStamp | Select-Object @{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd_hh:mm:ss')}}
    
    
    
    
    if (($Mbx.UseDatabaseQuotaDefaults -eq $true) -and (Get-MailboxDatabase $mbx.Database).ProhibitSendReceiveQuota.value -eq $null)
    {
    $ProhibitSendReceiveQuota = "Unlimited"
    }
    if (($Mbx.UseDatabaseQuotaDefaults -eq $true) -and (Get-MailboxDatabase $mbx.Database).ProhibitSendReceiveQuota.value -ne $null)
    {
    $ProhibitSendReceiveQuota = (Get-MailboxDatabase $mbx.Database).ProhibitSendReceiveQuota.Value.ToMB()
    }
    if (($Mbx.UseDatabaseQuotaDefaults -eq $false) -and ($mbx.ProhibitSendReceiveQuota.value -eq $null))
    {
    $ProhibitSendReceiveQuota = "Unlimited"
    }
    if (($Mbx.UseDatabaseQuotaDefaults -eq $false) -and ($mbx.ProhibitSendReceiveQuota.value -ne $null))
    {
    $ProhibitSendReceiveQuota = $Mbx.ProhibitSendReceiveQuota.Value.ToMB()
    }
    if ($Mbx.ArchiveName.count -eq "0")
    {
    $ArchiveTotalItemSize = $null
    $ArchiveTotalItemCount = $null
    }
    if ($Mbx.ArchiveName -ge "1")
    {
    $MbxArchiveStats = Get-mailboxstatistics $Mbx.distinguishedname -Archive -WarningAction SilentlyContinue
    $ArchiveTotalItemSize = $MbxArchiveStats.TotalItemSize
    $ArchiveTotalItemCount = $MbxArchiveStats.BigFunnelMessageCount
    }
    
    $userObj = New-Object PSObject
    
    $userObj | Add-Member NoteProperty -Name "Display Name" -Value $mbx.displayname
    $userObj | Add-Member NoteProperty -Name "Alias" -Value $Mbx.Alias
    $userObj | Add-Member NoteProperty -Name "SamAccountName" -Value $Mbx.SamAccountName
    $userObj | Add-Member NoteProperty -Name "RecipientType" -Value $Mbx.RecipientTypeDetails
    $userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $Mbx.OrganizationalUnit
    $userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $Mbx.PrimarySmtpAddress
    $userObj | Add-Member NoteProperty -Name "Email Addresses" -Value ($Mbx.EmailAddresses.smtpaddress -join ";")
    $userObj | Add-Member NoteProperty -Name "Office" -Value $mbx.Office
    $userObj | Add-Member NoteProperty -Name "Database" -Value $mbx.Database
    $userObj | Add-Member NoteProperty -Name "ServerName" -Value $mbx.ServerName
    $userObj | Add-Member NoteProperty -Name "Disabled" -Value $mbx.ExchangeUserAccountControl
    $userObj | Add-Member NoteProperty -Name "LitHold" -Value $mbx.LitigationHoldEnabled
    if($Stats)
    {
    $userObj | Add-Member NoteProperty -Name "TotalItemSize" -Value $Stats.TotalItemSize.Value.ToMB()
    $userObj | Add-Member NoteProperty -Name "ItemCount" -Value $Stats.ItemCount
    $userObj | Add-Member NoteProperty -Name "DeletedItemCount" -Value $Stats.DeletedItemCount
    $userObj | Add-Member NoteProperty -Name "TotalDeletedItemSize" -Value $Stats.TotalDeletedItemSize.Value.ToMB()
    }
    $userObj | Add-Member NoteProperty -Name "ProhibitSendReceiveQuota-In-MB" -Value $ProhibitSendReceiveQuota
    $userObj | Add-Member NoteProperty -Name "UseDatabaseQuotaDefaults" -Value $Mbx.UseDatabaseQuotaDefaults
    $userObj | Add-Member NoteProperty -Name "LastLogonTime" -Value $Stats.LastLogonTime
    $userObj | Add-Member NoteProperty -Name "LastLogonTime(AD)" -Value $AdUserLastLogon.Stamp
    $userObj | Add-Member NoteProperty -Name "ArchiveName" -Value ($Mbx.ArchiveName -join ";")
    $userObj | Add-Member NoteProperty -Name "ArchiveStatus" -Value $Mbx.ArchiveStatus
    $userObj | Add-Member NoteProperty -Name "ArchiveState" -Value $Mbx.ArchiveState 
    $userObj | Add-Member NoteProperty -Name "ArchiveQuota" -Value $Mbx.ArchiveQuota
    $userObj | Add-Member NoteProperty -Name "ArchiveTotalItemSize" -Value $ArchiveTotalItemSize
    $userObj | Add-Member NoteProperty -Name "ArchiveTotalItemCount" -Value $ArchiveTotalItemCount
    
    
    
    
    $output += $UserObj  
    # Update Counters and Write Progress
    $i++
    if ($AllMailbox.Count -ge 1)
    {
    Write-Progress -Activity "Scanning Mailboxes . . ." -Status "Scanned: $i of $($AllMailbox.Count)" -PercentComplete ($i/$AllMailbox.Count*100)
    }
    }
    
    
    $output | Export-csv -Path $outputCSVfile -NoTypeInformation -Encoding UTF8
    
    ;Break}

Default {Write-Host "No matches found , Enter Options 1 or 2" -ForeGround "red"}

}