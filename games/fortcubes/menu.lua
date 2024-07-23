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

    self.screenWidth = math.min(self.screenWidth, self.screenHeight)

    self.object = Object()
    self.object.Tick = function()
        if self.aboutUs ~= nil then
            self.setBorders(self.aboutUs)
            self.setBorders(self.settings)
            self.setBorders(self.armory)
            self.setBorders(self.play)
            self.setBorders(self.back)
        end
        if self.currentMenu == "menu" then
            Camera.Rotation:Slerp(Camera.Rotation, Rotation(0, -0.2, 0), 0.25)
            Camera.Position:Lerp(Camera.Position, Number3(-10, 5, 5), 0.2)
        elseif self.currentMenu == "about us" then
            Camera.Rotation:Slerp(Camera.Rotation, Rotation(0,  2.85, 0), 0.25)
            Camera.Position:Lerp(Camera.Position, Number3(1, 5, -8), 0.2)
        end
        if menu.music ~= nil then
            if menu.created == true then
                menu.music.Volume = lerp(menu.music.Volume, 0.7, 0.005)
                if not menu.music.IsPlaying then
                    menu.music:Play()
                end
            else
                menu.music.Volume = lerp(menu.music.Volume, 0, 0.05)
            end
        end
    end

    Camera:SetModeFree()
    Camera.Rotation = Rotation(0, -0.2, 0)
    Camera.Position = Number3(-10, 5, 5)
    Camera.FOV = 30
    self.avatar = require("avatar")

    loader:loadFunction("games/fortcubes/assets/ambience.lua", function(f) f() end)

    self.menus = {
        "menu", "about us", "settings", "armory"
    }
    self.currentMenu = "menu"

    -- -- ------  --  UI ELEMENTS CREATION  --  ------ -- --

    -- MAIN MENU

    self.titleBG = ui:createFrame(Color(0, 0, 0, 50))
    self.title2 = ui:createText("FORTCUBES", Color(0, 0, 0, 127))
    self.title = ui:createText("FORTCUBES", Color(255, 255, 255, 255))
    self.versionBG = ui:createFrame(Color(0, 0, 0, 50))
    self.version2 = ui:createText(VERSION, Color(0, 0, 0, 127))
    self.version = ui:createText(VERSION, Color(255, 255, 200, 255))

    menu:loadModels()

    menu.man3 = Quad() menu.man3:SetParent(World)
    menu.man4 = Quad() menu.man4:SetParent(World)

    menu.man3.Position = Number3(10, -3, -40)
    menu.man4.Rotation.Y = math.pi+0.1
    menu.man3.Shadow = true
    menu.man4.Position = Number3(7, -3, -40)
    menu.man4.Rotation.Y = math.pi+0.2
    menu.man4.Shadow = true

    menu.man3.Width, menu.man3.Height = 682/1.25/70, 1023/1.25/70
    menu.man4.Width, menu.man4.Height = 682/1.25/70, 1023/1.25/70


    HTTP:Get("https://img.freepik.com/premium-photo/tall-muscular-man-stands-confidently-beach-his-face-illuminated-by-setting-sun_846204-736.jpg", function(result)
        if result.StatusCode ~= 200 then
            error("Bad response")
        end
        local texture = result.Body
        menu.man3.Image = texture
    end)
    HTTP:Get("https://c4.wallpaperflare.com/wallpaper/859/261/313/fate-series-fate-apocrypha-fate-grand-order-astolfo-fate-apocrypha-rider-of-black-fate-apocrypha-hd-wallpaper-preview.jpg", function(result)
        if result.StatusCode ~= 200 then
            error("Bad response")
        end
        local texture = result.Body
        menu.man4.Image = texture
    end)

    loader:loadData("games/fortcubes/assets/menuTheme.mp3", function(data)
        local sound = data
        menu.music = AudioSource("gun_shot_1")
        menu.music:SetParent(Camera)
        menu.music.Sound = sound
        menu.music:Play()
        menu.music.Loop = true
        menu.music.Volume = 0.0001
        debug.log("music downloaded")
    end)

    -- MAIN MENU - BUTTONS

    self.aboutUs = ui:createButton("ABOUT US", menu.theme.button)
    self.aboutUs.onRelease = function(s)
        menu.currentMenu = "about us"
        menu:update()
    end
    self.settings = ui:createButton("SETTINGS", menu.theme.button)
    self.settings.onRelease = function(s)
        menu.currentMenu = "settings"
        menu:update()
    end
    self.armory = ui:createButton("ARMORY", menu.theme.button)
    self.armory.onRelease = function(s)
        menu.currentMenu = "armory"
        menu:update()
    end
    self.play = ui:createButton("PLAY", menu.theme.button)
    self.play.onRelease = function(s)
        menu:remove()
        game:create()
    end

    self.back = ui:createButton("BACK", menu.theme.button)
    self.back.onRelease = function(s)
        menu.currentMenu = "menu"
        menu:update()
    end

    -- -- ------  --  --------------------  --  ------ -- --
    function menu.update(self)
        if menu.created == nil then
            error("menu.update() should be called with ':'!", 2)
        end

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

        menu.versionBG.Width = menu.version.Width * 2
        menu.versionBG.Height = menu.version.Height + 6
        menu.versionBG.pos = Number2(Screen.Width-Screen.SafeArea.Right-menu.versionBG.Width, 0)

        menu.version.pos = Number2(menu.versionBG.pos.X + menu.versionBG.Width/2 - menu.version.Width/2, menu.versionBG.pos.Y + 3)
        menu.version2.pos = Number2(menu.version.pos.X, menu.version.pos.Y - 2)

        -- MAIN MENU -- BUTTONS
        for k, v in pairs(self.menus) do
            menu:hide(v)
        end
        menu:show(menu.currentMenu)
    end


    debug.log("menu() - Menu created.")
    menu:update()
