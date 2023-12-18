function activateMods($config, $targetProfile, $sourceProfile) {
    # Start-Process -FilePath "powershell.exe" -ArgumentList "-File ActivateMods.ps1", "-configParam $($config) -targetProfile $($targetProfile) -sourceProfile $($sourceProfile)"  -Wait
    & ".\ActivateMods.ps1" -configParam $config -targetProfile $targetProfile -sourceProfile $sourceProfile
}


function getTargetProfile {
    cls
    $foundFiles = Get-ChildItem -Path "..\..\profiles\" -Filter "plugins.txt" -File -Recurse
    if ($foundFiles.Count -eq 0) {
        Write-Host "Cannot find the folder where MO2 configuration files (plugins.txt, modlist.txt) are located. Please search manually and enter the path in the configuration file under 'folderTargetProfile'"
        Read-Host
        exit 1
    } elseif ($foundFiles.Count -eq 1) {
        $targetProfile = $foundFiles.DirectoryName+"\"
        Write-host "Applying all changes to profile: "$targetProfile
    } else {
        Write-Host "============================================================"
        Write-Host "Please choose which profile should be changed:"
        for ($i = 0; $i -lt $foundFiles.Count; $i++) {
            Write-Host ($i+1)". "$($foundFiles[$i].DirectoryName)
        }
        $userChoice = Read-Host "Select a number (1 - "$foundFiles.Count")"
        if (($userChoice -match "^\d+$") -and ($userChoice -gt 0) -and ($userChoice -le $foundFiles.Count)) {
            $targetProfile = $($foundFiles[($userChoice-1)].DirectoryName)+"\"
            Write-host "Applying all changes to profile: "$targetProfile
        } else {
            Write-Host "Wrong input, exiting now"
            Read-Host
            exit 1
        }
    }    
    return $targetProfile
}


function getSourceProfile {
    cls
    $foundFiles = Get-ChildItem -Path "..\..\profiles\" -Filter "plugins.txt" -Exclude $targetProfile -File -Recurse
    if ($foundFiles.Count -eq 0) {
        Write-Host "Cannot find the folder where MO2 configuration files (plugins.txt, modlist.txt) are located. Please search manually and enter the path in the configuration file under 'folderTargetProfile'"
        Read-Host
        exit 1
    } elseif ($foundFiles.Count -eq 1) {
        $sourceProfile = "None"
        Write-host "With only one profile in place there is no need to recreate it."
    } else {
        Write-Host "============================================================"
        Write-Host "Do you want to completely recreate this profile based on another profile?"
        Write-Host "The current configuration of this profile is deleted, the chosen profile taken as source and configuration changes applied to this."
        Write-Host "0 .  No (default)"
        for ($i = 0; $i -lt $foundFiles.Count; $i++) {
            Write-Host ($i+1)". "$($foundFiles[$i].DirectoryName)
        }
        $userChoice = Read-Host "Select a number (0 - "$foundFiles.Count")"
        if (($userChoice -match "^\d+$") -and ($userChoice -gt 0) -and ($userChoice -le $foundFiles.Count)) {
            $sourceProfile = $($foundFiles[($userChoice-1)].DirectoryName)+"\"
        } elseif (($userChoice -match "^\d+$") -and ($userChoice -eq 0)) {
            $sourceProfile = "None"
        } else {
            Write-Host "Wrong input, exiting now"
            Read-Host
            exit 1
        }
    }    
    return $sourceProfile
}


function mainMenu {
    cls
    $foundFiles = Get-ChildItem -Filter "config_*.json" -File
    Write-Host "============================================================"
    Write-Host "All changes will be applied to the following profile: "
    Write-Host $targetProfile
    Write-Host "If you wish to use/create a new profile, please create one in Mod Organizer 2 first."
    Write-Host "This script applies all changes defined in the configuration file to the profile mentioned above."
    Write-Host ""
    Write-Host "Please choose which configuration file should be used:"
    Write-Host "0 .  Use the Performance Assistent to chose best configuration"
    for ($i = 0; $i -lt $foundFiles.Count; $i++) {
        Write-Host ($i+1)". "$($foundFiles[$i].Name)
    }
    $userChoice = Read-Host "Select a number (0 - "$foundFiles.Count")"
    if (($userChoice -match "^\d+$") -and ($userChoice -eq 0)) {
        askGPU
    } elseif (($userChoice -match "^\d+$") -and ($userChoice -gt 0) -and ($userChoice -le $foundFiles.Count)) { 
        activateMods -config $foundFiles[($userChoice-1)].Name -targetProfile $targetProfile -sourceProfile $sourceProfile #"config_MO_CommunityShaders.json"
        clearOverwriteFolder
    } else {
        Write-Host "Wrong input, exiting now"
        Read-Host
        exit 1
    }
}

