local Addon = CreateFrame("FRAME", "Bleak");

local actionBar, stanceBar;

local _G = _G;


----
--TODO
-- fade in/out in/out-of-combat
-- create more bars (side bars)
-- create pet bar


--------------------------------------------
--UTILS
--------------------------------------------


--Blizz function
--Slightly changed
local function ActionButton_OnUpdate (self, elapsed)
	if ( ActionButton_IsFlashing(self) ) then
		local flashtime = self.flashtime;
		flashtime = flashtime - elapsed;
		
		if ( flashtime <= 0 ) then
			local overtime = -flashtime;
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0;
			end
			flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;

			local flashTexture = _G[self:GetName().."Flash"];
			if ( flashTexture:IsShown() ) then
				flashTexture:Hide();
			else
				flashTexture:Show();
			end
		end
		
		self.flashtime = flashtime;
	end
	
	-- Handle range indicator
	local rangeTimer = self.rangeTimer;
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed;

		if ( rangeTimer <= 0 ) then
			if ( IsActionInRange(self.action) == 0 ) then
				_G[self:GetName().."Icon"]:SetVertexColor(1.0, 0.1, 0.1);
				--_G[self:GetName().."HotKey"]:SetVertexColor(1.0, 0.1, 0.1);
			else
				ActionButton_UpdateUsable(self);
				--_G[self:GetName().."HotKey"]:SetVertexColor(1, 1, 1);
			end

			rangeTimer = 0.2; --TOOLTIP_UPDATE_TIME = 0.2
		end
		
		self.rangeTimer = rangeTimer;
	end
end

--Blizz function
--Modified to work with BleakStanceButtons
local function ShapeshiftBar_UpdateState ()
	local numForms = GetNumShapeshiftForms();
	local texture, name, isActive, isCastable;
	local button, icon, cooldown;
	local start, duration, enable;
	for i=1, numForms do
		button = _G["BleakStanceButton"..i];
		icon = _G["BleakStanceButton"..i.."Icon"];
		--if ( i <= numForms ) then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i);
			icon:SetTexture(texture);
			
			--Cooldown stuffs
			cooldown = _G["BleakStanceButton"..i.."Cooldown"];
			if ( texture ) then
				cooldown:Show();
			else
				cooldown:Hide();
			end
			start, duration, enable = GetShapeshiftFormCooldown(i);
			CooldownFrame_SetTimer(cooldown, start, duration, enable);
			
			if ( isActive ) then
				ShapeshiftBarFrame.lastSelected = button:GetID();
				button:SetChecked(1);
			else
				button:SetChecked(0);
			end

			if ( isCastable ) then
				icon:SetVertexColor(1.0, 1.0, 1.0);
			else
				icon:SetVertexColor(0.4, 0.4, 0.4);
			end

			--button:Show();
--		else
--			button:Hide();
--		end
	end
end

--------------------------------------------




local function createActionButton(id)

	local btn = CreateFrame("CheckButton", "BleakActionButton" .. id, actionBar, "ActionBarButtonTemplate");
	--btn:SetID(id);
    btn:SetAttribute("type", "action");
    btn:SetAttribute("action", id);
    
    btn:SetSize(45,45);
    btn:SetPoint("CENTER", actionBar, (id-4.5)*60, 0);


	--setting textures    
   	btn:SetNormalTexture("Interface\\AddOns\\Bleak\\Textures\\ButtonBorder.blp");
   	btn:GetNormalTexture():ClearAllPoints();
   	btn:GetNormalTexture():SetPoint("TOPLEFT", btn, -14, 15);
   	btn:GetNormalTexture():SetPoint("BOTTOMRIGHT", btn, 14, -13);
      	
   	btn:SetHighlightTexture("Interface\\AddOns\\Bleak\\Textures\\ButtonHighlight.blp");
       	
   	btn:SetPushedTexture("Interface\\AddOns\\Bleak\\Textures\\ButtonPushed.blp");
   	btn:GetPushedTexture():ClearAllPoints();
   	btn:GetPushedTexture():SetPoint("TOPLEFT", btn, -14, 15);
   	btn:GetPushedTexture():SetPoint("BOTTOMRIGHT", btn, 14, -13);
     	
   	btn:SetCheckedTexture("Interface\\AddOns\\Bleak\\Textures\\ButtonChecked.blp");
   	btn:GetCheckedTexture():ClearAllPoints();
   	btn:GetCheckedTexture():SetPoint("TOPLEFT", btn, -14, 15);
   	btn:GetCheckedTexture():SetPoint("BOTTOMRIGHT", btn, 14, -13);
      	       	
   	btn.icon:SetTexCoord(0.075,0.925,0.075,0.925);
    
    
    --updating hotkeys, it seems it doesnt update on login
    --ActionButton_UpdateHotkeys(btn);
    btn.cooldown:SetDrawEdge(true);
    
    --Hotkey font
    _G["BleakActionButton" .. id .. "HotKey"]:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 18, "OUTLINE");
	_G["BleakActionButton" .. id .. "HotKey"]:SetTextColor(0.7, 0.7, 0.7, 1);
	_G["BleakActionButton" .. id .. "HotKey"]:ClearAllPoints();
	_G["BleakActionButton" .. id .. "HotKey"]:SetJustifyH("CENTER");
	_G["BleakActionButton" .. id .. "HotKey"]:SetPoint("BOTTOM", 0, -20);
    
    --Name font
    _G["BleakActionButton" .. id .. "Name"]:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 14, "OUTLINE");
	_G["BleakActionButton" .. id .. "Name"]:SetTextColor(0.7, 0.7, 0.7, 1);
	
	--Count font
    _G["BleakActionButton" .. id .. "Count"]:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 16, "OUTLINE");
	_G["BleakActionButton" .. id .. "Count"]:SetTextColor(0.7, 0.7, 0.7, 1);
	
	
	btn:SetScript("OnUpdate", ActionButton_OnUpdate);
   
	return btn;
    
