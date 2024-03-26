---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the MultiDataLogger_Model and _Instances
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_MultiDataLogger'

local funcs = {}

-- Timer to update UI via events after page was loaded
local tmrMultiDataLogger = Timer.create()
tmrMultiDataLogger:setExpirationTime(300)
tmrMultiDataLogger:setPeriodic(false)

-- Timer to wait for other modules to be ready to register to their events
local tmrWaitForSetupOfOtherModules = Timer.create()
tmrWaitForSetupOfOtherModules:setExpirationTime(1000)
tmrWaitForSetupOfOtherModules:setPeriodic(false)

local multiDataLogger_Model -- Reference to model handle
local multiDataLogger_Instances -- Reference to instances handle
local selectedInstance = 1 -- Which instance is currently selected
local helperFuncs = require('Data/MultiDataLogger/helper/funcs')

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
Script.serveEvent("CSK_MultiDataLogger.OnNewValueToForwardNUM", "MultiDataLogger_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiDataLogger.OnNewValueUpdateNUM", "MultiDataLogger_OnNewValueUpdateNUM")
----------------------------------------------------------------

-- Real events
--------------------------------------------------

Script.serveEvent('CSK_MultiDataLogger.OnNewStatusStoragePath', 'MultiDataLogger_OnNewStatusStoragePath')
Script.serveEvent('CSK_MultiDataLogger.OnNewStatusDataMode', 'MultiDataLogger_OnNewStatusDataMode')
Script.serveEvent('CSK_MultiDataLogger.OnNewStatusDataType', 'MultiDataLogger_OnNewStatusDataType')

Script.serveEvent('CSK_MultiDataLogger.OnNewStatusCSVFilename', 'MultiDataLogger_OnNewStatusCSVFilename')

Script.serveEvent('CSK_MultiDataLogger.OnNewStatusCSVLables', 'MultiDataLogger_OnNewStatusCSVLables')
Script.serveEvent("CSK_MultiDataLogger.OnNewStatusSaveDataDirectly", "MultiDataLogger_OnNewStatusSaveDataDirectly")
Script.serveEvent("CSK_MultiDataLogger.OnNewStatusSaveOnlyChanges", "MultiDataLogger_OnNewStatusSaveOnlyChanges")

Script.serveEvent('CSK_MultiDataLogger.OnNewStatusImageType', 'MultiDataLogger_OnNewStatusImageType')
Script.serveEvent('CSK_MultiDataLogger.OnNewStatusImageCompressionValue', 'MultiDataLogger_OnNewStatusImageCompressionValue')

Script.serveEvent('CSK_MultiDataLogger.OnNewStatusAvailableEvents', 'MultiDataLogger_OnNewStatusAvailableEvents')
Script.serveEvent('CSK_MultiDataLogger.OnNewStatusRegisteredEvent', 'MultiDataLogger_OnNewStatusRegisteredEvent')

Script.serveEvent("CSK_MultiDataLogger.OnNewStatusLoadParameterOnReboot", "MultiDataLogger_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_MultiDataLogger.OnPersistentDataModuleAvailable", "MultiDataLogger_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_MultiDataLogger.OnNewParameterName", "MultiDataLogger_OnNewParameterName")

Script.serveEvent("CSK_MultiDataLogger.OnNewInstanceList", "MultiDataLogger_OnNewInstanceList")
Script.serveEvent("CSK_MultiDataLogger.OnNewProcessingParameter", "MultiDataLogger_OnNewProcessingParameter")
Script.serveEvent("CSK_MultiDataLogger.OnNewSelectedInstance", "MultiDataLogger_OnNewSelectedInstance")
Script.serveEvent("CSK_MultiDataLogger.OnDataLoadedOnReboot", "MultiDataLogger_OnDataLoadedOnReboot")

