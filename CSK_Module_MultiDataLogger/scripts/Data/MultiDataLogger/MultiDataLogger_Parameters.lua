---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()

  local multiDataLoggerParameters = {}
  multiDataLoggerParameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  multiDataLoggerParameters.registeredEvent = '' -- If thread internal function should react on external event, define it here, e.g. 'CSK_OtherModule.OnNewInput'
  multiDataLoggerParameters.processingFile = 'CSK_MultiDataLogger_Processing' -- which file to use for processing (will be started in own thread)
  multiDataLoggerParameters.path = '/public/'

  multiDataLoggerParameters.dataMode = 'file' -- Mode to log data like 'image', 'file'
  multiDataLoggerParameters.dataType = 'json' -- 'json', 'csv'
  multiDataLoggerParameters.csvFilename = 'csvFile'
  multiDataLoggerParameters.csvLabels = '' -- e.g. 'DateTime, ValueA, ValueB'
  multiDataLoggerParameters.csvLimit = false -- Status if CSV is limited to a maximum amount of entries
  multiDataLoggerParameters.csvLimitAmount = 100 -- Maximum CSV entries if limited
  multiDataLoggerParameters.saveOnlyChanges = true
  multiDataLoggerParameters.saveDataDirectly = false

  multiDataLoggerParameters.imageType = 'bmp' -- 'jpg', 'png', 'json', 'msgpack', 'bmp'
  multiDataLoggerParameters.imageCompressionValue = 80

  return multiDataLoggerParameters
end
functions.getParameters = getParameters

return functions