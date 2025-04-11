local AIO = AIO or require("AIO")

-- CLIENT SECRET
local clientSecret = ""
local handlerName = "yQ4CiWjHET"

local LastContainerNum = 1
-- Settings
local iconSize = 35
local leftConst = 172
local itemsPerRow = 7
local current_class = 1
local current_spec = 1
local prices = {}

-- Ready-to-use for the system
local classes = {
    "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman",
    "Warlock", "Warrior", "MONK", "DEMONHUNTER"
};
local class_list = {
    "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN",
    "WARLOCK", "WARRIOR"
}
local spell_point_list = {}
local talent_point_list = {}

-- Layout configuration object - easily modify these values to adjust positioning
local layoutConfig = {
    -- Main frame dimensions
    frameWidth = 750,
    contentPadding = 25,
    columnHeight = 540,
    topOffset = -55,

    -- Header positioning
    mainHeaderSpacing = 10,
    mainHeadersY = 100,

    -- Specialization section
    specSpacing = 70,
    specHeaderHeight = 30,
    specIconSize = 36,
    specNamePadding = 10,

    -- Column widths and positions
    spellLabelOffset = 40,
    talentLabelOffset = 80,
    contentTopPadding = 50,

    -- Grid layout
    iconSize = 35,
    iconHorizontalSpacing = 50,
    iconVerticalSpacing = 65,
    iconsPerHalfRow = 6,

    -- Class-specific offsets to fine-tune alignment
    classSpecOffsets = {
        ["DRUID"] = {[1] = {0, 0}, [2] = {0, 0}, [3] = {0, 0}},
        ["HUNTER"] = {[1] = {0, 0}, [2] = {0, 0}, [3] = {0, 0}},
        ["MAGE"] = {[1] = {0, 0}, [2] = {0, 0}, [3] = {0, 0}},
        ["PALADIN"] = {[1] = {0, 0}, [2] = {0, 0}, [3] = {0, 0}},
        ["PRIEST"] = {[1] = {0, 0}, [2] = {0, 0}, [3] = {0, 0}},
        ["ROGUE"] = {[1] = {0, 0}, [2] = {0, 0}, [3] = {0, 0}},
        ["SHAMAN"] = {[1] = {0, 0}, [2] = {0, 0}, [3] = {0, 0}},
        ["WARLOCK"] = {[1] = {0, 0}, [2] = {0, 0}, [3] = {0, 0}},
        ["WARRIOR"] = {[1] = {0, 0}, [2] = {0, 0}, [3] = {0, 0}}
    }
}

-- Data
if AIO.IsServer() then
    -- Spells
    AIO.AddAddon("lua_scripts/ClassLess/data/spells.data", "spells")
    -- Talents
    AIO.AddAddon("lua_scripts/ClassLess/data/talents.data", "talents")
    -- Locks
    AIO.AddAddon("lua_scripts/ClassLess/data/locks.data", "locks")
    -- Requirements
    AIO.AddAddon("lua_scripts/ClassLess/data/req.data", "req")
end

if AIO.AddAddon() then return end

-- Variables
local spellsplus, spellsminus = {}, {}
local tpellsplus, tpellsminus = {}, {}
local talentsplus, talentsminus = {}, {}
local db = CLDB

-- Functions
local function CountSpellPoints(c, s)
    local r = 0
    for k, v in pairs(db.data.spells[class_list[c]][s][4]) do
        if tContains(db.spells, v[1][1]) then r = r + 1 end
    end
    return r
end

local function CountTalentPoints(c, s)
    local r = 0
    for k, v in pairs(db.data.talents[class_list[c]][s][4]) do
        for i, j in pairs(v[1]) do
            if tContains(db.talents, j) then r = r + 1 end
        end
    end
    return r
end

local function UpdatePointText()
    for k, v in pairs(class_list) do
        local cap = 0
        local ctp = 0
        for i = 1, 3 do
            local ap = CountSpellPoints(k, i)
            cap = cap + ap
            local tp = CountTalentPoints(k, i)
            ctp = ctp + tp
            for j = 1, 2 do
                _G["CLContainer" .. j .. "Sub" .. k .. "SubButton" .. i].text:SetText(
                    tostring(ap))
                _G["CLContainer" .. j .. "Sub" .. k .. "SubButton" .. i].text2:SetText(
                    tostring(tp))
            end
        end
        for j = 1, 2 do
            _G["CLContainer" .. j .. "SubButton" .. k].text:SetText(
                tostring(cap))
            _G["CLContainer" .. j .. "SubButton" .. k].text2:SetText(tostring(
                                                                         ctp))
        end
    end
end

local function FrameToggle(frame)
    local f = _G[frame]
    if f ~= nil then
        if f:IsVisible() ~= 1 then
            f:Show()
        elseif f:IsVisible() == 1 then
            f:Hide()
        end
    end
end

local function FrameShow(fname)
    local frame = fname
    if type(fname) ~= "table" then frame = _G[fname] end
    if frame ~= nil and frame:IsVisible() ~= 1 then frame:Show() end
end

local function FrameHide(fname)
    local frame = fname
    if type(fname) ~= "table" then frame = _G[fname] end
    if frame ~= nil and frame:IsVisible() == 1 then frame:Hide() end
end

local function tCopy(t)
    local u = {}
    for k, v in pairs(t) do u[k] = v end
    return setmetatable(u, getmetatable(t))
end

local function tContainsCache(arr, val)
    if not arr.__lookupCache then
        arr.__lookupCache = {}
        for i, v in ipairs(arr) do arr.__lookupCache[v] = true end
    end
    return arr.__lookupCache[val] or false
end

-- Clear cache when modifying arrays
local function clearArrayCache(arr)
    if arr and arr.__lookupCache then arr.__lookupCache = nil end
end

