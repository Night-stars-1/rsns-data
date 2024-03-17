local View = require("UIHomePetStore/UIHomePetStoreView")
local DataModel = require("UIHomePetStore/UIHomePetStoreDataModel")
local Controller = require("UIHomePetStore/UIHomePetStoreController")
local ViewFunction = require("UIHomePetStore/UIHomePetStoreViewFunction")
local Luabehaviour = {
  serialize = function()
  end,
  deserialize = function(initParams)
    if initParams ~= nil then
      local t = Json.decode(initParams)
      DataModel.StationId = t.stationId
      DataModel.NpcId = t.npcId
      DataModel.BgPath = t.bgPath
      DataModel.BgColor = t.bgColor or "FFFFFF"
      DataModel.BgColor = "#" .. DataModel.BgColor
      DataModel.CanSaleList = {}
      DataModel.ShopIdToRecycle = {}
      DataModel.CurTradeType = 0
      DataModel.CurTabType = 0
      Controller:Init()
    end
  end,
  awake = function()
  end,
  start = function()
  end,
  update = function()
  end,
  ondestroy = function()
  end,
  enable = function()
  end,
  disenable = function()
  end
}
return {
  Luabehaviour,
  View,
  ViewFunction
}
