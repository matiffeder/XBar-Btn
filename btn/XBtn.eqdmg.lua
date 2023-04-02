local function DuraColor(color)
	if color<41 then return "|cffFF0000";
	elseif color<86 then return "|cffFFAA00";
	else return "|cffFFFFFF"; end
end

function XBarEQDmg_OnEvent(this)
	local AvgDur=0;
	local itemCount=0;
	XBarDps_BD:Hide();
	for i=0,21 do
		local X={};
		if GetInventoryItemTexture("player",i) then
			_G["XBarEQDmg_Slot"..i.."_Icon"]:SetTexture(GetInventoryItemTexture("player",i));
		else
			_G["XBarEQDmg_Slot"..i.."_Icon"]:SetTexture("Interface/Icons/Geq.tga"); 
			_G["XBarEQDmg_Slot"..i.."_Text"]:SetText("");
		end
		_G["XBarEQDmg_Slot"..i]:SetID(i);
		X["curD"],X["maxD"]=GetInventoryItemDurable("player",i);
		if X["maxD"]~=0 and i~=18 and i~=19 and i~=20 and i~=9 then
			itemCount=itemCount+1;
			local TEMP_DUR=math.ceil((X["curD"]/X["maxD"])*1000)/10;
			AvgDur=AvgDur+TEMP_DUR;
			if X["maxD"]>100 then
				X["maxD"] = "|cff00FF00"..X["maxD"].."|r";
			end
			if XBSet["EQDmg_C"]==false then
				if X["curD"]>100 then
					_G["XBarEQDmg_Slot"..i.."_Text"]:SetText("|cff00FF00"..TEMP_DUR.."%|r");
				else
					_G["XBarEQDmg_Slot"..i.."_Text"]:SetText(DuraColor(TEMP_DUR)..TEMP_DUR.."%|r");
				end
			elseif XBSet["EQDmg_C"]==true then
				if X["curD"]>100 then
					_G["XBarEQDmg_Slot"..i.."_Text"]:SetText("|cff00FF00"..X["curD"].."/|r"..X["maxD"]);
				else
					_G["XBarEQDmg_Slot"..i.."_Text"]:SetText(DuraColor(TEMP_DUR)..X["curD"].."/"..X["maxD"].."|r");
				end
			end
			if not XBarDps_BD:IsVisible() and (GetInventoryItemInvalid("player",i) or TEMP_DUR<50) then
				XBarDps_BD:Show();
			end
		end
	end
	if itemCount==0 then return; end
	AvgDur=math.ceil((AvgDur/itemCount)*10)/10;
	AvgDur=DuraColor(AvgDur)..AvgDur.."%|r";
	XBarEQDmg_AvgName:SetText(XLng["Ttip"]["AvgDur"]);
	XBarEQDmg_AvgDura:SetText(AvgDur);
	XBtnDura = AvgDur;
end
