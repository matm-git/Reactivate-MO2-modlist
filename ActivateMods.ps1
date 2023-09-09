$config = Get-Content -Raw -Path config.json | ConvertFrom-Json

# Disable unwanted mods and enable wanted mods for main profile
function ReactivateTargetMods {
    param (
        [String]$path,
        [array]$deactivateMods,
        [array]$activateMods
    )
    $filename = "modlist.txt"
    $backupfilename = $filename + "." + (Get-Date -Format "yyyy_MM_dd_HH_mm_ss")

    # Build the full path and the path for the backup
    $path = "{0}{1}" -f $path, $filename
    $backuppath = "{0}{1}" -f $path, $backupfilename

    # Create a backup first
    Copy-Item -Path $path -Destination $backuppath

    $content = Get-Content -Path $path
    foreach ($searchString in $deactivateMods) {
        $content = $content -replace [regex]::Escape('+' + $searchString), ('-' + $searchString)
    }
    foreach ($searchString in $activateMods) {
        $content = $content -replace [regex]::Escape('-' + $searchString), ('+' + $searchString)
    }
    $content | Set-Content -Path $path
    Write-Host "Backup created, deactivated unwanted mods and activated desired mods."
}

# Change settings to have local savegames per profile, if required
function ChangeSettings {
    param (
        [String]$path
    )
    $filename = "settings.ini"
    $backupfilename = $filename + "." + (Get-Date -Format "yyyy_MM_dd_HH_mm_ss")

    # Build the full path and the path for the backup
    $path = "{0}{1}" -f $path, $filename
    $backuppath = "{0}{1}" -f $path, $backupfilename

    # Check first if the setting needs to be updated
    $content = Get-Content -Path $path
    $istStringVorhanden = $content -match [regex]::Escape("LocalSaves=false")
    $istStringVorhanden = [bool]$istStringVorhanden

    if ($istStringVorhanden) {
        # Create a backup first
        Copy-Item -Path $path -Destination $backuppath

        $content = $content -replace [regex]::Escape("LocalSaves=false"), "LocalSaves=true"
        $content | Set-Content -Path $path
        Write-Host "Local savegames for profiles enabled"
    } else {
        Write-Host "Local savegames for profiles were already enabled, no action taken"
    }
}

function RecreateAlternateProfile {
       param (
        [String]$path,
        [String]$pathAlternateProfile
    ) 
    Remove-Item -LiteralPath $config.pathAlternateProfile -Force -Recurse
    Copy-Item -Path $path -Destination $pathAlternateProfile -Recurse
}

# Main part of the script
ReactivateTargetMods -path $config.path -activateMods $activateMods -deactivateMods $deactivateMods
ChangeSettings -path $config.path

if ($config.pathAlternateProfile -ne "" -and $config.pathAlternateProfile -ne $null) {        # Only create alternate profile if the config parameter is set to use an alternate profile
    RecreateAlternateProfile -path $config.path -pathAlternateProfile $config.pathAlternateProfile
    ReactivateTargetMods -path $config.pathAlternateProfile -activateMods $config.activateModsAlternateProfile -deactivateMods $config.deactivateModsAlternateProfile
}



