---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
local availableAPIs = require('Data/MultiDataLogger/helper/checkAPIs') -- check for available APIs
-----------------------------------------------------------
local nameOfModule = 'CSK_MultiDataLogger'
--Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

local helperFuncs = require('Data/MultiDataLogger/helper/funcs') -- Load helper functions

local scriptParams = Script.getStartArgument() -- Get parameters from model

local multiDataLoggerInstanceNumber = scriptParams:get('multiDataLoggerInstanceNumber') -- number of this instance
local multiDataLoggerInstanceNumberString = tostring(multiDataLoggerInstanceNumber) -- number of this instance as string

-- Event to forward content from this thread to Controller to show e.g. on UI
Script.serveEvent("CSK_MultiDataLogger.OnNewValueToForward".. multiDataLoggerInstanceNumberString, "MultiDataLogger_OnNewValueToForward" .. multiDataLoggerInstanceNumberString, 'string, auto')
-- Event to forward update of e.g. parameter update to keep data in sync between threads
Script.serveEvent("CSK_MultiDataLogger.OnNewValueUpdate" .. multiDataLoggerInstanceNumberString, "MultiDataLogger_OnNewValueUpdate" .. multiDataLoggerInstanceNumberString, 'int, string, auto, int:?')

local processingParams = {}
processingParams.registeredEvent = scriptParams:get('registeredEvent')
processingParams.activeInUI = false

processingParams.path = scriptParams:get('path') -- Path to store data
processingParams.dataMode = scriptParams:get('dataMode') -- Mode to log data
processingParams.dataType = scriptParams:get('dataType') -- Type of data to log
processingParams.csvFilename = scriptParams:get('csvFilename') -- CSV filename
processingParams.csvLabels = scriptParams:get('csvLabels') -- CSV labels
processingParams.saveOnlyChanges = scriptParams:get('saveOnlyChanges') -- Only save changes within CSV file
processingParams.saveDataDirectly = scriptParams:get('saveDataDirectly') -- Save CSV data automatically
processingParams.imageType = scriptParams:get('imageType') -- Mode to log data
processingParams.imageCompressionValue = scriptParams:get('imageCompressionValue') -- Mode to log data

local latestValue = ''
local dataArray = {}

--- Function to save temp log to file
local function saveCSVLog()

  local success
  local completeFilepath = processingParams.path .. processingParams.csvFilename .. '.csv'

  if not File.exists(completeFilepath) then
    local data = processingParams.csvLabels .. "\n"
    local newFile = File.open(completeFilepath, "wb")

    if (newFile ~= nil) then
      success = File.write(newFile, data)
      File.close(newFile)
    else
      _G.logger:warning(nameOfModule .. ": Did not work to create data file.")
    end
  end

  local data = ''
  for i = 1, #dataArray do
    for k, v in pairs(dataArray[i]) do
      data = data .. tostring(k)
      data = data .. "," .. v
      data = data .. "\n"
    end
  end

  local file = File.open(completeFilepath, "ab")
  if (file ~= nil) then
    success = File.write(file, data)
    File.close(file)
    dataArray = {}
  end
end

local function handleOnNewProcessing(dataContent, filename)

  _G.logger:fine(nameOfModule .. ": Check object on instance No." .. multiDataLoggerInstanceNumberString)

  if processingParams.dataMode == 'file' then
    local dataAsString = tostring(dataContent)
    if processingParams.dataType == 'csv' then

      -- Check change of data
      if dataAsString ~= latestValue or not processingParams.saveOnlyChanges then

        local day, month, year, hour, min, sec, ms = DateTime.getDateTimeValuesLocal()
        local formDateTime = string.format( "%04u-%02u-%02uT%02u:%02u:%02u.%03u", year, month, day, hour, min, sec, ms )

        -- Combine Values with timestamp
        local logKeyPair = {}
        logKeyPair[formDateTime] = dataAsString

        --Save with indeces
        dataArray[(#dataArray+1)] = logKeyPair
        latestValue = dataAsString

        if processingParams.saveDataDirectly then
          saveCSVLog()
        end
      end
    else
      -- JSON
      local tempFile
      if filename then
        tempFile = File.open(processingParams.path .. filename .. '.' .. processingParams.dataType, 'wb' )
      else
        local timestamp = tostring(DateTime.getTimestamp())
        tempFile = File.open(processingParams.path .. 'Data_' .. timestamp .. '.' .. processingParams.dataType, 'wb' )
      end
      File.write(tempFile, dataAsString)
      File.close(tempFile)
    end
  elseif processingParams.dataMode == 'image' then
    if processingParams.imageType == 'jpg' or processingParams.imageType == 'png' then
      if filename then
        Image.save(dataContent, processingParams.path .. filename .. '.' .. processingParams.imageType, processingParams.imageCompressionValue)
      else
        local timestamp = tostring(DateTime.getTimestamp())
        Image.save(dataContent, processingParams.path .. 'IMG_' .. timestamp .. '.' .. processingParams.imageType, processingParams.imageCompressionValue)
      end
    else
      if filename then
        Image.save(dataContent, processingParams.path .. filename .. '.' .. processingParams.imageType)
      else
        local timestamp = tostring(DateTime.getTimestamp())
        Image.save(dataContent, processingParams.path .. 'IMG_' .. timestamp .. '.' .. processingParams.imageType)
      end
    end
  end
end

--- Function to handle updates of processing parameters from Controller
---@param multiDataLoggerNo int Number of instance to update
---@param parameter string Parameter to update
---@param value auto Value of parameter to update
---@param internalObjectNo int? Number of object
local function handleOnNewProcessingParameter(multiDataLoggerNo, parameter, value, internalObjectNo)

  if multiDataLoggerNo == multiDataLoggerInstanceNumber then -- set parameter only in selected script
    _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiDataLoggerInstanceNo." .. tostring(multiDataLoggerNo) .. " to value = " .. tostring(value))

    if parameter == 'registeredEvent' then
      _G.logger:fine(nameOfModule .. ": Register instance " .. multiDataLoggerInstanceNumberString .. " on event " .. value)
      if processingParams.registeredEvent ~= '' then
        Script.deregister(processingParams.registeredEvent, handleOnNewProcessing)
      end
      processingParams.registeredEvent = value
      Script.register(value, handleOnNewProcessing)

    elseif parameter == 'path' then

      helperFuncs.createFolder(value)

      if string.sub(value, #value, #value) == '/' then
        processingParams[parameter] = value
      else
        processingParams[parameter] = value .. '/'
      end

    elseif parameter == 'saveCSVFile' then
      saveCSVLog()

    else
      processingParams[parameter] = value
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end
end
Script.register("CSK_MultiDataLogger.OnNewProcessingParameter", handleOnNewProcessingParameter)
