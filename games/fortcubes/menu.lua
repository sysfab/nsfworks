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
    self.aboutUs.onRelease = function(s)
        self.setBorders(s)
    end

    -- -- ------  --  --------------------  --  ------ -- --

    function menu.update(menu)
        if menu.created == nil then
            error("menu.update() should be called with ':'!", 2)
        end

        menu.screenWidth = math.max(640, Screen.Width)/1920

        debug.log("menu() - Menu updated.")

        -- MAIN MENU

        menu.titleBG.Width, menu.titleBG.Height = Screen.Width/2 - 10+ 60, Screen.Height/4 - Screen.SafeArea.Top - 10
        menu.titleBG.pos = Number2(5, Screen.Height - Screen.SafeArea.Top - menu.titleBG.Height - 5)
        
        menu.title.object.Scale = 8.85 * menu.screenWidth
        menu.title.pos = Number2(11+30 * menu.screenWidth, Screen.Height - Screen.SafeArea.Top - menu.titleBG.Height - 32+72/2-5)
        menu.title2.object.Scale = 8.85 * menu.screenWidth
        menu.title2.pos = Number2(11+30 * menu.screenWidth, Screen.Height - Screen.SafeArea.Top - menu.titleBG.Height - 32+72/2-10)

        -- MAIN MENU -- BUTTONS
        menu.aboutUs.pos = Number2(5, 5)
        --menu.aboutUs.Width, menu.aboutUs.Height = 
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