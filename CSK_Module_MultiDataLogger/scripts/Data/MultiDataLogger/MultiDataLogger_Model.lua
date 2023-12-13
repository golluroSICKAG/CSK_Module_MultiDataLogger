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

  -- Optionally check if specific API was loaded via
  --[[
  if _G.availableAPIs.specific then
  -- ... doSomething ...
  end
  ]]

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

  --self.object = Image.create() -- Use any AppEngine CROWN
  --self.counter = 1 -- Short docu of variable
  --self.varA = 'value' -- Short docu of variable

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters.registeredEvent = '' -- If thread internal function should react on external event, define it here, e.g. 'CSK_OtherModule.OnNewInput'
  self.parameters.processingFile = 'CSK_MultiDataLogger_Processing' -- which file to use for processing (will be started in own thread)
  --self.parameters.showImage = true -- Short docu of variable
  --self.parameters.paramA = 'paramA' -- Short docu of variable
  --self.parameters.paramB = 123 -- Short docu of variable

  self.parameters.internalObject = {} -- optionally
  --self.parameters.selectedObject = 1 -- Which object is currently selected
  --[[
    for i = 1, 10 do
    local obj = {}

    obj.objectName = 'Object' .. tostring(i) -- name of the object
    obj.active = false  -- is this object active
    -- ...

    table.insert(self.parameters.internalObject, obj)
  end

  local internalObjectContainer = self.helperFuncs.convertTable2Container(self.parameters.internalObject)
  ]]

  -- Parameters to give to the processing script
  self.multiDataLoggerProcessingParams = Container.create()
  self.multiDataLoggerProcessingParams:add('multiDataLoggerInstanceNumber', multiDataLoggerInstanceNo, "INT")
  self.multiDataLoggerProcessingParams:add('registeredEvent', self.parameters.registeredEvent, "STRING")
  --self.multiDataLoggerProcessingParams:add('showImage', self.parameters.showImage, "BOOL")
  --self.multiDataLoggerProcessingParams:add('viewerId', 'multiDataLoggerViewer' .. self.multiDataLoggerInstanceNoString, "STRING")

  --self.multiDataLoggerProcessingParams:add('internalObjects', internalObjectContainer, "OBJECT") -- optionally
  --self.multiDataLoggerProcessingParams:add('selectedObject', self.parameters.selectedObject, "INT")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiDataLoggerProcessingParams)

  return self
end

--[[
--- Some internal code docu for local used function to do something
function multiDataLogger:doSomething()
  self.object:doSomething()
end

--- Some internal code docu for local used function to do something else
function multiDataLogger:doSomethingElse()
  self:doSomething() --> access internal function
end
]]

return multiDataLogger

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************