function askGPU {
    Write-Host "============================================================"
    Write-Host "Which GPU are you using?"
    Write-Host "1. nVidia RTX 1080, 2070, 3060 or below"
    Write-Host "2. nVidia RTX 2080, 3070, 4060"
    Write-Host "3. nVidia RTX 3080, 4070 or above"
    Write-Host "4. AMD RX 5700 XT or below"
    Write-Host "5. AMD RX 7600"
    Write-Host "6. AMD RX 6800 XT or above"
    $userChoice = Read-Host "Select a number"
    if (($userChoice -match "^\d+$") -and ($userChoice -gt 0) -and ($userChoice -le 6)) {
        switch -wildcard ($userChoice) {
            1 { 
                Write-Host "For this setup it is recommended to use FUS which is another modlist focussed: https://github.com/Kvitekvist/FUS" 
                Read-Host
            }
            2 { 
                $global:gpu = "NVIDIA"
                $global:performance = "low"
                askHMD
            }
            3 { 
                $global:gpu = "NVIDIA"
                $global:performance = "medium"
                askHMD
            }
            4 { 
                Write-Host "For this setup it is recommended to use FUS which is another modlist focussed: https://github.com/Kvitekvist/FUS" 
                Read-Host
            }
            5 { 
                $global:gpu = "AMD"
                $global:performance = "low"
                askHMD
            }
            6 { 
                $global:gpu = "AMD"
                $global:performance = "medium"
                askHMD
            }                    
        }     
    } else {
        Write-Host "Wrong input, exiting now"
        Read-Host
        exit 1
    }
}    



function askHMD {
    Write-Host "============================================================"
    Write-Host "Which VR headset are you using?"
    Write-Host "1. Valve Index, Oculus Quest 1/2, HTC Vive Pro (or another headset with a resolution below 4k <2000x2000)"
    Write-Host "2. Oculus Quest 3, Pico 4 (or another headset with a resolution above 4k >2000x2000)"
    $userChoice = Read-Host "Select a number"
    if (($userChoice -match "^\d+$") -and ($userChoice -gt 0) -and ($userChoice -le 2)) {
        switch -wildcard ($userChoice) {
            1 { 
                $global:hmd = "low"
                finalize
            }
            2 { 
                $global:hmd = "medium"
                finalize
            }
        }
    } else {
        Write-Host "Wrong input, exiting now"
        Read-Host
        exit 1
    }
}    

function finalize {
    if ($gpu -eq "NVIDIA") {
        $activateMods = @("NVIDIA Reflex Support - Nvidia Only",
            "Skyrim Upscaler VR - Nvidia Only", "The Sharper Eye - Sharpening Only")
        $deactivateMods = @("VR Performance Kit")
        
        if (($performance = "medium") -or ($hmd = "low")) {     #Good GPU, Basic HMD
            $activateMods +="Skyrim Upscaler VR - Nvidia DLAA"
        } elseif (($hmd -eq "medium") -and ($performance = "low")) {        #Slow GPU, Highend HMD
            Write-Host "For this setup it is recommended to use FUS which is another modlist focussed: https://github.com/Kvitekvist/FUS" 
            Read-Host
            exit 1
        } else {
            $activateMods +="Skyrim Upscaler VR - Nvidia DLSS - Balanced"
        }
    } else {
        $activateMods = @("VR Performance Kit - Do Not Use With Open Composite and Reshade")        
        $deactivateMods = @("NVIDIA Reflex Support - Nvidia Only",
            "Skyrim Upscaler VR", "The Sharper Eye - Sharpening Only")
        if (($performance = "medium") -or ($hmd = "low")) {     #Good GPU, Basic HMD
            $activateMods +="VR Performance Kit - FSR Disabled, CAS Sharpening Only"
        } elseif (($hmd -eq "medium") -and ($performance = "low")) {        #Slow GPU, Highend HMD
            Write-Host "For this setup it is recommended to use FUS which is another modlist focussed: https://github.com/Kvitekvist/FUS" 
            Read-Host
            exit 1
        } else {
            $activateMods +="VR Performance Kit - FSR Balanced"
        }
    }

    $jsonconfig = [PSCustomObject]@{
        activateMods = $activateMods
        deactivateMods = $deactivateMods
    }
    
    $jsonObject = $jsonconfig | ConvertTo-Json
    $jsonObject | Set-Content -Path "setupAssistant.json"

    activateMods -config "setupAssistant.json" -targetProfile $targetProfile -sourceProfile "None"
    #$pluginDependencies = @()
}


function clearOverwriteFolder {
    $confirmation = Read-Host "It is strongly recommended to clear the overwrite folder. Please confirm with Y to proceed: (Y/N)"
    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
        Remove-Item -Path "..\..\overwrite" -Recurse -Force
    }

}


# & ".\ActivateMods.ps1" -configParam "config_Flatrim.json" -targetProfile "D:\MO2-Skyrim VR Minimalistic Overhaul\profiles\MO - Flatrim profile for grass cache\" -sourceProfile "D:\MO2-Skyrim VR Minimalistic Overhaul\profiles\Skyrim VR Minimalistic Overhaul - NSFW\"

$targetProfile = getTargetProfile
$sourceProfile = getSourceProfile
mainMenu
if (-not (Get-Process -Name "ModOrganizer" -ErrorAction SilentlyContinue)) { 
    Start-Process -FilePath "../../ModOrganizer.exe" 
}