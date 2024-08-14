--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Data.MultiDataLogger.FlowConfig.MultiDataLogger_DataSource')

-- Reference to the multiImageFilter_Instances handle
local multiDataLogger_Instances

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default then
    for i = 1, #multiDataLogger_Instances do
      if multiDataLogger_Instances[i].parameters.flowConfigPriority then
        CSK_MultiDataLogger.clearFlowConfigRelevantConfiguration()
        break
      end
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)

--- Function to get access to the multiDataLogger_Instances
---@param handle handle Handle of multiDataLogger_Instances object
local function setMultiDataLogger_Instances_Handle(handle)
  multiDataLogger_Instances = handle
end

return setMultiDataLogger_Instances_Handle