Script.serveEvent("CSK_MultiDataLogger.OnUserLevelOperatorActive", "MultiDataLogger_OnUserLevelOperatorActive")
Script.serveEvent("CSK_MultiDataLogger.OnUserLevelMaintenanceActive", "MultiDataLogger_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_MultiDataLogger.OnUserLevelServiceActive", "MultiDataLogger_OnUserLevelServiceActive")
Script.serveEvent("CSK_MultiDataLogger.OnUserLevelAdminActive", "MultiDataLogger_OnUserLevelAdminActive")

-- ************************ UI Events End **********************************

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("MultiDataLogger_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("MultiDataLogger_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("MultiDataLogger_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("MultiDataLogger_OnUserLevelAdminActive", status)
end
-- ***********************************************

--- Function to forward data updates from instance threads to Controller part of module
---@param eventname string Eventname to use to forward value
---@param value auto Value to forward
local function handleOnNewValueToForward(eventname, value)
  Script.notifyEvent(eventname, value)
end

--- Optionally: Only use if needed for extra internal objects -  see also Model
--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
---@param selectedObject int? Optionally if internal parameter should be used for internal objects
local function handleOnNewValueUpdate(instance, parameter, value, selectedObject)
    multiDataLogger_Instances[instance].parameters.internalObject[selectedObject][parameter] = value
end

--- Function to get access to the multiDataLogger_Model object
---@param handle handle Handle of multiDataLogger_Model object
local function setMultiDataLogger_Model_Handle(handle)
  multiDataLogger_Model = handle
  Script.releaseObject(handle)
end
funcs.setMultiDataLogger_Model_Handle = setMultiDataLogger_Model_Handle

--- Function to get access to the multiDataLogger_Instances object
---@param handle handle Handle of multiDataLogger_Instances object
local function setMultiDataLogger_Instances_Handle(handle)
  multiDataLogger_Instances = handle
  if multiDataLogger_Instances[selectedInstance].userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)

  for i = 1, #multiDataLogger_Instances do
    Script.register("CSK_MultiDataLogger.OnNewValueToForward" .. tostring(i) , handleOnNewValueToForward)
  end

  for i = 1, #multiDataLogger_Instances do
    Script.register("CSK_MultiDataLogger.OnNewValueUpdate" .. tostring(i) , handleOnNewValueUpdate)
  end

end
funcs.setMultiDataLogger_Instances_Handle = setMultiDataLogger_Instances_Handle

--- Function to update user levels
local function updateUserLevel()
  if multiDataLogger_Instances[selectedInstance].userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("MultiDataLogger_OnUserLevelAdminActive", true)
    Script.notifyEvent("MultiDataLogger_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("MultiDataLogger_OnUserLevelServiceActive", true)
    Script.notifyEvent("MultiDataLogger_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrMultiDataLogger()

  updateUserLevel()

  Script.notifyEvent('MultiDataLogger_OnNewSelectedInstance', selectedInstance)
  Script.notifyEvent("MultiDataLogger_OnNewInstanceList", helperFuncs.createStringListBySize(#multiDataLogger_Instances))

  local eventList = helperFuncs.getAvailableEvents()
  Script.notifyEvent("MultiDataLogger_OnNewStatusAvailableEvents", helperFuncs.createStringListBySimpleTable(eventList))

  Script.notifyEvent("MultiDataLogger_OnNewStatusRegisteredEvent", multiDataLogger_Instances[selectedInstance].parameters.registeredEvent)
  Script.notifyEvent("MultiDataLogger_OnNewStatusStoragePath", multiDataLogger_Instances[selectedInstance].parameters.path)

  Script.notifyEvent("MultiDataLogger_OnNewStatusDataMode", multiDataLogger_Instances[selectedInstance].parameters.dataMode)
  Script.notifyEvent("MultiDataLogger_OnNewStatusDataType", multiDataLogger_Instances[selectedInstance].parameters.dataType)

  Script.notifyEvent("MultiDataLogger_OnNewStatusCSVFilename", multiDataLogger_Instances[selectedInstance].parameters.csvFilename)
  Script.notifyEvent("MultiDataLogger_OnNewStatusCSVLables", multiDataLogger_Instances[selectedInstance].parameters.csvLabels)
  Script.notifyEvent("MultiDataLogger_OnNewStatusSaveDataDirectly", multiDataLogger_Instances[selectedInstance].parameters.saveDataDirectly)
  Script.notifyEvent("MultiDataLogger_OnNewStatusSaveOnlyChanges", multiDataLogger_Instances[selectedInstance].parameters.saveOnlyChanges)

  Script.notifyEvent("MultiDataLogger_OnNewStatusImageType", multiDataLogger_Instances[selectedInstance].parameters.imageType)
  Script.notifyEvent("MultiDataLogger_OnNewStatusImageCompressionValue", multiDataLogger_Instances[selectedInstance].parameters.imageCompressionValue)

  Script.notifyEvent("MultiDataLogger_OnNewStatusLoadParameterOnReboot", multiDataLogger_Instances[selectedInstance].parameterLoadOnReboot)
  Script.notifyEvent("MultiDataLogger_OnPersistentDataModuleAvailable", multiDataLogger_Instances[selectedInstance].persistentModuleAvailable)
  Script.notifyEvent("MultiDataLogger_OnNewParameterName", multiDataLogger_Instances[selectedInstance].parametersName)
end
Timer.register(tmrMultiDataLogger, "OnExpired", handleOnExpiredTmrMultiDataLogger)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrMultiDataLogger:start()
  return ''
end
Script.serveFunction("CSK_MultiDataLogger.pageCalled", pageCalled)

local function setSelectedInstance(instance)
  selectedInstance = instance
  _G.logger:fine(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
  multiDataLogger_Instances[selectedInstance].activeInUI = true
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  tmrMultiDataLogger:start()
end
Script.serveFunction("CSK_MultiDataLogger.setSelectedInstance", setSelectedInstance)

local function getInstancesAmount ()
  return #multiDataLogger_Instances
end
Script.serveFunction("CSK_MultiDataLogger.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:fine(nameOfModule .. ": Add instance")
  table.insert(multiDataLogger_Instances, multiDataLogger_Model.create(#multiDataLogger_Instances+1))
  Script.deregister("CSK_MultiDataLogger.OnNewValueToForward" .. tostring(#multiDataLogger_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiDataLogger.OnNewValueToForward" .. tostring(#multiDataLogger_Instances) , handleOnNewValueToForward)
  Script.deregister("CSK_MultiDataLogger.OnNewValueUpdate" .. tostring(#multiDataLogger_Instances) , handleOnNewValueUpdate)
  Script.register("CSK_MultiDataLogger.OnNewValueUpdate" .. tostring(#multiDataLogger_Instances) , handleOnNewValueUpdate)
  handleOnExpiredTmrMultiDataLogger()
end
Script.serveFunction('CSK_MultiDataLogger.addInstance', addInstance)

local function resetInstances()
  _G.logger:info(nameOfModule .. ": Reset instances.")
  setSelectedInstance(1)
  local totalAmount = #multiDataLogger_Instances
  while totalAmount > 1 do
    Script.releaseObject(multiDataLogger_Instances[totalAmount])
    multiDataLogger_Instances[totalAmount] =  nil
    totalAmount = totalAmount - 1
  end
  handleOnExpiredTmrMultiDataLogger()
end
Script.serveFunction('CSK_MultiDataLogger.resetInstances', resetInstances)

local function setRegisterEvent(event)
  if Script.isServedAsEvent(event) then
    multiDataLogger_Instances[selectedInstance].parameters.registeredEvent = event
    Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'registeredEvent', event)
  else
    _G.logger:warning(nameOfModule .. ": Event '" .. event .. "' is not available to register.")
    Script.notifyEvent("MultiDataLogger_OnNewStatusRegisteredEvent", multiDataLogger_Instances[selectedInstance].parameters.registeredEvent)
  end
end
Script.serveFunction("CSK_MultiDataLogger.setRegisterEvent", setRegisterEvent)

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'registeredEvent', multiDataLogger_Instances[selectedInstance].parameters.registeredEvent)

  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'path', multiDataLogger_Instances[selectedInstance].parameters.path)
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'dataMode', multiDataLogger_Instances[selectedInstance].parameters.dataMode)
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'dataType', multiDataLogger_Instances[selectedInstance].parameters.dataType)
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'csvFilename', multiDataLogger_Instances[selectedInstance].parameters.csvFilename)
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'csvLabels', multiDataLogger_Instances[selectedInstance].parameters.csvLabels)
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'imageType', multiDataLogger_Instances[selectedInstance].parameters.imageType)
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'imageCompressionValue', multiDataLogger_Instances[selectedInstance].parameters.selectedInstance)

end

local function setPath(path)
  local newPath
  if string.sub(path, #path, #path) == '/' then
    newPath = path
  else
    newPath = path .. '/'
  end

  _G.logger:fine(nameOfModule .. ": Set path to " .. newPath)
  multiDataLogger_Instances[selectedInstance].parameters.path = newPath
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'path', newPath)
  Script.notifyEvent("MultiDataLogger_OnNewStatusStoragePath", newPath)
end
Script.serveFunction('CSK_MultiDataLogger.setPath', setPath)

local function checkCompressionValue()
  if multiDataLogger_Instances[selectedInstance].parameters.imageType == 'jpg' then
    multiDataLogger_Instances[selectedInstance].parameters.imageCompressionValue = 95
  elseif multiDataLogger_Instances[selectedInstance].parameters.imageType == 'png' then
    multiDataLogger_Instances[selectedInstance].parameters.imageCompressionValue = 6
  end
  Script.notifyEvent("MultiDataLogger_OnNewStatusImageCompressionValue", multiDataLogger_Instances[selectedInstance].parameters.imageCompressionValue)
end

local function setDataMode(mode)
  _G.logger:fine(nameOfModule .. ": Set dataMode to " .. mode)
  multiDataLogger_Instances[selectedInstance].parameters.dataMode = mode
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'dataMode', mode)

  Script.notifyEvent("MultiDataLogger_OnNewStatusDataMode", mode)

  if dataType == 'image' then
    Script.notifyEvent("MultiDataLogger_OnNewStatusImageType", multiDataLogger_Instances[selectedInstance].parameters.imageType)
    checkCompressionValue()
  end
end
Script.serveFunction('CSK_MultiDataLogger.setDataMode', setDataMode)

local function setDataType(dataType)
  _G.logger:fine(nameOfModule .. ": Set dataType to " .. dataType)
  multiDataLogger_Instances[selectedInstance].parameters.dataType = dataType
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'dataType', dataType)
  Script.notifyEvent("MultiDataLogger_OnNewStatusDataType", multiDataLogger_Instances[selectedInstance].parameters.dataType)
end
Script.serveFunction('CSK_MultiDataLogger.setDataType', setDataType)

local function setCSVFilename(name)
  _G.logger:fine(nameOfModule .. ": Set csv filename to " .. labels)
  multiDataLogger_Instances[selectedInstance].parameters.csvFilename = name
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'csvFilename', name)
end
Script.serveFunction('CSK_MultiDataLogger.setCSVFilename', setCSVFilename)

local function setCSVLabels(labels)
  _G.logger:fine(nameOfModule .. ": Set csv labels to " .. labels)
  multiDataLogger_Instances[selectedInstance].parameters.csvLabels = labels
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'csvLabels', labels)
end
Script.serveFunction('CSK_MultiDataLogger.setCSVLabels', setCSVLabels)

local function setSaveOnlyChanges(status)
  multiDataLogger_Instances[selectedInstance].parameters.saveOnlyChanges = status
  _G.logger:info(nameOfModule .. ': Set CSV "save changes only" mode to = ' .. tostring(status))
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'saveOnlyChanges', status)
end
Script.serveFunction("CSK_MultiDataLogger.setSaveOnlyChanges", setSaveOnlyChanges)

local function setSaveDataDirectly(status)
  multiDataLogger_Instances[selectedInstance].parameters.saveDataDirectly = status
  _G.logger:info(nameOfModule .. ': Set CSV direct save mode to = ' .. tostring(status))
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'saveDataDirectly', status)
end
Script.serveFunction("CSK_MultiDataLogger.setSaveDataDirectly", setSaveDataDirectly)

