# Changelog
All notable changes to this project will be documented in this file.

## Release 2.0.0

### New features
- Supports FlowConfig feature to set sources to log data
- Provide version of module via 'OnNewStatusModuleVersion'
- Function 'getParameters' to provide PersistentData parameters
- Proper check if features of module can be used on device and provide this via 'OnNewStatusModuleIsActive' event / 'getStatusModuleActive' function
- Function to 'resetModule' to default setup

### Improvements
- New UI design available (e.g. selectable via CSK_Module_PersistentData v4.1.0 or higher), see 'OnNewStatusCSKStyle'
- Added info texts within UI
- Extra check if Image CROWN is available to log images
- check if instance exists if selected
- 'loadParameters' returns its success
- 'sendParameters' can control if sent data should be saved directly by CSK_Module_PersistentData
- Changed log level of some messages from 'info' to 'fine'
- Added UI icon and browser tab information

### Bugfix
- Never deregistered from events
- Wrong check of dataType to update image type
- Error if module is not active but 'getInstancesAmount' was called
- Wrong variable used within 'setCSVFilename'

## Release 1.0.0
- Initial commit