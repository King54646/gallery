MenuControl = {}
addModEventListener(MenuControl)


------------------------------------------------
-- LOAD MOD
------------------------------------------------

function MenuControl:loadMap()

    self.isActive = false
    self.showHUD = true


    ------------------------------------------------
    -- HUD POSITION / SIZE
    --
    -- Screen coords: 0 = left/bottom, 1 = right/top
    -- hudX = right edge of the menu
    -- hudY = top edge of the menu (kept below the
    --        FS22 money / clock / weather box)
    -- hudScale = 1.0 normal, lower = smaller
    ------------------------------------------------

    self.hudX = 0.985
    self.hudY = 0.875
    self.hudScale = 1.0


    ------------------------------------------------
    -- TIME SPEED SETTINGS
    ------------------------------------------------

    self.speeds = {
        20,
        50,
        120,
        1000,
        2000,
        5000,
        10000,
        60000,
        120000,
	200000,
        500000
    }

    -- Start at 120x
    self.speedIndex = 3


    ------------------------------------------------
    -- KEY STORAGE
    ------------------------------------------------

    self.keyPressed = {}


    ------------------------------------------------
    -- ORIGINAL TIME SCALE
    ------------------------------------------------

    self.oldTimeScale = nil


    ------------------------------------------------
    -- COTTON GROWTH SETTINGS
    ------------------------------------------------

    self.cottonGrowthSpeeds = {
        1,
        2,
        3
    }

    -- Start at 2x
    self.cottonGrowthIndex = 2

    self.cottonGrowthMultiplier =
        self.cottonGrowthSpeeds[
            self.cottonGrowthIndex
        ]

    -- Cotton controller starts OFF
    self.cottonGrowthEnabled = false


    ------------------------------------------------
    -- COTTON GROWTH TIMER
    ------------------------------------------------

    self.cottonGrowthTimer = 0
    self.cottonGrowthCheckInterval = 1000


    ------------------------------------------------
    -- LOAD MESSAGE
    ------------------------------------------------

    print(
        "=== Speed Menu Control LOADED ==="
    )

    print(
        "Selected Cotton Growth: "
        .. self.cottonGrowthMultiplier
        .. "x"
    )

    print(
        "Cotton Growth Controller: INACTIVE"
    )
end



------------------------------------------------
-- KEY PRESS HELPER
------------------------------------------------

function MenuControl:isPressed(key)

    if Input.isKeyPressed(key) then

        if not self.keyPressed[key] then

            self.keyPressed[key] = true
            return true
        end

    else

        self.keyPressed[key] = false
    end

    return false
end



------------------------------------------------
-- GET COTTON GROWTH MULTIPLIER
------------------------------------------------

function MenuControl:getCottonGrowthMultiplier()

    return self.cottonGrowthSpeeds[
        self.cottonGrowthIndex
    ]
end



------------------------------------------------
-- INCREASE COTTON GROWTH
------------------------------------------------

function MenuControl:increaseCottonGrowth()

    if self.cottonGrowthIndex <
        #self.cottonGrowthSpeeds then

        self.cottonGrowthIndex =
            self.cottonGrowthIndex + 1
    end


    self.cottonGrowthMultiplier =
        self:getCottonGrowthMultiplier()


    print(
        "Cotton Growth increased to "
        .. self.cottonGrowthMultiplier
        .. "x"
    )
end



------------------------------------------------
-- DECREASE COTTON GROWTH
------------------------------------------------

function MenuControl:decreaseCottonGrowth()

    if self.cottonGrowthIndex > 1 then

        self.cottonGrowthIndex =
            self.cottonGrowthIndex - 1
    end


    self.cottonGrowthMultiplier =
        self:getCottonGrowthMultiplier()


    print(
        "Cotton Growth decreased to "
        .. self.cottonGrowthMultiplier
        .. "x"
    )
end



------------------------------------------------
-- COTTON CONTROLLER ON / OFF
------------------------------------------------

