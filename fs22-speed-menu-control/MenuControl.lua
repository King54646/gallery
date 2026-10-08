MenuControl = {}
addModEventListener(MenuControl)


------------------------------------------------
-- LOAD MOD
------------------------------------------------

function MenuControl:loadMap()

    self.isActive = false
    self.showHUD = true


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


    local centerX = 0.5
    local baseY = 0.93


    setTextAlignment(
        RenderText.ALIGN_CENTER
    )


    ------------------------------------------------
    -- ORANGE DEFAULT
    ------------------------------------------------

    setTextColor(
        1,
        0.5,
        0,
        1
    )


    ------------------------------------------------
    -- TITLE
    -- ORANGE
    ------------------------------------------------

    setTextBold(true)

    renderText(
        centerX,
        baseY,
        0.028,
        "Speed Menu Control"
    )

    setTextBold(false)


    ------------------------------------------------
    -- TIME SPEED TITLE
    -- ORANGE
    ------------------------------------------------

    setTextColor(
        1,
        0.5,
        0,
        1
    )

    renderText(
        centerX,
        baseY - 0.040,
        0.020,
        "TIME SPEED"
    )


    ------------------------------------------------
    -- TIME SPEED VALUE + STATUS
    --
    -- ACTIVE = GREEN
    -- INACTIVE = RED
    ------------------------------------------------

    if self.isActive then

        setTextColor(
            0,
            1,
            0,
            1
        )

    else

        setTextColor(
            1,
            0,
            0,
            1
        )
    end


    ------------------------------------------------
    -- CURRENT TIME SPEED
    ------------------------------------------------

    renderText(
        centerX,
        baseY - 0.068,
        0.019,
        self.speeds[
            self.speedIndex
        ] .. "x"
    )


    ------------------------------------------------
    -- TIME SPEED STATUS
    ------------------------------------------------

    if self.isActive then

        renderText(
            centerX,
            baseY - 0.095,
            0.018,
            "Status: ACTIVE"
        )

    else

        renderText(
            centerX,
            baseY - 0.095,
            0.018,
            "Status: INACTIVE"
        )
    end


    ------------------------------------------------
    -- TIME SPEED CONTROLS
    -- ORANGE
    ------------------------------------------------

    setTextColor(
        1,
        0.5,
        0,
        1
    )


    renderText(
        centerX,
        baseY - 0.125,
        0.017,
        "[UP] [=] Increase Time Speed"
    )


    renderText(
        centerX,
        baseY - 0.152,
        0.017,
        "[DOWN] [-] Decrease Time Speed"
    )


    renderText(
        centerX,
        baseY - 0.179,
        0.017,
        "[LEFT/RIGHT] [Right CTRL] Toggle Time Speed"
    )


    ------------------------------------------------
    -- COTTON GROWTH TITLE
    -- ORANGE
    ------------------------------------------------

    setTextColor(
        1,
        0.5,
        0,
        1
    )


    renderText(
        centerX,
        baseY - 0.220,
        0.020,
        "COTTON GROWTH"
    )


    ------------------------------------------------
    -- GET COTTON MULTIPLIER
    ------------------------------------------------

    local cottonMultiplier =
        self:getCottonGrowthMultiplier()


    ------------------------------------------------
    -- COTTON VALUE + STATUS
    --
    -- ACTIVE = GREEN
    -- INACTIVE = RED
    ------------------------------------------------

    if self.cottonGrowthEnabled then

        setTextColor(
            0,
            1,
            0,
            1
        )

    else

        setTextColor(
            1,
            0,
            0,
            1
        )
    end


    ------------------------------------------------
    -- CURRENT COTTON SPEED
    ------------------------------------------------

    renderText(
        centerX,
        baseY - 0.248,
        0.019,
        cottonMultiplier .. "x"
    )


    ------------------------------------------------
    -- COTTON STATUS
    ------------------------------------------------

    if self.cottonGrowthEnabled then

        renderText(
            centerX,
            baseY - 0.275,
            0.018,
            "Status: ACTIVE"
        )

    else

        renderText(
            centerX,
            baseY - 0.275,
            0.018,
            "Status: INACTIVE"
        )
    end


    ------------------------------------------------
    -- COTTON CONTROLS
    -- ORANGE
    ------------------------------------------------

    setTextColor(
        1,
        0.5,
        0,
        1
    )


    renderText(
        centerX,
        baseY - 0.305,
        0.017,
        "[UP] [Page Up] Increase Cotton Growth"
    )


    renderText(
        centerX,
        baseY - 0.332,
        0.017,
        "[DOWN] [Page Down] Decrease Cotton Growth"
    )


    renderText(
        centerX,
        baseY - 0.359,
        0.017,
        "[LEFT/RIGHT] [Left Shift] Toggle Cotton Growth"
    )


    ------------------------------------------------
    -- HUD CONTROL
    -- ORANGE
    ------------------------------------------------

    setTextColor(
        1,
        0.5,
        0,
        1
    )


    renderText(
        centerX,
        baseY - 0.400,
        0.017,
        "[LEFT/RIGHT] [H] Toggle HUD"
    )
end