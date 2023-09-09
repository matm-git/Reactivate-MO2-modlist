$config = Get-Content -Raw -Path config.json | ConvertFrom-Json


# Activate plugins
function ActivatePlugins {
    param (
        [String]$folder,
        [String]$lastModlistPlugin
    )
    $filename = "plugins.txt"
    $backupfilename = $filename + "." + (Get-Date -Format "yyyy_MM_dd_HH_mm_ss")
    $verbose = $false

    #Create the complete path for the backup.
    $path = "{0}{1}" -f $folder, $filename
    $backuppath = "{0}{1}" -f $folder, $backupfilename

    $content = Get-Content -Path $path
    Move-Item -Path $path -Destination $backuppath

        $endOfModlist = $false
        foreach ($line in $content) {        ## Iterate through each lines of the load order
            if (($line -eq $lastModlistPlugin) -or ($line -eq ("*"+$lastModlistPlugin))) {
                $endOfModlist = $true
            }
            if (($endOfModlist) -and ($line[0] -ne "*")) { 
                Add-Content -Path $path -Value ("*"+$line)
            } else {
                Add-Content -Path $path -Value $line
            }

        }
    Write-Host "Plugins activated."
}

# Adjust plugin order
function AdjustPluginOrder {
    param (
        [String]$folder,
        [array]$pluginDependencies
    )
    $filename = "loadorder.txt"
    $backupfilename = $filename + "." + (Get-Date -Format "yyyy_MM_dd_HH_mm_ss")
    $verbose = $false

    #Create the complete path for the backup.
    $path = "{0}{1}" -f $folder, $filename
    $backuppath = "{0}{1}" -f $folder, $backupfilename

    # Load the contents of the file into a string variable.
    $content = Get-Content -Path $path
    ##write-Host $path  $backuppath
    Move-Item -Path $path -Destination $backuppath

        foreach ($line in $content) {        ## Iterate through each lines of the load order
            $skipline = $false
            foreach ($plugin in $pluginDependencies) {      ## Check if the line needs to be replace
                if ($line -eq $plugin[1]) {
                    if ($skipline -eq $false) {
                        if ($verbose) { write-Host $plugin[1] }
                        Add-Content -Path $path -Value $plugin[1]
                        $skipline = $true
                    }
                    if ($verbose) { write-Host $plugin[0] }
                    Add-Content -Path $path -Value $plugin[0]  
                } elseif ($line -eq $plugin[0]) {
                    $skipline = $true
                }
            }

            if ($skipline) {
                 if ($verbose) { write-Host "Skipping line: " $line }
                $skipline = $false
            } else {
                 if ($verbose) { write-Host $line }
                Add-Content -Path $path -Value $line
            }
        }
    Write-Host "Plugin load order adjusted."
}



# Main part of the script
Write-Host "Activating Plugins for main profile"
ActivatePlugins -folder $config.path -lastModlistPlugin $config.lastModlistPlugin
AdjustPluginOrder -folder $config.path -pluginDependencies $config.pluginDependencies

if ($config.pathAlternateProfile -ne "" -and $config.pathAlternateProfile -ne $null) {        # Only sort plugins for alternate profile if the config parameter is set to use an alternate profile
    Write-Host "Activating Plugins for alternate profile"
    ActivatePlugins -folder $config.pathAlternateProfile -lastModlistPlugin $config.lastModlistPlugin
    AdjustPluginOrder -folder $config.pathAlternateProfile -pluginDependencies $config.pluginDependencies
    AdjustPluginOrder -folder $config.pathAlternateProfile -pluginDependencies $config.pluginDependenciesAlternateProfile
}

