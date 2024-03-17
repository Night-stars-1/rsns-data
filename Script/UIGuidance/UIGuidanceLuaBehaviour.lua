local View = require("UIGuidance/UIGuidanceView")
local DataModel = require("UIGuidance/UIGuidanceDataModel")
local ViewFunction = require("UIGuidance/UIGuidanceViewFunction")
local Controller = require("UIGuidance/UIGuidanceController")
local Luabehaviour = {
  serialize = function()
  end,
  deserialize = function(initParams)
    Controller.IsOpen = true
  end,
  awake = function()
  end,
  start = function()
  end,
  update = function()
  end,
  ondestroy = function()
    Controller.RecycleSound()
    Controller.IsOpen = false
  end
}
return {
  Luabehaviour,
  View,
  ViewFunction
}
