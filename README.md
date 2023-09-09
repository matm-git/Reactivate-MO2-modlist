When you update a Wabbajack modlist for Skyrim your custom mods get out of order but we do not want to sort them over and over again manually. Using Loot for automatic sorting is generally not recommended. 
Also I like to have different profiles in MO2 and disable some mods from the modlist and add some additional ones. 
This script tries to automate this with the modlist from 'Skyrim VR Minimalistic Overhaul' ( https://www.nexusmods.com/skyrimspecialedition/mods/83995 ). It may require some adaptation for other modlists.

First, to overcome this manual sorting we have to follow some simple rules for our mods added on top:
- Remember to put [NoDelete] at the front of your custom mods. Otherwise they will be deleted with the next update
- Use alphabetical prefixes to put the mods in order. After updating the modlist via Wabbajack custom mods are sorted alphabetically per default. The prefixes will be used for default sorting and define which mod may overwrite contents of another mod. So think of the correct order once. 
- Per default plugin load order follows the same alphabetical sorting. But there is an option to define dependencies (load mod A after B) for certain mods. More on this below.
- Create and use empty mods as separators for the sake of readability (optional)
When you update or restore (yellow arrow) the modlist all your custom mods will be deactivated. This is where the Powershell scripts kick in which automatically deactivates unwanted mods and activates your custom mods.
With default configuration mods with the following prefixes activated per default:
    [NoDelete] a* Will be activated automatically in default profile
    [NoDelete] x* Will be activated automatically in alternate profile
    Anything else will not be activated automatically

Installation instructions
1) Download all the files here
2) Create a new mod in your MO2 instance, e.g. '[NoDelete] 0 Autoupdate MO2 Config' and copy all files there. Remeber to start the name with [NoDelete] to avoid it being removed with the next update
3) Edit config.json to define which mods should be automatically enabled and disabled

Modlist update instructions
1) Download latest modlist from: https://www.nexusmods.com/skyrimspecialedition/mods/86817/
2) Extract the downloaded file and open the wabbajack file
3) Activate 'overwrite' option and install into target directory (MO2)
4) Open MO2 and run the script (doubleclick): ActivateMods.ps1
5) Press F5, then close MO2
6) Run the Script (doubleclick): SortPlugins.ps1
The scripts create backups of your modlist and plugin load order. So in case something breaks, just restore those backups via MO2 (yellow arrow)