end


local function createStanceButton(id)

	local btn = CreateFrame("CheckButton", "BleakStanceButton" .. id, stanceBar, "ShapeshiftButtonTemplate");
	btn:SetID(id);
	
	btn:SetSize(32,32);
    btn:SetPoint("CENTER", stanceBar, (id-GetNumShapeshiftForms()/2-0.5)*45, 0);
    
    btn.icon:SetTexCoord(0.075,0.925,0.075,0.925);
    
    --setting textures    
   	btn:SetNormalTexture("Interface\\AddOns\\Bleak\\Textures\\ButtonBorder.blp");
   	btn:GetNormalTexture():ClearAllPoints();
   	btn:GetNormalTexture():SetPoint("TOPLEFT", btn, -9, 12);
   	btn:GetNormalTexture():SetPoint("BOTTOMRIGHT", btn, 10, -10);
      	
   	btn:SetHighlightTexture("Interface\\AddOns\\Bleak\\Textures\\ButtonHighlight.blp");
       	
   	btn:SetPushedTexture("Interface\\AddOns\\Bleak\\Textures\\ButtonPushed.blp");
   	btn:GetPushedTexture():ClearAllPoints();
   	btn:GetPushedTexture():SetPoint("TOPLEFT", btn, -9, 12);
   	btn:GetPushedTexture():SetPoint("BOTTOMRIGHT", btn, 10, -10);
     	
   	btn:SetCheckedTexture("Interface\\AddOns\\Bleak\\Textures\\ButtonChecked.blp");
   	btn:GetCheckedTexture():ClearAllPoints();
   	btn:GetCheckedTexture():SetPoint("TOPLEFT", btn, -9, 12);
   	btn:GetCheckedTexture():SetPoint("BOTTOMRIGHT", btn, 10, -10);
    
    
    btn.cooldown:SetDrawEdge(true);

end




local function setUpActionBar()
	
	actionBar = CreateFrame("FRAME", "BleakActionBar", UIParent);
	actionBar:SetSize(512*0.94,128*0.94);
	actionBar:SetPoint("BOTTOM", UIParent, 0, 0);
	
	actionBar.background = actionBar:CreateTexture(nil, "BACKGROUND");
	actionBar.background:SetTexture("Interface\\AddOns\\Bleak\\Textures\\Background.blp");
	actionBar.background:SetAllPoints();
	actionBar.background:SetAlpha(0.85);
	
	for buttonID = 1, 8 do
		actionBar[buttonID] = createActionButton(buttonID);
	end
	
	
	--Blizz is reducing alpha on normal textures everytime the actionBar grid is shown.
	--And it doesn't revert it back. So, this finish the job.
	actionBar:SetScript("OnEvent", function(self, event, ...)
		for buttonID = 1, 8 do
			actionBar[buttonID]:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	end);

	actionBar:RegisterEvent("ACTIONBAR_HIDEGRID");

end


local function setUpStanceBar()

	if(GetNumShapeshiftForms() == 0) then
		return;
	end
	
	stanceBar = CreateFrame("FRAME", "BleakStanceBar", actionBar);
	stanceBar:SetSize(512*0.94,64*0.94);
	stanceBar:SetPoint("TOP", actionBar, 0, 64*0.94*0.5);
	
	
	for buttonID = 1, GetNumShapeshiftForms() do
		stanceBar[buttonID] = createStanceButton(buttonID);
	end


	stanceBar:SetScript("OnEvent", ShapeshiftBar_UpdateState);
	
	ShapeshiftBar_OnLoad(stanceBar);
	
end




Addon:SetScript("OnEvent", function(self, event, ...)

	setUpActionBar();
	setUpStanceBar();
	
	--for Bindings.xml
	BINDING_HEADER_BLEAK = "Bleak";
	for i = 1, 8 do
		_G["BINDING_NAME_CLICK BleakActionButton".. i ..":LeftButton"] = "Action Button " .. i;
	end
	
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		_G["BINDING_NAME_CLICK BleakStanceButton".. i ..":LeftButton"] = "Stance Button " .. i;
	end
	

	MainMenuBar:Hide();
	
	Addon:UnregisterAllEvents();

end);

Addon:RegisterEvent("PLAYER_ENTERING_WORLD");