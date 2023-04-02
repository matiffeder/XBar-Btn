local Money={["total"]=GetPlayerMoney("copper"),["session"]=0,["spent"]=0};
 
function XBarMoney_OnEvent(this,event)
	if event=="LOADED" then
		this:RegisterEvent("PLAYER_MONEY");
		this:RegisterEvent("PLAYER_BAG_CHANGED");
	end
	if event=="PLAYER_MONEY" then 
		local temp=Money["total"];
		local diff=0;
		Money["total"]=GetPlayerMoney("copper");
		if temp<Money["total"] then
			diff=math.ceil(Money["total"]-temp);
			Money["session"]=Money["session"]+diff;
		elseif temp>Money["total"] then
			diff=math.ceil(temp-Money["total"]);
			Money["spent"]=Money["spent"]+diff;
		end
	end
	if event=="PLAYER_BAG_CHANGED" or event=="LOADED" then
		Money["AMCount"] = GetCountInBagByName(TEXT("Sys206879_name")) + GetCountInBankByName(TEXT("Sys206879_name"));
		Money["PSCount"] = GetCountInBagByName(TEXT("Sys240181_name")) + GetCountInBankByName(TEXT("Sys240181_name"));
		Money["EJCount"] = GetCountInBagByName(TEXT("Sys201545_name")) + GetCountInBankByName(TEXT("Sys201545_name"));
	end
-- Output
	local usrtxt={[1]=XBSet["MoneyV1"],[2]=XBSet["MoneyV2"]};
	local output="";
	for i=1,2 do
		usrtxt[i],_=string.gsub(usrtxt[i],"%[GOLD%]","|cffFFEE80"..XBar_Dec(GetPlayerMoney("copper")).."|r");
		usrtxt[i],_=string.gsub(usrtxt[i],"%[DIAS%]","|cffC7C7FF"..XBar_Dec(GetPlayerMoney("account")).."|r");
		usrtxt[i],_=string.gsub(usrtxt[i],"%[RUBY%]","|cffFFC7C7"..XBar_Dec(GetPlayerMoney("bonus")).."|r");
		usrtxt[i],_=string.gsub(usrtxt[i],"%[COIN%]","|cffC7C7C7"..XBar_Dec(GetPlayerMoney("billdin")).."|r");
		usrtxt[i],_=string.gsub(usrtxt[i],"%[AM%]", "|cffC7FFC7"..Money["AMCount"].."|r");
		usrtxt[i],_=string.gsub(usrtxt[i],"%[PS%]", "|cffC7FFC7"..Money["PSCount"].."|r");
		usrtxt[i],_=string.gsub(usrtxt[i],"%[EJ%]", "|cffC7FFC7"..Money["EJCount"].."|r");
	end
	if XBSet["MoneyT1"]==true then output=usrtxt[1]; end
	if XBSet["MoneyT2"]==true then
		if XBSet["MoneyT1"]==true then output=output.."\n"..usrtxt[2]; else output=usrtxt[2]; end
	end
	XBarMoney_F_S:SetText(output);
end

function XBarMoney_OnEnter(this)
	GameTooltip:SetOwner(this,"ANCHOR_TOPRIGHT", -180,0);
	GameTooltip:SetText(XLng["Ttip"]["Money1"]);
	GameTooltip:AddLine(XLng["Ttip"]["Money2"],0,.7,.9);
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cff8DE668"..XLng["Ttip"]["Money3"].."|r",XBar_Dec(Money["session"]));
	GameTooltip:AddDoubleLine("|cffE66868"..XLng["Ttip"]["Money4"].."|r",XBar_Dec(Money["spent"]));
	GameTooltip:AddDoubleLine(XLng["Ttip"]["Money5"],XBar_Dec(math.ceil(Money["session"]-Money["spent"])));
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cffFFE855"..MONEY_GOLD.."|r", XBar_Dec(GetPlayerMoney("copper")));
	GameTooltip:AddDoubleLine("|cffFFE855"..MONEY_RUNE.."|r", XBar_Dec(GetPlayerMoney("account")));
	GameTooltip:AddDoubleLine("|cffFFE855"..MONEY_RUBY.."|r", XBar_Dec(GetPlayerMoney("bonus")));
	GameTooltip:AddDoubleLine("|cffFFE855".._glossary_00844.."|r", XBar_Dec(GetPlayerMoney("billdin")));
	GameTooltip:AddDoubleLine("|cffFFE855"..TEXT("Sys206879_name").."|r", Money["AMCount"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..TEXT("Sys240181_name").."|r", Money["PSCount"]);
	GameTooltip:AddDoubleLine("|cffFFE855"..TEXT("Sys201545_name").."|r", Money["EJCount"]);
end