## Preparing a bottle using Tipple.

Execute install_a_cd.sh

A window will appear asking you to select DOS or Wine. Choose your option.

![Alt text](howto_screenshots/dos_or_wine.png?raw=true "Wine or DOS")

Another popup will appear asking you to select your iso. Browse to the file and select OK.

![Alt text](howto_screenshots/selectISO.png?raw=true "Select your ISO")

It will ask you to name your 'bottle', so give it a name and select OK.

![Alt text](howto_screenshots/type_name_of_bottle.png?raw=true "Give your bottle a name!")

It will ask you if you would like to add another CD. For this we click no, but you can add other CDs if you wish.

![Alt text](howto_screenshots/add_another_cd.png?raw=true "Add another CD?")

This will then create a directory at ${HOME}/WINEHOMES with a skeleton bottle and your game.

![Alt text](howto_screenshots/this_will_create_WINEHOMES.png?raw=true "WINEHOMES")

## Installing the application

cd to your game in the WINEHOMES directory and run ./install.sh

- If it is a DOS application, a popup will appear asking you to select an exe or bat from the mounted ISO to use to install.

- If however it is a Wine application ...

A popup will appear telling you to select your 'default' or 'global' version of windows.

![Alt text](howto_screenshots/it_will_ask_for_default_version_of_windows.png?raw=true "GLOBAL default version")

Click OK, select your default version of windows then click OK/Apply

![Alt text](howto_screenshots/select_default_version_of_windows.png?raw=true "Selecting the global default version of windoze")

Winetricks will then run for your 'default' or 'global' version. You can install directx and quicktime if you wish through this.

![Alt text](howto_screenshots/winetricks.png?raw=true "WINEHOMES")

When you are done with wine tricks for the global config, it will ask you if you want to run winecfg and winetricks for the application specifically.

![Alt text](howto_screenshots/winecfg_for_application_specifically.png?raw=true "WINEHOMES")

If you select no, the default version of windows you selected for the global config will be assumed.
If you click yes, you can set the version of windows compatibility for the application specifically. It will run winetricks specifically for that application.

In this example, most of our applications are XP, but this specific application requires windows 3.1 compat.

![Alt text](howto_screenshots/windows3point1.png?raw=true "Who remembers the days?")

NOTE: When you run winetricks on an application specifically, it automatically includes installations of dlls etc from the global config. You do not need to install things twice.

The auto run should fire up now. You can install your application.

## Running the application

Once the application is installed, run ./run.sh to run the application.

- Note; if it is a DOS application, a popup will appear asking you to select the installed exe or bat from the hard drive.