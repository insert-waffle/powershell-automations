$SiteURL = "https://cfecontracting.sharepoint.com/sites/<site url here>"
$DeletedBy = "<user email here>"
$DeletedOnDate = "MM/DD/YYYY" # has to be in format MM/DD/YYYY, example for the 12th of january 2022: 01/12/2022

if (Get-Module -ListAvailable -Name PnP.PowerShell) {

    Write-Host "LOG - Module exists, connecting to site."
    Connect-PnPOnline -Url $SiteURL -Interactive

} else {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

    if( $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)  ) {
        Write-Host "LOG - Module does not exist. You're in elevated Powershell, good. I'm installing the module for you."
        Install-Module PnP.PowerShell
    } else {
        Write-Host "LOG - Please install module PnP.PowerShell in elevated Powershell window. Run command: Install-Module PnP.PowerShell"
    }

}

$DeletedItems = Get-PnPRecycleBinItem | ? {($_.DeletedByEmail -eq $DeletedBy) -and ($_.DeletedDate -like "*$DeletedOnDate*")}

$DeletedItems | ForEach-Object {
    
    $logDate = (Get-Date -Format "MM/dd/yyyy HH:mm")
    $dir = $_.DirName
    $title = $_.Title
    $path = "/$dir/$title"

    $fileExists = Get-PnPFile -url "$path" -ErrorAction SilentlyContinue

    if ($fileExists) {

        Write-Host "$title exists, skipping restore"

    } else {

        Write-Host "$logDate - Path " -NoNewline
        Write-Host "$path" -ForegroundColor Red -NoNewLine
        Write-Host " doesnt exist, restoring in original location."
        $_ | Restore-PnpRecycleBinItem -Force

    }
}