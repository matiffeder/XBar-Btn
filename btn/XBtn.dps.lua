XBtnDps={};
XBtnDura = 0;
local TDps={["CurTime"]=nil,["DPS"]=0,["Dmg"]=0};
local THps={["CurTime"]=nil,["HPS"]=0,["Heal"]=0};
local abtext = {
	C_STR,
	C_AGI,
	C_STA,
	C_INT,
	C_MND,
	C_DPS,
	MELEE.." "..C_PHYSICAL_DAMAGE,
	MELEE.." "..C_PHYSICAL_ATTACK,
	MELEE.." "..C_PHYSICAL_CRITICAL,
	" ",
	" ",
	MELEE.." "..C_PHYSICAL_HIT,
	PHYSICAL_HIT_RATE,
	RANGE.." "..C_PHYSICAL_DAMAGE,
	RANGE.." "..C_PHYSICAL_ATTACK,
	RANGE.." "..C_PHYSICAL_CRITICAL,
	MAGIC.." "..C_MAGIC_DAMAGE,
	MAGIC.." "..C_MAGIC_ATTACK,
	MAGIC.." "..C_MAGIC_CRITICAL,
	MAGIC.." "..C_MAGIC_HEAL_POINT,
	MAGIC.." "..C_MAGIC_HIT,
	DEFENCE,
	C_PHYSICAL_PARRY,
	C_PHYSICAL_DODGE,
	C_PHYSICAL_RESIST_CRITICAL,
	MAGIC.." "..C_MAGIC_DEFENCE,
	MAGIC.." "..C_MAGIC_DODGE,
	MAGIC.." "..C_MAGIC_RESIST_CRITICAL,
};
local ability = {
	"STR",
	"AGI",
	"STA",
	"INT",
	"MND",
	"DPS",
	"MELEE_MAIN_DAMAGE",
	"MELEE_ATTACK",
	"MELEE_CRITICAL",
	"MELEE_MAIN_CRITICAL",
	"MELEE_OFF_CRITICAL",
	"PHYSICAL_MAIN_HIT",
	"PHYSICAL_HIT_RATE",
	"RANGE_DAMAGE",
	"RANGE_ATTACK",
	"RANGE_CRITICAL",
	"MAGIC_DAMAGE",
	"MAGIC_ATTACK",
	"MAGIC_CRITICAL",
	"MAGIC_HEAL",
	"MAGIC_HIT",
	"PHYSICAL_DEFENCE",
	"PHYSICAL_PARRY",
	"PHYSICAL_DODGE",
	"PHYSICAL_RESIST_CRITICAL",
	"MAGIC_DEFENCE",
	"MAGIC_DODGE",
	"MAGIC_RESIST_CRITICAL",
};

function XBarDps_OnUpdate()
	if TDps["CurTime"]~=nil then
		if GetTime()-TDps["CurTime"]>5 then
			TDps["Active"]=false;
			TDps["DPS"]=0;
			TDps["CurTime"]=nil;
		end
	end
	if THps["CurTime"]~=nil then
		if GetTime()-THps["CurTime"]>5 then
			THps["Active"]=false;
			THps["HPS"]=0;
			THps["CurTime"]=nil;
		end
	end
end
 
function XBarDps_OnEvent(this,event)
	local new = false;
	local name = UnitName("player");
	if event=="LOADED" then
		XBarEQDmg:RegisterEvent("PLAYER_INVENTORY_CHANGED");
		this:RegisterEvent("UNIT_HEALTH");
		this:RegisterEvent("COMBATMETER_DAMAGE")
		this:RegisterEvent("COMBATMETER_HEAL");
		if not XBtnDps[name] then XBtnDps[name] = 0; end
	end
	if event=="UNIT_HEALTH" then
		if UnitHealth("target")==0 and UnitExists("target") and new==true then
			new = false;
			XBtnDps[name] = XBtnDps[name] + 1;
		end
	end
	if event=="COMBATMETER_DAMAGE" then
		if _source==UnitName("player") then
			if UnitHealth("target")>0 and UnitExists("target") then new = true; end
			if not TDps["Active"] then
				TDps["Active"]=true;
				TDps["StartTime"]=(GetTime()-1);
				TDps["TotalDmg"]=0;
				TDps["DPS"]=0;
			end
			TDps["CurTime"]=GetTime();
			TDps["TotalTime"]=TDps["CurTime"]-TDps["StartTime"];
			TDps["Dmg"]=XBar_Dec(_damage);
			TDps["TotalDmg"]=TDps["TotalDmg"]+_damage;
			TDps["DPS"]=XBar_Dec(math.floor(TDps["TotalDmg"]/TDps["TotalTime"]));
		else
			return;
		end
	end
	if event=="COMBATMETER_HEAL" then
		if _source==UnitName("player") then
			if not THps["Active"] then
				THps["Active"]=true;
				THps["StartTime"]=(GetTime()-1);
				THps["TotalHeal"]=0;
				THps["HPS"]=0;
			end
			THps["CurTime"]=GetTime();
			THps["TotalTime"]=THps["CurTime"]-THps["StartTime"];
			THps["Heal"]=XBar_Dec(_heal);
			THps["TotalHeal"]=THps["TotalHeal"]+_heal;
			THps["HPS"]=XBar_Dec(math.floor(THps["TotalHeal"]/THps["TotalTime"]));
		else
			return;
		end
	end
