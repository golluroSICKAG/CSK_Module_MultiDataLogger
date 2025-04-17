---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find helper functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

local nameOfModule = 'CSK_MultiDataLogger'

local funcs = {}
-- Providing standard JSON functions
funcs.json = require('Data/MultiDataLogger/helper/Json')
-- Default parameters for instances of module
funcs.defaultParameters = require('Data/MultiDataLogger/MultiDataLogger_Parameters')

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to create a list with numbers
---@param size int Size of the list
---@return string list List of numbers
local function createStringListBySize(size)
  local list = "["
  if size >= 1 then
    list = list .. '"' .. tostring(1) .. '"'
  end
  if size >= 2 then
    for i=2, size do
      list = list .. ', ' .. '"' .. tostring(i) .. '"'
    end
  end
  list = list .. "]"
  return list
end
funcs.createStringListBySize = createStringListBySize

--- Function to convert a table into a Container object
---@param content auto[] Lua Table to convert to Container
---@return Container cont Created Container
local function convertTable2Container(content)
  local cont = Container.create()
  for key, value in pairs(content) do
    if type(value) == 'table' then
      cont:add(key, convertTable2Container(value), nil)
    else
      cont:add(key, value, nil)
    end
  end
  return cont
end
funcs.convertTable2Container = convertTable2Container

--- Function to convert a Container into a table
---@param cont Container Container to convert to Lua table
---@return auto[] data Created Lua table
local function convertContainer2Table(cont)
  local data = {}
  local containerList = Container.list(cont)
  local containerCheck = false
  if tonumber(containerList[1]) then
    containerCheck = true
  end
  for i=1, #containerList do

    local subContainer

    if containerCheck then
      subContainer = Container.get(cont, tostring(i) .. '.00')
    else
      subContainer = Container.get(cont, containerList[i])
    end
    if type(subContainer) == 'userdata' then
      if Object.getType(subContainer) == "Container" then

        if containerCheck then
          table.insert(data, convertContainer2Table(subContainer))
        else
          data[containerList[i]] = convertContainer2Table(subContainer)
        end

      else
        if containerCheck then
          table.insert(data, subContainer)
        else
          data[containerList[i]] = subContainer
        end
      end
    else
      if containerCheck then
        table.insert(data, subContainer)
      else
        data[containerList[i]] = subContainer
      end
    end
  end
  return data
end
funcs.convertContainer2Table = convertContainer2Table

--- Function to get content list out of table
---@param data string[] Table with data entries
---@return string sortedTable Sorted entries as string, internally seperated by ','
local function createContentList(data)
  local sortedTable = {}
  for key, _ in pairs(data) do
    table.insert(sortedTable, key)
  end
  table.sort(sortedTable)
  return table.concat(sortedTable, ',')
end
funcs.createContentList = createContentList

--- Function to get content list as JSON string
---@param data string[] Table with data entries
---@return string sortedTable Sorted entries as JSON string
local function createJsonList(data)
  local sortedTable = {}
  for key, _ in pairs(data) do
    table.insert(sortedTable, key)
  end
  table.sort(sortedTable)
  return funcs.json.encode(sortedTable)
end
funcs.createJsonList = createJsonList

--- Function to create a list from table
---@param content string[] Table with data entries
---@return string list String list
local function createStringListBySimpleTable(content)
  local list = "["
  if #content >= 1 then
    list = list .. '"' .. content[1] .. '"'
  end
  if #content >= 2 then
    for i=2, #content do
      list = list .. ', ' .. '"' .. content[i] .. '"'
    end
  end
  list = list .. "]"
  return list
end
funcs.createStringListBySimpleTable = createStringListBySimpleTable

---@param pos int Position to start to search for a slash
---@param path string Full file path to search for subfolders
local function createRecursiveFolder(pos, path)
  local foundPos = string.find(path, '/', pos)
  if foundPos then
    local found2ndPos = string.find(path, '/', foundPos+1)
    if found2ndPos and found2ndPos ~= #path then
      local folderToCheck = string.sub(path, 1, found2ndPos)
      local folderExists = File.isdir(folderToCheck)
      if not folderExists then
        local suc = File.mkdir(folderToCheck)
      end
      return createRecursiveFolder(foundPos+1, path)
    else
      local folderExists = File.isdir(path)
      if not folderExists then
        local suc = File.mkdir(path)
        return
      end
    end
  else
    return
  end
end
funcs.createRecursiveFolder = createRecursiveFolder

local function createFolder(path)
  if string.sub(path, 1, 1) == '/' then
    createRecursiveFolder(1, path)
  else
    createRecursiveFolder(1, '/' .. path)
  end
end
funcs.createFolder = createFolder

local function getAvailableEvents()
  local listOfEvents = {}

  local appNames = Engine.listApps()

  for key, value in pairs(appNames) do
    local startPos = string.find(value, '_', 5)
    if startPos then
      local crownName = 'CSK' .. string.sub(value, startPos, #value)
      local content = Engine.getCrownAsXML(crownName)
      local lastSearchPos = 0
      if content then

        while true do
          local _, eventStart = string.find(content, 'event name="', lastSearchPos)
          if eventStart then
            lastSearchPos = eventStart+1
            local endPos = string.find(content, '"', eventStart+1)
            if endPos then
              local eventName = crownName .. '.' .. string.sub(content, eventStart+1, endPos-1)
              table.insert(listOfEvents, eventName)
            end
          else
            break
          end
        end
      end
    end
  end
  return listOfEvents
end
funcs.getAvailableEvents = getAvailableEvents


--- Function to compare table content. Optionally will fill missing values within content table with values of defaultTable
---@param content auto Data to check
---@param defaultTable auto Reference data
---@return auto[] content Update of data
local function checkParameters(content, defaultTable)
  for key, value in pairs(defaultTable) do
    if type(value) == 'table' then
      if content[key] == nil then
        _G.logger:info(nameOfModule .. ": Created missing parameters table '" .. tostring(key) .. "'")
        content[key] = {}
      end
      content[key] = checkParameters(content[key], defaultTable[key])
    elseif content[key] == nil then
      _G.logger:info(nameOfModule .. ": Missing parameter '" .. tostring(key) .. "'. Adding default value '" .. tostring(defaultTable[key]) .. "'")
      content[key] = defaultTable[key]
      if key == 'cameraNo' then
        _G.logger:warning(nameOfModule .. ": '" .. tostring(key) .. "' is a major parameter! Default value might not work and needs to be edited!")
      end
    end
  end
  return content
end
funcs.checkParameters = checkParameters

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************