function MenuControl:setCottonGrowthActive(active)

    if active then

        self.cottonGrowthEnabled = true
        self.cottonGrowthTimer = 0

        print(
            "Cotton Growth Controller ACTIVE"
        )

    else

        self.cottonGrowthEnabled = false
        self.cottonGrowthTimer = 0

        print(
            "Cotton Growth Controller INACTIVE"
        )
    end
end



------------------------------------------------
-- COTTON GROWTH CONTROLLER
------------------------------------------------

function MenuControl:updateCottonGrowth(dt)

    if not self.cottonGrowthEnabled then
        return
    end


    if g_currentMission == nil then
        return
    end


    if not g_currentMission:getIsServer() then
        return
    end


    ------------------------------------------------
    -- UPDATE TIMER
    ------------------------------------------------

    self.cottonGrowthTimer =
        self.cottonGrowthTimer + dt


    if self.cottonGrowthTimer <
        self.cottonGrowthCheckInterval then

        return
    end


    self.cottonGrowthTimer = 0


    ------------------------------------------------
    -- GET SELECTED COTTON SPEED
    ------------------------------------------------

    local multiplier =
        self:getCottonGrowthMultiplier()


    ------------------------------------------------
    -- HARD MAXIMUM = 3x
    ------------------------------------------------

    if multiplier > 3 then
        multiplier = 3
    end


    ------------------------------------------------
    -- MINIMUM = 1x
    ------------------------------------------------

    if multiplier < 1 then
        multiplier = 1
    end


    ------------------------------------------------
    -- 1x = NORMAL COTTON GROWTH
    ------------------------------------------------

    if multiplier <= 1 then
        return
    end


    ------------------------------------------------
    -- CALCULATE EXTRA GROWTH
    --
    -- 1x = 0 extra
    -- 2x = 1 extra
    -- 3x = 2 extra
    ------------------------------------------------

    local extraGrowth =
        multiplier - 1


    self:applyExtraCottonGrowth(
        extraGrowth
    )
end



------------------------------------------------
-- APPLY EXTRA PHYSICAL COTTON GROWTH
------------------------------------------------

function MenuControl:applyExtraCottonGrowth(
    extraStages
)

    if extraStages == nil then
        return
    end


    if extraStages <= 0 then
        return
    end


    ------------------------------------------------
    -- HARD MAXIMUM
    ------------------------------------------------

    if extraStages > 2 then
        extraStages = 2
    end


    if g_currentMission == nil then
        return
    end


    ------------------------------------------------
    -- FRUIT TYPE MANAGER
    ------------------------------------------------

    local fruitTypeManager =
        g_currentMission.fruitTypeManager


    if fruitTypeManager == nil then
        return
    end


    ------------------------------------------------
    -- FIND COTTON
    ------------------------------------------------

    local cotton =
        fruitTypeManager:getFruitTypeByName(
            "COTTON"
        )


    if cotton == nil then

        cotton =
            fruitTypeManager:getFruitTypeByName(
                "cotton"
            )
    end


    if cotton == nil then

        print(
            "Speed Menu Control: Cotton fruit type not found"
        )

        return
    end


    ------------------------------------------------
    -- COTTON FRUIT INDEX
    ------------------------------------------------

    local cottonIndex =
        cotton.index


    ------------------------------------------------
    -- PHYSICAL FS22 COTTON GROWTH HOOK
    ------------------------------------------------
    --
    -- extraStages:
    --
    -- 1 = 2x selected
    -- 2 = 3x selected
    --
    -- Actual FS22 density-map growth code
    -- still needs to be inserted here.
    ------------------------------------------------

    print(
        "Cotton index: "
        .. tostring(cottonIndex)
        .. " | Extra growth stages requested: "
        .. tostring(extraStages)
    )
end



------------------------------------------------
-- TIME SPEED CONTROLLER ON / OFF
------------------------------------------------

