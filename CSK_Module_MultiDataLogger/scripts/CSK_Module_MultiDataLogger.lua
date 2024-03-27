--MIT License
--
--Copyright (c) 2023 SICK AG
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- 
-- CreationTemplateVersion: 3.6.0
--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

-- If app property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection

_G.availableAPIs = require('Data/MultiDataLogger/helper/checkAPIs') -- can be used to adjust function scope of the module related on available APIs of the device
-----------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
_G.logHandle = Log.Handler.create()
_G.logHandle:attachToSharedLogger('ModuleLogger')
_G.logHandle:setConsoleSinkEnabled(false) --> Set to TRUE if CSK_Logger is not used
_G.logHandle:setLevel("ALL")
_G.logHandle:applyConfig()
-----------------------------------------------------------

-- Loading script regarding MultiDataLogger_Model
-- Check this script regarding MultiDataLogger_Model parameters and functions
local multiDataLogger_Model = require('Data/MultiDataLogger/MultiDataLogger_Model')

local multiDataLogger_Instances = {} -- Handle all instances
table.insert(multiDataLogger_Instances, multiDataLogger_Model.create(1)) -- Create at least 1 instance

-- Load script to communicate with the MultiDataLogger_Model UI
-- Check / edit this script to see/edit functions which communicate with the UI
local multiDataLoggerController = require('Data/MultiDataLogger/MultiDataLogger_Controller')
multiDataLoggerController.setMultiDataLogger_Instances_Handle(multiDataLogger_Instances) -- share handle of instances

--**************************************************************************
--**********************End Global Scope ***********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on startup event of the app
local function main()

  multiDataLoggerController.setMultiDataLogger_Model_Handle(multiDataLogger_Model) -- share handle of Model

  ----------------------------------------------------------------------------------------
  -- INFO: Please check if module will eventually load inital configuration triggered via
  --       event CSK_PersistentData.OnInitialDataLoaded
  --       (see internal variable _G.multiDataLogger_Model.parameterLoadOnReboot)
  --       If so, the app will trigger the "OnDataLoadedOnReboot" event if ready after loading parameters
  --
  -- Can be used e.g. like this

  --[[
  -- File
  CSK_MultiDataLogger.setSelectedInstance(1)
  CSK_MultiDataLogger.setPath('/public/MetaData/')
  CSK_MultiDataLogger.setDataMode('file')
  CSK_MultiDataLogger.setDataType('json')
  CSK_MultiDataLogger.setRegisterEvent('CSK_OtherModule.OnNewLogData')

  -- Image
  CSK_MultiDataLogger.addInstance()
  CSK_MultiDataLogger.setSelectedInstance(2)
  CSK_MultiDataLogger.setPath('/public/ImageData/')
  CSK_MultiDataLogger.setDataMode('image')
  CSK_MultiDataLogger.setImageType('bmp')
  CSK_MultiDataLogger.setRegisterEvent('CSK_OtherModule.OnNewImage')

  -- CSV data
  CSK_MultiDataLogger.addInstance()
  CSK_MultiDataLogger.setSelectedInstance(3)
  CSK_MultiDataLogger.setPath('/public/Data/')
  CSK_MultiDataLogger.setDataMode('file')
  CSK_MultiDataLogger.setImageType('csv')
  CSK_MultiDataLogger.setCSVFilename('csvDataFile')
  CSK_MultiDataLogger.setCSVLabels('DateTime, ValueA, ValueB')
  CSK_MultiDataLogger.setSaveOnlyChanges(true)
  CSK_MultiDataLogger.setSaveDataDirectly(false)
  CSK_MultiDataLogger.setRegisterEvent('CSK_OtherModule.OnNewImage')
  ]]
  ----------------------------------------------------------------------------------------

  CSK_MultiDataLogger.pageCalled() -- Update UI

end
Script.register("Engine.OnStarted", main)

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************