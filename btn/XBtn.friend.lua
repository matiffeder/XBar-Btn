local start=1;
local max=20;
local function FriendGroup(v1,v2)
	XBarFriendGroups={};
	local count=GetSocalGroupCount("Friend");
	if not count or count==0 then count=0;
	else
		for i=1,count do
			local ID,Name,Sort=GetSocalGroupInfo("Friend",i);
			XBarFriendGroups[ID]={["Name"]=Name,["Sort"]=Sort};
		end
	end
	if v1=="COUNT" then return count; end
	if v1=="NAME" and count then return XBarFriendGroups[v2]["Name"]; end
end

function XBarFriend_OnEvent(this,event)
	if event=="LOADED" then
		this:RegisterEvent("RESET_FRIEND");
	end
-- Output
	local usrtxt={[1]=XBSet["FriendV1"],[2]=XBSet["FriendV2"]};
	local output="";
	for i=1,2 do
		usrtxt[i],_=string.gsub(usrtxt[i],"%[ONLINE%]",XBarFriend_Info("OnlineCount"));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[COUNT%]",XBarFriend_Info("FriendCount"));
		--usrtxt[i],_=string.gsub(usrtxt[i],"%[GROUPS%]",tostring(FriendGroup("COUNT")));
	end
	if XBSet["FriendT1"]==true then output=usrtxt[1]; end
	if XBSet["FriendT2"]==true then
		if XBSet["FriendT1"]==true then output=output.."\n"..usrtxt[2]; else output=usrtxt[2]; end
	end
	XBarFriend_F_S:SetText(output);
end

function XBarFriend_Info(v)
	if GetFriendCount("Friend")==0 then return NONE; end
	local online=0;
	if v=="FriendCount" then return GetFriendCount("Friend"); end
	if v=="OnlineCount" then
		for i=1,GetFriendCount("Friend") do
			local _,_,On=GetFriendInfo("Friend",i);
			if On then if On==true then online=online+1; end; end
		end
		return online;
	end
end

local function FriendIcon(both)
	if both==true then return "Interface/Icons/Pet_Froster01"; end
	if both==false then return "Interface/Icons/Pet_Froster02"; end
	return "Interface/Icons/Item_Mea_011";
end

local function PopSelect(this,key)
	if key=="LBUTTON" then ChatFrame_SendTell(XBar_PopupMenu.Buttons[this:GetID()].CharName);
	else InviteByName(XBar_PopupMenu.Buttons[this:GetID()].CharName); end
end

local function PopScroll(delta)
	if delta>0 then if start>1 then start=start-1; end; end
	if delta<0 then if start<XBarFriend_Info("OnlineCount")-(max-1) then start=start+1; end; end
	XBarFriend_OnClick("LBUTTON",true);
end

function XBarFriend_OnClick(key,wheel)
	local scroll=(wheel and 1) or false;
	XBarFriendButtons={};
	local count=0;
	for i=1,GetFriendCount("Friend") do
		local Name,GroupID,Online,Friends=GetFriendInfo("Friend",i);
		if Online then
			if Online==true then
				count=count+1;
				local _,MC,ML,SC,SL,Zone=XBarGuild_Roster(Name);
				local Map, Title, Guild, Main, MainLV, Sub, SubLV = GetFriendDetail(Name);
				MC = MC or Main; ML = ML or MainLV; SC = SC or Sub; SL = SL or SubLV; Zone = Zone or Map;
				if SC=="" then SC = NONE; end
				XBarFriendButtons[count]={
					icon=FriendIcon(Friends),
					CharName=Name,
					GetText=function() return Name; end,
					GetTooltip=function()
						info="";
						info=info.."|cffFFE855"..XLng["Ttip"]["Friend4"].."|r "..FriendGroup("NAME",GroupID).."\n";
						if MC~=nil then
							info=info.."|cffFFE855"..CLASS_CHANGE_CLASS1.." :|r |cff"..XBarGuild_ClassColor(MC)..MC.."|r ("..ML..")\n";
							info=info.."|cffFFE855"..CLASS_CHANGE_CLASS2.." :|r |cff"..XBarGuild_ClassColor(SC)..SC.."|r ("..SL..")\n";
							info=info.."|cffFFE855"..XLng["Ttip"]["Loc"].."|r "..Zone.."\n";
						end
						if Guild~=nil and Guild~="" then info=info.."|cffFFE855"..GUILD.." :|r "..Guild.."\n"; end
						--info=info.."|cff857318"..XLng["Ttip"]["Friend5"].."|r "..tostring(DiedOf).."\n";
						--info=info.."|cff857318"..XLng["Ttip"]["Friend6"].."|r"..tostring(Kills).."\n";
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
	if start>1 then for i=1,start-1 do table.remove(XBarFriendButtons,1); end; end
	while #XBarFriendButtons>max do table.remove(XBarFriendButtons); end
	XBar_PopupMenu.Buttons=XBarFriendButtons;
	XBar_PopupMenu_Toggle("XBarFriend",0,32,scroll);
end