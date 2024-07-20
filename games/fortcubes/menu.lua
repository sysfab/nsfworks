local menu = {}
menu.created = false

function menu.create(self)
    if self.created == nil then
        error("menu.create() should be called with ':'!", 2)
    end
    if self.created then
        error("menu:create() - menu currently created.", 2)
    end

    debug.log("Menu() - Creating menu...")
    self.created = true

    self.listener = LocalEvent:Listen(LocalEvent.Name.ScreenDidResize, function()
        self:update()
    end)

    -- -- ------  --  UI ELEMENTS CREATION  --  ------ -- --

    self.titleBG = ui:createFrame(Color(0, 0, 0, 50))
    self.title2 = ui:createText("FORTCUBES", Color(0, 0, 0, 127))
    self.title = ui:createText("FORTCUBES", Color(255, 255, 255, 255))

    -- -- ------  --  --------------------  --  ------ -- --

    function menu.update(self)
        if self.created == nil then
            error("menu.update() should be called with ':'!", 2)
        end

        self.titleBG.Width, self.titleBG.Height = Screen.Width/2 - 10, Screen.Height/4 - Screen.SafeArea.Top - 10
        self.titleBG.pos = Number2(5, Screen.Height - Screen.SafeArea.Top - self.titleBG.Height - 5)
        
        self.title.object.FontSize = 22 * 8.85
        self.title.pos = Number2(11, Screen.Height - Screen.SafeArea.Top - self.titleBG.Height - 32+72/2-5)
        self.title2.object.FontSize = 22 * 8.85
        self.title2.pos = Number2(11, Screen.Height - Screen.SafeArea.Top - self.titleBG.Height - 32+72/2-5)
    end

    debug.log("Menu() - Menu created.")
end

function menu.remove()
    if self.created == nil then
        error("menu.remove() should be called with ':'!", 2)
    end
    if not self.created then
        error("menu:remove() - menu currently removed.", 2)
    end

    debug.log("Menu() - Removing menu...")
    self.created = false
    self.listener:Remove()

    self.titleBG:remove()
    self.title:remove()
    self.title2:remove()

    debug.log("Menu() - Menu removed.")
end

return menu