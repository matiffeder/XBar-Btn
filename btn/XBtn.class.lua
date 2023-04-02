XBtnChars={};
local Chars={["mc"]=NONE,["ml"]=0,["tc"]=NONE,["tl"]=0,["CQuest"]=0};
local regpoint = TEXT("SC_TRANSFER_SAVEHOME_MEG"):gsub("%[$VAR1]", "(.*)");
local function Daily()
	local dailyCount, dailyPerDay = Daily_count();
	if dailyCount==dailyPerDay then
		Chars["daily"] = "|cffff0000"..dailyCount.."/"..dailyPerDay.."|r";
	else
		Chars["daily"] = dailyCount.."/"..dailyPerDay;
	end
end

local function Quest()
	local totalQuest = GetNumQuestBookButton_QuestBook();
	local finishQuest = 0;
	if totalQuest>0 then
		for i = 1, totalQuest do
			local _, _, _, _, _, _, _, _, _, Complete = GetQuestInfo(i);
			if Complete then
				finishQuest = finishQuest + 1;
			end
		end
		Chars["quest"] = finishQuest.."/"..totalQuest;
	else
		Chars["quest"] = NONE;
	end
end

function XBarClass_OnEvent(this,event,arg1)
	if event=="LOADED" then
		this:RegisterEvent("UNIT_LEVEL");
		this:RegisterEvent("UNIT_CLASS_CHANGED");
		this:RegisterEvent("CHAT_MSG_SYSTEM");
		this:RegisterEvent("PLAYER_GET_TITLE");
		this:RegisterEvent("PLAYER_TITLE_ID_CHANGED")
		this:RegisterEvent("CARDBOOKFRAME_UPDATE");
		this:RegisterEvent("PLAYER_HONOR_CHANGED");
		Quest();
		Daily();
		for i = 420034, 424751 do
			local complete = CheckQuest(i);
			if complete==2 then
				Chars["CQuest"] = Chars["CQuest"] + 1;
			end
		end
		if not XBtnChars[UnitName("player")] then
			XBtnChars[UnitName("player")] = NONE;
		end
	end
	if event=="UNIT_CLASS_CHANGED" or event=="UNIT_LEVEL" or event=="LOADED" then
		local mainC, subC = UnitClass("player");
		local count = GetPlayerNumClasses();
		for i = 1, count do
			local class, _, level = GetPlayerClassInfo(i, true);
			if class~=nil then
				if class==mainC then
					Chars["mc"] = class;
					Chars["ml"] = level;
				elseif class==subC then
					Chars["sc"] = class;
					Chars["sl"] = level;
				elseif count==3 then
					Chars["tc"] = class;
					Chars["tl"] = level;
				end
			end
		end
		if subC=="" or subC==nil then
			Chars["sc"] = NONE;
			Chars["sl"] = 0;
		end
	end
	if event=="CHAT_MSG_SYSTEM" then
		if string.find(arg1, string.format(TEXT("QUEST_MSG_GET"), "(.*)"))
		or string.find(arg1, string.format(TEXT("QUEST_MSG_CONDITION_FINISHED"), "(.*)")) then
			Quest();
		elseif string.find(arg1:gsub("%d", "1"), string.format(TEXT("QUEST_MSG_DAILYGROUP_COMPLETE"), "(.*)", 1, "(.*)"))
		or string.find(arg1, string.format(TEXT("QUEST_MSG_DAILYGROUP_DONE"), "(.*)", "(.*)")) then
			Daily();
		elseif string.find(arg1, string.format(TEXT("QUEST_MSG_FINISHED"), "(.*)")) then
			Quest();
			Chars["CQuest"] = Chars["CQuest"] + 1;
		elseif string.find(arg1, regpoint) then
			XBtnChars[UnitName("player")] = string.match(arg1, regpoint);
		elseif string.find(arg1, TEXT("SC_SETRECORDPOINT")) then
			XBtnChars[UnitName("player")] = GetZoneName();
		end
	end
	if event=="PLAYER_HONOR_CHANGED" or event=="LOADED" then
		Chars["honor"] = XBar_Dec(math.floor(GetPlayerHonorPoint()));
	end
	if event=="PLAYER_TITLE_ID_CHANGED" or event=="LOADED" then
		UpdateTitleInfo();
		Chars["titleC"] = 0;
		for i = 1, GetTitleCount() do
			local tname, tID, tgeted = GetTitleInfoByIndex(i - 1);
			if tgeted==true then
				local ID = GetCurrentTitle();
				if tID==ID then
					Chars["title"] = tname;
				elseif ID==0 then
					Chars["title"] = NONE;
				end
				Chars["titleC"] = Chars["titleC"] + 1;
			end
		end
		if Chars["titleC"]==0 then Chars["title"] = NONE; end
	end
	if event=="PLAYER_GET_TITLE" then
		Chars["titleC"] = Chars["titleC"] + 1;
	end
	if event=="CARDBOOKFRAME_UPDATE" or event=="LOADED" then
		local cardMax, cardCount = 0, 0;
		for i = 0, 16 do
			local GMax = LuaFunc_GetCardMaxCount(i);
			if GMax~=nil and GMax>0 then
				cardMax = cardMax + GMax;
				cardCount = cardCount + LuaFunc_GetCardCount(i);
			end
		end
		Chars["card"] = cardCount.."/"..cardMax;
	end
-- Output
	local usrtxt={[1]=XBSet["ClassV1"],[2]=XBSet["ClassV2"]};
	local output="";
	for i=1,2 do
		usrtxt[i],_=string.gsub(usrtxt[i],"%[MLVL%]",Chars["ml"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[MCLASS%]",Chars["mc"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[SLVL%]",Chars["sl"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[SCLASS%]",Chars["sc"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TLVL%]",Chars["tl"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TCLASS%]",Chars["tc"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[HONOR%]",Chars["honor"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[CARD%]",Chars["card"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TITLE%]",Chars["title"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TITLEC%]",Chars["titleC"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[QUEST%]",Chars["quest"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[DAY%]",Chars["daily"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[CQUEST%]",Chars["CQuest"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[POINT]",XBtnChars[UnitName("player")]);
	end
	if XBSet["ClassT1"]==true then output=usrtxt[1]; end
	if XBSet["ClassT2"]==true then
		if XBSet["ClassT1"]==true then output=output.."\n"..usrtxt[2]; else output=usrtxt[2]; end
	end
	XBarClass_F_S:SetText(output);
end

function XBarClass_OnEnter(this)
	GameTooltip:SetOwner(this,"ANCHOR_TOPRIGHT", -180,0);
	GameTooltip:SetText(XLng["Ttip"]["Class1"]);
	GameTooltip:AddLine(XLng["Ttip"]["Class2"],0,.7,.9);
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cffFFE855"..CLASS.."|r", Chars["mc"].." "..Chars["ml"].." / "..Chars["sc"].." "..Chars["sl"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..C_HONOR_POINT.."|r", Chars["honor"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..UI_TITLE_TYPE_2_3.."|r", Chars["card"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..C_TITLE.."|r", Chars["title"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Class9"].."|r", Chars["titleC"]);
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Class8"].."|r", Chars["quest"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Class7"].."|r", Chars["daily"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..BILLBOARD_015.."|r", Chars["CQuest"]);
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cffFFE855"..XBar_UpF(_glossary_00824).."|r", XBtnChars[UnitName("player")]);
end