local setDate, setOnline, setFormat;
local Clock={
	["start"]=GetTime(),["time"]=0,["12"]=0,["24"]=0,
	["hour"]=0,["mins"]=0,["_hour"]=0,["_mins"]=0,
	["clock"]="",["date"]="",["game"]="",["total"]="",
	["update"]=0,
};

local function Indicator(duration,remaining)
	if duration>0 and remaining>0 then
		XBarClock_B_Icon:SetCooldown(duration,remaining);
	end
end

function XBarClock_OnUpdate(this,elapsedTime)
	Clock["update"]=Clock["update"]+elapsedTime;
	if Clock["update"]>=1 then
		Clock["update"]=0;
		Indicator(60,60-tonumber(os.date("%S")));
		Clock["time"]=GetTime()-Clock["start"];
		Clock["_hour"]=string.format("%02d",Clock["hour"]);
		Clock["hour"]=math.floor(Clock["time"]/3600);
		Clock["_mins"]=string.format("%02d",Clock["mins"]);
		Clock["mins"]=((Clock["time"]-(Clock["hour"]*3600))/60);
		if Clock["_mins"]<string.format("%02d",Clock["mins"]) then XBSet["PlayedMins"]=XBSet["PlayedMins"]+1; end
		if XBSet["PlayedMins"]>59 then XBSet["PlayedHour"]=XBSet["PlayedHour"]+1; XBSet["PlayedMins"]=0; end
		if Clock["_hour"]<string.format("%02d",Clock["hour"]) then XBSet["PlayedHour"]=XBSet["PlayedHour"]+1; end
		if XBSet["PlayedHour"]>23 then XBSet["PlayedDays"]=XBSet["PlayedDays"]+1; XBSet["PlayedHour"]=0; end
		Clock["12"]=os.date("%I:%M.%S %p");
		Clock["24"]=os.date("%H:%M.%S");
		if GetLanguage()=="ENUS" then
			Clock["date"]=os.date("%a %m-%d-%Y");
		else
			Clock["date"]=os.date("%a-%d.%m.%Y");
		end
		Clock["game"]=string.format("%02d:%02d",Clock["hour"],Clock["mins"]);
		Clock["total"]=string.format("%d "..DAYS.." %02d:%02d",XBSet["PlayedDays"],XBSet["PlayedHour"],XBSet["PlayedMins"]);
	-- Output
		local usrtxt={[1]=XBSet["ClockV1"],[2]=XBSet["ClockV2"],[3]=XBSet["ClockV3"],[4]=XBSet["ClockV4"],[5]=XBSet["ClockV5"]};
		local output="";
		for i=1,5 do
			usrtxt[i],_=string.gsub(usrtxt[i],"%[TIME24%]",Clock["24"]);
			usrtxt[i],_=string.gsub(usrtxt[i],"%[TIME12%]",Clock["12"]);
			usrtxt[i],_=string.gsub(usrtxt[i],"%[DATE%]",Clock["date"]);
			usrtxt[i],_=string.gsub(usrtxt[i],"%[ONLINE%]",Clock["game"]);
			usrtxt[i],_=string.gsub(usrtxt[i],"%[TOTALONLINE%]",Clock["total"]);
		end
		if XBSet["ClockT1"]==true then
			if setDate==1 then output=usrtxt[3]; elseif setFormat==12 then output=usrtxt[2]; else output=usrtxt[1]; end
		end
		if XBSet["ClockT2"]==true then
			if setOnline==1 then if XBSet["ClockT1"]==true then output=output.."\n"..usrtxt[5]; else output=usrtxt[5]; end
			else if XBSet["ClockT1"]==true then output=output.."\n"..usrtxt[4]; else output=usrtxt[4]; end; end
		end
		XBarClock_F_S:SetText(output);
	end
end

function XBarClock_OnClick(key,this)
	if key=="RBUTTON" and not IsShiftKeyDown() then if setDate==1 then setDate=0; else setDate=1; end
	elseif key=="LBUTTON" and IsShiftKeyDown() then if setOnline==1 then setOnline=0; else setOnline=1; end
	elseif key=="LBUTTON" then if setFormat==12 then setFormat=24; else setFormat=12; end; end
end

function XBarClock_OnEnter(this)
	XBarClock_B_Icon:SetTexture("interface/icons/Skill_ran54-1");
	GameTooltip:SetOwner(this,"ANCHOR_TOPRIGHT", -180,0);
	GameTooltip:SetText(XLng["Ttip"]["Clock1"]);
	GameTooltip:AddLine(XLng["Ttip"]["Clock2"],0,.7,.9);
	GameTooltip:AddLine(XLng["Ttip"]["Clock3"],0,.7,.9);
	GameTooltip:AddLine(XLng["Ttip"]["Clock4"],0,.7,.9);
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Clock3"].."|r", Clock["date"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Clock2"].."|r", Clock["24"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Clock4"].."|r", Clock["game"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["Clock5"].."|r", Clock["total"]);
end