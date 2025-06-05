--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Data.MultiDataLogger.FlowConfig.MultiDataLogger_DataSource')

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default then
    CSK_MultiDataLogger.clearFlowConfigRelevantConfiguration()
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
