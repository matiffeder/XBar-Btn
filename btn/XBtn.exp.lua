--primary class exp fix by Yamabuki
local Exp={
	["xpbonus"]=0,["tpbonus"]=0,["xpdebt"]=0,["tpdebt"]=0,
	["xpm"]=0,["xpmold"]=0,["xpnew"]=0,["xpold"]=0,["tpnew"]=0,["tpold"]=0,
	["xplast"]=0,["tplast"]=0,["xpre"]=0,["xpleft"]=0,["xpse"]=0,["tpse"]=0,
	["sc"]=NONE,["sl"]=0,["sExp"]=NONE,["smExp"]=NONE,["sExpd"]=NONE,["sTpd"]=NONE,["sPer"]=0,
	["tc"]=NONE,["tl"]=0,["tExp"]=NONE,["tmExp"]=NONE,["tExpd"]=NONE,["tPer"]=0
};

function XBarExp_OnEvent(this,event)
	if event=="LOADED" then
		this:RegisterEvent("TP_EXP_UPDATE");
		this:RegisterEvent("UNIT_CLASS_CHANGED");
		this:RegisterEvent("PLAYER_EXP_CHANGED");
	end
	if event=="UNIT_CLASS_CHANGED" then
		Exp["xpnew"]=0;
		Exp["tpnew"]=0;
		Exp["xpbonus"],Exp["tpbonus"]=GetPlayerExtraPoint();
	end
	if event=="TP_EXP_UPDATE" or event=="PLAYER_EXP_CHANGED" or event=="LOADED" then
		Exp["xpbonus"],Exp["tpbonus"]=GetPlayerExtraPoint();
		Exp["tpused"] = XBar_Dec(GetTotalTpExp() - GetTpExp("Tp"));
		Exp["xpdebt"], Exp["tpdebt"] = GetPlayerExpDebt();
		if Exp["xpdebt"]<0 or Exp["tpdebt"]<0 then XBarExp_Debt:Show(); else XBarExp_Debt:Hide(); end
		if Exp["tpnew"]~=GetTpExp("Tp") then
			if Exp["tpnew"]~=0 then Exp["tpold"]=Exp["tpnew"];
			else Exp["tpold"]=GetTpExp("Tp"); end
			Exp["tpnew"]=GetTpExp("Tp");
			Exp["tplast"]=Exp["tpnew"]-Exp["tpold"];
			Exp["tpse"]=Exp["tpse"]+Exp["tplast"];
		end
		if Exp["xpnew"]~=GetPlayerExp("player") then
			if Exp["xpnew"]~=0 then
				Exp["xpold"]=Exp["xpnew"];
				Exp["xpmold"]=Exp["xpm"];
			else
				Exp["xpold"]=GetPlayerExp("player");
				Exp["xpmold"]=GetPlayerMaxExp("player");
			end
			Exp["xpnew"]=GetPlayerExp("player");
			Exp["xpm"]=GetPlayerMaxExp("player");
			if Exp["xpm"]~=Exp["xpmold"] then Exp["xplast"]=Exp["xpnew"]+Exp["xpleft"];	-- level up
			else Exp["xplast"]=Exp["xpnew"]-Exp["xpold"]; end
			Exp["xpleft"]=Exp["xpm"]-Exp["xpnew"];
			Exp["xpse"]=Exp["xpse"]+Exp["xplast"];
			if Exp["xplast"]~=0 then Exp["xpre"]=math.ceil(Exp["xpleft"]/Exp["xplast"]);
			else Exp["xpre"]=NONE; end
		end
	end
	if event=="UNIT_CLASS_CHANGED" or event=="LOADED" then
		local sload = nil;
		local mainC, subC = UnitClass("player");
		local count = GetPlayerNumClasses();
		for i = 1, count do
			local class, _, level, currExp, maxExp, debt = GetPlayerClassInfo(i, true);
			if class~=nil and class~=mainC then
				if class==subC or (subC=="" and sload==nil) then
					Exp["sc"] = class;
					Exp["sl"] = level;
					Exp["sExp"] = XBar_Dec(currExp);
					Exp["smExp"] = XBar_Dec(maxExp);
					Exp["sPer"] = string.format("%.2f", currExp/maxExp*100);
					Exp["sExpd"] = XBar_Dec(debt);
					Exp["sTpd"] = NONE;
					sload = true;
				end
				if count==3 then
					if (subC~="" and class~=subC) or subC=="" then
						Exp["tc"] = class;
						Exp["tl"] = level;
						Exp["tExp"] = XBar_Dec(currExp);
						Exp["tmExp"] = XBar_Dec(maxExp);
						Exp["tPer"] = string.format("%.2f", currExp/maxExp*100);
						Exp["tExpd"] = XBar_Dec(debt);
					end
				end
			end
		end
		if subC~="" and subC~=nil then _, _, Exp["sExpd"], Exp["sTpd"] = GetPlayerExpDebt(); end
	end