end

function menu.show(self, name)
    if self.created == nil then
        error("menu.show(name) should be called with ':'!", 2)
    end
    if type(name) ~= "string" then
        error("menu:show(name) - 1st argument should be a string.", 2)
    end

    if name == "menu" then
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
    elseif name == "armory" then
        menu.back.pos = Number2(5, 5 + 85 * menu.screenHeight*0)
        menu.back.Width, menu.back.Height = 380 * menu.screenWidth, 80 * menu.screenHeight
        menu.back.content.Scale.X = menu.screenWidth * 3
        menu.back.content.Scale.Y = menu.screenHeight * 3
        menu.back.content.pos = Number2(menu.back.Width/2 - menu.back.content.Width/2, menu.back.Height/2 - menu.back.content.Height/2)
    elseif name == "settings" then
        menu.back.pos = Number2(5, 5 + 85 * menu.screenHeight*0)
        menu.back.Width, menu.back.Height = 380 * menu.screenWidth, 80 * menu.screenHeight
        menu.back.content.Scale.X = menu.screenWidth * 3
        menu.back.content.Scale.Y = menu.screenHeight * 3
        menu.back.content.pos = Number2(menu.back.Width/2 - menu.back.content.Width/2, menu.back.Height/2 - menu.back.content.Height/2)
    elseif name == "about us" then
        menu.back.pos = Number2(5, 5 + 85 * menu.screenHeight*0)
        menu.back.Width, menu.back.Height = 380 * menu.screenWidth, 80 * menu.screenHeight
        menu.back.content.Scale.X = menu.screenWidth * 3
        menu.back.content.Scale.Y = menu.screenHeight * 3
        menu.back.content.pos = Number2(menu.back.Width/2 - menu.back.content.Width/2, menu.back.Height/2 - menu.back.content.Height/2)
    end
end

