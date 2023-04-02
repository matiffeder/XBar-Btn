local Ammo={};
 
function XBarAmmo_OnEvent(this,event)
	if event=="LOADED" then
		this:RegisterEvent("PLAYER_BAG_CHANGED");
		this:RegisterEvent("PLAYER_INVENTORY_CHANGED");
	end
	local _, _, name =GetInventoryItemDurable("player",9);
	local ECount, BCount;
	if name then
		Ammo["name"] = name;
		Ammo["ecount"] = GetInventoryItemCount("player",9);
		Ammo["bcount"] = GetCountInBagByName(name);
	else
		Ammo["name"] = TEXT("SYS_EQWEARPOS_10");
		Ammo["ecount"] = 0;
		Ammo["bcount"] = 0;
	end
	Ammo["count"] = Ammo["ecount"] + Ammo["bcount"];
	if GetInventoryItemInvalid("player",9) or GetInventoryItemInvalid("player",10) then
		Ammo["count"]="|cff767676"..Ammo["count"].."|r";
	elseif Ammo["count"]<101 then
		Ammo["count"]="|cffFF0000"..Ammo["count"].."|r";
	elseif Ammo["count"]<501 then
		Ammo["count"]="|cffFFAA00"..Ammo["count"].."|r";
	end
--	Output
	local usrtxt={[1]=XBSet["AmmoV1"],[2]=XBSet["AmmoV2"]};
	local output="";
	for i=1,2 do
		usrtxt[i],_=string.gsub(usrtxt[i],"%[COUNT%]",Ammo["count"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[NAME%]",Ammo["name"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[EQUIP%]",Ammo["ecount"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[BAG%]",Ammo["bcount"]);
	end
	if XBSet["AmmoT1"]==true then output=usrtxt[1]; end
	if XBSet["AmmoT2"]==true then
		if XBSet["AmmoT1"]==true then output=output.."\n"..usrtxt[2]; else output=usrtxt[2]; end
	end
	XBarAmmo_F_S:SetText(output);
end

function XBarAmmo_OnEnter(this)
	GameTooltip:SetOwner(this,"ANCHOR_TOPRIGHT", -180,0);
	GameTooltip:SetText(XLng["Ttip"]["Ammo1"]);
	GameTooltip:AddLine(XLng["Ttip"]["Ammo2"],0,.7,.9);
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cffFFE855"..Ammo["name"].."|r", Ammo["count"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..BACKPACK_EQUIP.."|r", Ammo["ecount"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..GCF_TEXT_BAG.."|r", Ammo["bcount"]);
end