function MenuControl:setSpeedActive(active)

    if active then

        ------------------------------------------------
        -- SAVE ORIGINAL TIME SCALE
        ------------------------------------------------

        self.oldTimeScale =
            g_currentMission.missionInfo.timeScale


        ------------------------------------------------
        -- ACTIVATE TIME SPEED
        ------------------------------------------------

        self.isActive = true


        g_currentMission:setTimeScale(
            self.speeds[
                self.speedIndex
            ]
        )


        print(
            "Time Speed Controller ACTIVE"
        )

    else

        ------------------------------------------------
        -- DEACTIVATE TIME SPEED
        ------------------------------------------------

        self.isActive = false


        ------------------------------------------------
        -- RESTORE ORIGINAL TIME SCALE
        ------------------------------------------------

        g_currentMission:setTimeScale(
            self.oldTimeScale or 1
        )


        print(
            "Time Speed Controller INACTIVE"
        )
    end
end



------------------------------------------------
-- MAIN UPDATE
------------------------------------------------

function MenuControl:update(dt)

    if g_currentMission == nil then
        return
    end


    local isHost =
        g_currentMission:getIsServer()


    ------------------------------------------------
    -- UPDATE COTTON CONTROLLER
    ------------------------------------------------

    self:updateCottonGrowth(dt)


    ------------------------------------------------
    -- H = SHOW / HIDE HUD
    ------------------------------------------------

    if self:isPressed(
        Input.KEY_h
    ) then

        self.showHUD =
            not self.showHUD
    end


    ------------------------------------------------
    -- HOST CONTROLS
    ------------------------------------------------

    if self.showHUD and isHost then


        ------------------------------------------------
        -- =
        -- INCREASE TIME SPEED
        ------------------------------------------------

        if self:isPressed(
            Input.KEY_equals
        ) then

            if self.speedIndex <
                #self.speeds then

                self.speedIndex =
                    self.speedIndex + 1


                if self.isActive then

                    g_currentMission:setTimeScale(
                        self.speeds[
                            self.speedIndex
                        ]
                    )
                end
            end
        end


        ------------------------------------------------
        -- -
        -- DECREASE TIME SPEED
        ------------------------------------------------

        if self:isPressed(
            Input.KEY_minus
        ) then

            if self.speedIndex > 1 then

                self.speedIndex =
                    self.speedIndex - 1


                if self.isActive then

                    g_currentMission:setTimeScale(
                        self.speeds[
                            self.speedIndex
                        ]
                    )
                end
            end
        end


        ------------------------------------------------
        -- PAGE UP
        -- INCREASE COTTON GROWTH
        ------------------------------------------------

        if self:isPressed(
            Input.KEY_pageup
        ) then

            self:increaseCottonGrowth()
        end


        ------------------------------------------------
        -- PAGE DOWN
        -- DECREASE COTTON GROWTH
        ------------------------------------------------

        if self:isPressed(
            Input.KEY_pagedown
        ) then

            self:decreaseCottonGrowth()
        end


        ------------------------------------------------
        -- LEFT SHIFT
        -- TOGGLE COTTON CONTROLLER
        ------------------------------------------------

        if self:isPressed(
            Input.KEY_lctrl
        ) then

            self:setCottonGrowthActive(
                not self.cottonGrowthEnabled
            )
        end


        ------------------------------------------------
        -- RIGHT CTRL
        -- TOGGLE TIME SPEED
        ------------------------------------------------

        if self:isPressed(
            Input.KEY_rctrl
        ) then

            self:setSpeedActive(
                not self.isActive
            )
        end
    end
end



------------------------------------------------
-- DRAW HUD
-- Compact panel in the top right corner
------------------------------------------------

