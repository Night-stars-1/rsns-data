local Order = {}
local isFinish = false

function Order:OnStart(ca)
  local pos = HomeManager:GetCurRoomFurnitureTruePos(ca.furnitureId)
  HomeManager:HomeCameraMoveXTween(pos, ca.moveTime, function()
    isFinish = true
  end)
end

function Order:IsFinish()
  return isFinish
end

return Order
