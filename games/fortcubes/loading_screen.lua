local loading = {}
loading.created = false

function loading.create(self)
    if self.created == nil then
        error("loading.create() should be called with ':'!", 2)
    end
    if self.created then
        error("loading:create() - loading currently created.", 2)
    end

    debug.log("Creating loading screen...")
    self.created = true

    self.listener = LocalEvent:Listen(LocalEvent.Name.ScreenDidResize, function()
        self:update()
    end)

    -- -- ------  --  UI ELEMENTS CREATION  --  ------ -- --

    self.BG = ui:createFrame(Color(0, 0, 0, 0))
    self.Title = ui:createText("Loading...", Color(255, 255, 255, 255))

    -- -- ------  --  --------------------  --  ------ -- --

    function self.update(self)
        if self.created == nil then
            error("loading.update() should be called with ':'!", 2)
        end

        self.BG.Width = Screen.Width
        self.BG.Height = Screen.Height

        self.Title.pos = Number2(Screen.Width/2-self.Title.Width/2, Screen.Height/2-self.Title.Height/2)
    end
    
    function self.setText(self, text)
        self.Title.Text = text
    end
end

function loading.remove()
    if self.created == nil then
        error("loading.remove() should be called with ':'!", 2)
    end
    if not self.created then
        error("loading:remove() - loading screen currently removed.", 2)
    end

    debug.log("Removing loading screen...")

    self.BG:remove()
    self.Title:remove()

    self.BG = nil
    self.Title = nil

    self.created = false
    self.listener:Remove()
end

return loading