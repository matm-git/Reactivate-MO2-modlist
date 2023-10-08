$config = Get-Content -Raw -Path config.json | ConvertFrom-Json



# Activate or deactivate plugins which are part of targeted mod
function switchPlugins {
    param (
        [String]$modname,
        [String]$type,
        [String]$folder
    )
    $verbose = $false

    # Add plugins to plugin file to activate the plugins
    $pluginFilename = "plugins.txt"
    $pluginPath = "{0}{1}" -f $folder, $pluginFilename

    $LoadorderFilename = "loadorder.txt"
    $LoadorderPath = "{0}{1}" -f $folder, $LoadorderFilename

    if ($verbose) { write-Host $type " plugins for mod " $modname }

    $modname_masked = $modname -replace '(\[|\])', '`$1'        # Powershell does not like those braces: [ ] So you need to mask them
    $pluginList = Get-ChildItem -Path ($config.modsDirectory+$modname_masked+"\*") -Include "*.esm", "*.esp" -Name
    # Get all .esp's for the mod
    foreach ($plugin in $pluginList) { 
        if ($verbose) { write-Host ("Added plugin "+$plugin +" to "+$pluginFilename + " and "+$LoadorderFilename) }
        # Remove the plugins from plugins.txt and loadorder.txt first
        (Get-Content $pluginPath) | Where-Object { $_ -notmatch ("^\*?"+[regex]::Escape($plugin) + "$") } | Set-Content $pluginPath -Force
        (Get-Content $LoadorderPath) | Where-Object { $_ -notmatch ([regex]::Escape($plugin) + "$") } | Set-Content $LoadorderPath -Force

        # Add the plugin if it is to be added
        if ($type -eq 'activate')  {    
            Add-Content -Path $pluginPath -Value ("*$plugin") -Force
            Add-Content -Path $LoadorderPath -Value $plugin -Force
            if ($verbose) { write-Host ("Added plugin "+$plugin +" to "+$pluginFilename + " and "+$LoadorderFilename) }
        }
    }
}

function createBackup {
    param (
        [String]$folder
    )   
    $verbose = $true
    $files = @("modlist.txt", "plugins.txt", "loadorder.txt")

    foreach ($file in $files) {
        $backupFilename = $file + "." + (Get-Date -Format "yyyy_MM_dd_HH_mm_ss")
        $filePath = "{0}{1}" -f $folder, $file
        $backupPath = "{0}{1}" -f $folder, $backupfilename
        if ($verbose) { write-Host "Copying file from " $filePath " to " $backupPath }
        Copy-Item -Path $filePath -Destination $backupPath
    }
    Write-Host "Backup created."
}


# Disable unwanted mods and enable wanted mods for main profile
function ActivateTargetMods {
    param (
        [array]$activateMods,
        [array]$deactivateMods,
        [String]$folder
    )
    $verbose = $false
    $filename = "modlist.txt"
    $path = "{0}{1}" -f $folder, $filename

    $content = Get-Content -Path $path
    foreach ($searchString in $deactivateMods) {
        $matchingSubfolders = Get-ChildItem -Path $config.modsDirectory -Directory -Filter ("*$searchString*")
        foreach ($mod in $matchingSubfolders) {           # Search for all mods related to the searchstring
            if ($verbose) { write-Host "Deactivating "$mod.Name }
            switchPlugins -modname $mod.Name -type 'deactivate' -folder $folder    # Then find related plugins to deactivate them in plugins.txt and loadorder.txt
        }
        $content = $content -replace [regex]::Escape('+' + $searchString), ('-' + $searchString)   # Then generally deactivate all that match this string in modlist.txt
    }

    # Activate all mods (left side in MO2) that match the pattern given in the config  
    foreach ($searchString in $activateMods) {
        #$matchingRows = Select-String -Path $folder -Pattern $searchString
        $matchingSubfolders = Get-ChildItem -Path $config.modsDirectory -Directory -Filter ("*$searchString*")
        foreach ($mod in $matchingSubfolders) {           # Search for all mods related to the searchstring
            if ($verbose) { write-Host "Activating "$mod.Name }
            switchPlugins -modname $mod.Name -type 'activate' -folder $folder     # Then find related plugins to activate them  in plugins.txt and loadorder.txt
        }
        $content = $content -replace [regex]::Escape('-' + $searchString), ('+' + $searchString)        # Then generally activate all that match this string in modlist.txt
    }
    $content | Set-Content -Path $path
    Write-Host "Deactivated unwanted mods and activated desired mods."
}

