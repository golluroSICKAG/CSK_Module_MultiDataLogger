--[[
++============================================================================++
||                                                                            ||
||  Inside of this script, you will find helper functions.                    ||
||                                                                            ||
++============================================================================++
]]--
---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--[[ ********************************************************************** ]]--
--[[ ************************ Start of Global Scope *********************** ]]--
--[[ ********************************************************************** ]]--

local funcs = {}
-- Providing access to standard JSON functions.
funcs.json = require( "Data/MultiDataLogger/helper/Json" )

--[[ ********************************************************************** ]]--
--[[ ************************* End of Global Scope ************************ ]]--
--[[ ********************************************************************** ]]--

--[[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]]--
--[[ :::::::::::::::::: Start of Function and Event Scope ::::::::::::::::: ]]--
--[[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]]--

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Create a string containing a list with a sequence of numbers.
---@param inSize int Size of the list
---@return string outString List of numbers
local function createStringListBySize(inSize)
  local outString = "["
  if inSize >= 1 then
    outString = outString .. '"' .. tostring(1) .. '"'
  end
  if inSize >= 2 then
    for i=2, inSize, 1 do
      outString = outString .. ", " .. '"' .. tostring(i) .. '"'
    end
  end
  outString = outString .. "]"

  return outString
end
funcs.createStringListBySize = createStringListBySize

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Convert a table into a 'Container' object.
---@param inContent auto[] Lua table to convert to 'Container'
---@return Container outContainer Created 'Container'
local function convertTable2Container(inContent)
  local outContainer = Container.create()
  for key, value in pairs(inContent) do
    if type(value) == "table" then
      outContainer:add(key, convertTable2Container(value), nil)
    else
      outContainer:add(key, value, nil)
    end
  end

  return outContainer
end
funcs.convertTable2Container = convertTable2Container

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Convert a 'Container' object into a table.
---@param inContainer Container 'Container' to convert to Lua table
---@return auto[] outData Created Lua table
local function convertContainer2Table(inContainer)
  local outData = {}
  local containerList = Container.list(inContainer)
  local containerCheck = false
  if tonumber(containerList[1]) ~= nil then
    containerCheck = true
  end
  for i=1, #containerList, 1 do
    local subContainer

    if containerCheck == true then
      subContainer = Container.get(inContainer, tostring(i) .. ".00")
    else
      subContainer = Container.get(inContainer, containerList[i])
    end
    if type(subContainer) == "userdata" then
      if Object.getType(subContainer) == "Container" then

        if containerCheck == true then
          table.insert(outData, convertContainer2Table(subContainer))
        else
          outData[containerList[i]] = convertContainer2Table(subContainer)
        end

      else
        if containerCheck == true then
          table.insert(outData, subContainer)
        else
          outData[containerList[i]] = subContainer
        end
      end
    else
      if containerCheck == true then
        table.insert(outData, subContainer)
      else
        outData[containerList[i]] = subContainer
      end
    end
  end

  return outData
end
funcs.convertContainer2Table = convertContainer2Table

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Get a content list out of a string table.
---@param inStringTable string[] String table with data entries
---@return string sortedTable Sorted entries as string, internally separated by ','
local function createContentList(inStringTable)
  local sortedTable = {}
  for key, _ in pairs(inStringTable) do
    table.insert(sortedTable, key)
  end
  table.sort(sortedTable)

  return table.concat(sortedTable, ",")
end
funcs.createContentList = createContentList

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Get a content list as a JSON string out of a string table.
---@param inStringTable string[] String table with data entries
---@return string sortedTable Sorted entries as JSON string
local function createJsonList(inStringTable)
  local sortedTable = {}
  for key, _ in pairs(inStringTable) do
    table.insert(sortedTable, key)
  end
  table.sort(sortedTable)

  return funcs.json.encode(sortedTable)
end
funcs.createJsonList = createJsonList

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Create a string of all elements of a table.
---@param inStringTable string[] String table with data entries
---@return string outString List of data entries
local function createStringListBySimpleTable(inStringTable)
  if inStringTable ~= nil then
    local outString = "["
    if #inStringTable >= 1 then
      outString = outString .. '"' .. inStringTable[1] .. '"'
    end
    if #inStringTable >= 2 then
      for i=2, #inStringTable, 1 do
        outString = outString .. ", " .. '"' .. inStringTable[i] .. '"'
      end
    end
    outString = outString .. "]"

    return outString
  else

    return ""
  end
end
funcs.createStringListBySimpleTable = createStringListBySimpleTable

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Recursively create subfolder(s) if it does not yet exist.
---@param inPosition int Position to start searching for a slash
---@param inPath string Full file path to search for subfolder(s)
local function createRecursiveFolder(inPosition, inPath)
  local foundPos = string.find(inPath, "/", inPosition)
  if foundPos ~= nil then
    local found2ndPos = string.find(inPath, "/", foundPos + 1)
    if found2ndPos~= nil
       and found2ndPos ~= #inPath then
      local folderToCheck = string.sub(inPath, 1, found2ndPos)
      local folderExists = File.isdir(folderToCheck)
      if folderExists == false then
        File.mkdir(folderToCheck)
      end

      return createRecursiveFolder(foundPos + 1, inPath)
    else
      local folderExists = File.isdir(inPath)
      if folderExists == true then
        --_G.logger:info(nameOfModule .. ": Folder '" .. path .. "' already exists.")
      else
        File.mkdir(inPath)

        return
      end
    end
  else

    return
  end
end
funcs.createRecursiveFolder = createRecursiveFolder

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Create required file path if it does not yet exist.
---@param inFilePath string Full required file path
local function createFolder(inFilePath)
  if string.sub(inFilePath, 1, 1) == "/" then
    createRecursiveFolder(1, inFilePath)
  else
    createRecursiveFolder(1, "/" .. inFilePath)
  end
end
funcs.createFolder = createFolder

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Provide a table with currently available events.
---@return string[] outStringTable String table of available events
local function getAvailableEvents()
  local outStringTable = {}
  local appNames = Engine.listApps()
  for key, value in pairs(appNames) do
    local startPos = string.find(value, "_", 5)
    if startPos ~= nil then
      local crownName = "CSK" .. string.sub(value, startPos, #value)
      local content = Engine.getCrownAsXML(crownName)
      local lastSearchPos = 0

      while true do
        local _, eventStart = string.find(content, 'event name="', lastSearchPos)
        if eventStart ~= nil then
          lastSearchPos = eventStart + 1
          local endPos = string.find(content, '"', eventStart + 1)
          if endPos ~= nil then
            local eventName = crownName .. "." .. string.sub(content, eventStart + 1, endPos - 1)
            table.insert(outStringTable, eventName)
          end
        else

          break
        end
      end
    end
  end

  return outStringTable
end
funcs.getAvailableEvents = getAvailableEvents

return funcs

--[[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]]--
--[[ ::::::::::::::::::: End of Function and Event Scope :::::::::::::::::: ]]--
--[[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]]--
