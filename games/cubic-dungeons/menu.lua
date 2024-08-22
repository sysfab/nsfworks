local menu = {}
menu.created = false

function menu.create(self)
    if self.created == nil then
        error("menu.create() should be called with ':'!", 2)
    end
    if self.created then
        error("menu:create() - menu currently created.", 2)
    end

    AudioListener:SetParent(Camera)
    Debug.log("menu() - Creating menu...")
    self.created = true
    self.closing = false

    self.listener = LocalEvent:Listen(LocalEvent.Name.ScreenDidResize, function()
        self:update()
    end)

    self.theme = {
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

    function self.setBorders(button)
        if button == nil or button.borders == nil then
            error("menu.setBorders(button) 1st argument should be a button.")
        end

        for k, v in pairs(button.borders) do
            v.Color = Color(0, 0, 0, 127)
        end
    end

    -- MENU INITIALION
    
    self.screenWidth = math.max(640, Screen.Width)/1920
    self.screenHeight = math.max(360, Screen.Height)/1080

    menu.mainbuttonsx = 0
    menu.backsx = 0

    if menu.object == nil then
        menu.object = Object()
    end
    Debug.log("menu() - Setting tick...")
    menu.object.Tick = errorHandler(function(self, dt)
        local delta = dt * 63
        
    end, function(err) CRASH("menu.object.Tick - "..err) end)

    Camera:SetModeFree()
    Camera.Rotation = Rotation(0, -0.2, 0)
    Camera.Position = Number3(-10, 5, 5)
    Camera.FOV = 30
    self.avatar = require("avatar")
    self.ha = require("hierarchyactions")

    self.menus = {
        "menu"
    }
    self.currentMenu = "menu"

    -- -- ------  --  UI ELEMENTS CREATION  --  ------ -- --

    -- MAIN MENU

    Debug.log("menu() - Creating elements...")

    Debug.log("menu() - Loading models...")
    menu:loadModels()

    if menu.music == nil then
        Debug.log("menu() - Starting music...")

        --menu.music = AudioSource("gun_shot_1")
        --menu.music:SetParent(Camera)
        --menu.music.Sound = audio.menu_theme
        --menu.music:Play()
        --menu.music.Loop = true
        --menu.music.Volume = 0.0001
    end

    -- MAIN MENU - BUTTONS

    Debug.log("menu() - Creating buttons...")


    self.blackPanel = ui:createFrame(Color(0, 0, 0, 0))
    self.blackPanel.alpha = 255


    -- -- ------  --  --------------------  --  ------ -- --
    Debug.log("menu() - Creating menu:update()...")
    function menu.update(self)
        if menu.created == nil then
            error("menu.update() should be called with ':'!", 2)
        end
        Debug.log("menu() - updating...")

        menu.wh = math.max(Screen.Width, Screen.Height)
        menu.screenWidth = math.min(640, menu.wh)/1920
        menu.screenHeight = math.min(360, menu.wh)/1080

        local coff = (0.5+(Screen.Width*Screen.Height)/(1920*1080)*0.5)*3
        menu.screenWidth = menu.screenWidth * coff
        menu.screenHeight = menu.screenHeight * coff

        if menu.screenWidth < 0.334 or menu.screenHeight < 0.445 then
            Debug.log("menu() - game resolution is too small!")
            if menu.resolution_error == nil then
                menu.resolution_error = ui:createFrame(Color(100, 0, 0))
                menu.resolution_error_text = ui:createText("Your resolution is too small!", Color(255, 255, 255)) 
            end
            menu.resolution_error.Width = Screen.Width
            menu.resolution_error.Height = Screen.Height

            menu.resolution_error_text.pos = Number2(Screen.Width/2-menu.resolution_error_text.Width/2, Screen.Height/2-menu.resolution_error_text.Height/2)
        else
            if menu.resolution_error ~= nil then
                menu.resolution_error:remove()
                menu.resolution_error = nil
                menu.resolution_error_text:remove()
                menu.resolution_error_text = nil
            end
        end

        -- MAIN MENU

        menu.blackPanel.Width = Screen.Width
        menu.blackPanel.Height = Screen.Height

        -- MAIN MENU -- BUTTONS
        for k, v in pairs(self.menus) do
            menu:hide(v)
        end
        menu:show(menu.currentMenu)
    end


    Debug.log("menu() - Menu created.")
end

function menu.show(self, name)
    if self.created == nil then
        error("menu.show(name) should be called with ':'!", 2)
    end
    if type(name) ~= "string" then
        error("menu:show(name) - 1st argument should be a string.", 2)
    end
    

end

function menu.hide(self, name)
    if self.created == nil then
        error("menu.hide(name) should be called with ':'!", 2)
    end
    if type(name) ~= "string" then
        error("menu:hide(name) - 1st argument should be a string.", 2)
    end


end

function menu.remove(self, callback)
    if self.created == nil then
        error("menu.remove() should be called with ':'!", 2)
    end
    if not self.created then
        error("menu:remove() - menu currently removed.", 2)
    end

    Debug.log("menu() - Removing menu...")
    self.closing = true

    Timer(0.5, false, function()
        self.created = false
        self.firstTick = nil
        self.listener:Remove()

        if self.resolution_error ~= nil then
            self.resolution_error:remove()
            self.resolution_error = nil
            self.resolution_error_text:remove()
            self.resolution_error_text = nil
        end

        menu.pointer:Remove()

        Debug.log("menu() - Menu removed.")
        Debug.log("menu() - Executing remove callback...")
        if callback ~= nil then
            callback()
        end
    end)
end

function menu.loadModels(self)

end

return menu