--	Output
	local usrtxt={[1]=XBSet["ExpV1"],[2]=XBSet["ExpV2"]};
	local output="";
	for i=1,2 do
		usrtxt[i],_=string.gsub(usrtxt[i],"%[XP%]",XBar_Dec(GetPlayerExp("player")));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TP%]",XBar_Dec(GetTpExp("Tp")));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[XPN%]",XBar_Dec(GetPlayerMaxExp("player")-GetPlayerExp("player")));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[XPF%]",XBar_Dec(GetPlayerMaxExp("player")));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[PER%]",string.format("%.2f",(GetPlayerExp("player")/GetPlayerMaxExp("player"))*100));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[PERN%]",string.format("%.2f",((GetPlayerMaxExp("player")-GetPlayerExp("player"))/GetPlayerMaxExp("player"))*100));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TPA%]",XBar_Dec(GetTotalTpExp()));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TPU%]",Exp["tpused"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[XPB%]",XBar_Dec(Exp["xpbonus"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TPB%]",XBar_Dec(Exp["tpbonus"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[XPD%]",XBar_Dec(Exp["xpdebt"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TPD%]",XBar_Dec(Exp["tpdebt"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[XPL%]",XBar_Dec(Exp["xplast"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TPL%]",XBar_Dec(Exp["tplast"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[XPS%]",XBar_Dec(Exp["xpse"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TPS%]",XBar_Dec(Exp["tpse"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[XPRE%]",XBar_Dec(Exp["xpre"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[SEXP%]",XBar_Dec(Exp["sExp"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[SMEXP%]",XBar_Dec(Exp["smExp"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[SPER%]",Exp["sPer"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[SXPD%]",XBar_Dec(Exp["sExpd"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[STPD%]",XBar_Dec(Exp["sTpd"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TEXP%]",XBar_Dec(Exp["tExp"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TMEXP%]",XBar_Dec(Exp["tmExp"]));
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TPER%]",Exp["tPer"]);
		usrtxt[i],_=string.gsub(usrtxt[i],"%[TXPD%]",XBar_Dec(Exp["tExpd"]));
	end
	if XBSet["ExpT1"]==true then output=usrtxt[1]; end
	if XBSet["ExpT2"]==true then
		if XBSet["ExpT1"]==true then output=output.."\n"..usrtxt[2]; else output=usrtxt[2]; end
	end
	XBarExp_F_S:SetText(output);
end

function XBarExp_OnEnter(this)
	GameTooltip:SetOwner(this,"ANCHOR_TOPRIGHT", -180,0);
	GameTooltip:SetText(XLng["Ttip"]["Exp1"]);
	GameTooltip:AddLine(XLng["Ttip"]["Exp2"],0,.7,.9);
	GameTooltip:AddLine(XLng["Ttip"]["CR_REST"],0,.7,.9);
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["Exp3"].."|r",XBar_Dec(GetPlayerExp("player")).." / "..string.format("%.2f",(GetPlayerExp("player")/GetPlayerMaxExp("player"))*100).."%");
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["Exp4"].."|r",XBar_Dec(GetPlayerMaxExp("player")-GetPlayerExp("player")).." / "..string.format("%.2f",((GetPlayerMaxExp("player")-GetPlayerExp("player"))/GetPlayerMaxExp("player"))*100).."%");
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["Exp7"].."|r",XBar_Dec(GetPlayerMaxExp("player")).." / 100%");
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["Exp5"].."|r",string.format("XP: %s (TP: %s)",XBar_Dec(Exp["xplast"]),XBar_Dec(Exp["tplast"])));
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["Exp6"].."|r",XBar_Dec(Exp["xpre"]));
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["Exp7"].."|r",string.format("XP: %s (TP: %s)",XBar_Dec(Exp["xpse"]),XBar_Dec(Exp["tpse"])));
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Ttip"]["Exp8"].."|r",XBar_Dec(GetTpExp("Tp")));
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Exp16"].."|r",XBar_Dec(GetTotalTpExp()));
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Exp17"].."|r",XBar_Dec(Exp["tpused"]));
	GameTooltip:AddSeparator();
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Exp7"].."|r",XBar_Dec(Exp["xpbonus"]));
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Exp8"].."|r",XBar_Dec(Exp["tpbonus"]));
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Exp9"].."|r",XBar_Dec(Exp["xpdebt"]));
	GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Exp10"].."|r",XBar_Dec(Exp["tpdebt"]));
	if Exp["sc"]~=NONE then
		GameTooltip:AddSeparator();
		GameTooltip:AddDoubleLine(" ", "|cff8DE668"..Exp["sc"].." "..Exp["sl"]);
		GameTooltip:AddDoubleLine("|cffFFE855"..PET_EXP.."|r", Exp["sExp"].."/"..Exp["smExp"]);
		GameTooltip:AddDoubleLine(" ", Exp["sPer"].."%");
		GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Exp9"].."|r", Exp["sExpd"]);
		GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Exp10"].."|r", Exp["sTpd"]);
	end
	if Exp["tc"]~=NONE then
		GameTooltip:AddSeparator();
		GameTooltip:AddDoubleLine(" ", "|cff8DE668"..Exp["tc"].." "..Exp["tl"]);
		GameTooltip:AddDoubleLine("|cffFFE855"..PET_EXP.."|r", Exp["tExp"].."/"..Exp["tmExp"]);
		GameTooltip:AddDoubleLine(" ", Exp["tPer"].."%");
		GameTooltip:AddDoubleLine("|cffFFE855"..XLng["Config"]["Exp9"].."|r", Exp["tExpd"]);
	end
end

function XBarExp_Reset()
	Exp["xplast"] = 0; Exp["tplast"] = 0; Exp["xpre"] = 0; Exp["xpse"] = 0; Exp["tpse"] = 0;
end