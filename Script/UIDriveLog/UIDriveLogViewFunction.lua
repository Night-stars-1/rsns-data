local View = require("UIDriveLog/UIDriveLogView")
local DataModel = require("UIDriveLog/UIDriveLogDataModel")
local mainView = require("UIMainUI/UIMainUIView")
local ViewFunction = {
  DriveLog_Group_TrainInfo_ScrollView__Viewport_Content_Img_Bg1_Img_Durability_Btn__Click = function(btn, str)
    if DataModel.durability >= DataModel.totalDurability then
      CommonTips.OpenTips(80601009)
      return
    end
    local delta = DataModel.totalDurability - DataModel.durability
    local homeConfig = PlayerData:GetFactoryData(99900014, "ConfigFactory")
    local costInfo = homeConfig.repairpriceList[1]
    local cost = delta * costInfo.num
    cost = math.floor(cost * (1 - PlayerData:GetHomeSkillIncrease(EnumDefine.HomeSkillEnum.ReduceRepairCost)) + 0.5)
    CommonTips.OnPrompt(string.format(GetText(80601024), cost), nil, nil, function()
      Net:SendProto("home.repair", function(json)
        DataModel.durability = json.readiness.repair.current_durable
        local item1 = View.Group_TrainInfo.ScrollView_.Viewport.Content.Img_Bg1
        item1.Img_Durability.Txt_1.Txt_2:SetText(DataModel.durability .. "/" .. DataModel.totalDurability)
      end)
    end)
  end,
  DriveLog_Group_TrainInfo_ScrollView__Viewport_Content_Img_Bg1_Img_TrainName_Btn__Click = function(btn, str)
    View.Group_ChangeName:SetActive(true)
  end,
  DriveLog_Group_ChangeName_Btn_Close_Click = function(btn, str)
  end,
  DriveLog_Group_ChangeName_Btn_Confirm_Click = function(btn, str)
    local name = View.Group_ChangeName.InputField_ChangeName:GetText()
    Net:SendProto("home.update_name", function(json)
      PlayerData.ServerData.user_home_info.home_name = name
      DataModel.trainName = PlayerData.ServerData.user_home_info.home_name
      View.Group_TrainInfo.ScrollView_.Viewport.Content.Img_Bg1.Img_TrainName.Txt_1.Txt_2:SetText(DataModel.trainName)
      View.Group_ChangeName:SetActive(false)
    end, name)
  end,
  DriveLog_Group_ChangeName_Btn_Cancel_Click = function(btn, str)
    View.Group_ChangeName:SetActive(false)
  end,
  DriveLog_Btn__Click = function(btn, str)
  end,
  DriveLog_Group_CommonTopLeft_Btn_Return_Click = function(btn, str)
    if DataModel.playMainAni then
      mainView.self:PlayAnim("InMove")
    end
    View.self:PlayAnim("Out", function()
      mainView.timer:Resume()
      UIManager:GoBack(not DataModel.playMainAni)
    end)
  end,
  DriveLog_Group_CommonTopLeft_Btn_Home_Click = function(btn, str)
    if DataModel.playMainAni then
      mainView.self:PlayAnim("InMove")
      View.self:PlayAnim("Out", function()
        mainView.timer:Resume()
        UIManager:GoBack(not DataModel.playMainAni)
      end)
      return
    end
    UIManager:GoHome()
  end,
  DriveLog_Group_CommonTopLeft_Btn_Menu_Click = function(btn, str)
  end,
  DriveLog_Group_CommonTopLeft_Btn_Help_Click = function(btn, str)
  end
}
return ViewFunction
