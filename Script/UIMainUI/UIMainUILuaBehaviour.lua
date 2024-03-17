local View = require("UIMainUI/UIMainUIView")
local ViewFunction = require("UIMainUI/UIMainUIViewFunction")
local Controller = require("UIMainUI/UIMainUIController")
local DataModel = require("UIMainUI/UIMainUIDataModel")
local TradeDataModel = require("UIHome/UIHomeTradeDataModel")
local TradeController = require("UIHome/UIHomeTradeController")
local MapDataModel = require("UIHome/UIHomeMapDataModel")
local MapController = require("UIHome/UIHomeMapController")
local HomeController = require("UIHome/UIHomeController")
local HomeCoachDataModel = require("UIHomeCoach/UIHomeCoachDataModel")
local HomeCoachController = require("UIHomeCoach/UIHomeCoachController")
local Timer = require("Common/Timer")
local RenderSettingController = require("UIMainUI/UIMainUIRenderSettingController")
local liveDataModel = require("UINewHomeLive/UINewHomeLiveDataModel")
local liveController = require("UINewHomeLive/UINewHomeLiveController")
local emergencyDataModel = require("UIHomeEmergency/UIHomeEmergencyDataModel")
local homeFoodController = require("UIHomeFood/UIHomeFoodController")
local RefreshMissIonRed = function()
  View.Group_Common.Group_TopRight.Btn_Mission.Img_Remind:SetActive(false)
  local row = PlayerData:GetBattlePassRedState()
  local count_1 = row.count_1
  local count_2 = row.count_2
  local count_3 = row.count_3
  if count_1 == true or count_2 == true or count_3 == true then
    View.Group_Common.Group_TopRight.Btn_Mission.Img_Remind:SetActive(true)
  end
end
local OpenPanelCallBack = function(prefabUrl)
  if prefabUrl == "UI/MainUI/MainUI" then
    local remainTime = DataModel.GetRushRemainTime()
    if remainTime == nil or remainTime <= 0 then
      Controller.SetRushEffectState()
      Controller.SetRushState(false)
    elseif remainTime < 18 and 0 < remainTime then
      Controller.SetRushState(false)
    end
  end
end
local BackgroundGravityMove = {
  _CurrentAcceleration = nil,
  _Config = {
    speed = 500,
    lerp = 0.05,
    xMaxDistance = 150,
    yMaxDistance = 80,
    kEpsilonSqrt = 50
  },
  InitParams = function(self)
    self._CurrentAcceleration = Input.acceleration
    local user_info = PlayerData:GetUserInfo()
    local Group_TopLeft = View.Group_TopLeft
    local Group_Left = View.Group_TopLeft
    if user_info == nil then
      Group_Left.Btn_Commander.Txt_Lv.Txt_Num_0:SetText(1)
      Group_Left.Btn_Commander.Txt_Name:SetText("")
      Group_Left.Btn_Commander.Txt_UID.Txt_Num_3:SetText("")
      Group_TopLeft.Btn_Diamond.Txt_Num:SetText(0)
      Group_TopLeft.Btn_Energy.Txt_Num:SetText(0)
      Group_TopLeft.Btn_Gold.Txt_Num:SetText(0)
    else
      Group_Left.Btn_Commander.Txt_Lv.Txt_Num_0:SetText(user_info.lv or 1)
      if user_info.role_name == nil then
        Group_Left.Btn_Commander.Txt_Name:SetText("")
      else
        Group_Left.Btn_Commander.Txt_Name:SetText(user_info.role_name)
      end
      Group_Left.Btn_Commander.Txt_UID.Txt_Num_3:SetText(user_info.uid)
      Group_TopLeft.Btn_Diamond.Txt_Num:SetText(user_info.bm_rock or 0)
      if user_info.max_energy then
        Group_TopLeft.Btn_Energy.Txt_Num:SetText(user_info.energy .. "/" .. user_info.max_energy or 0)
      else
        Group_TopLeft.Btn_Energy.Txt_Num:SetText(user_info.energy or 0)
      end
      Group_TopLeft.Btn_Gold.Txt_Num:SetText(user_info.gold or 0)
      local endExp = PlayerData:GetMaxExp()
      Group_Left.Btn_Commander.Group_ExpBar.Img_Bar:SetFilledImgAmount(user_info.exp / endExp)
    end
    local count, state = PlayerData:GetUnreadMailNum()
    View.Group_BottomLeft.Btn_Mail.Img_Remind.self:SetActive(state)
    View.Group_BottomLeft.Btn_Mail.Img_Remind.Txt_Num:SetText(count)
    View.Group_BottomLeft.Btn_Friends.Img_Remind.self:SetActive(false)
  end,
  GetPosition = function(self, currentPos)
    local x_move = Input.acceleration.x - self._CurrentAcceleration.x
    local y_move = Input.acceleration.y - self._CurrentAcceleration.y
    local position = Vector3()
    position.x = MathEx.Clamp(x_move * self._Config.speed, -self._Config.xMaxDistance, self._Config.xMaxDistance)
    position.y = MathEx.Clamp(y_move * self._Config.speed, -self._Config.yMaxDistance, self._Config.yMaxDistance)
    if (currentPos - position).sqrMagnitude > self._Config.kEpsilonSqrt then
      return Vector3.Lerp(currentPos, position, self._Config.lerp)
    end
    self._CurrentAcceleration = Input.acceleration
    return currentPos
  end
}
local AutoUseBullet = function()
  if not DataModel.isRun then
    return
  end
  if not DataModel.autoUseBullet then
    return
  end
  if PlayerData:GetHomeInfo().readiness.fuel.fuel_num <= 0 then
    return
  end
  if PlayerData.TempCache.MainUIShowState == DataModel.UIShowEnum.Coach or DataModel.CurSceneName == DataModel.SceneNameEnum.Home then
    return
  end
  Controller.Rush()