--	Output
	local usrtxt={[1]=XBSet["DpsV1"],[2]=XBSet["DpsV2"]};
	local output="";
	for i=1,2 do
		usrtxt[i],_=string.gsub(usrtxt[i],"%[DPS%]",TDps["DPS"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[DMG%]",TDps["Dmg"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[HPS%]",THps["HPS"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[HEAL%]",THps["Heal"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[KILLS%]",XBar_Dec(XBtnDps[name]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[DURA%]",XBtnDura);
	end
	if XBSet["DpsT1"]==true then output=usrtxt[1]; end
	if XBSet["DpsT2"]==true then
		if XBSet["DpsT1"]==true then output=output.."\n"..usrtxt[2]; else output=usrtxt[2]; end
	end
	XBarDps_F_S:SetText(output);
end

function XBarDps_OnClick(key)
	if key=="LBUTTON" then
		XBar_ToggleUI(XBarEQDmg);
	elseif IsCtrlKeyDown() then
		XBtnDps[UnitName("player")] = 0;
		XBarDps_OnEvent();
	elseif not IsShiftKeyDown() then
		local c = CharactFrame_GetEquipSlotCount();
		local n = GetEuipmentNumber();
		for i=1,c do
			if n==i then
				if c==i then
					n = 0;
				else
					n = i;
				end
				break;
			end
		end
		SwapEquipmentItem(n);
	end
end

function XBarDps_OnEnter(this)
	GameTooltip:SetOwner(this,"ANCHOR_TOPRIGHT", -180,0);
	GameTooltip:SetText(XLng["Ttip"]["Dps1"]);
	GameTooltip:AddLine(XLng["Ttip"]["Dps2"],0,.7,.9);
	GameTooltip:AddLine(XLng["Ttip"]["Dps3"],0,.7,.9);
	GameTooltip:AddLine(XLng["Ttip"]["CR_REST"],0,.7,.9);
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["AvgDur"].."|r", XBtnDura);
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Dps2"].."|r", XBar_Dec(XBtnDps[UnitName("player")]));
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(" ", "|cffFFE855"..C_ABILITY.."|r");
	for i, v in ipairs(ability) do
		local base, extra, per = GetPlayerAbility(v);
		local value;
		if i==6 then
			value=string.format("%.2f", base+extra);
		elseif i==10 or i==11 then
			value=string.format("%.2f%%", per);
		elseif i==13 then
			value=base+extra.."%";
		else
			if extra>0 then
				value="|cff8DE668"..XBar_Dec(base+extra).."|r / "..XBar_Dec(base).."|cff8DE668+"..XBar_Dec(extra);
			elseif extra<0 then
				value="|cffE66868"..XBar_Dec(base+extra).."|r / "..XBar_Dec(base).."|cffE66868"..XBar_Dec(extra);
			else
				value=XBar_Dec(base);
			end
		end
		if i==6 or i==14 or i==17 or i==22 or i==26 then GameTooltip:AddSeparator(); end
		if i==16 or i==19 or i==23 then
			GameTooltip:AddDoubleLine(abtext[i], value);
			GameTooltip:AddDoubleLine(" ", string.format("%.2f%%", per));
		else
			GameTooltip:AddDoubleLine(abtext[i], value);
		end
	end
end