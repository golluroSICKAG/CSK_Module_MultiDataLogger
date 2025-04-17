# CSK_Module_MultiDataLogger

Module to store data like files (json, csv) or images.

![](./docu/media/UI_Screenshot.png)

## How to Run

The module includes an intuitive GUI to setup the instances of the data logger.  
For further information regarding the externally available functions / events, please check out the [documentation](https://raw.githack.com/SICKAppSpaceCodingStarterKit/CSK_Module_MultiDataLogger/main/docu/CSK_Module_MultiDataLogger.html) in the folder "docu".

## Known issues

- Switching in CSV mode from unlimited to limited entry mode: Old values will be lost and data logger will start with new entries.  
- Switching in CSV mode from limited to unlimited entry mode: If old values were not saved before, they will be lost.

## Information

Tested on  

|Device|Firmware|Module version|
|--|--|--|
|SICK AppEngine|v1.7.0|v2.1.0|
|SICK AppEngine|v1.7.0|v2.0.0|
|SICK AppEngine|v1.7.0|v1.0.0|
|SICK AppEngine|v1.3.2|v1.0.0|
|SIM1012|v2.4.2|v2.0.0|
|SIM1012|v2.4.1|v1.0.0|

This module is part of the SICK AppSpace Coding Starter Kit developing approach.  
It is programmed in an object-oriented way. Some of the modules use kind of "classes" in Lua to make it possible to reuse code / classes in other projects.  
In general, it is not neccessary to code this way, but the architecture of this app can serve as a sample to be used especially for bigger projects and to make it easier to share code.  
Please check the [documentation](https://github.com/SICKAppSpaceCodingStarterKit/.github/blob/main/docu/SICKAppSpaceCodingStarterKit_Documentation.md) of CSK for further information.  

## Topics

Coding Starter Kit, CSK, Module, SICK-AppSpace, Data, Images, Save, Store