end
local Luabehaviour = {
  serialize = function()
    local t = {}
    t.ShowPosterGirl = DataModel.isPosterGirlShow
    t.IsGoHomeCoach = DataModel.IsGoHomeCoach
    return Json.encode(t)
  end,
  deserialize = function(initParams)
    local forceShowPosterGirl = false
    if initParams ~= nil then
      local data = Json.decode(initParams)
      if data.ShowPosterGirl ~= nil and DataModel.isPosterGirlShow then
        forceShowPosterGirl = data.ShowPosterGirl
      end
      if data.IsGoHomeCoach ~= nil then
        DataModel.IsGoHomeCoach = true
      end
    end
    DataModel.CurFrame = 0
    DataModel.FirstFrame = true
    DataModel.GetCurShowSceneInfo()
    DataModel.roleId = ""
    Controller:ShowPosterGirl(false)
    DataModel.CurSceneName = MainManager.bgSceneName
    View.self:SetEnableAnimator(true)
    DataModel.isOpenView = true
    Controller:Init()
    Controller:InitCommonShow()
    Controller:ChangeDashBoard()
    DataModel.curTimeEffect = ""
    PlayerData.FreeCameraIndex = PlayerData.FreeCameraIndex or 1
    TradeDataModel.CurRemainDistance = TrainManager.RemainDistance
    if PlayerData.TempCache.FirstLogin then
      if not TrainManager.IsRunning then
        DataModel.RefreshData(PlayerData.ServerData.user_home_info.coach)
        TradeDataModel.Refresh3DTravelInfoNew(EnumDefine.TrainStateEnter.FirstLogin)
        Controller.ChangeDriveBtnState()
      end
      PlayerData.TempCache.FirstLogin = false
    end
    if PlayerData.TempCache.EventFinish then
      Controller.MainLineEventShow(DataModel.TrainEventId, false, false)
      Controller:RunBtnState(true)
      Controller.OpenBattleLoss()
      MapController:SetPolluteLines()
    else
      Controller.MainLineEventShow(DataModel.TrainEventId, true, false)
    end
    Controller:PlayBGM()
    Controller.SetSpeedAddShow()
    Controller.ShowWarning(false)
    TradeDataModel.RefreshStockInfo()
    MapDataModel.TravelLineWayPoints = {}
    MapDataModel.HomeMapType = 1
    MapController:ShowDetailMap(false, true)
    Controller.ChangeDriveBtnState()
    Controller:InitDrinkBuffShow()
    Controller:InitSpeedUpBuffShow()
    Controller:InitBattleUpBuffShow()
    Controller.RefreshTrainMove(true)
    if PlayerData.TempCache.MainUIShowState ~= 0 then
      Controller:SwitchTab(PlayerData.TempCache.MainUIShowState, true)
    end
    if DataModel.CurSceneName == DataModel.SceneNameEnum.Main then
      TradeDataModel.DelayPer = 0
      local guideId = GuideManager:GetCurrentClientGuideNO()
      if guideId == -1 then
        guideId = PlayerData:GetUserInfo().newbie_step
      end
      if 5 < guideId then
        TradeDataModel.SetTrainMode(function()
          View.Group_Common.Group_Position.self:SetActive(TradeDataModel.GetInTravel())
          Controller:InitCheDengLight()
          Controller.SetTrainBreakEffect()
          PlayerData:GetPolluteTurntable()
          if TrainManager.CurrTrainState == TrainState.Event then
            DataModel.SetCamera(2)
          else
            DataModel.SetCamera(PlayerData.FreeCameraIndex)
          end
          if PlayerData.BattleInfo.BattleResult and PlayerData.BattleInfo.BattleResult.isWin and PlayerData.BattleInfo.battleStageId then
            local sessionController = require("UIMapSession/UIMapSessionDataModelController")
            sessionController:ExitToSession(tonumber(PlayerData.BattleInfo.battleStageId))
          end
        end)
        if PlayerData.TempCache.MainUIShowState == 0 then
          Controller:SwitchTab(DataModel.UIShowEnum.OutSide, true)
        end
      end
    elseif DataModel.CurSceneName == DataModel.SceneNameEnum.Home then
      HomeCoachDataModel.InitRoomData(PlayerData.ServerData.user_home_info.furniture)
      HomeCharacterManager:ReShowAll()
      if PlayerData.TempCache.MainUIShowState == 0 then
        Controller:SwitchTab(DataModel.UIShowEnum.Coach, true)
      end
    end
    if LoadingManager.isLoading then
      LoadingManager:SetLoadingPercent(1)
    end
    Controller.SetQuestTrace()
    DataModel:InitRoleTrustData()
    Controller.ShowHelpButton()
    local isShowGetTrustBtn = TimeUtil:GetServerTimeStamp() - PlayerData:GetUserInfo().receptionist_ts > 3600 and false
    View.Group_Common.Group_PosterGirl.Btn_GetTrust:SetActive(isShowGetTrustBtn)
    RefreshMissIonRed()
    Controller.ReachNewCityRoleTip()
    if forceShowPosterGirl and not DataModel.isPosterGirlShow then
      Controller:ShowPosterGirl(true)
    end
    Controller.FuncActive()
    Controller.RepRedPointCheck()
    PlayerData:SetTargetFrameRate()
    if UseGSDK then
      GSDKManager:OnRequestProductInfo()
    end
    if DataModel.TrailerCityId then
      Controller.BackShow(false)
    end
    View.timer_2 = Timer.New(1, function()
      CommonTips.OpenMoonthCard()
      View.timer_2:Stop()
      View.timer_2 = nil
    end)
    View.timer_2:Start()
    PlayerData:SetSound()
    Controller.ShowEndActive(PlayerData:GetHomeInfo().station_info.is_arrived == 1)
    DataModel.autoUseBullet = PlayerData:GetPlayerPrefs("int", "autoUseBullet") ~= 0
  end,
  awake = function()
    MapDataModel.InitLineInfo()
    TradeDataModel.SpeedRatio = PlayerData:GetFactoryData(99900014, "ConfigFactory").speedRatio
    View.timer = Timer.New(3, function()
      if not LoadingManager.isLoading and MapDataModel.HomeMapType ~= 2 then
        Controller:RandomPlayRoleSound()
      else
        View.timer.delay = 2
      end
    end)
  end,
  start = function()
    DataModel.cameraTween = true
    DataModel.GetCurShowSceneInfo()
    DataModel.RefreshData(PlayerData.ServerData.user_home_info.coach)
    if MainManager.bgSceneName == DataModel.SceneNameEnum.Main then
      TrainCameraManager:SetPostProcessing(1, DataModel.CurShowSceneInfo.postProcessingPath)
      if PlayerData.TempCache.MainUIShowState ~= DataModel.UIShowEnum.OutSide and PlayerData.TempCache.MainUIShowState ~= DataModel.UIShowEnum.Passenger then
        Controller:SwitchTab(DataModel.UIShowEnum.OutSide)
      end
      Controller.InitTrain(false)
    elseif MainManager.bgSceneName == DataModel.SceneNameEnum.Home then
      if PlayerData.TempCache.MainUIShowState ~= DataModel.UIShowEnum.Coach then
        Controller:SwitchTab(DataModel.UIShowEnum.Coach)
      end
      TrainCameraManager:OpenCamera(2)
      HomeController:RefreshTrains()
      HomeCoachController:InitEnvironment()
      HomeCoachDataModel.InitRoomData(PlayerData.ServerData.user_home_info.furniture)
      HomeCoachDataModel.InitPresetData(PlayerData.ServerData.user_home_info.pre_dress_up)
      HomeCoachDataModel.CalcCurrentCharacter()
      HomeCoachDataModel.CalcCurrentPet()
      HomeCoachDataModel.RemoveNoEmptyRoomCharacter()
      HomeCharacterManager:CreateAll(HomeCoachDataModel.characterData, HomeCoachDataModel.petData)
      liveDataModel.InitLiveFurData()
      liveController.InitSleep()
      emergencyDataModel.InitEmergencyFurData()
      emergencyDataModel.InitEmergency()
      local passengerDataModel = require("UIPassenger/UIPassengerDataModel")
      passengerDataModel.CreateHomePassenger()
      homeFoodController.InitFoodCook()
      HomeManager:OpenHome(0)
    end
    View.touchCamera = nil
    DataModel.aniGroupColorTime = 30
    DataModel.aniGroupColor = false
    DataModel.groupColorRotation = View.Group_Common.Group_MB.Group_PollutionIndex.Img_Mask.Group_Color.self.transform.rotation.z
    if MainManager.bgSceneName ~= DataModel.SceneNameEnum.Home then
      Controller.SetTouchCamera()
      DataModel:GetNextSoundTime()
      View.timer:Start()
      if PlayerData:GetHomeInfo().station_info.is_arrived == 1 or PlayerData.showPosterGirl == -1 then
        View.timer:Pause()
      end
    end
  end,
  update = function()
    if DataModel.FirstFrame then
      DataModel.FirstFrame = false
      MapController:ReSizeMapToView()
    end
    local homeConfig = PlayerData:GetFactoryData(99900014, "ConfigFactory")
    local totalDis = math.floor(TradeDataModel.GetCurrTravelDis() * homeConfig.disRatio)
    local mainConfig = PlayerData:GetFactoryData(99900034, "ConfigFactory")
    totalDis = totalDis > mainConfig.mileageMax and mainConfig.mileageMax or totalDis
    View.Group_Common.Group_MB.Img_Speed.Txt_Num:SetText(totalDis)
    if TradeDataModel.GetIsTravel() then
      local buffVal = 1
      local buff = PlayerData:GetCurStationStoreBuff(EnumDefine.HomeSkillEnum.AccelerationBrakingPerformance)
      if buff then
        buffVal = buffVal + buff.param
      end
      if DataModel.GetIsWeaponRushShow() then
        if DataModel.GetWeaponRushDuration() <= 0 then
          DataModel.SetIsWeaponRushShow(false)
          Controller.WeaponRush()
        else
          DataModel.SetWeaponRushDuration(DataModel.GetWeaponRushDuration() - Time.fixedDeltaTime)
        end
      end
      local currRatio = TrainManager:GetAccerlationRatio()
      if currRatio ~= buffVal then
        TrainManager:SetAccerlationRatio(buffVal)
      end
      TradeDataModel.CurRemainDistance = TrainManager.RemainDistance
      if TradeDataModel.CurRemainDistance ~= -1 then
        if TradeDataModel.CurRemainDistance <= 1000 and DataModel.GetIsArrivingState() == false then
          local t = TradeDataModel.GetAnnouncementList(EnumDefine.Announcement.Arriving)
          SoundManager:PlaySoundList(t)
          DataModel.SetIsArrivingState(true)
        elseif not DataModel.GetIsArrivingState() then
          DataModel.SetIsArrivingState(false)
        end
      end
      TrainManager:SetTargetSpeed(TradeDataModel.GetServerSpeed())
      TrainManager:SetServerSpeed(TradeDataModel.GetServerSpeed())
      MapController:RefreshStationPosImmediately()
      if MapDataModel.HomeMapType == 1 then
        MapController:RefreshViewToTrain()
      end
      Controller.RefreshTrainMove()
      if TrainManager.CurrTrainState == TrainState.Running or TrainManager.CurrTrainState == TrainState.Rush then
        if TrainManager.CurrSpeed == TrainManager.TargetSpeed then
          if Time.fixedUnscaledTime >= DataModel.FixedTime + 1 then
            DataModel.FixedTime = Time.fixedUnscaledTime
            local currSpeed = math.random(-4, 4) + TrainManager.CurrSpeed * TradeDataModel.SpeedRatio
            Controller.SetSpeedShow(currSpeed, true)
          end
        else
          Controller.SetSpeedShow(TrainManager.CurrSpeed * TradeDataModel.SpeedRatio)
        end
      else
        Controller.SetSpeedShow(TrainManager.CurrSpeed * TradeDataModel.SpeedRatio)
      end
      if DataModel.GetTrainEventId() and (TrainManager.CurrStrikeState == StrikeState.Ready or TrainManager.CurrStrikeState == StrikeState.Start) then
        local percent = DataModel.GetStrikeSuccessPercent(DataModel.GetTrainEventId(), DataModel.GetTrainLineId())
        View.Group_Common.Group_MB.Img_Durability.Group_Start.Txt_Success:SetText(percent .. "%")
        View.Group_Common.Group_MB.Group_Strike.Group_Start.Txt_Success:SetText(percent .. "%")
      end
      Controller:JudgementReachArea()
      Controller:JudgementReachAttraction()
      if View.Obj_AdBoard ~= nil and View.Obj_AdBoard:IsNull() then
        View.Obj_AdBoard = nil
      end
      View.Btn_AdBoard:SetActive(false)
    else
      if PlayerData.TempCache.IsTrailer and PlayerData.TempCache.IsBlackOver and not DataModel.IsShow then
        DataModel.IsShow = true
        CommonTips.OnPrompt("80601271", "80600068", "80600067", function()
          PlayerData.TempCache.IsTrailer = false
          PlayerData.TempCache.IsBlackOver = false
          PlayerData.TempCache.IsHelp = false
          DataModel.IsShow = false
          local CarriageDataModel = require("UIHomeCarriageeditor/UIHomeCarriageeditorDataModel")
          local FixDataModel = require("UIHomeCarriageeditor/UIFixDataModel")
          local t = {
            CurrTag = CarriageDataModel.TagType.Fix,
            ChildTag = FixDataModel.TagType.Repair
          }
          CommonTips.OpenToHomeCarriageeditor(t)
        end, function()
          PlayerData.TempCache.IsBlackOver = false
          PlayerData.TempCache.IsTrailer = false
          PlayerData.TempCache.IsHelp = false
          DataModel.IsShow = false
        end)
      end
      if View.Obj_AdBoard == nil or View.Obj_AdBoard:IsNull() then
        View.Obj_AdBoard = CS.UnityEngine.GameObject.Find("AD_Board")
      end
      local adBoardObj = View.Obj_AdBoard
      if MainManager.bgSceneName == "Main" and adBoardObj ~= nil and PlayerData:GetHomeInfo().station_info.stop_info[2] == -1 then
        local cam = TrainCameraManager:GetCamera(1)
        local pos1 = cam:WorldToScreenPoint(adBoardObj.transform.position)
        local pos2 = UIManager.UICamera:ScreenToWorldPoint(Vector3(pos1.x, pos1.y, 100))
        View.Btn_AdBoard:SetActive(true)
        View.Btn_AdBoard.transform.position = Vector3(pos2.x, pos2.y, View.Btn_AdBoard.transform.position.z)
      else
        View.Btn_AdBoard:SetActive(false)
      end
    end
    Controller.RefreshTrainMove()
    if MainManager.bgSceneName ~= DataModel.SceneNameEnum.Home and View.timer and PlayerData:GetHomeInfo().station_info.is_arrived == 2 then
      View.timer:Update()
    end
    if View.timer_2 then
      View.timer_2:Update()
    end
    MapController.RefreshSoftMaskPosition()
    Controller:CheckDrinkBuffShow()
    Controller:CheckSpeedUpBuffShow()
    Controller:CheckBattleUpBuffShow()
    if DataModel.aniGroupColor == true then
      DataModel.aniGroupColorTime = DataModel.aniGroupColorTime - 1
      local Group_Color = View.Group_Common.Group_MB.Group_PollutionIndex.Img_Mask.Group_Color
      if DataModel.groupColorRotation < DataModel.average_value then
        DataModel.groupColorRotation = DataModel.groupColorRotation + (DataModel.average_value - DataModel.groupColorRotation) / 30
      end
      if DataModel.groupColorRotation > DataModel.average_value then
        DataModel.groupColorRotation = DataModel.groupColorRotation - (DataModel.groupColorRotation - DataModel.average_value) / 30
      end
      Group_Color:SetLocalEulerAngles(DataModel.groupColorRotation)
      if 0 >= DataModel.aniGroupColorTime then
        Group_Color:SetLocalEulerAngles(DataModel.average_value)
        DataModel.aniGroupColor = false
        DataModel.aniGroupColorTime = 30
      end
    end
    Controller:RefreshFestivalGift()
    if MainManager.bgSceneName == DataModel.SceneNameEnum.Home then
      liveController.RefreshAutoSleep()
    end
    Controller.SpineBgFollow()
    AutoUseBullet()
  end,
  ondestroy = function()
    DataModel.roleId = ""
    DataModel.isOpenView = false
    MapDataModel.MapDetailMask = nil
    MapDataModel.MapCanvasGroup = nil
    MapDataModel.trainDirection = nil
    MapController:CleanPolluteLinesData()
    MapController.ClearMapNeedle()
    if DataModel.CacheQuestAwardCo then
      View.self:StopC(DataModel.CacheQuestAwardCo)
      DataModel.CacheQuestAwardCo = nil
    end
    if DataModel.passengerCoroutine then
      View.self:StopC(DataModel.passengerCoroutine)
      DataModel.passengerCoroutine = nil
    end
  end,
  enable = function()
    EventMgr:SendEvent("event_uimainui_enable")
    print_r("==============ENABLE=====================")
    print_r(MainManager.bgSceneName)
    if MainManager.bgSceneName == DataModel.SceneNameEnum.Main then
      if not TradeDataModel.GetInTravel() then
        PlayerData.TempCache.MainUIOpenCamera = true
        TrainCameraManager:OpenCamera(1)
      else
        TrainCameraManager:OpenCamera(0)
      end
    else
      TrainCameraManager:OpenCamera(2)
    end
    ListenerManager.AddListener(ListenerManager.Enum.SetQuestTrace, "MainUI", function(id)
      Controller.SetQuestTrace()
    end)
    ListenerManager.AddListener(ListenerManager.Enum.CompleteQuestInQuestTrace, "MainUI", function(id)
      Controller.SetQuestTrace()
    end)
    View.Group_Adjutant.Btn_Achieve.Img_Red:SetActive(0 < RedpointTree:GetRedpointCnt(RedpointTree.NodeNames.AchievementUI))
    RedpointTree:SetCallBack(RedpointTree.NodeNames.AchievementUI, "AchievementUI", function(redpointCnt)
      View.Group_Adjutant.Btn_Achieve.Img_Red:SetActive(0 < redpointCnt)
    end)
    EventManager:AddOpenPanelEvent(OpenPanelCallBack)
  end,
  disenable = function()
    EventMgr:SendEvent("event_uimainui_disenable")
    print_r("==============DISABLE=====================")
    print_r(DataModel.CurSceneName)
    if DataModel.CurSceneName == DataModel.SceneNameEnum.Main and not DataModel.MainToESC then
      TrainCameraManager:OpenCamera(-1)
    end
    ListenerManager.RemoveListener(ListenerManager.Enum.SetQuestTrace, "MainUI")
    ListenerManager.RemoveListener(ListenerManager.Enum.CompleteQuestInQuestTrace, "MainUI")
    if View.coroutineSound then
      View.self:StopC(View.coroutineSound)
      View.coroutineSound = nil
    end
    MapController:CleanPolluteLinesData()
    MapController.ClearMapNeedle()
    RedpointTree:SetCallBack(RedpointTree.NodeNames.AchievementUI, "AchievementUI", nil)
    if View.passengerCoroutine then
      View.self:StopC(View.passengerCoroutine)
      View.passengerCoroutine = nil
    end
    DataModel.MainToESC = false
    EventManager:RemoveOpenPanelEvent(OpenPanelCallBack)
  end,
  refresh = function()
    DataModel.RefreshData(PlayerData.ServerData.user_home_info.coach)
    TradeDataModel.Refresh3DTravelInfoNew(EnumDefine.TrainStateEnter.ApplicationQuit)
    Controller.RefreshTrainMove()
  end
}
return {
  Luabehaviour,
  View,
  ViewFunction
}
