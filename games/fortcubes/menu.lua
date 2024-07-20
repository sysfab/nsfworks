local menu = {}
menu.created = false

function menu.create(self)
    if self.created == nil then
        error("menu.create() should be called with ':'!", 2)
    end
    if self.created then
        error("menu:create() - menu currently created.", 2)
    end

    debug.log("Creating menu...")
    self.created = true

    self.listener = LocalEvent.Listen(LocalEvent.Name.ScreenDidResize, function()
        menu.update()
    end)

    -- -- ------  --  UI ELEMENTS CREATION  --  ------ -- --

    menu.titleBG = ui:createFrame(Color(0, 0, 0, 50))
    menu.title = ui:createText("FORTCUBES", Color(255, 255, 255, 255))

    -- -- ------  --  --------------------  --  ------ -- --

    function menu.update(self)
        if self.created == nil then
            error("menu.update() should be called with ':'!", 2)
        end

        self.titleBG.scale = Number2()
    end
end

function menu.remove()
    if self.created == nil then
        error("menu.remove() should be called with ':'!", 2)
    end
    if not self.created then
        error("menu:remove() - menu currently removed.", 2)
    end

    debug.log("Removing menu...")
    self.created = false
    self.listener:Remove()
end

return menu