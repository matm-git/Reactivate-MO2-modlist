Background
==========
When you update a Wabbajack modlist for Skyrim your custom mods get out of order but we do not want to sort them over and over again manually. Using Loot for automatic sorting is generally not recommended. 
Also I like to have different profiles in MO2 and disable some mods from the modlist and add some additional ones. 
This script tries to automate this and allows to easily use and update different profiles of your carefully maintained modlist. 
As an example, I use the same modlist with different profiles for ENB, Community Shaders, VR and SkyrimSSE. 
I do not want to maintain four different lists, but instead add new mods only to my primary list. Those are automatically added and activated in the other lists then.


Installation
================
MO2
1) Download and install automatically as any other MO2 mod

Manual
1) Download the zip file from here (Releases)
2) Open MO2 and install the zip as a mod and name it '[NoDelete] 0 Wabbajack Customizer'

Configuration and usage
=======================
1) Create as many different profiles in MO2 as you like using topbar Tools > Profiles
2) Copy config_default.json to something like config_myconfig.json
3) Modify this config_myconfig.json as you like.
   activateMods: Contains the list of mods which are activated when the configuration file is executed
   deactivateMods: Contains the list of mods which are deactivated when the configuration file is executed
   pluginDependencies: With this list you can manage plugin dependencies. The syntax is always 'Load A directly after B'.
4) Run SetupAssistant.ps1 by double-clicking on it. Follow the explanation on screen.
5) The script creates backups of your modlist and plugin load order. So in case something breaks, just restore those backups via MO2 (yellow arrow)






General advice
==============
Some further general advice when adding mods to a Wabbajack modlist. This is not so much related to this mod
- Remember to put [NoDelete] at the front of your custom mods. Otherwise they will be deleted with the next update
- Use alphabetical prefixes to put the mods in order. After updating the modlist via Wabbajack custom mods are sorted alphabetically per default. The prefixes will be used for default sorting and define which mod may overwrite contents of another mod. So think of the correct order once. 
- Per default plugin load order follows the same alphabetical sorting. But there is an option to define dependencies (load mod A after B) for certain mods. More on this below.
- Create and use empty mods as separators for the sake of readability (optional)

Wabbajack update instructions
1) Download latest modlist from nexusmods
2) Extract the downloaded file and open the Wabbajack file
3) In Wabbajack activate 'overwrite' option and install into target directory (MO2)
4) Open MO2 once so that it can generate/update the initial modlist
5) Close MO2
6) Run the script via Windows Explorer: ActivateMods.ps1
