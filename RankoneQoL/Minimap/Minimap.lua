-------------------------------------------------------------------------------
-- 1. MODULE INITIALIZATION
-------------------------------------------------------------------------------
local addonName, RankoneQoL = ...

-------------------------------------------------------------------------------
-- 2. MINIMAP BUTTON INTERACTION LOGIC
-------------------------------------------------------------------------------
local function AktualisiereMinimapButtonPosition(btn)
    local winkel = RankoneQoLEinstellungen.minimapWinkel or 45
    local x = math.cos(math.rad(winkel)) * 80
    local y = math.sin(math.rad(winkel)) * 80
    btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function RankoneQoL.ErstelleMinimapButton()
    local btn = CreateFrame("Button", "RankoneQoLMiniBtn", Minimap)
    btn:SetSize(31, 31) btn:SetFrameStrata("MEDIUM") btn:SetFrameLevel(8) btn:SetDontSavePosition(true)
    
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52) border:SetPoint("TOPLEFT", btn, "TOPLEFT", -6, 6)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    
    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(18, 18) icon:SetPoint("CENTER", btn, "CENTER", -1, 1)
    icon:SetTexture("Interface\\AddOns\\RankoneQoL\\logo")
    
    RankoneQoL.ErstelleDasMenue()
    AktualisiereMinimapButtonPosition(btn)
    
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then if RankoneQoL.ToggleStandaloneUI then RankoneQoL.ToggleStandaloneUI() end
        elseif button == "RightButton" then ReloadUI() end
    end)
    
    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(self)
            local mx, my = GetCursorPosition() local scale = Minimap:GetEffectiveScale() local px, py = Minimap:GetCenter()
            local winkel = math.deg(math.atan2((my/scale) - py, (mx/scale) - px))
            if winkel < 0 then winkel = winkel + 360 end
            RankoneQoLEinstellungen.minimapWinkel = winkel AktualisiereMinimapButtonPosition(self)
        end)
    end)
    btn:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT") GameTooltip:SetText("|cFF575EFFRankøneQoL|r")
        if GetLocale() == "deDE" then
            GameTooltip:AddLine("|cFFFFFFFFLinksklick:|r Addon-Fenster öffnen", 1, 1, 1)
            GameTooltip:AddLine("|cFFFFFFFFRechtsklick:|r Interface neu laden (Reload)", 1, 1, 1)
            GameTooltip:AddLine("|cFF888888Ziehen zum Bewegen|r", 1, 1, 1)
        else
            GameTooltip:AddLine("|cFFFFFFFFLeft-Click:|r Open Addon Window", 1, 1, 1)
            GameTooltip:AddLine("|cFFFFFFFFRight-Click:|r Reload User Interface", 1, 1, 1)
            GameTooltip:AddLine("|cFF888888Drag to move|r", 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
end