function MenuControl:draw()

    if g_currentMission == nil then
        return
    end


    if not self.showHUD then
        return
    end


    if not g_currentMission:getIsServer() then
        return
    end


    local scale = self.hudScale or 1.0
    local rightX = self.hudX or 0.985
    local topY = self.hudY or 0.875


    ------------------------------------------------
    -- COLOURS
    ------------------------------------------------

    local orange = { 1, 0.5, 0, 1 }
    local green = { 0, 1, 0, 1 }
    local red = { 1, 0, 0, 1 }


    ------------------------------------------------
    -- TEXT SIZES
    ------------------------------------------------

    local titleSize = 0.014 * scale
    local headerSize = 0.012 * scale
    local valueSize = 0.012 * scale
    local hintSize = 0.010 * scale
    local gap = 0.006 * scale


    ------------------------------------------------
    -- TIME SPEED VALUE + STATUS
    ------------------------------------------------

    local speedColor = red
    local speedStatus = "INACTIVE"

    if self.isActive then
        speedColor = green
        speedStatus = "ACTIVE"
    end


    ------------------------------------------------
    -- COTTON VALUE + STATUS
    ------------------------------------------------

    local cottonColor = red
    local cottonStatus = "INACTIVE"

    if self.cottonGrowthEnabled then
        cottonColor = green
        cottonStatus = "ACTIVE"
    end


    ------------------------------------------------
    -- MENU LINES (top to bottom)
    ------------------------------------------------

    local lines = {
        { text = "Speed Menu Control", size = titleSize, color = orange, bold = true },
        { gap = gap },

        { text = "TIME SPEED", size = headerSize, color = orange, bold = true },
        { text = self.speeds[self.speedIndex] .. "x  |  " .. speedStatus, size = valueSize, color = speedColor },
        { text = "[=] / [-]  Speed up / down", size = hintSize, color = orange },
        { text = "[Right CTRL]  Toggle time speed", size = hintSize, color = orange },
        { gap = gap },

        { text = "COTTON GROWTH", size = headerSize, color = orange, bold = true },
        { text = self:getCottonGrowthMultiplier() .. "x  |  " .. cottonStatus, size = valueSize, color = cottonColor },
        { text = "[Page Up] / [Page Down]  Growth up / down", size = hintSize, color = orange },
        { text = "[Left CTRL]  Toggle cotton growth", size = hintSize, color = orange },
        { gap = gap },

        { text = "[H]  Toggle HUD", size = hintSize, color = orange }
    }


    ------------------------------------------------
    -- MEASURE PANEL
    ------------------------------------------------

    local lineSpacing = 1.25
    local maxWidth = 0
    local totalHeight = 0

    for _, line in ipairs(lines) do

        if line.gap ~= nil then

            totalHeight = totalHeight + line.gap

        else

            setTextBold(line.bold == true)

            local width =
                getTextWidth(line.size, line.text)

            if width > maxWidth then
                maxWidth = width
            end

            totalHeight =
                totalHeight + line.size * lineSpacing
        end
    end

    setTextBold(false)


    ------------------------------------------------
    -- BACKGROUND
    -- Semi-transparent black box like FS22's HUD
    ------------------------------------------------

    local padX = 0.006 * scale
    local padY = 0.006 * scale

    drawFilledRect(
        rightX - maxWidth - padX,
        topY - totalHeight - padY,
        maxWidth + padX * 2,
        totalHeight + padY * 2,
        0,
        0,
        0,
        0.6
    )


    ------------------------------------------------
    -- TEXT
    -- Right aligned to the right edge of the screen
    ------------------------------------------------

    setTextAlignment(
        RenderText.ALIGN_RIGHT
    )

    local y = topY

    for _, line in ipairs(lines) do

        if line.gap ~= nil then

            y = y - line.gap

        else

            y = y - line.size * lineSpacing

            setTextColor(
                line.color[1],
                line.color[2],
                line.color[3],
                line.color[4]
            )

            setTextBold(line.bold == true)

            renderText(
                rightX,
                y + line.size * 0.2,
                line.size,
                line.text
            )
        end
    end


    ------------------------------------------------
    -- RESET TEXT SETTINGS
    -- So other HUD text is not affected
    ------------------------------------------------

    setTextBold(false)

    setTextColor(
        1,
        1,
        1,
        1
    )

    setTextAlignment(
        RenderText.ALIGN_LEFT
    )
end
