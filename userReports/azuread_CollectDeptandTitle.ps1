$output = @()
$i = 0

$upncsv = Import-Csv C:\temp\mobile_device_user_export.csv
$CSVfile = "C:\temp\mobile_device_user_export_completed.csv"



Foreach($user in $upncsv) {

    $upn = $user.upn

    $msoluserinfo = Get-MsolUser -UserPrincipalName $upn


$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "Display Name" -Value $msoluserinfo.displayname
$userObj | Add-Member NoteProperty -Name "UPN" -Value $msoluserinfo.UserPrincipalName
$userObj | Add-Member NoteProperty -Name "Department" -Value $msoluserinfo.Department
$userObj | Add-Member NoteProperty -Name "Title" -Value $msoluserinfo.Title


$output += $UserObj
# Update Counters and Write Progress
$i++
if ($upncsv.Count -ge 1)
{
Write-Progress -Activity "Exporting Results . . . " -Status "Scanned: $i of $($upncsv.Count)" -PercentComplete ($i/$upncsv.Count*100)
}

}

$output | Export-csv -Path $CSVfile -NoTypeInformation -Encoding UTF8