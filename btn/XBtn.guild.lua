local start=1;
local max=20;
local Guild={1,2,3,4,5,6,7,["rank"]=NONE};
local function GuildInfo(v)
	if GetNumGuildMembers()==0 then return NONE; end
	local GuildName,leader,recruit,_,MaxMember,score,_,_,_,_,_,level=GetGuildInfo();
	if v=="GuildName" then return GuildName; end
	if v=="leader" then return leader; end
	if v=="recruit" then if recruit==true then return XLng["Ttip"]["Guild9"]; else return XLng["Ttip"]["Guild10"]; end; end
	if v=="MaxMember" then return MaxMember; end
	if v=="score" then return score; end
	if v=="level" then return level; end
end

function XBarGuild_OnEvent(this,event)
	if event=="LOADED" then
		this:RegisterEvent("UPDATE_GUILD_MEMBER");
		this:RegisterEvent("UPDATE_GUILD_MEMBER_INFO");
	end
	local rank = XBarGuild_Roster(UnitName("player"));
	if rank then Guild["rank"] = rank.." - "..GF_GetRankStr(rank); end
	for i = 1, 7 do
		Guild[i]=XBar_Dec(GCB_GetGuildResource(i));
	end

-- Output
	local usrtxt={[1]=XBSet["GuildV1"],[2]=XBSet["GuildV2"]};
	local output="";
	for i=1,2 do
		usrtxt[i],_=string.gsub(usrtxt[i],"%[GNAME%]",GuildInfo("GuildName"));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[GLVL%]",GuildInfo("level"));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[GLEADER%]",GuildInfo("leader"));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[ONLINE%]",XBarGuild_Roster("online"));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[MEMBER%]",GetNumGuildMembers());
		usrtxt[i],_=string.gsub(usrtxt[i],"%[MAX%]",GuildInfo("MaxMember"));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[RIGHT%]",GuildInfo("recruit"));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[RANK%]",Guild["rank"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[GOLD%]",Guild[1]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[RUBY%]",Guild[2]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[ORE%]",Guild[3]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[WOOD%]",Guild[4]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[HERB%]",Guild[5]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[RUNE%]",Guild[6]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[STONE%]",Guild[7]);
	end
	if XBSet["GuildT1"]==true then output=usrtxt[1]; end
	if XBSet["GuildT2"]==true then
		if XBSet["GuildT1"]==true then output=output.."\n"..usrtxt[2]; else output=usrtxt[2]; end
	end
	XBarGuild_F_S:SetText(output);
end

function XBarGuild_Roster(v)
	local online=0;
	for i=1,GetNumGuildMembers() do
		local Name,Rank,MC,ML,SC,SL,_,_,_,_,On,_,Zone=GetGuildRosterInfo(i);
		if v==Name then return Rank,MC,ML,SC,SL,Zone; end
		if On then if On==true then online=online+1 end end
	end
	if v=="online" then return online; end
end

local function ClassIcon(class)
	if not class then return nil;
	elseif class==TEXT("SYS_CLASSNAME_WARRIOR") then return "Interface/TargetFrame/TargetFrameIcon-Warrior";
	elseif class==TEXT("SYS_CLASSNAME_RANGER") then return "Interface/TargetFrame/TargetFrameIcon-Ranger";
	elseif class==TEXT("SYS_CLASSNAME_THIEF") then return "Interface/TargetFrame/TargetFrameIcon-Thief";
	elseif class==TEXT("SYS_CLASSNAME_MAGE") then return "Interface/TargetFrame/TargetFrameIcon-Mage";
	elseif class==TEXT("SYS_CLASSNAME_AUGUR") then return "Interface/TargetFrame/TargetFrameIcon-Augur";
	elseif class==TEXT("SYS_CLASSNAME_KNIGHT") then return "Interface/TargetFrame/TargetFrameIcon-Knight";
	elseif class==TEXT("SYS_CLASSNAME_WARDEN") then return "Interface/TargetFrame/TargetFrameIcon-Warden";
	elseif class==TEXT("SYS_CLASSNAME_DRUID") then return "Interface/TargetFrame/TargetFrameIcon-Druid";
	elseif class==TEXT("SYS_CLASSNAME_HARPSYN") then return "Interface/TargetFrame/Targetframeicon-Harpsyn";
	elseif class==TEXT("SYS_CLASSNAME_PSYRON") then return "Interface/TargetFrame/TargetFrameIcon-Psyron";
	else return "Interface/TargetFrame/TargetFrameIcon-Runedancer"; end
end

local function PopSelect(this,key)
	if key=="LBUTTON" then ChatFrame_SendTell(XBar_PopupMenu.Buttons[this:GetID()].CharName);
	else InviteByName(XBar_PopupMenu.Buttons[this:GetID()].CharName); end
end

local function PopScroll(delta)
	if delta>0 then if start>1 then start=start-1; end; end
	if delta<0 then if start<XBarGuild_Roster("online")-max-1 then start=start+1; end; end
	XBarGuild_OnClick("LBUTTON",true);
end

function XBarGuild_OnClick(key,wheel)
	local scroll=(wheel and 1) or false;
	XBarGuildButtons={};
	local count=0;
	for i=1,GetNumGuildMembers() do
		local Name,Rank,MC,ML,SC,SL,_,_,DBID,Title,Online,LogTime,Zone,Note=GetGuildRosterInfo(i);
		if Online then
			if Online==true then
				count=count+1;
				if SC=="" then SC = NONE; end
				Rank = Rank.." - "..GF_GetRankStr(Rank);
				XBarGuildButtons[count]={
					icon=ClassIcon(MC),
					CharName=Name,
					GetText=function() return "|cff"..XBarGuild_ClassColor(MC)..Name.."|r"; end,
					GetTooltip=function()
						info="";
						info=info.."|cffFFE855"..CLASS_CHANGE_CLASS1.." :|r |cff"..XBarGuild_ClassColor(MC)..MC.."|r ("..ML..")\n";
						info=info.."|cffFFE855"..CLASS_CHANGE_CLASS2.." :|r |cff"..XBarGuild_ClassColor(SC)..SC.."|r ("..SL..")\n";
						info=info.."\n";
						info=info.."|cffFFE855"..XLng["Ttip"]["Loc"].."|r "..Zone.."\n";
						info=info.."|cffFFE855"..C_RANK.." :|r "..Rank.."\n";
						info=info.."|cff857318ID|r |cff767676"..XBar_Dec(DBID).."|r\n";
						if Note then if Note~="" then info=info.."|cff857318"..XLng["Ttip"]["Note"].."|r |cff767676"..tostring(Note).."|r\n"; end; end
						info=info.."\n";
						info=info.."|cff00B2E5"..XLng["Ttip"]["LMOUSE_WSP"].."|r\n";
						info=info.."|cff00B2E5"..XLng["Ttip"]["RMOUSE_INV"].."|r\n";
						info=info.."|cff00B2E5"..XLng["Ttip"]["SCROLL_ON"].."|r\n";
						return info; end,
					OnClick=function(this,key) PopSelect(this,key); end,
					OnScroll=function(delta) PopScroll(delta); end,
				};
			end
		end
	end
	if start>1 then for i=1,start-1 do table.remove(XBarGuildButtons,1); end; end
	while #XBarGuildButtons>max do table.remove(XBarGuildButtons); end
	XBar_PopupMenu.Buttons=XBarGuildButtons;
	XBar_PopupMenu_Toggle("XBarGuild",0,32,scroll);
end

function XBarGuild_ClassColor(class)
	if not class then return nil;
	elseif class==TEXT("SYS_CLASSNAME_WARRIOR") then return "FF0033";
	elseif class==TEXT("SYS_CLASSNAME_RANGER") then return "A5D603";
	elseif class==TEXT("SYS_CLASSNAME_THIEF") then return "00D6C5";
	elseif class==TEXT("SYS_CLASSNAME_MAGE") then return "FF9100";
	elseif class==TEXT("SYS_CLASSNAME_AUGUR") then return "288CEC";
	elseif class==TEXT("SYS_CLASSNAME_KNIGHT") then return "FFFF70";
	elseif class==TEXT("SYS_CLASSNAME_WARDEN") then return "0CF360";
	elseif class==TEXT("SYS_CLASSNAME_DRUID") then return "8B35FF";
	elseif class==TEXT("SYS_CLASSNAME_HARPSYN") then return "BF30E7";
	elseif class==TEXT("SYS_CLASSNAME_PSYRON") then return "5677DD";
	else return "FFFFFF"; end
end

function XBarGuild_OnEnter(this)
	GameTooltip:SetOwner(this,"ANCHOR_TOPRIGHT", -180,0);
	GameTooltip:SetText(XLng["Ttip"]["Guild1"]);
	GameTooltip:AddLine(XLng["Ttip"]["Guild2"],0,.7,.9);
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["Guild3"].."|r","|cffFFFFFF"..GuildInfo("GuildName").."|r |cff767676("..XLng["Ttip"]["Guild4"]..GuildInfo("level")..")|r");
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["Guild5"].."|r",GuildInfo("leader"));
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["Guild6"].."|r","|cff8DE668"..XBarGuild_Roster("online").."|r / "..GetNumGuildMembers().." /|cffE66868 "..GuildInfo("MaxMember").."|r "..XLng["Ttip"]["Guild7"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["Guild8"].."|r","|cff767676"..GuildInfo("recruit").."|r");
	GameTooltip:AddDoubleLine("|cffFFE855"..C_RANK.."|r",Guild["rank"]);
	if GuildInfo("GuildName")~=NONE then
		GameTooltip:AddSeparator();
		for i = 1, 7 do
			GameTooltip:AddDoubleLine("|cffFFE855"..TEXT("SYS_GUILD_RESOURCE_STR_"..i).."|r",XBar_Dec(Guild[i]));
		end
	end
end