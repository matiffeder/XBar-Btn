--Sold Items feature made by Mavoc
local soldstring = string.gsub(TEXT("SYS_AC_SELL_SUCCESS"), "%%s", "(.+)")
local unread = 0
local soldtable = {}

function XBarMail_OnEvent(this,event)
	if event=="LOADED" then
		this:RegisterEvent("MAIL_SHOW")
		this:RegisterEvent("CHAT_MSG_SYSTEM")
	end
	if event=="MAIL_SHOW" then
		unread = 0
		soldtable = {}
		XBarMail_New:Hide();
	end
	if event=="CHAT_MSG_SYSTEM" then
		if arg1==TEXT("SYS_NEW_MAIL") then
			XBarMail_New:Show();
			unread = unread + 1
		elseif string.match(arg1, soldstring) then
			for v in string.gmatch(arg1, soldstring) do
				table.insert(soldtable, v)
			end
		end
	end
--	Output
	local usrtxt = {[1] = XBSet["MailV1"], [2] = XBSet["MailV2"]}
	local output = ""
	for i = 1, 2 do
		usrtxt[i], _ = string.gsub(usrtxt[i], "%[UNREAD%]", unread)
	end
	if XBSet["MailT1"]==true then
		output=usrtxt[1]
	end
	if XBSet["MailT2"]==true then
		if XBSet["MailT1"]==true then
			output=output.."\n"..usrtxt[2]
		else
			output=usrtxt[2]
		end
	end
	XBarMail_F_S:SetText(output);
end

function XBarMail_OnClick()
	if TimeLet_GetLetTime("MailLet")<0 then
		StaticPopup_Show("TIMEFLAG_FAIL1")
		return
	else
		OpenMail()
		XBarMail_New:Hide();
	end
end

function XBarMail_OnEnter(this)
	GameTooltip:SetOwner(this,"ANCHOR_TOPRIGHT", -180,0)
	GameTooltip:SetText(XLng["Ttip"]["Mail1"]) --line 1
	GameTooltip:AddLine(XLng["Ttip"]["Mail2"],0,.7,.9) --line 2.3
	GameTooltip:AddSeparator(); --line 4
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Mail1"].."|r", unread); --line 5
	if #(soldtable)>0 then
		GameTooltip:AddSeparator(); --line 6
		GameTooltip:AddLine("|cff8DE668"..XLng["Ttip"]["Mail3"].."|r"); --line 7
		for i, v in ipairs(soldtable) do
			if i<32 then --lines 8-39
				GameTooltip:AddLine(v);
			else
				GameTooltip:AddLine("..."); --line 40
				break
			end
		end
	end
end