-- Main UI Setup Function
local function InitializeClasslessUI()
    -- Table Functions
    local function tRemoveKey(table, key)
        for i = #table, 1, -1 do  -- Iterate backwards to avoid skip issues
            if table[i] == key then tremove(table, i) end
        end
    end

    local function tCompare(t1, t2)
        if #t1 ~= #t2 then return false end
        for i = 1, #t1 do if t1[i] ~= t2[i] then return false end end
        return true
    end

    local function pairsSort(t, f)
        local a = {}
        for n in pairs(t) do table.insert(a, n) end
        table.sort(a, f)
        local i = 0
        local iter = function()
            i = i + 1
            if a[i] == nil then
                return nil
            else
                return a[i], t[a[i]]
            end
        end
        return iter
    end

    -- Frame Creation Functions
    local function CreateTexture(base, layer, path, blend)
        local t = base:CreateTexture(nil, layer)
        if path then t:SetTexture(path) end
        if blend then t:SetBlendMode(blend) end
        return t
    end

    local function FrameBackground(frame, background)
        local t = CreateTexture(frame, "BACKGROUND")
        t:SetPoint("TOPLEFT")
        frame.topleft = t

        t = CreateTexture(frame, "BACKGROUND")
        t:SetPoint("TOPLEFT", frame.topleft, "TOPRIGHT")
        frame.topright = t

        t = CreateTexture(frame, "BACKGROUND")
        t:SetPoint("TOPLEFT", frame.topleft, "BOTTOMLEFT")
        frame.bottomleft = t

        t = CreateTexture(frame, "BACKGROUND")
        t:SetPoint("TOPLEFT", frame.topleft, "BOTTOMRIGHT")
        frame.bottomright = t
    end

    local function FrameLayout(frame, width, height)
        local texture_height = height / (256 + 75)
        local texture_width = width / (256 + 44)

        frame:SetSize(width, height)

        local wl, wr, ht, hb = texture_width * 256, texture_width * 64,
                               texture_height * 256, texture_height * 128

        frame.topleft:SetSize(wl, ht)
        frame.topright:SetSize(wr, ht)
        frame.bottomleft:SetSize(wl, hb)
        frame.bottomright:SetSize(wr, hb)
    end

    local function MakeButton(name, parent)
        local button = CreateFrame("Button", name, parent)

        button:SetNormalFontObject(GameFontNormal)
        button:SetHighlightFontObject(GameFontHighlight)
        button:SetDisabledFontObject(GameFontDisable)
        if name == "CLButton1" or name == "CLButton2" then
            local texture = button:CreateTexture("BACKGROUND")
            if name == "CLButton1" then
                texture:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
            else
                texture:SetTexture("Interface\\Icons\\Ability_Marksmanship")
            end
            local size = button:GetSize()
            texture:SetAllPoints()
            texture:SetSize(0.5 * size, 0.5 * size)
            button.texture = texture
        else
            local texture = button:CreateTexture()
            texture:SetTexture "Interface\\Buttons\\UI-Panel-Button-Up"
            texture:SetTexCoord(0, 0.625, 0, 0.6875)
            texture:SetAllPoints(button)
            button.normal = texture
            button:SetNormalTexture(texture)
            texture = button:CreateTexture()
            texture:SetTexture "Interface\\Buttons\\UI-Panel-Button-Down"
            texture:SetTexCoord(0, 0.625, 0, 0.6875)
            texture:SetAllPoints(button)
            button.pushed = texture
            button:SetPushedTexture(texture)
            texture = button:CreateTexture()
            texture:SetTexture "Interface\\Buttons\\UI-Panel-Button-Highlight"
            texture:SetTexCoord(0, 0.625, 0, 0.6875)
            texture:SetAllPoints(button)
            button:SetHighlightTexture(texture)
        end
        return button
    end

    local function MakeRankFrame(button, anchor)
        local fs =
            button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOP", button, "BOTTOM", 0, -2)
        return fs
    end

    local function NewButton(name, parent, size, icon, rank, a, b, c, d, empty)
        local button = CreateFrame("Button", name, parent)
        button:SetSize(size, size)

        -- Set up the texture
        local t = button:CreateTexture(nil, "BORDER")
        t:SetSize(size * 0.8, size * 0.8)
        t:SetPoint("CENTER")
        button.texture = t

        if (empty == nil) then
            t = button:CreateTexture(nil, "ARTWORK")
            t:SetTexture("Interface\\Buttons\\CLCircle")
            t:SetSize(size * 1.2, size * 1.2)
            t:SetPoint("CENTER")
            button.normal = t
            button:SetNormalTexture(t)

            t = button:CreateTexture(nil, "ARTWORK")
            t:SetTexture("Interface\\Buttons\\CLCircleActive")
            t:SetSize(size * 1.2, size * 1.2)
            t:SetPoint("CENTER")
            button.pushed = t
            button:SetPushedTexture(t)
        end

        if rank ~= nil then
            button.rank = MakeRankFrame(button, "BOTTOMRIGHT")
        end

        if icon ~= nil then
            button.texture:SetTexture(icon)
            if a ~= nil then button.texture:SetTexCoord(a, b, c, d) end
        end

        return button
    end

    -- Utility Functions
    function GetPoints(type)
        if type == "ap" then
            local ap = math.floor(UnitLevel("player")) - #db.spells
            local tap = #spellsplus - #spellsminus  -- Account for pending unlearns
            return ap - tap, tap
        end
    
        if type == "tp" then
            local tp = UnitLevel("player") - 9
            if tp < 0 then tp = 0 end
            tp = tp - (#db.talents + #db.tpells)
            local ttp = #talentsplus + #tpellsplus - #talentsminus - #tpellsminus  -- Account for pending unlearns
            return tp - ttp, ttp
        end
        return 0, 0
    end

    -- main Frame Functions
    local function SelectTab(tab, cname, pname, bname)
        if tab ~= 0 then
            local parent = _G[pname]
            local ltab = parent:GetAttribute("tab")

            local button, lbutton = _G[bname .. tab], _G[bname .. ltab]
            local child, lchild = _G[cname .. tab], _G[cname .. ltab]
            if lchild ~= nil then FrameHide(lchild) end
            if lbutton ~= nil then lbutton:SetButtonState("NORMAL") end
            if button ~= nil then
                button:SetButtonState("PUSHED", true)
            end
            if child ~= nil then FrameShow(child) end
            parent:SetAttribute("tab", tab)
        end
    end

    local function LearnConfirm(action, state)
        if action == "Apply" and state == "true" then
            -- Always apply both spell and talent changes
            
            -- Apply spell changes
            for i = 1, #spellsplus do
                if not tContains(db.spells, spellsplus[i]) then
                    tinsert(db.spells, spellsplus[i])
                end
            end
            for i = 1, #tpellsplus do
                if not tContains(db.tpells, tpellsplus[i]) then
                    tinsert(db.tpells, tpellsplus[i])
                end
            end
            for i = 1, #spellsminus do
                if tContains(db.spells, spellsminus[i]) then
                    tRemoveKey(db.spells, spellsminus[i])
                end
            end
            for i = 1, #tpellsminus do
                if tContains(db.tpells, tpellsminus[i]) then
                    tRemoveKey(db.tpells, tpellsminus[i])
                end
            end
            wipe(spellsplus)
            wipe(spellsminus)
            wipe(tpellsplus)
            wipe(tpellsminus)
            sort(db.spells)
            sort(db.tpells)
            AIO.Handle(handlerName, "LearnSpell", db.spells, db.tpells, clientSecret)
            
            -- Apply talent changes
            for i = 1, #talentsplus do
                if not tContains(db.talents, talentsplus[i]) then
                    tinsert(db.talents, talentsplus[i])
                end
            end
            for i = 1, #talentsminus do
                if tContains(db.talents, talentsminus[i]) then
                    tRemoveKey(db.talents, talentsminus[i])
                end
            end
            wipe(talentsplus)
            wipe(talentsminus)
            sort(db.talents)
            AIO.Handle(handlerName, "LearnTalent", db.talents, clientSecret)
            
            -- Force a full UI refresh for all classes
            for k, v in pairs(class_list) do
                for j = 1, 2 do
                    local classButton = _G["CLContainer" .. j .. "SubButton" .. k]
                    if classButton and classButton.text then
                        local cap = 0
                        for i = 1, 3 do
                            cap = cap + CountSpellPoints(k, i)
                        end
                        classButton.text:SetText(tostring(cap))
    
                        local ctp = 0
                        for i = 1, 3 do
                            ctp = ctp + CountTalentPoints(k, i)
                        end
                        classButton.text2:SetText(tostring(ctp))
                    end
                end
            end

          
        elseif action == "Reset" and state == "true" then
            -- Reset all pending changes regardless of tab
            wipe(spellsplus)
            wipe(spellsminus)
            wipe(tpellsplus)
            wipe(tpellsminus)
            wipe(talentsplus)
            wipe(talentsminus)
    
            -- Force refresh the display for current class/spec
            local currentClass = current_class
            local currentSpec = current_spec
            
            -- Refresh both containers to be safe
            for tab = 1, 2 do
                local containerFrame = _G["CLContainer" .. tab .. "Sub" ..
                                           currentClass .. "Sub" .. currentSpec]
                if containerFrame then
                    containerFrame:Hide()
                    containerFrame:Show()
                end
            end
        end
    
        UpdatePointText()
        
        -- Force tab 1 to always be shown
        local tab = 1
        SelectTab(tab, "CLContainer", "CLMainFrame", "CLButton")

        if GetSpellBookItemInfo then  -- Check if function exists
            -- Force full spellbook cache refresh
            for tab = 1, 2 do  -- Both tabs (General and Profession)
                for slot = 1, MAX_SPELLS do
                    GetSpellBookItemInfo(slot, tab)  -- This refreshes the cache
                end
            end
            
            -- Refresh UI if visible
            if SpellBookFrame and SpellBookFrame:IsVisible() then
                SpellBookFrame_Update()
            end
        end
    end

    ------Fill Spells Functions
    local function TempLearnSpell(spell, talent)
        if tContains(spellsminus, spell) then
            tRemoveKey(spellsminus, spell)
        end
        if not tContains(spellsplus, spell) then
            tinsert(spellsplus, spell)
        end
        if talent == 1 then
            if tContains(tpellsminus, spell) then
                tRemoveKey(tpellsminus, spell)
            end
            if not tContains(tpellsplus, spell) then
                tinsert(tpellsplus, spell)
            end
        end
    end

    local function TempUnlearnSpell(spell, talent)
        if tContains(spellsplus, spell) then
            tRemoveKey(spellsplus, spell)
        end
        if not tContains(spellsminus, spell) then
            tinsert(spellsminus, spell)
        end
        if talent == 1 then
            if tContains(tpellsplus, spell) then
                tRemoveKey(tpellsplus, spell)
            end
            if not tContains(tpellsminus, spell) then
                tinsert(tpellsminus, spell)
            end
        end
    end

    local function TempLearnTalent(spell, talent)
        if tContains(talentsminus, spell) then
            tRemoveKey(talentsminus, spell)
        end
        if not tContains(talentsplus, spell) then
            tinsert(talentsplus, spell)
        end
    end

    local function TempUnlearnTalent(spell, talent)
        if tContains(talentsplus, spell) then
            tRemoveKey(talentsplus, spell)
        end
        if not tContains(talentsminus, spell) then
            tinsert(talentsminus, spell)
        end
    end

    local function ParseTooltip(spell)
        local f = CreateFrame("GameTooltip", "CLTmpTooltip", UIParent,
                              "GameTooltipTemplate")
        f:SetOwner(UIParent, "ANCHOR_NONE")
        local link = GetSpellLink(spell)
        if link == nil then
            link = GetSpellLink(78)
            link = gsub(link, "78", spell)
        end
        f:SetHyperlink(link)

        local t = {}

        for i = 1, select("#", f:GetRegions()) do
            local ttl = _G["CLTmpTooltipTextLeft" .. i]
            local ttr = _G["CLTmpTooltipTextRight" .. i]
            if (ttl ~= nil and ttl:GetText() ~= nil) and
                (ttr ~= nil and ttr:GetText() ~= nil) then
                tinsert(t, {ttl:GetText(), ttr:GetText()})
            elseif (ttl ~= nil and ttl:GetText() ~= nil) then
                tinsert(t, ttl:GetText())
            end
        end

        f:ClearLines()
        f:Hide()
        return t
    end

    local function ButtonTooltip(button, spell, nspell, rank, ranks, level, lcolor, ccolor, state, cost, lock, req, rreq, istalent)
        local bname = button:GetName()
        
        -- Create tooltip once and reuse it
        if not button.tooltip then
            local tooltip = CreateFrame("GameTooltip", bname .. "tooltip", UIParent, "GameTooltipTemplate")
            tooltip:SetFrameStrata("TOOLTIP")
            
            -- Create a custom background frame that sits behind the tooltip content
            local bg = CreateFrame("Frame", nil, tooltip)
            bg:SetPoint("TOPLEFT", 3, -3)
            bg:SetPoint("BOTTOMRIGHT", -3, 3)
            bg:SetFrameLevel(tooltip:GetFrameLevel() - 1)
            
            -- Add a texture to this background
            local tex = bg:CreateTexture(nil, "BACKGROUND")
            tex:SetAllPoints()
            tex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
            tex:SetVertexColor(0, 0, 0, 0.85)  -- Black with 85% opacity
            
            button.tooltip = tooltip
            button.tooltipBg = bg  -- Store reference to bg
        end
    
        button:SetScript("OnEnter", function()
            button.tooltip:Hide()
            button.tooltip:SetOwner(button, "ANCHOR_RIGHT")

            
            -- Set a consistent fixed width for ALL tooltips
            local fixedWidth = 300  -- Same width for both spell and talent tooltips
            -- Set minimum width for the tooltip to ensure consistency
            button.tooltip:SetMinimumWidth(fixedWidth)
            
            -- Common tooltip processing regardless of type
            local link
            if istalent then
                -- Talent tooltip handling
                if rank > 0 then
                    if rank < ranks then
                        link = GetSpellLink(nspell) or gsub(GetSpellLink(78), "78", nspell)
                    else
                        link = GetSpellLink(spell) or gsub(GetSpellLink(78), "78", spell)
                    end
                else
                    link = GetSpellLink(nspell) or gsub(GetSpellLink(78), "78", nspell)
                end
            else
                -- Regular spell tooltip
                link = GetSpellLink(nspell) or gsub(GetSpellLink(78), "78", nspell)
            end
            
            -- Set the hyperlink and get the tooltip content
            button.tooltip:SetHyperlink(link)
            
            -- Add talent-specific additional lines
            if istalent then
                if rank > 0 then
                    if rank < ranks then
                        button.tooltip:AddLine(" ")
                        local currentName = GetSpellInfo(spell)
                        --button.tooltip:AddLine(currentName, 0.6, 0.6, 0.6)
                        
                        local currentTooltipInfo = ParseTooltip(spell)
                        if currentTooltipInfo and #currentTooltipInfo > 0 then
                            for i = 2, min(3, #currentTooltipInfo) do
                                if type(currentTooltipInfo[i]) == "string" then
                                    button.tooltip:AddLine(currentTooltipInfo[i], 0.6, 0.6, 0.6)
                                end
                            end
                        end
                    else
                        button.tooltip:AddLine("Max Rank: " .. rank .. "/" .. ranks, 0.1, 0.95, 0.1)
                    end
                else
                    button.tooltip:AddLine("Rank: 1/" .. ranks, 1, 0.82, 0)
                end
            end
            
            -- Add additional info for all tooltips
            if cost then button.tooltip:AddLine(cost, 1, 1, 1) end
            if lock then button.tooltip:AddLine(lock, 1, 0, 0) end
            if req then button.tooltip:AddLine(req, 1, 0, 0) end
            if rreq then button.tooltip:AddLine(rreq, 1, 0.5, 0) end
        
            -- Show the tooltip first to get its natural dimensions
            button.tooltip:Show()
            
            -- Resize our custom background to match the tooltip's current size
            if button.tooltipBg then
                button.tooltipBg:SetPoint("TOPLEFT", 2, -2)
                button.tooltipBg:SetPoint("BOTTOMRIGHT", -2, 2)
            end
            
            -- Apply consistent width to all text lines
            for i = 1, button.tooltip:NumLines() do
                local line = _G[bname .. "tooltipTextLeft" .. i]
                if line then
                    line:SetWidth(fixedWidth - 30)  -- Same padding for both types
                end
            end
            
            
            
            -- Refresh the tooltip
            button.tooltip:Show()
        end)
    
        button:SetScript("OnLeave", function() button.tooltip:Hide() end)
    end
    

    -- Helper function to get class-specific offset
    local function getClassSpecOffset(classKey, specIndex, offsetIndex)
        if layoutConfig.classSpecOffsets[classKey] and
            layoutConfig.classSpecOffsets[classKey][specIndex] then
            return
                layoutConfig.classSpecOffsets[classKey][specIndex][offsetIndex] or
                    0
        end
        return 0 -- Default offset if not defined
    end

    local function FillSpells(class, spec, parent, mode)
        -- Process spell data
        local spellcheck1 = tCopy(db.spells)
        local i = 1
        while i <= #spellsplus do
            if not tContains(spellcheck1, spellsplus[i]) then
                tinsert(spellcheck1, spellsplus[i])
                i = i + 1
            else
                tremove(spellsplus, i)
                -- Don't increment i when removing items
            end
        end

        for i = 1, #spellsminus do
            if tContains(spellcheck1, spellsminus[i]) then
                tRemoveKey(spellcheck1, spellsminus[i])
            else
                tremove(spellsminus, i)
            end
        end

        -- Process talent data
        local spellcheck2 = tCopy(db.talents)
        for i = 1, #talentsplus do
            if not tContains(spellcheck2, talentsplus[i]) then
                tinsert(spellcheck2, talentsplus[i])
            else
                tremove(talentsplus, i)
            end
        end
        for i = 1, #talentsminus do
            if tContains(spellcheck2, talentsminus[i]) then
                tRemoveKey(spellcheck2, talentsminus[i])
            else
                tremove(talentsminus, i)
            end
        end

        local allspells = tCopy(spellcheck1)
        for i = 1, #spellcheck2 do
            if not tContains(allspells, spellcheck2[i]) then
                tinsert(allspells, spellcheck2[i])
            end
        end

        -- Get equality check for spells and talents
        local eqtSpell = "false"
        if tCompare(db.spells, spellcheck1) then eqtSpell = "true" end

        local eqtTalent = "false"
        if tCompare(db.talents, spellcheck2) then eqtTalent = "true" end

        -- Calculate derived values
        local contentWidth = layoutConfig.frameWidth -
                                 (layoutConfig.contentPadding * 2)
        local specHeaderWidth = contentWidth - 30 -- Width minus scrollbar

        -- Create global headers first
        local mainHeaderFrame = _G["CLMainHeaderFrame" .. class] or
                                    CreateFrame("Frame",
                                                "CLMainHeaderFrame" .. class,
                                                parent)
        mainHeaderFrame:SetSize(contentWidth, 40)
        mainHeaderFrame:SetPoint("TOPLEFT", layoutConfig.contentPadding,
                                 layoutConfig.mainHeadersY)

        -- Create Spells Header
        local spellsHeaderName = "CLMainSpellsHeader" .. class
        local spellsHeader = _G[spellsHeaderName] or
                                 mainHeaderFrame:CreateFontString(
                                     spellsHeaderName, "OVERLAY",
                                     "GameFontNormalLarge")
        spellsHeader:SetPoint("TOPLEFT", layoutConfig.mainHeaderSpacing, 0)
        spellsHeader:SetText("Spells")

        -- Create Talents Header
        local talentsHeaderName = "CLMainTalentsHeader" .. class
        local talentsHeader = _G[talentsHeaderName] or
                                  mainHeaderFrame:CreateFontString(
                                      talentsHeaderName, "OVERLAY",
                                      "GameFontNormalLarge")
        talentsHeader:SetPoint("TOPLEFT", floor(contentWidth / 2) +
                                   layoutConfig.mainHeaderSpacing - 10, 0)
        talentsHeader:SetText("Talents")

        -- Create or get the scroll frame
        local scrollFrame = _G["CLScrollFrame" .. class]
        local contentFrame = _G["CLScrollFrame" .. class .. "Content"]

        -- Create the scroll frame if it doesn't exist
        if not scrollFrame then
            -- Create scroll frame with visible scrollbar
            scrollFrame = CreateFrame("ScrollFrame", "CLScrollFrame" .. class,
                                      parent, "UIPanelScrollFrameTemplate")
            scrollFrame:SetPoint("TOPLEFT", layoutConfig.contentPadding,
                                 -layoutConfig.topOffset) -- Position below the headers
            scrollFrame:SetSize(contentWidth, layoutConfig.columnHeight)

            -- Create content frame
            contentFrame = CreateFrame("Frame",
                                       "CLScrollFrame" .. class .. "Content",
                                       scrollFrame)
            contentFrame:SetSize(contentWidth - 30, 1) -- Width minus scrollbar, height will be set dynamically
            scrollFrame:SetScrollChild(contentFrame)
        else
            -- Clear existing buttons from content frame
            for i, child in ipairs({contentFrame:GetChildren()}) do
                child:Hide()
            end
        end

        -- Setup mouse wheel scrolling
        scrollFrame:EnableMouseWheel(true)
        scrollFrame:SetScript("OnMouseWheel", function(self, delta)
            -- Calculate new scroll value
            local newValue = self:GetVerticalScroll() - (delta * 30)
            newValue = max(0, min(newValue, self:GetVerticalScrollRange()))

            -- Update scrollBar value
            local scrollBar = _G[self:GetName() .. "ScrollBar"]
            scrollBar:SetValue(newValue)
        end)

        -- Set up variables for layout
        local itemsPerRow = floor((contentWidth - 30) /
                                      layoutConfig.iconHorizontalSpacing)
        local baseTop = -10 -- Starting point within content frame
        local contentTop = baseTop

        for specIndex = 1, 3 do
            local spellSpecData = db.data.spells[class][specIndex]
            local talentSpecData = db.data.talents[class][specIndex]

            -- Create specialization header
            local specHeaderName = "CLSpecHeader" .. class .. specIndex
            local specHeader = _G[specHeaderName] or
                                   CreateFrame("Frame", specHeaderName,
                                               contentFrame)
            specHeader:SetSize(specHeaderWidth, layoutConfig.specHeaderHeight)
            specHeader:SetPoint("TOPLEFT", 10, contentTop)
            specHeader:Show()

            -- Create spec icon - positioned first
            local specIconName = "CLSpecIcon" .. class .. specIndex
            local specIcon = _G[specIconName] or
                                 NewButton(specIconName, specHeader,
                                           layoutConfig.specIconSize,
                                           "Interface\\Icons\\" ..
                                               spellSpecData[2], nil, nil, nil,
                                           nil, nil, true)
            specIcon:SetPoint("TOPLEFT", 0, 0)
            specIcon:Show()

            -- Create labels for specialization
            if not specIcon.label then
                specIcon.label = specIcon:CreateFontString(nil, "OVERLAY",
                                                           "GameFontNormalLarge")
                specIcon.label:SetPoint("LEFT", specIcon, "RIGHT",
                                        layoutConfig.specNamePadding, 0)
                specIcon.label:SetText(spellSpecData[1])
            end

            -- Move down for content
            contentTop = contentTop - layoutConfig.contentTopPadding

            -- Process Spells Section
            local spellsLeft = 10
            local spellsInRow = 0
            local startingTop = contentTop

            -- Apply any class-specific offset for spells
            local spellsOffset = getClassSpecOffset(class, specIndex, 1)
            contentTop = contentTop + spellsOffset

            -- Get spells for this specialization
            local spells = spellSpecData[4]

            -- Process each spell in this specialization
            for i = 1, #spells do
                local spellid, levelid = spells[i][1], spells[i][2]
                local prank, rank, nrank, ranks, spell, nspell, nlevel
                rank, ranks = 0, #spellid

                for j = 1, ranks do
                    if tContains(spellcheck1, spellid[j]) then
                        rank = j
                    end
                end

                if rank > 0 then
                    spell = spellid[rank]
                else
                    rank = 0
                    spell = spellid[1]
                end

                if rank + 1 <= ranks then
                    nspell, nlevel, nrank = spellid[rank + 1],
                                            levelid[rank + 1], rank + 1
                else
                    nspell, nlevel, nrank = spellid[rank], levelid[rank], rank
                end

                prank = rank - 1

                -- Create spell button
                local buttonID = "CLSpellContentClass" .. class .. "Spec" ..
                                     specIndex .. "spell" .. i
                local icon = ({GetSpellInfo(nspell)})[3]
                if nspell == 75 then
                    icon = "Interface/Icons/Ability_Whirlwind"
                end

                local button = _G[buttonID] or
                                   NewButton(buttonID, contentFrame,
                                             layoutConfig.iconSize, icon, "true")
                button:SetButtonState("NORMAL", "true")
                button:SetPoint("TOPLEFT", spellsLeft, contentTop)
                button:Show()

                if button:GetAttribute("hrank") == nil or eqtSpell == "true" then
                    button:SetAttribute("hrank", rank)
                end

                -- Store spell info
                if spell_point_list[class] == nil then
                    spell_point_list[class] = {}
                end
                if spell_point_list[class][specIndex] == nil then
                    spell_point_list[class][specIndex] = {}
                end
                spell_point_list[class][specIndex][icon] = rank

                local hrank = button:GetAttribute("hrank")

                -- Spell status calculation
                local state, saturated, color, acost, tcost, lock, req, rreq =
                    "normal", 0, GREEN_FONT_COLOR, 1, 0, nil, nil, nil
                local ap, tp = GetPoints("ap"), GetPoints("tp")
                local lcolor, ccolor = color, color
                local nacost, ntcost = acost, tcost
                local ncost

                if rank == 1 and spells[i][4] == 1 then tcost = 1 end
                if nrank == 1 and spells[i][4] == 1 then
                    ntcost = 1
                end

                if rank == ranks then state = "full" end

                if state ~= "full" then
                    if UnitLevel("player") < nlevel then
                        state = "disabled"
                        lcolor = RED_FONT_COLOR
                    end

                    if ap < nacost or tp < ntcost then
                        state = "disabled"
                        ccolor = RED_FONT_COLOR
                    end

                    if db.locks[spell] ~= nil then
                        for h = 1, #db.locks[spell] do
                            if tContains(allspells, db.locks[spell][h]) then
                                state = "disabled"
                                lock = 'Locked by "' ..
                                           ({GetSpellInfo(db.locks[spell][h])})[1] ..
                                           '" spell'
                                break
                            end
                        end
                    end

                    if db.req[nspell] ~= nil then
                        local reqs, reqr = ({GetSpellInfo(db.req[nspell])})[1],
                                           ({GetSpellInfo(db.req[nspell])})[2]
                        if not tContains(allspells, db.req[nspell]) then
                            state = "disabled"
                            req = "req spell '" .. reqs
                            if reqr ~= "" then
                                req = req .. "(" .. reqr .. ')\"'
                            else
                                req = req .. '"'
                            end
                        end
                    end
                end

                if db.rreq[spell] ~= nil then
                    local rreqs, rreqr = ({GetSpellInfo(db.rreq[spell])})[1],
                                         ({GetSpellInfo(db.rreq[spell])})[2]
                    if tContains(allspells, db.rreq[spell]) and rank ~= hrank then
                        state = "req"
                        rreq = "Required for spell '" .. rreqs
                        if rreqr ~= "" then
                            rreq = rreq .. "(" .. rreqr .. ')\"'
                        else
                            rreq = rreq .. '"'
                        end
                    end
                end

                if state == "disabled" and rank > 0 then
                    state = "temp"
                end

                if state == "disabled" then
                    saturated = 1
                    color = GRAY_FONT_COLOR
                elseif state == "full" then
                    color = NORMAL_FONT_COLOR
                elseif state == "temp" then
                    color = RAID_CLASS_COLORS["SHAMAN"]
                elseif state == "req" then
                    color = ORANGE_FONT_COLOR
                end

                button.texture:SetDesaturated(saturated)
                button.rank:SetVertexColor(color.r, color.g, color.b)
                button.rank:SetText(rank)

                ncost = "Requires 1 AP"
                if ntcost == 1 then ncost = ncost .. ", 1 TP" end

                local clickable = true

                if state == "normal" and rank > hrank then
                    if nrank <= ranks then
                        button:RegisterForClicks("LeftButtonDown",
                                                 "RightButtonDown")
                    end
                end
                if state == "normal" and rank == hrank then
                    if nrank <= ranks then
                        button:RegisterForClicks("LeftButtonDown",
                                                 "RightButtonDown")
                    end
                end
                if state == "normal" and rank == 0 then
                    button:RegisterForClicks("LeftButtonDown")
                end
                if (state == "full" or state == "temp") and rank > hrank then
                    button:RegisterForClicks("RightButtonDown")
                end
                if (state == "full" or state == "temp") and rank == hrank then
                    button:RegisterForClicks("RightButtonDown")
                end
                if state == "req" and rank > hrank and nrank <= ranks and rreq ~=
                    nil then
                    if UnitLevel("player") < nlevel then
                        button:RegisterForClicks()
                        clickable = false
                    else
                        button:RegisterForClicks("LeftButtonDown")
                    end
                end
                if state == "disabled" then
                    button:RegisterForClicks()
                    clickable = false
                end

                -- Set up spell button click handler
                button:SetScript("OnClick", function(self, key, down)
                    if not (button:IsEnabled() and clickable ~= false) then
                        return
                    end
                    local ap, tap = GetPoints("ap")
                    local tp, ttp = GetPoints("tp")
                    if key == "LeftButton" then
                        if (ap > 0 and UnitLevel("player") >= nlevel) then
                            if (ntcost == 1) then
                                if (tp > 0) then
                                    TempLearnSpell(nspell, ntcost)
                                end
                            else
                                TempLearnSpell(nspell, ntcost)
                            end
                        end
                    end

                    if key == "RightButton" then
                        TempUnlearnSpell(spell, tcost)
                    end

                    FillSpells(class, spec, parent, mode)
                end)

                ButtonTooltip(button, spell, nspell, rank, ranks, nlevel,
                lcolor, ccolor, state, ncost, lock, req, rreq, false)  -- false = not a talent

                -- Adjust spell grid position
                spellsInRow = spellsInRow + 1
                if spellsInRow >= layoutConfig.iconsPerHalfRow then -- Half the items per row for two sections
                    spellsLeft = 10
                    contentTop = contentTop - layoutConfig.iconVerticalSpacing
                    spellsInRow = 0
                else
                    spellsLeft = spellsLeft + layoutConfig.iconHorizontalSpacing
                end
            end

            -- Calculate the height of the spells section and reset position for talents
            local spellsSectionHeight = startingTop - contentTop
            if spellsInRow > 0 then
                contentTop = contentTop - layoutConfig.iconVerticalSpacing -- Complete the row
            end

            -- Reset position for talents section
            contentTop = startingTop

            -- Apply any class-specific offset for talents
            local talentsOffset = getClassSpecOffset(class, specIndex, 2)
            contentTop = contentTop + talentsOffset

            -- Process Talents Section
            local talentsLeft = floor(specHeaderWidth / 2) + 10 -- Start talents on the right half
            local talentsInRow = 0

            -- Get talents for this specialization
            local talents = talentSpecData[4]

            -- Process each talent in this specialization
            for i = 1, #talents do
                local talentid, levelid = talents[i][1], talents[i][2]
                local prank, rank, nrank, ranks, talent, ntalent, nlevel
                rank, ranks = 0, #talentid

                for j = 1, ranks do
                    if tContains(spellcheck2, talentid[j]) then
                        rank = j
                    end
                end

                if rank > 0 then
                    talent = talentid[rank]
                else
                    rank = 0
                    talent = talentid[1]
                end

                if rank + 1 <= ranks then
                    ntalent, nlevel, nrank = talentid[rank + 1],
                                             levelid[rank + 1], rank + 1
                else
                    ntalent, nlevel, nrank = talentid[rank], levelid[rank], rank
                end

                prank = rank - 1

                -- Create talent button
                local buttonID = "CLTalentContentClass" .. class .. "Spec" ..
                                     specIndex .. "talent" .. i
                local icon = ({GetSpellInfo(ntalent)})[3]
                if ntalent == 75 then
                    icon = "Interface/Icons/Ability_Whirlwind"
                end

                local button = _G[buttonID] or
                                   NewButton(buttonID, contentFrame,
                                             layoutConfig.iconSize, icon, "true")
                button:SetButtonState("NORMAL", "true")
                button:SetPoint("TOPLEFT", talentsLeft, contentTop)
                button:Show()

                if button:GetAttribute("hrank") == nil or eqtTalent == "true" then
                    button:SetAttribute("hrank", rank)
                end

                -- Store talent info
                if talent_point_list[class] == nil then
                    talent_point_list[class] = {}
                end
                if talent_point_list[class][specIndex] == nil then
                    talent_point_list[class][specIndex] = {}
                end
                talent_point_list[class][specIndex][icon] = rank

                local hrank = button:GetAttribute("hrank")

                -- Talent status calculation
                local state, saturated, color, acost, tcost, lock, req, rreq =
                    "normal", 0, GREEN_FONT_COLOR, 1, 0, nil, nil, nil
                local ap, tp = GetPoints("ap"), GetPoints("tp")
                local lcolor, ccolor = color, color
                local nacost, ntcost = acost, tcost
                local ncost

                if rank == 1 and talents[i][4] == 1 then
                    tcost = 1
                end
                if nrank == 1 and talents[i][4] == 1 then
                    ntcost = 1
                end

                if rank == ranks then state = "full" end

                if state ~= "full" then
                    if UnitLevel("player") < nlevel then
                        state = "disabled"
                        lcolor = RED_FONT_COLOR
                    end

                    if tp < nacost or ap < ntcost then
                        state = "disabled"
                        ccolor = RED_FONT_COLOR
                    end

                    if db.locks[talent] ~= nil then
                        for h = 1, #db.locks[talent] do
                            if tContains(allspells, db.locks[talent][h]) then
                                state = "disabled"
                                lock = 'Locked by "' ..
                                           ({GetSpellInfo(db.locks[talent][h])})[1] ..
                                           '" talent'
                                break
                            end
                        end
                    end

                    if db.req[ntalent] ~= nil then
                        local reqs, reqr = ({GetSpellInfo(db.req[ntalent])})[1],
                                           ({GetSpellInfo(db.req[ntalent])})[2]
                        if not tContains(allspells, db.req[ntalent]) then
                            state = "disabled"
                            req = "req talent '" .. reqs
                            if reqr ~= "" then
                                req = req .. "(" .. reqr .. ')\"'
                            else
                                req = req .. '"'
                            end
                        end
                    end
                end

                if db.rreq[talent] ~= nil then
                    local rreqs, rreqr = ({GetSpellInfo(db.rreq[talent])})[1],
                                         ({GetSpellInfo(db.rreq[talent])})[2]
                    if tContains(allspells, db.rreq[talent]) and rank ~= hrank then
                        state = "req"
                        rreq = "Required for talent '" .. rreqs
                        if rreqr ~= "" then
                            rreq = rreq .. "(" .. rreqr .. ')\"'
                        else
                            rreq = rreq .. '"'
                        end
                    end
                end

                if state == "disabled" and rank > 0 then
                    state = "temp"
                end

                if state == "disabled" then
                    saturated = 1
                    color = GRAY_FONT_COLOR
                elseif state == "full" then
                    color = NORMAL_FONT_COLOR
                elseif state == "temp" then
                    color = RAID_CLASS_COLORS["SHAMAN"]
                elseif state == "req" then
                    color = ORANGE_FONT_COLOR
                end

                button.texture:SetDesaturated(saturated)
                button.rank:SetVertexColor(color.r, color.g, color.b)
                button.rank:SetText(rank)

                ncost = "Requires 1 TP"
                if ntcost == 1 then ncost = ncost .. ", 1 AP" end

                local clickable = true

                if state == "normal" and rank > hrank then
                    if nrank <= ranks then
                        button:RegisterForClicks("LeftButtonDown",
                                                 "RightButtonDown")
                    end
                end
                if state == "normal" and rank == hrank then
                    if nrank <= ranks then
                        button:RegisterForClicks("LeftButtonDown",
                                                 "RightButtonDown")
                    end
                end
                if state == "normal" and rank == 0 then
                    button:RegisterForClicks("LeftButtonDown")
                end
                if (state == "full" or state == "temp") and rank > hrank then
                    button:RegisterForClicks("RightButtonDown")
                end
                if (state == "full" or state == "temp") and rank == hrank then
                    button:RegisterForClicks("RightButtonDown")
                end
                if state == "req" and rank > hrank and nrank <= ranks and rreq ~=
                    nil then
                    if UnitLevel("player") < nlevel then
                        button:RegisterForClicks()
                        clickable = false
                    else
                        button:RegisterForClicks("LeftButtonDown")
                    end
                end
                if state == "disabled" then
                    button:RegisterForClicks()
                    clickable = false
                end

                -- Set up talent button click handler
                button:SetScript("OnClick", function(self, key, down)
                    if not (button:IsEnabled() and clickable ~= false) then
                        return
                    end
                    local ap, tap = GetPoints("ap")
                    local tp, ttp = GetPoints("tp")
                    if key == "LeftButton" then
                        if tp > 0 and UnitLevel("player") >= nlevel then
                            TempLearnTalent(ntalent, ntcost)
                        end
                    end

                    if key == "RightButton" then
                        TempUnlearnTalent(talent, tcost)  
                        
                    end

                    FillSpells(class, spec, parent, mode)
                end)

                ButtonTooltip(button, talent, ntalent, rank, ranks, nlevel,
                lcolor, ccolor, state, ncost, lock, req, rreq, true)  -- true = is a talent

                -- Adjust talent grid position
                talentsInRow = talentsInRow + 1
                if talentsInRow >= layoutConfig.iconsPerHalfRow then -- Half the items per row for two sections
                    talentsLeft = floor(specHeaderWidth / 2) + 10
                    contentTop = contentTop - layoutConfig.iconVerticalSpacing
                    talentsInRow = 0
                else
                    talentsLeft = talentsLeft +
                                      layoutConfig.iconHorizontalSpacing
                end
            end

            -- Calculate the talent section height
            local talentsSectionHeight = startingTop - contentTop
            if talentsInRow > 0 then
                contentTop = contentTop - layoutConfig.iconVerticalSpacing -- Complete the row
            end

            local maxSectionHeight = max(spellsSectionHeight,
                                         talentsSectionHeight)

            -- Use the maximum section height for spacing
            contentTop = startingTop - maxSectionHeight

            -- Add spacing for next specialization
            contentTop = contentTop - layoutConfig.specSpacing
        end

        -- Update content frame height
        contentFrame:SetHeight(abs(contentTop) + 20)
    end

    -- Create Main Button
    local button = _G["CLButton"] or
                       NewButton("CLButton", UIParent, 48,
                                 "Interface\\Tooltips\\Book_Icon", nil, nil,
                                 nil, nil, nil, true)

    button:SetMovable(true)
    button:EnableMouse(true)
    button:SetToplevel(true)
    button:RegisterForDrag("RightButton")
    button:SetScript("OnDragStart", button.StartMoving)
    button:SetScript("OnDragStop", button.StopMovingOrSizing)
    button:SetPoint("RIGHT", -24, 0)
    local talentButton = _G["TalentMicroButton"]

    talentButton:Enable();
    talentButton:SetScript("OnClick", function() FrameToggle("CLMainFrame") end)
    button:Hide();

    AIO.SavePosition(button)

    button.tooltip = _G["CLButtontooltip"] or
                         CreateFrame("GameTooltip", "CLButtontooltip", button,
                                     "GameTooltipTemplate")
    button:SetScript("OnEnter", function()
        local ap, tp = GetPoints("ap"), GetPoints("tp")
        button.tooltip:Hide()
        button.tooltip:SetOwner(button, "ANCHOR_RIGHT")
        button.tooltip:AddLine("Distribute your Ability or Talents Points", nil,
                               nil, nil, true)
        local c = GREEN_FONT_COLOR
        if ap > 0 or tp > 0 then
            local string = "You have\n" .. ap .. " Ability Points\n" .. tp ..
                               " Talent Points"
            button.tooltip:AddLine(string, c.r, c.g, c.b, true)
        end
        button.tooltip:AddLine("Drag with right button for move", 1, 1, 1, true)
        button.tooltip:Show()
    end)
    button:SetScript("OnLeave", function() button.tooltip:Hide() end)

    button:SetScript("OnUpdate", function()
        local ap, tp = GetPoints("ap"), GetPoints("tp")
        if ap > 0 or tp > 0 then
            FrameShow(button.flash)
        else
            FrameHide(button.flash)
        end
    end)

    button:RegisterEvent("PLAYER_LEVEL_UP")
    button:SetScript("OnEvent", function()
        SelectTab(1, "CLContainer", "CLMainFrame", "CLButton")
    end)

    -- Create Main Frame
    local frame = CLMainFrame or CreateFrame("Frame", "CLMainFrame", UIParent)
    frame:Hide()
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetToplevel(true)

    frame.titleRegion = frame:CreateTitleRegion()
    frame.titleRegion:SetSize(967, 24)
    frame.titleRegion:SetPoint("TOPLEFT")
    frame.titleTexture = frame:CreateTexture("frame_titleTexture", "ARTWORK")
    frame.titleTexture:SetSize(967, 24)
    frame.titleTexture:SetPoint("TOPLEFT")

    tinsert(UISpecialFrames, "CLMainFrame")

    frame:RegisterForDrag("LeftButton")
    frame:SetToplevel(true)
    frame:SetSize(967, 670)
    frame:SetPoint("CENTER", 0, 0)
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetAttribute("tab", 0)
    frame:SetAttribute("child", "CLContainer")
    frame:SetClampedToScreen(false)

    AIO.SavePosition(frame)

    local function TabSelect(frame)
        if (frame == nil) then frame = _G["CLMainFrame"] end
        local tab = frame:GetAttribute("tab")
        if tab == 0 then tab = 1 end
        SelectTab(tab, "CLContainer", "CLMainFrame", "CLButton")
    end

    frame:SetScript("OnShow", function()
        TabSelect()
        UpdatePointText()
    end)

    frame:SetScript("OnHide", function()
        local tab = frame:GetAttribute("tab")
        if tab ~= 0 then FrameHide("Container" .. tab) end
    end)

    frame:SetScript("OnUpdate", function()
        local ap, tap = GetPoints("ap")
        local tp, ttp = GetPoints("tp")
        local string2 = ap
        if tap > 0 then string2 = string2 .. "(" .. tap .. ")" end
        string2 = string2 .. " AP         " .. tp
        if ttp > 0 then string2 = string2 .. "(" .. ttp .. ")" end
        string2 = string2 .. " TP "
    
        if _G["CLMainFramePoints"] ~= nil then
            CLMainFramePoints.text2:SetText(string2)
        end
    
        -- MODIFIED: Check for changes in both spell and talent arrays regardless of tab
        local hasChanges = (#spellsplus > 0 or #spellsminus > 0 or 
                           #tpellsplus > 0 or #tpellsminus > 0 or
                           #talentsplus > 0 or #talentsminus > 0)
    
        if hasChanges then
            FrameShow("CLResetButtonFrame")
        else
            FrameHide("CLResetButtonFrame")
        end
    end)

    -- Close button
    local button = _G["CLMainFrameClose"] or
                       CreateFrame("Button", "CLMainFrameClose",
                                   _G["CLMainFrame"])
    button:SetSize(36, 36)
    button:SetPoint("TOPRIGHT")
    button:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    button:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    button:SetHighlightTexture(
        "Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    button:SetScript("OnClick", function() FrameHide("CLMainFrame") end)

    -- AP and TP points
    local frame = _G["CLMainFramePoints"] or
                      CreateFrame("Frame", "CLMainFramePoints",
                                  _G["CLMainFrame"])
    frame:SetSize(160, 32)
    frame:SetPoint("TOPLEFT", 25, -30)
    frame.text = frame:CreateFontString("CLMainFramePointsText", "OVERLAY",
                                        "GameFontNormal")
    frame.text:SetTextColor(199 / 255, 42 / 255, 42 / 255)
    CLMainFramePoints.text:SetJustifyV("MIDDLE");
    CLMainFramePoints.text:SetJustifyH("LEFT");
    frame.text:SetPoint("CENTER")

    frame.text2 = frame:CreateFontString("CLMainFramePointsText2", "OVERLAY",
                                         "GameFontNormal")
    frame.text2:SetTextColor(204 / 255, 126 / 255, 43 / 255)
    CLMainFramePoints.text2:SetJustifyV("MIDDLE");
    CLMainFramePoints.text2:SetJustifyH("LEFT");
    frame.text2:SetPoint("CENTER")

    -- Reset Frame Setup
    local frame = _G["CLResetFrame"] or
    CreateFrame("Frame", "CLResetFrame", _G["CLMainFrame"])
frame:SetSize(160, 32)
frame:SetPoint("TOPRIGHT", 0, 0)  -- Position at top right with some padding

    local frame = _G["CLResetButtonFrame"] or
                      CreateFrame("Frame", "CLResetButtonFrame",
                                  _G["CLResetFrame"])
    frame:Hide()
    frame:SetSize(160, 32)
    frame:SetPoint("CENTER")

    local frame = _G["CLWipeButtonFrame"] or
                      CreateFrame("Frame", "CLWipeButtonFrame",
                                  _G["CLResetFrame"])
    frame:SetSize(32, 32)
    frame:SetPoint("LEFT", 20, 0)

    local button = _G["CLWipeButton"] or
                       NewButton("CLWipeButton", _G["CLWipeButtonFrame"], 36,
                                 "Interface\\Tooltips\\Reverse_White", nil)
    button:SetPoint("BOTTOMLEFT", -836, 5)
    button:SetScript("OnClick", function()
        if not (button:IsEnabled()) then return end
        StaticPopup_Show("WIPE_SPELLS")
    end)

    StaticPopupDialogs["WIPE_SPELLS"] = {
        text = "Please, confirm resetting ALL your spells and talents",
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            AIO.Handle(handlerName, "WipeAll", clientSecret)

            -- Clear local data to match server state
            wipe(db.spells)
            wipe(db.talents)
            wipe(db.tpells)
            wipe(spellsplus)
            wipe(spellsminus)
            wipe(talentsplus)
            wipe(talentsminus)
            wipe(tpellsplus)
            wipe(tpellsminus)

            -- Explicitly force update every class counter in both tabs
            for k, v in pairs(class_list) do
                for j = 1, 2 do
                    local classButton = _G["CLContainer" .. j .. "SubButton" ..
                                            k]
                    if classButton and classButton.text then
                        classButton.text:SetText("0") -- No spells after wipe
                        classButton.text2:SetText("0") -- No talents after wipe

                        -- Also update spec buttons
                        for i = 1, 3 do
                            local specButton =
                                _G["CLContainer" .. j .. "Sub" .. k ..
                                    "SubButton" .. i]
                            if specButton then
                                if specButton.text then
                                    specButton.text:SetText("0") -- Reset spec spell count
                                end
                                if specButton.text2 then
                                    specButton.text2:SetText("0") -- Reset spec talent count
                                end
                            end
                        end
                    end
                end
            end

            -- Refresh current tab
            TabSelect()
            StaticPopup_Hide("WIPE_SPELLS")
            UpdatePointText()

            -- Force a refresh of the current visible container
            local tab = _G["CLMainFrame"]:GetAttribute("tab")
            if tab ~= 0 then
                local currentContainer = _G["CLContainer" .. tab]
                if currentContainer and currentContainer:IsVisible() then
                    local subTab = currentContainer:GetAttribute("tab")
                    if subTab ~= 0 then
                        local subContainer =
                            _G["CLContainer" .. tab .. "Sub" .. subTab]
                        if subContainer and subContainer:IsVisible() then
                            local subSubTab = subContainer:GetAttribute("tab")
                            if subSubTab ~= 0 then
                                local subSubContainer =
                                    _G["CLContainer" .. tab .. "Sub" .. subTab ..
                                        "Sub" .. subSubTab]
                                if subSubContainer then
                                    subSubContainer:Hide()
                                    subSubContainer:Show()
                                end
                            end
                        end
                    end
                end
            end
        end,
        OnShow = function(self)
            rst = db.reset + 1
            if (rst > #prices) then rst = #prices end
            MoneyFrame_Update(self.moneyFrame, prices[rst]);
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        hasMoneyFrame = 1,
        preferredIndex = 3
    }

    local frame = _G["CLUnusedButtonFrame"] or
                      CreateFrame("Frame", "CLUnusedButtonFrame",
                                  _G["CLResetFrame"])
    frame:SetSize(32, 32)
    frame:SetPoint("BOTTOMLEFT", -20, 0)

    local buttons = {"Apply", "Reset"}
    for i = 1, #buttons do
        local button = _G["CLResetButton" .. i] or
                           MakeButton("CLResetButton" .. i,
                                      _G["CLResetButtonFrame"])
        button:SetText(buttons[i])
        button:SetSize(75, 32)
        
        -- Position buttons side by side from right to left
        button:SetPoint("RIGHT", -100 - (-80 * (i - 1)), -38)  
        
        button:SetScript("OnClick", function()
            if not (button:IsEnabled()) then return end
            LearnConfirm(buttons[i], "true")
        end)
    end

    -- Main Tab buttons, containers
    local buttons = {"", ""}
    for i = 1, #buttons do
        -- containers:
        local frame = _G["CLContainer" .. i] or
                          CreateFrame("Frame", "CLContainer" .. i,
                                      _G["CLMainFrame"])
        frame:SetSize(967, 670)
        frame:SetPoint("TOPLEFT")
        frame:SetAttribute("tab", 0)
        frame:SetAttribute("child", "CLContainer" .. i .. "Sub")
        frame:Hide()
        frame:SetScript("OnShow", function()
            local tab = frame:GetAttribute("tab")
            if tab == 0 then tab = 1 end
            local child = frame:GetAttribute("child")
            SelectTab(tab, child, "CLContainer" .. i, child .. "Button")
        end)
    end

    local frame = _G["CLClassesFrame"] or
                      CreateFrame("Frame", "CLClassesFrame", _G["CLMainFrame"])
    frame:SetSize(967, 670)
    frame:SetPoint("TOPLEFT")
    t = CreateTexture(frame, "BACKGROUND")
    t:SetTexCoord(0, 0.944, 0, 0.654)
    frame.background = t
    frame.background:SetTexture("Interface\\Tooltips\\CLMainFrame")
    frame.background:SetAllPoints()

    for index = 1, 2 do
        -- Class buttons for spells and talents
        local i = 1
        local arr
        local mode
        if index == 1 then
            arr = db.data.spells
            mode = "spell"
        else
            arr = db.data.talents
            mode = "talent"
        end
        for k, v in pairsSort(arr) do
            local class, cnum, inum = k, i, index
            local button = _G["CLContainer" .. index .. "SubButton" .. i] or
                               NewButton(
                                   "CLContainer" .. index .. "SubButton" .. i,
                                   _G["CLContainer" .. index], 36,
                                   "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES",
                                   nil, unpack(CLASS_ICON_TCOORDS[class]))
            button:SetPoint("TOPLEFT", 50, -54 - 60 * i)
            button.text = _G["CLContainer" .. index .. "SubButton" .. i ..
                              "Text"] or
                              button:CreateFontString(
                                  "CLContainer" .. index .. "SubButton" .. i ..
                                      "Text", "OVERLAY")
            button.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
            button.text:SetPoint("CENTER", 50, 0)
            button.text:SetText(tostring(
                                    CountSpellPoints(i, 1) +
                                        CountSpellPoints(i, 2) +
                                        CountSpellPoints(i, 3)))
            button.text:SetTextColor(186 / 255, 38 / 255, 38 / 255)
            button.texttex = button:CreateTexture(nil, "ARTWORK")
            button.texttex:SetTexture("Interface/Buttons/CLCircleSmall")
            button.texttex:SetPoint("CENTER", button.text, "CENTER")
            button.text2 = _G["CLContainer" .. index .. "SubButton" .. i ..
                               "Text2"] or
                               button:CreateFontString(
                                   "CLContainer" .. index .. "SubButton" .. i ..
                                       "Text2", "OVERLAY")
            button.text2:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
            button.text2:SetPoint("CENTER", 80, 0)
            button.text2:SetText(tostring(
                                     CountTalentPoints(i, 1) +
                                         CountTalentPoints(i, 2) +
                                         CountTalentPoints(i, 3)))
            button.text2:SetTextColor(204 / 255, 126 / 255, 43 / 255)
            button.text2tex = button:CreateTexture(nil, "ARTWORK")
            button.text2tex:SetTexture("Interface/Buttons/CLCircleSmall")
            button.text2tex:SetPoint("CENTER", button.text2, "CENTER")
            button:SetScript("OnClick", function()
                if not (button:IsEnabled()) then return end
                current_class = cnum
                SelectTab(cnum, "CLContainer" .. inum .. "Sub",
                          "CLContainer" .. inum,
                          "CLContainer" .. inum .. "SubButton")
                LastContainerNum = inum
            end)

            local frame = _G["CLContainer" .. index .. "Sub" .. i] or
                              CreateFrame("Frame",
                                          "CLContainer" .. index .. "Sub" .. i,
                                          _G["CLContainer" .. index])
            frame:SetSize(_G["CLContainer" .. index]:GetSize())
            frame:SetPoint("TOPLEFT")
            frame:SetAttribute("tab", 0)
            frame:SetAttribute("child",
                               "CLContainer" .. index .. "Sub" .. i .. "Sub")
            frame:Hide()
            frame:SetScript("OnShow", function()
                local tab = frame:GetAttribute("tab")
                if tab == 0 then tab = 1 end
                local child = frame:GetAttribute("child")
                SelectTab(tab, child, "CLContainer" .. inum .. "Sub" .. cnum,
                          child .. "Button")
            end)

            -- buttons and containers for spells
            for j = 1, #arr[class] do
                local snum = j
                local frame =
                    _G["CLContainer" .. index .. "Sub" .. i .. "Sub" .. j] or
                        CreateFrame("Frame",
                                    "CLContainer" .. index .. "Sub" .. i ..
                                        "Sub" .. j,
                                    _G["CLContainer" .. index .. "Sub" .. i])
                frame:SetSize(
                    _G["CLContainer" .. index .. "Sub" .. i]:GetWidth() + 10,
                    _G["CLContainer" .. index .. "Sub" .. i]:GetHeight() + 35)
                frame:SetPoint("TOP", 200, -145)
                FrameBackground(frame,
                                "Interface\\TalentFrame\\" .. arr[class][j][3])
                FrameLayout(frame, frame:GetWidth(), frame:GetHeight() + 45)
                frame:Hide()
                frame:SetScript("OnShow", function()
                    frame:SetScript("OnUpdate", function()
                        FillSpells(class, snum, frame, mode)
                        _G["Zin"] = spell_point_list
                        frame:SetScript("OnUpdate", nil)
                    end)
                end)
            end

            i = i + 1
        end
    end -- end of index

    -- ClassLess Bars
    local frame = CLBarsFrame or CreateFrame("Frame", "CLBarsFrame", UIParent)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetToplevel(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetToplevel(true)
    frame:SetSize(172, 79)
    frame:SetBackdrop({
        bgFile = "",
        edgeFile = "",
        tile = true,
        edgeSize = 16,
        tileSize = 32,
        insets = {left = 5, right = 5, top = 5, bottom = 5}
    })
    frame:SetPoint("CENTER", 0, 0)
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    AIO.SavePosition(frame)

    -- Create an energy bar
    local energy = 1
    local colors = {[1] = {r = 255, g = 0, b = 0}}

    local bar = CreateFrame("StatusBar", nil, _G["CLBarsFrame"])
    bar:SetPoint("TOPLEFT", 8, -8)
    bar:SetWidth(116)
    bar:SetHeight(16)
    bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    bar:GetStatusBarTexture():SetHorizTile(false)
    bar:GetStatusBarTexture():SetVertTile(false)
    bar:SetStatusBarColor(colors[energy].r, colors[energy].g, colors[energy].b)

    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    bar.bg:SetAllPoints(true)
    bar.bg:SetVertexColor(0, 0, 0)

    bar.value = bar:CreateFontString(nil, "OVERLAY")
    bar.value:SetPoint("CENTER")
    bar.value:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    bar.value:SetJustifyH("CENTER")
    bar.value:SetShadowOffset(1, -1)
    bar.value:SetTextColor(1, 1, 1)

    bar:SetScript("Onupdate", function()
        local pw = UnitPower("player", energy) or 0
        local pwm = UnitPowerMax("player", energy) or 100
        bar:SetMinMaxValues(0, pwm)
        bar:SetValue(pw)
        bar.value:SetText(pw .. "/" .. pwm)
    end)
end -- End of InitializeClasslessUI

-- Main Execution
local MyHandlers = AIO.AddHandlers(handlerName, {})

function MyHandlers.LoadVars(player, spr, tpr, tar, rem, rst, prc, scr, rsd)
    -- Init
    db.spells = spr
    db.tpells = tpr
    db.talents = tar
    db.reset = rst
    prices = prc
    if (rsd ~= true) then
        clientSecret = scr
        InitializeClasslessUI()
    end
end

-- hook original Talent Frame
function ToggleTalentFrame() FrameToggle("CLMainFrame") end
