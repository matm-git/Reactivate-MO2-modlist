function activateMods {
    param (
        [string]$config
    )    
    Start-Process -FilePath "powershell.exe" -ArgumentList "-File ActivateMods.ps1", "-config $($config)" -Wait
}

function mainMenu {
    Write-Host "============================================================"
    Write-Host "This setup assistent is intented to be used together with one of the following modlists:"
    Write-Host "Skyrim VR Minimalistic Overhaul: https://www.nexusmods.com/skyrimspecialedition/mods/83995"
    Write-Host "Skyrim VR Minimalistic Overhaul - NSFW: https://www.nexusmods.com/skyrimspecialedition/mods/86817/"
    Write-Host "This mod must be installed in the MO2 instance from this modlist. If it is not, please close the window."
    Write-Host ""
    Write-Host "Please choose between one of the following options:"
    Write-Host "1. Start setup assistant"
    Write-Host "2. Activate Community Shaders"
    Write-Host "3. Activate ENB"
    $userChoice = Read-Host "Select a number"
    if (($userChoice -match "^\d+$") -and ($userChoice -gt 0) -and ($userChoice -le 3)) {
        switch -wildcard ($userChoice) {
            1 { askGPU }
            2 { activateMods -config "config_MO_CommunityShaders.json"}
            3 { activateMods -config "config_MO_ENB.json"}
        }
        
    } else {
        Write-Host "Wrong input, exiting now"
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
        folderDefaultProfile = "autodetect"
        modsDirectory = "..\"
        activateModsDefaultProfile = $activateMods
        deactivateModsDefaultProfile = $deactivateMods
    }
    
    $jsonObject = $jsonconfig | ConvertTo-Json
    $jsonObject | Set-Content -Path "setupAssistant.json"

    activateMods -config "setupAssistant.json"
    #$pluginDependencies = @()
}

function createCombinedSettings {
    # Initialize an empty array to store JSON objects
    $jsonObjects = @()

    # List of JSON files to combine
    $jsonFiles = "file1.json", "file2.json", "file3.json"

    # Read and parse each JSON file
    foreach ($file in $jsonFiles) {
        $jsonContent = Get-Content -Path $file | ConvertFrom-Json
        $jsonObjects += $jsonContent
    }

    # Convert the combined objects back to JSON
    $combinedJson = $jsonObjects | ConvertTo-Json

    # Save the combined JSON to a file
    $combinedJson | Set-Content -Path "combined.json"
}

mainMenu
if (-not (Get-Process -Name "ModOrganizer" -ErrorAction SilentlyContinue)) { 
    Start-Process -FilePath "../../ModOrganizer.exe" 
}