# Change settings to have local savegames per profile, if required
function ChangeSettings {
    $filename = "settings.ini"
    $backupfilename = $filename + "." + (Get-Date -Format "yyyy_MM_dd_HH_mm_ss")

    # Build the full path and the path for the backup
    $path = "{0}{1}" -f $config.folderDefaultProfile, $filename
    $backuppath = "{0}{1}" -f $config.folderDefaultProfile, $backupfilename

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
    if (Test-Path -Path $config.folderAlternateProfile -PathType Container) {
        Write-Host "Recreating alternate profile located at "$config.folderAlternateProfile
        #Remove-Item -LiteralPath $config.folderAlternateProfile -Force -Recurse
        Get-ChildItem $config.folderAlternateProfile -File | Remove-Item -Force
        #Copy-Item -Path $config.folderDefaultProfile -Destination $config.folderAlternateProfile -Recurse
    } else {
        Write-Host "Creating new profile at "$config.folderAlternateProfile
        New-Item -ItemType Directory -Path $config.folderAlternateProfile
    }
    Get-ChildItem $config.folderDefaultProfile -File | Copy-Item -Destination $config.folderAlternateProfile      

}

# Adjust plugin order
function AdjustPluginOrder {
    param (
        [String]$folder,
        [array]$pluginDependencies,
        [int]$iteration = 0
    )
    $filename = "loadorder.txt"
    $verbose = $false

    $path = "{0}{1}" -f $folder, $filename
    # Load the contents of the file into a string variable.
    $content = Get-Content -Path $path
    foreach ($plugin in $pluginDependencies) {     
        $content = Get-Content -Path $path 
        $lineIndex = $content.IndexOf($plugin[1])
        if ($lineIndex -ge 0) {
            if ($verbose) { write-Host ("Found "+$plugin[1]+" in line $lineIndex. Adding "+$plugin[0]+" after it.") }
            #$content = $content | Where-Object { $_ -notmatch ([regex]::Escape($plugin[0])) }       # Remove the plugin which is being moved from the old position
            $content = $content | Where-Object { $_ -ne $plugin[0] }       # Remove the plugin which is being moved from the old position
            $lineIndex = $content.IndexOf($plugin[1])                                               # Due to the removal the position may have changed
            $newFileContent = $content[0..$lineIndex] + $plugin[0] + $content[($lineIndex+1)..($content.Length - 1)]        # Create a new array with the plugin placed after the found one
            $newFileContent | Set-Content -Path $path -Force                       # Write the modified content back to the file
        }
    }
}


function validatePluginDependencies {
    param (
        [array]$pluginDependencies
    )

    # Create a hash set to store unique values
    $uniqueValues = @{}

    # Initialize a flag for duplicate detection
    $hasDuplicates = $false

    # Iterate through the array and check for duplicates
    foreach ($entry in $pluginDependencies) {
        $valueToCheck = $entry[1]

        # Check if the value has already been encountered
        if ($uniqueValues.ContainsKey($valueToCheck)) {
            $hasDuplicates = $true
            Write-Host "Duplicate found: $valueToCheck"
        } else {
            $uniqueValues[$valueToCheck] = $true
        }
    }

    # Check if any duplicates were found
    if ($hasDuplicates) {
        Write-Host "The plugin sorting must be unique! The script will abend here. Please correct the variable pluginDependencies in config.json so that each plugin has a unique predecessor. Then rerun."
        return $false
    } else {
        Write-Host "Everything okay, no duplicates found in pluginDependencies. Starting with activation and sorting."
        return $true
    }
}


# Main part of the script
if (validatePluginDependencies -pluginDependencies $config.pluginDependenciesDefaultProfile) {
    createBackup $config.folderDefaultProfile
    ActivateTargetMods -activateMods $config.activateModsDefaultProfile -deactivateMods $config.deactivateModsDefaultProfile -folder $config.folderDefaultProfile
    AdjustPluginOrder -folder $config.folderDefaultProfile -pluginDependencies $config.pluginDependenciesDefaultProfile
    ChangeSettings

    if ($config.folderAlternateProfile -ne "" -and $config.folderAlternateProfile -ne $null -and (validatePluginDependencies -pluginDependencies $config.pluginDependenciesAlternateProfile)) {        # Only create alternate profile if the config parameter is set to use an alternate profile
        RecreateAlternateProfile 
        createBackup $config.folderAlternateProfile
        ActivateTargetMods -activateMods $config.activateModsAlternateProfile -deactivateMods $config.deactivateModsAlternateProfile -folder $config.folderAlternateProfile
        AdjustPluginOrder -folder $config.folderAlternateProfile -pluginDependencies $config.pluginDependenciesDefaultProfile
        AdjustPluginOrder -folder $config.folderAlternateProfile -pluginDependencies $config.pluginDependenciesAlternateProfile
    }
}
