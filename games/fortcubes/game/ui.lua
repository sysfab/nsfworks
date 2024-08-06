ui = {}

ui.created = false
ui.create = function(u)
	u.theme = {
        button = {
            borders = true,
            underline = false,
            padding = true,
            shadow = false,
            sound = "button_1",
            color = Color(100, 100, 100, 127),
            colorPressed = Color(50, 50, 50, 127),
            colorSelected = Color(50, 50, 50, 127),
            colorDisabled = Color(100, 100, 100, 127/2),
            textColor = Color(255, 255, 255, 255),
            textColorDisabled = Color(255, 255, 255, 200),
        }
    }
    u.closing = false

    function u.setBorders(button)
        if button == nil or button.borders == nil then
            error("game.ui.setBorders(button) 1st argument should be a button.")
        end

        for k, v in pairs(button.borders) do
            v.Color = Color(0, 0, 0, 127)
        end
    end

    u.wh = math.max(Screen.Width, Screen.Height)
    u.screenWidth = math.min(640, u.wh)/1920
    u.screenHeight = math.min(360, u.wh)/1080

    local coff = (0.5+(Screen.Width*Screen.Height)/(1920*1080)*0.5)*3
    u.screenWidth = u.screenWidth * coff
    u.screenHeight = u.screenHeight * coff

	u.timerBG = ui:createFrame(Color(0, 0, 0, 0.5))
	u.timerBG.pos = Number2(-1000, -1000)
	u.timer = ui:createText("0:00", Color(255, 255, 255))
	u.timer.pos = Number2(-1000, -1000)

    if u.object == nil then
        u.object = Object()
    end

    u.object.Tick = function(self, dt)
		local delta = dt*63
        if u.toMenu ~= nil then
            u.setBorders(u.toMenu)
        end
        if u.blackPanel ~= nil and u.blackPanel.alpha ~= nil then
            u.blackPanel.Color.A = u.blackPanel.alpha
        end
        if u.closing then
            if u.blackPanel.alpha ~= nil then
                u.blackPanel.alpha = math.ceil(lerp(u.blackPanel.alpha, 255, 0.3))
            end
        else
            if u.blackPanel.alpha ~= nil then
                u.blackPanel.alpha = math.floor(lerp(u.blackPanel.alpha, 0, 0.3))
            end
        end
		if u.music ~= nil then
            if u.created == true then
                u.music.Volume = lerp(u.music.Volume, settings.currentSettings.musicVolume*0.01, 0.005*delta)
                if not u.music.IsPlaying then
                    u.music:Play()
                end
            else
                u.music.Volume = lerp(u.music.Volume, 0, 0.05*delta)
            end
        end
		
		if u.timer ~= nil and u.loadedTimer then
			u.timer.pos = Number2(Screen.Width/2-Screen.SafeArea.Right-u.timer.Width/2, Screen.Height-Screen.SafeArea.Top-u.timer.Height-15)
			u.timerBG.pos = Number2(u.timer.pos.X-15, u.timer.pos.Y-15)
			u.timerBG.Width = u.timer.Width + 30
			u.timerBG.Height = u.timer.Height + 30

			local minutes = (game.time_end - math.floor(game.time))//60
			local seconds = (game.time_end - math.floor(game.time))%60
			if seconds < 10 then
                seconds = "0".. seconds
			end
			u.timer.Text = minutes .. ":" .. seconds
			game.time = game.time + dt
		end
    end

	if u.music == nil then
		u.music = AudioSource("gun_shot_1")
		u.music:SetParent(Player)
		u.music.Sound = audio.game_theme
		u.music:Play()
		u.music.Loop = true
		u.music.Volume = 0.0001
    end

    u.toMenu = ui:createButton("To Menu", u.theme.button)
    u.toMenu.pos = Number2(-1000, -1000)
    u.toMenu.onRelease = function(s)
    	u.toMenu:disable()
        game:remove(function() menu:create() menu:update() end)
    end

    u.blackPanel = ui:createFrame(Color(0, 0, 0, 0))
    u.blackPanel.alpha = 255

	u.created = true
end
ui.remove = function(u, callback)
    if u.created == nil then
        error("game.ui.remove() should be called with ':'!", 2)
    end
    if not u.created then
        error("game.ui:remove() - menu currently removed.", 2)
    end

    Debug.log("game() - Removing game.ui...")
    u.closing = true

    Timer(0.5, false, function()
        u.created = false

		u.timerBG:remove()
		u.timerBG = nil
		u.timer:remove()
        u.timer = nil
		u.loadedTimer = false

        u.toMenu:remove()
        u.toMenu = nil
        
        u.blackPanel:remove()
        u.blackPanel = nil

        Debug.log("game() - game.ui removed.")
        if callback ~= nil then callback() end
    end)
end
ui.screenResize = function(u)
	if u.created == nil then
        error("menu.update() should be called with ':'!", 2)
    end

    u.wh = math.max(Screen.Width, Screen.Height)
    u.screenWidth = math.min(640, u.wh)/1920
    u.screenHeight = math.min(360, u.wh)/1080

    local coff = (0.5+(Screen.Width*Screen.Height)/(1920*1080)*0.5)*3
    u.screenWidth = u.screenWidth * coff
    u.screenHeight = u.screenHeight * coff

    u.blackPanel.Width = Screen.Width
    u.blackPanel.Height = Screen.Height

    u.toMenu.Width, u.toMenu.Height = 380 * u.screenWidth * 0.7, 80 * u.screenHeight * 0.6
    u.toMenu.pos.Y = Screen.Height - Screen.SafeArea.Top - 5 - u.toMenu.Height
    u.toMenu.pos.X = 5
    u.toMenu.content.Scale.X = u.screenWidth * 2
    u.toMenu.content.Scale.Y = u.screenHeight * 2
    u.toMenu.content.pos = Number2(u.toMenu.Width/2 - u.toMenu.content.Width/2, u.toMenu.Height/2 - u.toMenu.content.Height/2)
end

return ui