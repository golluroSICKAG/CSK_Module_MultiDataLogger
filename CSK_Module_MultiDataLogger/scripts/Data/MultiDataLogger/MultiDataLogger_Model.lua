---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_MultiDataLogger'

-- Create kind of "class"
local multiDataLogger = {}
multiDataLogger.__index = multiDataLogger

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to create new instance
---@param multiDataLoggerInstanceNo int Number of instance
---@return table[] self Instance of multiDataLogger
function multiDataLogger.create(multiDataLoggerInstanceNo)

  local self = {}
  setmetatable(self, multiDataLogger)

  self.multiDataLoggerInstanceNo = multiDataLoggerInstanceNo -- Number of this instance
  self.multiDataLoggerInstanceNoString = tostring(self.multiDataLoggerInstanceNo) -- Number of this instance as string
  self.helperFuncs = require('Data/MultiDataLogger/helper/funcs') -- Load helper functions

  -- Create parameters etc. for this module instance
  self.activeInUI = false -- Check if this instance is currently active in UI

  -- Check if CSK_PersistentData module can be used if wanted
  self.persistentModuleAvailable = CSK_PersistentData ~= nil or false

  -- Check if CSK_UserManagement module can be used if wanted
  self.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

  -- Default values for persistent data
  -- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
  self.parametersName = 'CSK_MultiDataLogger_Parameter' .. self.multiDataLoggerInstanceNoString -- name of parameter dataset to be used for this module
  self.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters.registeredEvent = '' -- If thread internal function should react on external event, define it here, e.g. 'CSK_OtherModule.OnNewInput'
  self.parameters.processingFile = 'CSK_MultiDataLogger_Processing' -- which file to use for processing (will be started in own thread)
  self.parameters.path = '/public/'

  self.parameters.dataMode = 'file' -- Mode to log data like 'image', 'file'
  self.parameters.dataType = 'json' -- 'json', 'csv'
  self.parameters.csvFilename = 'csvFile'
  self.parameters.csvLabels = '' -- e.g. 'DateTime, ValueA, ValueB'
  self.parameters.saveOnlyChanges = true
  self.parameters.saveDataDirectly = false

  self.parameters.imageType = 'bmp' -- 'jpg', 'png', 'json', 'msgpack', 'bmp'
  self.parameters.imageCompressionValue = 80

  -- Parameters to give to the processing script
  self.multiDataLoggerProcessingParams = Container.create()
  self.multiDataLoggerProcessingParams:add('multiDataLoggerInstanceNumber', multiDataLoggerInstanceNo, "INT")
  self.multiDataLoggerProcessingParams:add('registeredEvent', self.parameters.registeredEvent, "STRING")
  self.multiDataLoggerProcessingParams:add('path', self.parameters.path, "STRING")
  self.multiDataLoggerProcessingParams:add('dataMode', self.parameters.dataMode, "STRING")
  self.multiDataLoggerProcessingParams:add('dataType', self.parameters.dataType, "STRING")
  self.multiDataLoggerProcessingParams:add('csvFilename', self.parameters.csvFilename, "STRING")
  self.multiDataLoggerProcessingParams:add('csvLabels', self.parameters.csvLabels, "STRING")
  self.multiDataLoggerProcessingParams:add('saveOnlyChanges', self.parameters.saveOnlyChanges, "BOOL")
  self.multiDataLoggerProcessingParams:add('saveDataDirectly', self.parameters.saveDataDirectly, "BOOL")
  self.multiDataLoggerProcessingParams:add('imageType', self.parameters.imageType, "STRING")
  self.multiDataLoggerProcessingParams:add('imageCompressionValue', self.parameters.imageCompressionValue, "INT")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiDataLoggerProcessingParams)

  return self
end

return multiDataLogger

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************