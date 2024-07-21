local menu = {}
menu.created = false

function menu.create(self)
    if self.created == nil then
        error("menu.create() should be called with ':'!", 2)
    end
    if self.created then
        error("menu:create() - menu currently created.", 2)
    end

    debug.log("menu() - Creating menu...")
    self.created = true

    self.listener = LocalEvent:Listen(LocalEvent.Name.ScreenDidResize, function()
        self:update()
    end)

    self.theme = {
        button = {
            borders = true,
            borderColor = Color(0, 0, 0, 127),
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

    function self.setBorders(button)
        if button == nil or button.borders == nil then
            error("menu.setBorders(button) 1st argument should be a button.")
        end
        button.select = function(s)
            if s.selected then
                return
            end
            s.selected = true
            self.setBorders(s)
        end
        button.unselect = function(s)
            if s.selected then
                return
            end
            s.selected = true
            self.setBorders(s)
        end
        for k, v in pairs(button.borders) do
            v.Color = self.theme.button.borderColor
        end
    end
    
    self.screenWidth = math.max(640, Screen.Width)/1920

    -- -- ------  --  UI ELEMENTS CREATION  --  ------ -- --

    -- MAIN MENU

    self.titleBG = ui:createFrame(Color(0, 0, 0, 50))
    self.title2 = ui:createText("FORTCUBES", Color(0, 0, 0, 127))
    self.title = ui:createText("FORTCUBES", Color(255, 255, 255, 255))

    -- MAIN MENU - BUTTONS

    self.aboutUs = ui:createButton("ABOUT US", menu.theme.button)
    self.setBorders(self.aboutUs)

    self.settings = ui:createButton("SETTINGS", menu.theme.button)
    self.setBorders(self.settings)

    self.armory = ui:createButton("ARMORY", menu.theme.button)
    self.setBorders(self.armory)

    self.play = ui:createButton("PLAY", menu.theme.button)
    self.setBorders(self.play)

    -- -- ------  --  --------------------  --  ------ -- --
    function menu.update(menu)
        if menu.created == nil then
            error("menu.update() should be called with ':'!", 2)
        end
        debug.log("menu() - Menu updated.")

        menu.wh = math.min(Screen.Width, Screen.Height)
        menu.screenWidth = math.max(640, menu.wh)/1920*2
        menu.screenHeight = math.max(360, menu.wh)/1080

        if menu.screenWidth < 0.334 or menu.screenHeight < 0.445 then
            -- TODO: Add message that game cannot be played with this screen scale.
        end

        -- MAIN MENU

        menu.titleBG.Width, menu.titleBG.Height = menu.screenWidth * 1010, menu.screenHeight * 220
        menu.titleBG.pos = Number2(5, Screen.Height - Screen.SafeArea.Top - menu.titleBG.Height - 5)
        
        menu.title.object.Scale.X = menu.screenWidth * 8.85
        menu.title.object.Scale.Y = menu.screenHeight * 8.85
        menu.title.pos = Number2(11+30 * menu.screenWidth, Screen.Height - Screen.SafeArea.Top - menu.titleBG.Height - 32+72/2+10)
        menu.title2.object.Scale.X = menu.screenWidth * 8.85
        menu.title2.object.Scale.Y = menu.screenHeight * 8.85
        menu.title2.pos = Number2(11+30 * menu.screenWidth, Screen.Height - Screen.SafeArea.Top - menu.titleBG.Height - 32+72/2+5)

        -- MAIN MENU -- BUTTONS
        menu.aboutUs.pos = Number2(5, 5 + 85 * menu.screenHeight*0)
        menu.aboutUs.Width, menu.aboutUs.Height = 380 * menu.screenWidth, 80 * menu.screenHeight
        menu.aboutUs.content.Scale.X = menu.screenWidth * 3
        menu.aboutUs.content.Scale.Y = menu.screenHeight * 3
        menu.aboutUs.content.pos = Number2(menu.aboutUs.Width/2 - menu.aboutUs.content.Width/2, menu.aboutUs.Height/2 - menu.aboutUs.content.Height/2)

        menu.settings.pos = Number2(5, 5 + 85 * menu.screenHeight*1)
        menu.settings.Width, menu.settings.Height = 380 * menu.screenWidth, 80 * menu.screenHeight
        menu.settings.content.Scale.X = menu.screenWidth * 3
        menu.settings.content.Scale.Y = menu.screenHeight * 3
        menu.settings.content.pos = Number2(menu.settings.Width/2 - menu.settings.content.Width/2, menu.settings.Height/2 - menu.settings.content.Height/2)

        menu.armory.pos = Number2(5, 5 + 85 * menu.screenHeight*2)
        menu.armory.Width, menu.armory.Height = 380 * menu.screenWidth, 80 * menu.screenHeight
        menu.armory.content.Scale.X = menu.screenWidth * 3
        menu.armory.content.Scale.Y = menu.screenHeight * 3
        menu.armory.content.pos = Number2(menu.armory.Width/2 - menu.armory.content.Width/2, menu.armory.Height/2 - menu.armory.content.Height/2)

        menu.play.pos = Number2(5, 5 + 85 * menu.screenHeight*3)
        menu.play.Width, menu.play.Height = 380 * menu.screenWidth, 80 * menu.screenHeight
        menu.play.content.Scale.X = menu.screenWidth * 3
        menu.play.content.Scale.Y = menu.screenHeight * 3
        menu.play.content.pos = Number2(menu.play.Width/2 - menu.play.content.Width/2, menu.play.Height/2 - menu.play.content.Height/2)
    end


    debug.log("menu() - Menu created.")
    menu:update()
end

function menu.remove(self)
    if self.created == nil then
        error("menu.remove() should be called with ':'!", 2)
    end
    if not self.created then
        error("menu:remove() - menu currently removed.", 2)
    end

    debug.log("menu() - Removing menu...")
    self.created = false
    self.listener:Remove()

    self.titleBG:remove()
    self.titleBG = nil
    self.title:remove()
    self.title = nil
    self.title2:remove()
    self.title2 = nil

    debug.log("menu() - Menu removed.")
end

return menu