local function saveCSVFile()
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'saveCSVFile', true)
end
Script.serveFunction('CSK_MultiDataLogger.saveCSVFile', saveCSVFile)

local function setImageType(imgType)
  _G.logger:fine(nameOfModule .. ": Set image type to " .. imgType)
  multiDataLogger_Instances[selectedInstance].parameters.imageType = imgType
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'imageType', imgType)
  Script.notifyEvent("MultiDataLogger_OnNewStatusImageType", imgType)
  checkCompressionValue()
end
Script.serveFunction('CSK_MultiDataLogger.setImageType', setImageType)

local function setCompressionValue(value)
  _G.logger:fine(nameOfModule .. ": Set image compression value to " .. value)
  multiDataLogger_Instances[selectedInstance].parameters.imageCompressionValue = value
  Script.notifyEvent('MultiDataLogger_OnNewProcessingParameter', selectedInstance, 'imageCompressionValue', value)
end
Script.serveFunction('CSK_MultiDataLogger.setCompressionValue', setCompressionValue)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name = " .. tostring(name))
  multiDataLogger_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiDataLogger.setParameterName", setParameterName)

local function sendParameters()
  if multiDataLogger_Instances[selectedInstance].persistentModuleAvailable then
    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiDataLogger_Instances[selectedInstance].parameters), multiDataLogger_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiDataLogger_Instances[selectedInstance].parametersName, multiDataLogger_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiDataLogger_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiDataLogger_Instances[selectedInstance].parametersName, multiDataLogger_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:fine(nameOfModule .. ": Send MultiDataLogger parameters with name '" .. multiDataLogger_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_MultiDataLogger.sendParameters", sendParameters)

local function loadParameters()
  if multiDataLogger_Instances[selectedInstance].persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(multiDataLogger_Instances[selectedInstance].parametersName)
    if data then
      _G.logger:fine(nameOfModule .. ": Loaded parameters for multiDataLoggerObject " .. tostring(selectedInstance) .. " from CSK_PersistentData module.")
      multiDataLogger_Instances[selectedInstance].parameters = helperFuncs.convertContainer2Table(data)

      -- If something needs to be configured/activated with new loaded data
      updateProcessingParameters()
      handleOnExpiredTmrMultiDataLogger()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
  tmrMultiDataLogger:start()
end
Script.serveFunction("CSK_MultiDataLogger.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiDataLogger_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_MultiDataLogger.setLoadOnReboot", setLoadOnReboot)

--- Function to react on timer started after initial load of persistent parameters
local function handleOnWaitForSetupTimerExpired()

  _G.logger:fine(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    for j = 1, #multiDataLogger_Instances do
      multiDataLogger_Instances[j].persistentModuleAvailable = false
    end
  else
    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      local parameterName, loadOnReboot, totalInstances = CSK_PersistentData.getModuleParameterName(nameOfModule, '1')
      -- Check for amount if instances to create
      if totalInstances then
        local c = 2
        while c <= totalInstances do
          addInstance()
          c = c+1
        end
      end
    end

    for i = 1, #multiDataLogger_Instances do
      local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule, tostring(i))

      if parameterName then
        multiDataLogger_Instances[i].parametersName = parameterName
        multiDataLogger_Instances[i].parameterLoadOnReboot = loadOnReboot
      end

      if multiDataLogger_Instances[i].parameterLoadOnReboot then
        setSelectedInstance(i)
        loadParameters()
      end
    end
    Script.notifyEvent('MultiDataLogger_OnDataLoadedOnReboot')
  end
end
Timer.register(tmrWaitForSetupOfOtherModules, 'OnExpired', handleOnWaitForSetupTimerExpired)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()
  tmrWaitForSetupOfOtherModules:start()
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************
