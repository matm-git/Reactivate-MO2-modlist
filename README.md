When you update a Wabbajack modlist for Skyrim your custom mods get out of order but we do not want to sort them over and over again manually. Using Loot for automatic sorting is generally not recommended. 
Also I like to have different profiles in MO2 and disable some mods from the modlist and add some additional ones. 
This script tries to automate this with the modlist from 'Skyrim VR Minimalistic Overhaul' ( https://www.nexusmods.com/skyrimspecialedition/mods/83995 ). It may require some adaptation for other modlists.

First, to overcome this manual sorting we have to follow some simple rules for our mods added on top:
- Remember to put [NoDelete] at the front of your custom mods. Otherwise they will be deleted with the next update
- Use alphabetical prefixes to put the mods in order. After updating the modlist via Wabbajack custom mods are sorted alphabetically per default. The prefixes will be used for default sorting and define which mod may overwrite contents of another mod. So think of the correct order once. 
- Per default plugin load order follows the same alphabetical sorting. But there is an option to define dependencies (load mod A after B) for certain mods. More on this below.
- Create and use empty mods as separators for the sake of readability (optional)
  
When you update or restore (yellow arrow) the modlist all your custom mods will be deactivated. This is where the Powershell script kicks in which automatically deactivates unwanted mods and activates your custom mods.
With default configuration mods with the following prefixes are activated per default:

    * [NoDelete] a* Will be activated automatically in default profile
    * [NoDelete] x* Will be activated automatically in alternate profile
    * Anything else will not be activated automatically

Installation instructions
1) Download the zip file from here (Releases)
2) Open MO2 and install the zip as a mod and name it '[NoDelete] 0 Autoupdate MO2 Config'
4) Edit config.json to define which mods should be automatically enabled and disabled and give dependencies.
   The script activates all plugins that are part of a mod. If you do not want to activate some optional plugins, just set them to hidden in MO2.

Modlist update instructions
1) Download latest modlist from nexusmods
2) Extract the downloaded file and open the Wabbajack file
3) In Wabbajack activate 'overwrite' option and install into target directory (MO2)
4) Open MO2 once so that it can generate/update the initial modlist
5) Close MO2
6) Run the script via Windows Explorer: ActivateMods.ps1
The script creates backups of your modlist and plugin load order. So in case something breaks, just restore those backups via MO2 (yellow arrow)