function menu.hide(self, name)
    if self.created == nil then
        error("menu.hide(name) should be called with ':'!", 2)
    end
    if type(name) ~= "string" then
        error("menu:hide(name) - 1st argument should be a string.", 2)
    end

    if name == "menu" then
        self.aboutUs.pos.X = -1000
        self.settings.pos.X = -1000
        self.armory.pos.X = -1000
        self.play.pos.X = -1000
    elseif name == "armory" then
        self.back.pos.X = -1000
    elseif name == "settings" then
        self.back.pos.X = -1000
    elseif name == "about us" then
        self.back.pos.X = -1000
    end
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
    self.versionBG:remove()
    self.versionBG = nil
    self.version2:remove()
    self.version2 = nil
    self.version:remove()
    self.version = nil

    if self.man1 ~= nil then
        self.man1.pistol:SetParent(nil)
        self.man1.pistol = nil
        self.man1:nanStop()
        self.man1:SetParent(nil)
        self.man1.Tick = nil
        self.man1 = nil
    end
    if self.man2 ~= nil then
        self.man2.katana:SetParent(nil)
        self.man2.katana = nil
        self.man2:nanStop()
        self.man2:SetParent(nil)
        self.man2.Tick = nil
        self.man2 = nil
    end
    self.yard:SetParent(nil)
    self.yard.Tick = nil
    self.yard = nil

    self.aboutUs:remove()
    self.aboutUs = nil
    self.settings:remove()
    self.settings = nil
    self.armory:remove()
    self.armory = nil
    self.play:remove()
    self.play = nil

    debug.log("menu() - Menu removed.")

    -- aboba
end

menu.loadModels = function(self)
    loader:loadText("games/fortcubes/assets/animations/menu/pistol_idle.json", function(data)
        nanimator.import(data, "menu_idle")

        menu.man1 = self.avatar:get(Player.Username) menu.man1:SetParent(World)
        menu.man1.Animations.Idle:Stop()
        menu.man1.Position = Number3(-14, 2.63, 35)
        menu.man1.Rotation.Y = 0.4+math.pi
        menu.man1.Shadow = true
        menu.man1.Scale = 0.3

        Object:Load("voxels.silver_pistol", function(s)
            menu.man1.pistol = Shape(s)
            menu.man1.pistol:SetParent(menu.man1:GetChild(4):GetChild(1))
            menu.man1.pistol.Scale = 0.65
            menu.man1.pistol.LocalRotation = Rotation(math.pi, math.pi/2, math.pi/2)
            menu.man1.pistol.LocalPosition = Number3(8, -1, 3)
        end)

        nanimator.add(menu.man1, "menu_idle")
        menu.man1:setLoop(true)
        menu.man1:nanPlay("menu_idle", "default")
    end)
    loader:loadText("games/fortcubes/assets/animations/menu/shotgun_idle.json", function(data)
        nanimator.import(data, "menu2_idle")

        menu.man2 = self.avatar:get("nsfworker1") menu.man2:SetParent(World)
        menu.man2.Animations.Idle:Stop()
        menu.man2.Position = Number3(-7, 2.63, 37)
        menu.man2.Rotation.Y = -0.6+math.pi
        menu.man2.Shadow = true
        menu.man2.Scale = 0.3

        Object:Load("flafilez.water_nichirin",function(s)
            menu.man2.katana = s
            menu.man2.katana:SetParent(menu.man2:GetChild(4):GetChild(1))
            menu.man2.katana.Scale = 1
            menu.man2.katana.LocalRotation = Rotation(-math.pi/2, 0 ,-0.3)
            menu.man2.katana.LocalPosition = Number3(3, 0 ,0)
        end)

        nanimator.add(menu.man2, "menu2_idle")
        menu.man2:setLoop(true)
        menu.man2:nanPlay("menu2_idle", "default")
    end)
    Object:Load("nsfworks.fortcubes_yard", function(s)
        menu.yard = Shape(s)
        menu.yard:SetParent(World)
        menu.yard.Pivot = Number3(menu.yard.Width*menu.yard.Scale.X/2, menu.yard.Height*menu.yard.Scale.Y/2, menu.yard.Depth*menu.yard.Scale.Z/2)
        menu.yard.Shadow = true
    end)
end

return menu