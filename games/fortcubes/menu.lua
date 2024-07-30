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
    debug.log("menu() - Creating menu...")
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
    debug.log("menu() - Setting tick...")
    menu.object.Tick = function(self, dt) 
        errorHandler(function(self, dt)
            local delta = dt * 63
            if menu.aboutUs ~= nil then
                menu.setBorders(menu.aboutUs)
                menu.setBorders(menu.settings)
                menu.setBorders(menu.armory)
                menu.setBorders(menu.play)
                menu.setBorders(menu.back)
            end
            if menu.created then
                if menu.currentMenu == "menu" then
                    Camera.Rotation:Slerp(Camera.Rotation, Rotation(0, -0.2, 0), 0.15*delta)
                    Camera.Position:Lerp(Camera.Position, Number3(-10, 5, 5), 0.1*delta)
                    Camera.FOV = lerp(Camera.FOV, 30, 0.1*delta)
                    menu.titleBG.posy = lerp(menu.titleBG.posy, Screen.Height - Screen.SafeArea.Top - menu.titleBG.Height - 5, 0.3*delta)
                    menu.title.posy = lerp(menu.title.pos.Y, Screen.Height - Screen.SafeArea.Top - menu.title.Height - 32+72/2-15, 0.3*delta)
                    menu.title2.posy = lerp(menu.title2.pos.Y, Screen.Height - Screen.SafeArea.Top - menu.title2.Height - 32+72/2-20, 0.3*delta)
                    menu.description.posy = lerp(menu.description.pos.Y, -menu.description.Height-50, 0.3*delta)
                elseif menu.currentMenu == "about us" then
                    Camera.Rotation:Slerp(Camera.Rotation, Rotation(0,  2.85, 0), 0.15*delta)
                    Camera.Position:Lerp(Camera.Position, Number3(1, 5, -8), 0.1*delta)
                    Camera.FOV = lerp(Camera.FOV, 27, 0.1*delta)
                    menu.titleBG.posy = lerp(menu.titleBG.posy, Screen.Height, 0.3*delta)
                    menu.title.posy = lerp(menu.title.pos.Y, Screen.Height, 0.3*delta)
                    menu.title2.posy = lerp(menu.title2.pos.Y, Screen.Height, 0.3*delta)
                    menu.description.posy = lerp(menu.description.pos.Y, 10, 0.3*delta)
                elseif menu.currentMenu == "settings" then
                    Camera.Rotation:Slerp(Camera.Rotation, Rotation(0,  -2.31, 0), 0.15*delta)
                    Camera.Position:Lerp(Camera.Position, Number3(5, 7, -3), 0.1*delta)
                    Camera.FOV = lerp(Camera.FOV, 23, 0.1*delta)
                    menu.titleBG.posy = lerp(menu.titleBG.posy, Screen.Height, 0.3*delta)
                    menu.title.posy = lerp(menu.title.pos.Y, Screen.Height, 0.3*delta)
                    menu.title2.posy = lerp(menu.title2.pos.Y, Screen.Height, 0.3*delta)
                    menu.description.posy = lerp(menu.description.pos.Y, -menu.description.Height-50, 0.3*delta)
                    if menu.book.left ~= nil then
                        menu.book.left.LocalRotation:Slerp(menu.book.left.LocalRotation, Rotation(0, -1.34, 0), 0.05*delta)
                        menu.book.right.LocalRotation:Slerp(menu.book.right.LocalRotation, Rotation(0, 1.34, 0), 0.05*delta)
                    end
                elseif menu.currentMenu == "armory" then
                    Camera.Rotation:Slerp(Camera.Rotation, Rotation(0, math.pi/2-0.5, 0), 0.15*delta)
                    Camera.Position:Lerp(Camera.Position, Number3(-12.46, 6.89, -14.66), 0.1*delta)
                    Camera.FOV = lerp(Camera.FOV, 15, 0.1*delta)
                    menu.titleBG.posy = lerp(menu.titleBG.posy, Screen.Height, 0.3*delta)
                    menu.title.posy = lerp(menu.title.pos.Y, Screen.Height, 0.3*delta)
                    menu.title2.posy = lerp(menu.title2.pos.Y, Screen.Height, 0.3*delta)
                    menu.description.posy = lerp(menu.description.pos.Y, -menu.description.Height-50, 0.3*delta)
                    menu.descriptionName.posy = lerp(menu.descriptionName.pos.Y, menu.description.Height + 15, 0.3*delta)
                end
                menu.titleBG.pos.Y = menu.titleBG.posy
                menu.title.pos.Y = menu.title.posy
                menu.title2.pos.Y = menu.title2.posy
                menu.description.pos.Y = menu.description.posy
                menu.descriptionName.pos.Y = menu.description.posy + menu.description.Height + 5
                menu.descriptionBG.pos.Y = menu.description.posy - 10
                if menu.currentMenu == "menu" and not menu.closing then
                    menu.mainbuttonsx = lerp(menu.mainbuttonsx, 5, 0.3*delta)
                    menu.backsx = lerp(menu.backsx, -menu.back.Width-5, 0.3*delta)
                elseif menu.currentMenu ~= "menu" and not menu.closing then
                    menu.mainbuttonsx = lerp(menu.mainbuttonsx, -menu.back.Width-5, 0.3*delta)
                    menu.backsx = lerp(menu.backsx, 5, 0.3*delta)
                end
                if menu.currentMenu ~= "menu" and not menu.closing then
                    menu.back.pos.X = menu.backsx
                end
                if menu.closing then
                    menu.mainbuttonsx = lerp(menu.mainbuttonsx, -menu.play.Width-5, 0.3*delta)
                    menu.backsx = lerp(menu.backsx, -menu.back.Width-5, 0.3*delta)
                end
                menu.aboutUs.pos.X = menu.mainbuttonsx
                menu.settings.pos.X = menu.mainbuttonsx
                menu.play.pos.X = menu.mainbuttonsx
                menu.armory.pos.X = menu.mainbuttonsx
                if menu.currentMenu ~= "settings" and menu.book.left ~= nil then
                    menu.book.left.LocalRotation:Slerp(menu.book.left.LocalRotation, Rotation(0, 0, 0), 0.05*delta)
                    menu.book.right.LocalRotation:Slerp(menu.book.right.LocalRotation, Rotation(0, 0, 0), 0.05*delta)
                end
                for k, v in pairs(Players) do
                    v.IsHidden = true
                end
            else
                for k, v in pairs(Players) do
                    if not v.isDead then
                        v.IsHidden = false
                    end
                end
            end
            if menu.closing then
                if menu.blackPanel.alpha ~= nil then
                    menu.blackPanel.alpha = math.ceil(lerp(menu.blackPanel.alpha, 255, 0.3*delta))
                end
            else
                if menu.blackPanel.alpha ~= nil then
                    menu.blackPanel.alpha = math.floor(lerp(menu.blackPanel.alpha, 0, 0.3*delta))
                end
            end
            if menu.blackPanel ~= nil and menu.blackPanel.alpha ~= nil then
                menu.blackPanel.Color.A = menu.blackPanel.alpha
            end
            if menu.music ~= nil then
                if menu.created == true then
                    menu.music.Volume = lerp(menu.music.Volume, settings.currentSettings.musicVolume*0.01, 0.005*delta)
                    if not menu.music.IsPlaying then
                        menu.music:Play()
                    end
                else
                    menu.music.Volume = lerp(menu.music.Volume, 0, 0.05*delta)
                end
            end
            if menu.music ~= nil and menu.sysfab ~= nil and menu.nanskip ~= nil and menu.yard ~= nil and menu.workinprogress ~= nil then
                if loading_screen.created then
                    loading_screen:remove()
                end
                if not menu.firstTick then
                    menu:update()
                end
                menu.firstTick = true
                menu.play:enable()
                menu.aboutUs:enable()
                menu.settings:enable()
                menu.armory:enable()
            else
                if menu.created then
                    menu.play:disable()
                    menu.aboutUs:disable()
                    menu.settings:disable()
                    menu.armory:disable()
                end
            end, 
            function(err) CRASH("menu.object.Tick() - "..err) end)(self, dt)
        end
    end

    Camera:SetModeFree()
    Camera.Rotation = Rotation(0, -0.2, 0)
    Camera.Position = Number3(-10, 5, 5)
    Camera.FOV = 30
    self.avatar = require("avatar")
    self.ha = require("hierarchyactions")

    loader:loadFunction("games/fortcubes/assets/ambience.lua", function(f) f() end)

    self.menus = {
        "menu", "about us", "settings", "armory"
    }
    self.currentMenu = "menu"

    -- -- ------  --  UI ELEMENTS CREATION  --  ------ -- --

    -- MAIN MENU

    debug.log("menu() - Creating elements...")

    self.titleBG = ui:createFrame(Color(0, 0, 0, 50))
    self.titleBG.pos = Number2(-1000, -1000)
    menu.titleBG.posy = 0
    self.title2 = ui:createText("FORTCUBES", Color(0, 0, 0, 127))
    self.title2.pos = Number2(-1000, -1000)
    menu.title2.posy = 0
    self.title = ui:createText("FORTCUBES", Color(255, 255, 255, 255))
    self.title.pos = Number2(-1000, -1000)
    menu.title.posy = 0
    self.versionBG = ui:createFrame(Color(0, 0, 0, 50))
    self.versionBG.pos = Number2(-1000, -1000)
    self.version2 = ui:createText(VERSION.." ["..githash.."]", Color(0, 0, 0, 127))
    self.version2.pos = Number2(-1000, -1000)
    self.version = ui:createText(VERSION.." ["..githash.."]", Color(255, 255, 200, 255))
    self.version.pos = Number2(-1000, -1000)


    menu.descriptionBG = ui:createFrame(Color(0, 0, 0, 80))
    menu.descriptionBG.pos = Number2(-1000, -1000)
    menu.descriptionName = ui:createText("NSFWorks Team")
    menu.descriptionName.pos = Number2(-1000, -1000)
    menu.descriptionName.Color = Color(255, 255, 255, 255)
    menu.description = ui:createText("We create games that are" .. string.char(10) .. " not suitable for work -" .. string.char(10) .. "but suitable for playing")
    menu.description.pos = Number2(-1000, -1000)
    menu.description.Color = Color(200, 200, 200, 255)

    debug.log("menu() - Loading models...")

    menu:loadModels()

    if menu.music == nil then
        menu.music = AudioSource("gun_shot_1")
        menu.music:SetParent(Camera)
        menu.music.Sound = audio.menu_theme
        menu.music:Play()
        menu.music.Loop = true
        menu.music.Volume = 0.0001
    end

    -- MAIN MENU - BUTTONS

    debug.log("menu() - Creating buttons...")

    self.aboutUs = ui:createButton("ABOUT US", menu.theme.button)
    self.aboutUs.pos = Number2(-1000, -1000)
    self.aboutUs.onRelease = function(s)
        menu.currentMenu = "about us"
        menu:update()
    end
    self.settings = ui:createButton("SETTINGS", menu.theme.button)
    self.settings.pos = Number2(-1000, -1000)
    self.settings.onRelease = function(s)
        menu.currentMenu = "settings"
        menu.book.musicVolume.text.Text = settings.currentSettings.musicVolume
        menu.book.soundVolume.text.Text = settings.currentSettings.soundVolume
        menu:update()
    end
    self.armory = ui:createButton("ARMORY", menu.theme.button)
    self.armory.pos = Number2(-1000, -1000)
    self.armory.onRelease = function(s)
        menu.currentMenu = "armory"
        menu:update()
    end
    self.play = ui:createButton("PLAY", menu.theme.button)
    self.play.pos = Number2(-1000, -1000)
    self.play.onRelease = function(s)
        menu:remove()
    end

    self.back = ui:createButton("BACK", menu.theme.button)
    self.back.pos = Number2(-1000, -1000)
    self.back.onRelease = function(s)
        if menu.currentMenu == "settings" then
            settings:save()
        end
        menu.currentMenu = "menu"
        menu:update()
    end

    self.blackPanel = ui:createFrame(Color(0, 0, 0, 0))
    self.blackPanel.alpha = 255

    -- -- ------  --  --------------------  --  ------ -- --
    debug.log("menu() - Creating menu:update()...")
    function menu.update(self)
        if menu.created == nil then
            error("menu.update() should be called with ':'!", 2)
        end
        debug.log("menu() - updating...")

        menu.wh = math.max(Screen.Width, Screen.Height)
        menu.screenWidth = math.min(640, menu.wh)/1920
        menu.screenHeight = math.min(360, menu.wh)/1080

        local coff = (0.5+(Screen.Width*Screen.Height)/(1920*1080)*0.5)*3
        menu.screenWidth = menu.screenWidth * coff
        menu.screenHeight = menu.screenHeight * coff

        if menu.screenWidth < 0.334 or menu.screenHeight < 0.445 then
            debug.log("menu() - game resolution is too small!")
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

        menu.titleBG.Width, menu.titleBG.Height = menu.screenWidth * 1010, menu.screenHeight * 220
        if Screen.Height < 480 then
            menu.titleBG.Width, menu.titleBG.Height = menu.titleBG.Width/1.85, menu.titleBG.Height/1.85
        end
        --menu.titleBG.pos = Number2(5, Screen.Height - Screen.SafeArea.Top - menu.titleBG.Height - 5)
        menu.titleBG.pos.X = 5
        
        menu.title.object.Scale.X = menu.screenWidth * 8.85
        menu.title.object.Scale.Y = menu.screenHeight * 8.85
        --menu.title.pos = Number2(11+30 * menu.screenWidth, Screen.Height - Screen.SafeArea.Top - menu.titleBG.Height - 32+72/2+10)
        menu.title.pos.X = 11+30 * menu.screenWidth
        menu.title2.object.Scale.X = menu.screenWidth * 8.85
        menu.title2.object.Scale.Y = menu.screenHeight * 8.85
        --menu.title2.pos = Number2(11+30 * menu.screenWidth, Screen.Height - Screen.SafeArea.Top - menu.titleBG.Height - 32+72/2+5)
        menu.title2.pos.X = 11+30 * menu.screenWidth

        menu.versionBG.Width = menu.version.Width + 10
        menu.versionBG.Height = menu.version.Height + 6
        menu.versionBG.pos = Number2(Screen.Width-Screen.SafeArea.Right-menu.versionBG.Width, 0)

        menu.version.pos = Number2(menu.versionBG.pos.X + menu.versionBG.Width/2 - menu.version.Width/2, menu.versionBG.pos.Y + 3)
        menu.version2.pos = Number2(menu.version.pos.X, menu.version.pos.Y - 2)

        menu.blackPanel.Width = Screen.Width
        menu.blackPanel.Height = Screen.Height

        local deskScale = 1
        if menu.screenWidth <= menu.screenHeight then
            deskScale = menu.screenWidth*2
        else
            deskScale = menu.screenHeight*2
        end
        menu.description.object.Scale = deskScale
        menu.descriptionName.object.Scale = deskScale
        menu.description.pos.X = Screen.Width/2 - menu.description.Width/2
        menu.descriptionName.pos.X = Screen.Width/2 - menu.descriptionName.Width/2
        menu.descriptionBG.Width = menu.description.Width + 20
        menu.descriptionBG.Height = menu.description.Height + 20 + menu.descriptionName.Height
        menu.descriptionBG.pos.X = Screen.Width/2 - menu.descriptionBG.Width/2

        -- MAIN MENU -- BUTTONS
        for k, v in pairs(self.menus) do
            menu:hide(v)
        end
        menu:show(menu.currentMenu)
    end


    debug.log("menu() - Menu created.")
end

function menu.show(self, name)
    if self.created == nil then
        error("menu.show(name) should be called with ':'!", 2)
    end
    if type(name) ~= "string" then
        error("menu:show(name) - 1st argument should be a string.", 2)
    end
    menu.play.Width, menu.play.Height = 380 * menu.screenWidth, 80 * menu.screenHeight
    menu.play.content.Scale.X = menu.screenWidth * 3 menu.play.content.Scale.Y = menu.screenHeight * 3
    menu.aboutUs.Width, menu.aboutUs.Height = 380 * menu.screenWidth, 80 * menu.screenHeight
    menu.aboutUs.content.Scale.X = menu.screenWidth * 3 menu.aboutUs.content.Scale.Y = menu.screenHeight * 3
    menu.settings.Width, menu.settings.Height = 380 * menu.screenWidth, 80 * menu.screenHeight
    menu.settings.content.Scale.X = menu.screenWidth * 3 menu.settings.content.Scale.Y = menu.screenHeight * 3
    menu.armory.Width, menu.armory.Height = 380 * menu.screenWidth, 80 * menu.screenHeight
    menu.armory.content.Scale.X = menu.screenWidth * 3 menu.armory.content.Scale.Y = menu.screenHeight * 3
    menu.back.Width, menu.back.Height = 380 * menu.screenWidth, 80 * menu.screenHeight
    menu.back.content.Scale.X = menu.screenWidth * 3 menu.back.content.Scale.Y = menu.screenHeight * 3

    if name == "menu" then
        menu.aboutUs.pos.Y = 5 + 85 * menu.screenHeight*0
        menu.aboutUs.content.pos = Number2(menu.aboutUs.Width/2 - menu.aboutUs.content.Width/2, menu.aboutUs.Height/2 - menu.aboutUs.content.Height/2)

        menu.settings.pos.Y = 5 + 85 * menu.screenHeight*1
        menu.settings.content.pos = Number2(menu.settings.Width/2 - menu.settings.content.Width/2, menu.settings.Height/2 - menu.settings.content.Height/2)

        menu.armory.pos.Y = 5 + 85 * menu.screenHeight*2
        menu.armory.content.pos = Number2(menu.armory.Width/2 - menu.armory.content.Width/2, menu.armory.Height/2 - menu.armory.content.Height/2)

        menu.play.pos.Y = 5 + 85 * menu.screenHeight*3
        menu.play.content.pos = Number2(menu.play.Width/2 - menu.play.content.Width/2, menu.play.Height/2 - menu.play.content.Height/2)

        menu.aboutUs:enable()
        menu.settings:enable()
        menu.play:enable()
        menu.armory:enable()
    elseif name == "armory" then
        menu.back.pos.Y = 5 + 85 * menu.screenHeight*0
        menu.back.content.pos = Number2(menu.back.Width/2 - menu.back.content.Width/2, menu.back.Height/2 - menu.back.content.Height/2)

        menu.aboutUs:disable()
        menu.settings:disable()
        menu.play:disable()
        menu.armory:disable()
    elseif name == "settings" then
        menu.back.pos.Y = 5 + 85 * menu.screenHeight*0
        menu.back.content.pos = Number2(menu.back.Width/2 - menu.back.content.Width/2, menu.back.Height/2 - menu.back.content.Height/2)

        menu.aboutUs:disable()
        menu.settings:disable()
        menu.play:disable()
        menu.armory:disable()
    elseif name == "about us" then
        menu.back.pos.Y = 5 + 85 * menu.screenHeight*0
        menu.back.content.pos = Number2(menu.back.Width/2 - menu.back.content.Width/2, menu.back.Height/2 - menu.back.content.Height/2)

        menu.aboutUs:disable()
        menu.settings:disable()
        menu.play:disable()
        menu.armory:disable()
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
    self.closing = true

    Timer(0.5, false, function()
        self.created = false
        self.firstTick = nil
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
        self.description:remove()
        self.description = nil
        self.descriptionName:remove()
        self.descriptionName = nil
        self.descriptionBG:remove()
        self.descriptionBG = nil
        self.blackPanel:remove()
        self.blackPanel = nil

        if self.resolution_error ~= nil then
            self.resolution_error:remove()
            self.resolution_error = nil
            self.resolution_error_text:remove()
            self.resolution_error_text = nil
        end

        if menu.man1 ~= nil then
            menu.man1.pistol:SetParent(nil)
            menu.man1.pistol = nil
            menu.man1:nanStop()
            menu.man1.nanplayer:remove()
            menu.man1:SetParent(nil)
            menu.man1.Tick = nil
            menu.man1 = nil
        end
        if menu.man2 ~= nil then
            menu.man2.katana:SetParent(nil)
            menu.man2.katana = nil
            menu.man2:nanStop()
            menu.man2.nanplayer:remove()
            menu.man2:SetParent(nil)
            menu.man2.Tick = nil
            menu.man2 = nil
        end
        if menu.sysfab ~= nil then
            
            menu.sysfab.nameText.shadow:SetParent(nil)
            menu.sysfab.nameText.shadow = nil
            menu.sysfab.nameText:SetParent(nil)
            menu.sysfab.nameText.Tick = nil
            menu.sysfab.nameText = nil

            menu.sysfab:nanStop()
            menu.sysfab.nanplayer:remove()
            menu.sysfab.luablock:SetParent(nil)
            menu.sysfab.luablock = nil
            menu.sysfab:SetParent(nil)
            menu.sysfab.Tick = nil
            menu.sysfab = nil
        end
        if menu.nanskip ~= nil then
            
            menu.nanskip.nameText.shadow:SetParent(nil)
            menu.nanskip.nameText.shadow = nil
            menu.nanskip.nameText:SetParent(nil)
            menu.nanskip.nameText.Tick = nil
            menu.nanskip.nameText = nil

            menu.nanskip:nanStop()
            menu.nanskip.nanplayer:remove()
            menu.nanskip.toolgun:SetParent(nil)
            menu.nanskip.toolgun = nil
            menu.nanskip:SetParent(nil)
            menu.nanskip.Tick = nil
            menu.nanskip = nil
        end
        self.yard:SetParent(nil)
        self.yard.Tick = nil
        self.yard = nil
        self.book.sound:SetParent(nil)
        self.book.sound = nil
        self.book:SetParent(nil)
        self.book.Tick = nil
        self.book = nil

        self.aboutUs:remove()
        self.aboutUs = nil
        self.settings:remove()
        self.settings = nil
        self.armory:remove()
        self.armory = nil
        self.play:remove()
        self.play = nil
        self.back:remove()
        self.back = nil

        self.workinprogress:SetParent(nil)
        self.workinprogress = nil

        menu.pointer:Remove()

        for k, v in pairs(menu.bushes) do
            v:SetParent(nil)
            v = nil
        end
        for k, v in pairs(menu.trees) do
            v:SetParent(nil)
            v = nil
        end

        debug.log("menu() - Menu removed.")
        game:create()

    end)
end

menu.loadModels = function(self)

    ---- MAN1 ANIMATION ----

    nanimator.import(animations.pistol_idle, "menu_idle")

    menu.man1 = self.avatar:get(Player.Username) menu.man1:SetParent(World)
    menu.man1.Animations.Idle:Stop()
    menu.man1.Position = Number3(-14, 2.63, 35)
    menu.man1.Rotation.Y = 0.4+math.pi
    menu.man1.Shadow = true
    menu.man1.Scale = 0.3

    Object:Load("voxels.silver_pistol", function(s)
        menu.man1.pistol = Shape(s)
        menu.man1.pistol:SetParent(menu.man1.RightHand)
        menu.man1.pistol.Scale = 0.65
        menu.man1.pistol.LocalRotation = Rotation(math.pi, math.pi/2, math.pi/2)
        menu.man1.pistol.LocalPosition = Number3(8, -1, 3)
    end)

    self.ha:applyToDescendants(menu.man1, {includeRoot = true}, function(s)
        if type(s) == "Shape" or type(s) == "MutableShape" then
            s.Shadow = true
        end
    end)

    nanimator.add(menu.man1, "menu_idle")
    menu.man1:setLoop(true)
    menu.man1:nanPlay("menu_idle", "default")

    ---- MAN2 ANIMATION ----

    nanimator.import(animations.katana_idle, "menu2_idle")

    menu.man2 = self.avatar:get("nsfworker1") menu.man2:SetParent(World)
    menu.man2.Animations.Idle:Stop()
    menu.man2.Position = Number3(-7, 2.63, 37)
    menu.man2.Rotation.Y = -0.6+math.pi
    menu.man2.Shadow = true
    menu.man2.Scale = 0.3

    Object:Load("flafilez.water_nichirin",function(s)
        menu.man2.katana = s
        menu.man2.katana:SetParent(menu.man2.RightHand)
        menu.man2.katana.Scale = 1
        menu.man2.katana.LocalRotation = Rotation(-math.pi/2, 0 ,-0.3)
        menu.man2.katana.LocalPosition = Number3(3, 0 ,0)
    end)

    self.ha:applyToDescendants(menu.man2, {includeRoot = true}, function(s)
        if type(s) == "Shape" or type(s) == "MutableShape" then
            s.Shadow = true
        end
    end)

    nanimator.add(menu.man2, "menu2_idle")
    menu.man2:setLoop(true)
    menu.man2:nanPlay("menu2_idle", "default")

    ---- SYSFAB ANIMATION ----

    nanimator.import(animations.sysfab, "sysfab")

    menu.sysfab = menu.avatar:get("fab3kleuuu") menu.sysfab:SetParent(World)
    menu.sysfab.Animations.Idle:Stop()
    menu.sysfab.Position = Number3(5, 3.6, -40)
    menu.sysfab.Rotation.Y = 0.4
    menu.sysfab.Shadow = true
    menu.sysfab.Scale = 0.3

    menu.sysfab.luablock = Shape(shapes.lua_block, {includeChildren = true})
    menu.sysfab.luablock:SetParent(World)
    menu.sysfab.luablock.Scale = Number3(0.3, 0.3, 0.3)
    menu.sysfab.luablock.Position = Number3(5, 0.3, -40)
    menu.sysfab.luablock.Rotation = Rotation(0, 0.3, 0)

    menu.sysfab.nameText = Text()
    menu.sysfab.nameText.Text = "sysfab"
    menu.sysfab.nameText:SetParent(menu.sysfab)
    menu.sysfab.nameText.Color = Color(255, 255, 255, 255)
    menu.sysfab.nameText.Scale = 2
    menu.sysfab.nameText.BackgroundColor = Color(255, 255, 255, 0)
    menu.sysfab.nameText.Tick = function(self, dt)
        menu.sysfab.nameText.Position = menu.sysfab.Position + Number3(0, 6.5, 0)
        self.Backward = Camera.Backward
    end
    menu.sysfab.nameText.shadow = Text()
    menu.sysfab.nameText.shadow.Text = "sysfab"
    menu.sysfab.nameText.shadow:SetParent(menu.sysfab.nameText)
    menu.sysfab.nameText.shadow.Color = Color(0, 0, 0, 255)
    menu.sysfab.nameText.shadow.Scale = 1
    menu.sysfab.nameText.shadow.BackgroundColor = Color(255, 255, 255, 0)
    menu.sysfab.nameText.shadow.LocalPosition = Number3(0.05, -0.1, 0.01)

    self.ha:applyToDescendants(menu.sysfab, {includeRoot = true}, function(s)
        if type(s) == "Shape" or type(s) == "MutableShape" then
            s.Shadow = true
        end
    end)

    nanimator.add(menu.sysfab, "sysfab")
    menu.sysfab:setLoop(true)
    menu.sysfab:nanPlay("sysfab", "default")

    ---- NANSKIP ANIMATION ----

    nanimator.import(animations.nanskip, "nanskip")

    menu.nanskip = menu.avatar:get("nanskip") menu.nanskip:SetParent(World)
    menu.nanskip.Animations.Idle:Stop()
    menu.nanskip.Position = Number3(13, 2.63, -37)
    menu.nanskip.Rotation.Y = -0.4
    menu.nanskip.Shadow = true
    menu.nanskip.Scale = 0.3

    menu.nanskip.toolgun = Shape(shapes.toolgun, {includeChildren = true})
    menu.nanskip.toolgun:SetParent(menu.nanskip.RightHand)
    menu.nanskip.toolgun.Scale = 1
    menu.nanskip.toolgun.LocalRotation = Rotation(0, math.pi/2, math.pi/2)
    menu.nanskip.toolgun.LocalPosition = Number3(9.3, 0.1, 0.1)
    
    menu.nanskip.nameText = Text()
    menu.nanskip.nameText.Text = "nanskip"
    menu.nanskip.nameText:SetParent(menu.nanskip)
    menu.nanskip.nameText.Color = Color(255, 255, 255, 255)
    menu.nanskip.nameText.Scale = 2
    menu.nanskip.nameText.BackgroundColor = Color(255, 255, 255, 0)
    menu.nanskip.nameText.Tick = function(self, dt)
        menu.nanskip.nameText.Position = menu.nanskip.Position + Number3(0, 6.5, 0)
        self.Backward = Camera.Backward
    end
    menu.nanskip.nameText.shadow = Text()
    menu.nanskip.nameText.shadow.Text = "nanskip"
    menu.nanskip.nameText.shadow:SetParent(menu.nanskip.nameText)
    menu.nanskip.nameText.shadow.Color = Color(0, 0, 0, 255)
    menu.nanskip.nameText.shadow.Scale = 1
    menu.nanskip.nameText.shadow.BackgroundColor = Color(255, 255, 255, 0)
    menu.nanskip.nameText.shadow.LocalPosition = Number3(0.05, -0.1, 0.01)

    self.ha:applyToDescendants(menu.nanskip, {includeRoot = true}, function(s)
        if type(s) == "Shape" or type(s) == "MutableShape" then
            s.Shadow = true
        end
    end)

    nanimator.add(menu.nanskip, "nanskip")
    menu.nanskip:setLoop(true)
    menu.nanskip:nanPlay("nanskip", "default")

    ---- END OF ANIMATIONS ----

    menu.yard = Shape(shapes.yard, {includeChildren = true})
    menu.yard:SetParent(World)
    menu.yard.Pivot = Number3(menu.yard.Width*menu.yard.Scale.X/2, menu.yard.Height*menu.yard.Scale.Y/2, menu.yard.Depth*menu.yard.Scale.Z/2)
    menu.yard.Shadow = true

    menu.book = Shape(shapes.book, {includeChildren = true})
    menu.book:SetParent(World)
    menu.book.Scale = 0.75
    menu.book.Position = Number3(-30, 7, -35)
    menu.book.Rotation = Rotation(0, 0.8, 0)
    menu.book.Shadow = true
    menu.book.left = menu.book:GetChild(1)
    menu.book.left.Shadow = true
    menu.book.right = menu.book:GetChild(2)
    menu.book.right.Shadow = true

    menu.book.sound = AudioSource("button_1")
    menu.book.sound.Volume = settings.currentSettings.soundVolume*0.01
    menu.book.sound:SetParent(Camera)

    menu.pointer = LocalEvent:Listen(LocalEvent.Name.PointerClick, function(pe)
        local impact = pe:CastRay(Map.CollisionGroup)
        if impact then
            if impact.Object.name == "musicRight" then
                if settings.currentSettings.musicVolume < 100 then
                    settings.currentSettings.musicVolume = settings.currentSettings.musicVolume + 5
                    menu.book.musicVolume.text.Text = settings.currentSettings.musicVolume
                    menu.music.Volume = settings.currentSettings.musicVolume*0.01
                    menu.book.sound:Play()
                end
            elseif impact.Object.name == "musicLeft" then
                if settings.currentSettings.musicVolume > 0 then
                    settings.currentSettings.musicVolume = settings.currentSettings.musicVolume - 5
                    menu.book.musicVolume.text.Text = settings.currentSettings.musicVolume
                    menu.music.Volume = settings.currentSettings.musicVolume*0.01
                    menu.book.sound:Play()
                end
            elseif impact.Object.name == "soundRight" then
                if settings.currentSettings.soundVolume < 100 then
                    settings.currentSettings.soundVolume = settings.currentSettings.soundVolume + 5
                    menu.book.soundVolume.text.Text = settings.currentSettings.soundVolume
                    menu.book.sound.Volume = settings.currentSettings.soundVolume*0.01
                    menu.book.sound:Play()
                end
            elseif impact.Object.name == "soundLeft" then
                if settings.currentSettings.soundVolume > 0 then
                    settings.currentSettings.soundVolume = settings.currentSettings.soundVolume - 5
                    menu.book.soundVolume.text.Text = settings.currentSettings.soundVolume
                    menu.book.sound.Volume = settings.currentSettings.soundVolume*0.01
                    menu.book.sound:Play()
                end
            end
        end
    end)

    menu.book.musicVolume = Text()
    menu.book.musicVolume.Text = "Music volume: "
    menu.book.musicVolume:SetParent(menu.book.right)
    menu.book.musicVolume.Scale = 0.75
    menu.book.musicVolume.LocalPosition = Number3(-1.01, 4, 5.5)
    menu.book.musicVolume.BackgroundColor = Color(0, 0, 0, 0)
    menu.book.musicVolume.LocalRotation.Y = math.pi/2

    menu.book.musicVolume.text = Text()
    menu.book.musicVolume.text.Text = "0"
    menu.book.musicVolume.text:SetParent(menu.book.left)
    menu.book.musicVolume.text.Scale = 0.75
    menu.book.musicVolume.text.LocalPosition = Number3(1.01, 4, 5.5)
    menu.book.musicVolume.text.BackgroundColor = Color(0, 0, 0, 0)
    menu.book.musicVolume.text.LocalRotation.Y = -math.pi/2

    menu.book.musicVolume.right = Text()
    menu.book.musicVolume.right.Text = ">"
    menu.book.musicVolume.right:SetParent(menu.book.left)
    menu.book.musicVolume.right.Scale = 0.75
    menu.book.musicVolume.right.LocalPosition = Number3(1.01, 4, 8)
    menu.book.musicVolume.right.BackgroundColor = Color(0, 0, 0, 0)
    menu.book.musicVolume.right.LocalRotation.Y = -math.pi/2
    menu.book.musicVolume.right.quad = Quad()
    menu.book.musicVolume.right.quad.name = "musicRight"
    menu.book.musicVolume.right.quad.Color.A = 0
    menu.book.musicVolume.right.quad:SetParent(menu.book.musicVolume.right)
    menu.book.musicVolume.right.quad.Scale = 2
    menu.book.musicVolume.right.quad.LocalPosition = Number3(-1, -1, 0)
    menu.book.musicVolume.right.quad.Physics = PhysicsMode.Static

    menu.book.musicVolume.left = Text()
    menu.book.musicVolume.left.Text = "<"
    menu.book.musicVolume.left:SetParent(menu.book.left)
    menu.book.musicVolume.left.Scale = 0.75
    menu.book.musicVolume.left.LocalPosition = Number3(1.01, 4, 3)
    menu.book.musicVolume.left.BackgroundColor = Color(0, 0, 0, 0)
    menu.book.musicVolume.left.LocalRotation.Y = -math.pi/2
    menu.book.musicVolume.left.quad = Quad()
    menu.book.musicVolume.left.quad.name = "musicLeft"
    menu.book.musicVolume.left.quad.Color.A = 0
    menu.book.musicVolume.left.quad:SetParent(menu.book.musicVolume.left)
    menu.book.musicVolume.left.quad.Scale = 2
    menu.book.musicVolume.left.quad.LocalPosition = Number3(-1, -1, 0)
    menu.book.musicVolume.left.quad.Physics = PhysicsMode.Static

    menu.book.soundVolume = Text()
    menu.book.soundVolume.Text = "Sound volume: "
    menu.book.soundVolume:SetParent(menu.book.right)
    menu.book.soundVolume.Scale = 0.75
    menu.book.soundVolume.LocalPosition = Number3(-1.01, 2, 5.5)
    menu.book.soundVolume.BackgroundColor = Color(0, 0, 0, 0)
    menu.book.soundVolume.LocalRotation.Y = math.pi/2

    menu.book.soundVolume.text = Text()
    menu.book.soundVolume.text.Text = "0"
    menu.book.soundVolume.text:SetParent(menu.book.left)
    menu.book.soundVolume.text.Scale = 0.75
    menu.book.soundVolume.text.LocalPosition = Number3(1.01, 2, 5.5)
    menu.book.soundVolume.text.BackgroundColor = Color(0, 0, 0, 0)
    menu.book.soundVolume.text.LocalRotation.Y = -math.pi/2

    menu.book.soundVolume.right = Text()
    menu.book.soundVolume.right.Text = ">"
    menu.book.soundVolume.right:SetParent(menu.book.left)
    menu.book.soundVolume.right.Scale = 0.75
    menu.book.soundVolume.right.LocalPosition = Number3(1.01, 2, 8)
    menu.book.soundVolume.right.BackgroundColor = Color(0, 0, 0, 0)
    menu.book.soundVolume.right.LocalRotation.Y = -math.pi/2
    menu.book.soundVolume.right.quad = Quad()
    menu.book.soundVolume.right.quad.name = "soundRight"
    menu.book.soundVolume.right.quad.Color.A = 0
    menu.book.soundVolume.right.quad:SetParent(menu.book.soundVolume.right)
    menu.book.soundVolume.right.quad.Scale = 2
    menu.book.soundVolume.right.quad.LocalPosition = Number3(-1, -1, 0)
    menu.book.soundVolume.right.quad.Physics = PhysicsMode.Static

    menu.book.soundVolume.left = Text()
    menu.book.soundVolume.left.Text = "<"
    menu.book.soundVolume.left:SetParent(menu.book.left)
    menu.book.soundVolume.left.Scale = 0.75
    menu.book.soundVolume.left.LocalPosition = Number3(1.01, 2, 3)
    menu.book.soundVolume.left.BackgroundColor = Color(0, 0, 0, 0)
    menu.book.soundVolume.left.LocalRotation.Y = -math.pi/2
    menu.book.soundVolume.left.quad = Quad()
    menu.book.soundVolume.left.quad.name = "soundLeft"
    menu.book.soundVolume.left.quad.Color.A = 0
    menu.book.soundVolume.left.quad:SetParent(menu.book.soundVolume.left)
    menu.book.soundVolume.left.quad.Scale = 2
    menu.book.soundVolume.left.quad.LocalPosition = Number3(-1, -1, 0)
    menu.book.soundVolume.left.quad.Physics = PhysicsMode.Static

--[[
    for k, v in pairs(menu.bushes) do
        v:SetParent(nil)
        v = nil
    end
]]
    local bushes = {
        {pos = Number3(-9, 1, 60), rot = Rotation(0, -math.pi-0.6, 0), scale = 0.45},
        {pos = Number3(-1, 0.9, 64), rot = Rotation(0, 0.2, 0), scale = 0.58},
        {pos = Number3(5, 1, 65), rot = Rotation(0, -0.9, 0), scale = 0.46},
        {pos = Number3(9, 0.85, 69), rot = Rotation(0, 0.1, 0), scale = 0.52},
        {pos = Number3(16, 1, 72), rot = Rotation(0, -0.7, 0), scale = 0.53},
        {pos = Number3(-15, 0.8, 58), rot = Rotation(0, -0.2+math.pi, 0), scale = 0.45},
        {pos = Number3(-20, 0.9, 63), rot = Rotation(0, -0.1+math.pi/2, 0), scale = 0.5},
        {pos = Number3(-25, 0.85, 67), rot = Rotation(0, 0.4, 0), scale = 0.45},
        {pos = Number3(-30, 0.78, 59), rot = Rotation(0, -0.5, 0), scale = 0.55},
        {pos = Number3(-36, 0.75, 61), rot = Rotation(0, 0.3, 0), scale = 0.45},
        {pos = Number3(-40, 0.95, 58), rot = Rotation(0, -1.5, 0), scale = 0.47},
        {pos = Number3(-45, 0.75, 57), rot = Rotation(0, -2.5, 0), scale = 0.5},
        {pos = Number3(-52, 0.85, 60), rot = Rotation(0, 1.2, 0), scale = 0.57},

        {pos = Number3(30, 0.8, 120), rot = Rotation(0, -0.2+math.pi, 0), scale = 1},
        {pos = Number3(20, 0.9, 120), rot = Rotation(0, -0.1+math.pi/2, 0), scale = 1},
        {pos = Number3(10, 0.8, 120), rot = Rotation(0, -0.2, 0), scale = 1},
        {pos = Number3(0, 0.8, 120), rot = Rotation(0, -0.8+math.pi, 0), scale = 1},
        {pos = Number3(-10, 0.9, 120), rot = Rotation(0, -0.1+math.pi/2, 0), scale = 1},
        {pos = Number3(-20, 0.8, 120), rot = Rotation(0, -0.6, 0), scale = 1},
        {pos = Number3(-30, 0.9, 120), rot = Rotation(0, -0.1+math.pi/2, 0), scale = 1},
        {pos = Number3(-40, 0.85, 120), rot = Rotation(0, 0.4, 0), scale = 1},
        {pos = Number3(-50, 0.8, 120), rot = Rotation(0, -0.4+math.pi, 0), scale = 1},
        {pos = Number3(-60, 0.9, 120), rot = Rotation(0, -0.1+2, 0), scale = 1},
        {pos = Number3(-70, 0.85, 120), rot = Rotation(0, 0.4, 0), scale = 1},
        {pos = Number3(-80, 0.8, 120), rot = Rotation(0, -0.2, 0), scale = 1},
        {pos = Number3(-90, 0.8, 120), rot = Rotation(0, -0.4+math.pi, 0), scale = 1},

        {pos = Number3(-32, 0, 51), rot = Rotation(0, -0.24, 0), scale = 0.58},
        {pos = Number3(-35, 0, 47), rot = Rotation(0, 0.5, 0), scale = 0.5},
        {pos = Number3(-38, 0, 43), rot = Rotation(0, -0.24, 0), scale = 0.6},
        {pos = Number3(-41, 0, 39), rot = Rotation(0, 0.24, 0), scale = 0.5},
        {pos = Number3(-44, 0, 32), rot = Rotation(0, -0.3, 0), scale = 0.6},
        {pos = Number3(-47, 0, 28), rot = Rotation(0, -1.24, 0), scale = 0.55},
        {pos = Number3(-50, 0, 20), rot = Rotation(0, -3.7, 0), scale = 0.6},
        {pos = Number3(-48, 0, 13), rot = Rotation(0, -0.24, 0), scale = 0.56},
        {pos = Number3(-50, 0, 7), rot = Rotation(0, -0.24, 0), scale = 0.5},
        {pos = Number3(-50, 0, -1), rot = Rotation(0, -1.4, 0), scale = 0.5},
        {pos = Number3(-48, 0, -9), rot = Rotation(0, 0.2, 0), scale = 0.5},
        {pos = Number3(-50, 0, -17), rot = Rotation(0, 1.4, 0), scale = 0.55},
        {pos = Number3(-50, 0, -24), rot = Rotation(0, -0.2, 0), scale = 0.45},
        {pos = Number3(-52, 0, -30), rot = Rotation(0, 0.4, 0), scale = 0.55},
        {pos = Number3(-46, 0, -37), rot = Rotation(0, 1.4, 0), scale = 0.5},
        {pos = Number3(-41, 0, -40), rot = Rotation(0, -0.7, 0), scale = 0.45},    
        {pos = Number3(-35, 0, -44), rot = Rotation(0, 0.4, 0), scale = 0.5},
        {pos = Number3(-28, 0, -46), rot = Rotation(0, -0.7, 0), scale = 0.45},
        {pos = Number3(-35, 0, -44), rot = Rotation(0, 0.4, 0), scale = 0.5},
        {pos = Number3(-28, 0, -46), rot = Rotation(0, -0.7, 0), scale = 0.45},
        {pos = Number3(-21, 0, -48), rot = Rotation(0, 0, 0), scale = 0.52},
        {pos = Number3(-14, 0, -50), rot = Rotation(0, -0.3, 0), scale = 0.48},
        {pos = Number3(-7, 0, -50), rot = Rotation(0, 0.3, 0), scale = 0.45},
        {pos = Number3(0, 0, -50), rot = Rotation(0, -0.7, 0), scale = 0.5},
        {pos = Number3(7, 0, -50), rot = Rotation(0, -0.3, 0), scale = 0.52},
        {pos = Number3(14, 0, -50), rot = Rotation(0, 0.4, 0), scale = 0.45},
        {pos = Number3(21, 0, -50), rot = Rotation(0, -0.7, 0), scale = 0.52},
        {pos = Number3(28, 0, -48), rot = Rotation(0, -0.3, 0), scale = 0.5},
        {pos = Number3(32, 0, -45), rot = Rotation(0, 0, 0), scale = 0.45},
        {pos = Number3(36, 0, -40), rot = Rotation(0, 0.4, 0), scale = 0.48},
        {pos = Number3(40, 0, -35), rot = Rotation(0, -0.7, 0), scale = 0.5},
        {pos = Number3(44, 0, -29), rot = Rotation(0, 0.3, 0), scale = 0.45},

        {pos = Number3(-35, 0, -100), rot = Rotation(0, 0.4, 0), scale = 1},
        {pos = Number3(-28, 0, -100), rot = Rotation(0, -0.7, 0), scale = 1},
        {pos = Number3(-21, 0, -90), rot = Rotation(0, 0, 0), scale = 1},
        {pos = Number3(-14, 0, -90), rot = Rotation(0, -0.3, 0), scale = 1},
        {pos = Number3(-7, 0, -100), rot = Rotation(0, 0.3, 0), scale = 1},
        {pos = Number3(0, 0, -100), rot = Rotation(0, -0.7, 0), scale = 1},
        {pos = Number3(7, 0, -90), rot = Rotation(0, -0.3, 0), scale = 1},
        {pos = Number3(14, 0, -100), rot = Rotation(0, 0.4, 0), scale = 1},
        {pos = Number3(21, 0, -90), rot = Rotation(0, -0.7, 0), scale = 1},
        {pos = Number3(28, 0, -90), rot = Rotation(0, -0.3, 0), scale = 1},
        {pos = Number3(32, 0, -100), rot = Rotation(0, 0, 0), scale = 1},
        {pos = Number3(36, 0, -90), rot = Rotation(0, 0.4, 0), scale = 1},
        {pos = Number3(40, 0, -90), rot = Rotation(0, -0.7, 0), scale = 1},
        {pos = Number3(44, 0, -100), rot = Rotation(0, 0.3, 0), scale = 1},
        {pos = Number3(50, 0, -100), rot = Rotation(0, 0, 0), scale = 1},
        {pos = Number3(57, 0, -90), rot = Rotation(0, 0.4, 0), scale = 1},
        {pos = Number3(64, 0, -90), rot = Rotation(0, -0.7, 0), scale = 1},
        {pos = Number3(72, 0, -100), rot = Rotation(0, 0.3, 0), scale = 1},
        {pos = Number3(79, 0, -90), rot = Rotation(0, 0.3, 0), scale = 1},
        {pos = Number3(-80, 0, 90), rot = Rotation(0, 0.24, 0), scale = 1},
        {pos = Number3(-83, 0, 80), rot = Rotation(0, 0.7, 0), scale = 1.1},
        {pos = Number3(-78, 0, 70), rot = Rotation(0, -1.44, 0), scale = 0.9},
        {pos = Number3(-83, 0, 60), rot = Rotation(0, 0.24, 0), scale = 1},
        {pos = Number3(-78, 0, 50), rot = Rotation(0, -1.4, 0), scale = 1.1},
        {pos = Number3(-83, 0, 40), rot = Rotation(0, -0.24, 0), scale = 0.9},
        {pos = Number3(-78, 0, 30), rot = Rotation(0, 1.4, 0), scale = 1},
        {pos = Number3(-83, 0, 20), rot = Rotation(0, 0.24, 0), scale = 0.9},
        {pos = Number3(-86, 0, 10), rot = Rotation(0, -0.7, 0), scale = 1.1},
        {pos = Number3(-83, 0, 0), rot = Rotation(0, -0.24, 0), scale = 1},
        {pos = Number3(-85, 0, -10), rot = Rotation(0, 1.4, 0), scale = 1.1},
        {pos = Number3(-83, 0, -20), rot = Rotation(0, 0.24, 0), scale = 1},
        {pos = Number3(-80, 0, -30), rot = Rotation(0, -0.24, 0), scale = 0.9},
        {pos = Number3(-73, 0, -40), rot = Rotation(0, 0.7, 0), scale = 1.1},
        {pos = Number3(-64, 0, -50), rot = Rotation(0, -0.24, 0), scale = 1},
        {pos = Number3(-59, 0, -60), rot = Rotation(0, 1.4, 0), scale = 1.1},
        {pos = Number3(-53, 0, -70), rot = Rotation(0, -0.24, 0), scale = 0.9},
        {pos = Number3(-48, 0, -80), rot = Rotation(0, 0.24, 0), scale = 1},
        {pos = Number3(-41, 0, -90), rot = Rotation(0, -0.7, 0), scale = 1},
        {pos = Number3(-36, 0, -100), rot = Rotation(0, 1.4, 0), scale = 1.1},

        {pos = Number3(50, 1, -60), rot = Rotation(0, -0.2, 0), scale = 0.55},
        {pos = Number3(54, 1, -54), rot = Rotation(0, -0.6, 0), scale = 0.62},
        {pos = Number3(58, 1, -46), rot = Rotation(0, 1.7, 0), scale = 0.58},
        {pos = Number3(62, 1, -38), rot = Rotation(0, -0.6, 0), scale = 0.62},
        {pos = Number3(66, 1, -30), rot = Rotation(0, 2.4, 0), scale = 0.55},
        {pos = Number3(70, 1, -22), rot = Rotation(0, -0, 0), scale = 0.6},
        {pos = Number3(70, 0, -16), rot = Rotation(0, 0.2, 0), scale = 0.6},
        {pos = Number3(70, 0, -8), rot = Rotation(0, 2.4, 0), scale = 0.58},
        {pos = Number3(70, 0, 0), rot = Rotation(0, -1.7, 0), scale = 0.62},
        {pos = Number3(68, 0, 8), rot = Rotation(0, 0, 0), scale = 0.62},
        {pos = Number3(64, 0, 16), rot = Rotation(0, 0.2, 0), scale = 0.58},
        {pos = Number3(60, 0, 22), rot = Rotation(0, -0.6, 0), scale = 0.55},
        {pos = Number3(56, 0, 30), rot = Rotation(0, -2.4, 0), scale = 0.55},
        {pos = Number3(52, 0, 38), rot = Rotation(0, -0.6, 0), scale = 0.6},
        {pos = Number3(48, 0, 46), rot = Rotation(0, 0.2, 0), scale = 0.58},
        {pos = Number3(40, 0, 54), rot = Rotation(0, -1.7, 0), scale = 0.62},
        {pos = Number3(32, 0, 62), rot = Rotation(0, 2.4, 0), scale = 0.58},
        {pos = Number3(24, 0, 70), rot = Rotation(0, -0.6, 0), scale = 0.55},

        {pos = Number3(50, 1, -12*6.5), rot = Rotation(0, 0.2, 0), scale = 1},
        {pos = Number3(55, 1, -12*6), rot = Rotation(0, -1, 0), scale = 1},
        {pos = Number3(60, 1, -12*5.5), rot = Rotation(0, 2.1, 0), scale = 1},
        {pos = Number3(70, 1, -12*5), rot = Rotation(0, -2.1, 0), scale = 1},
        {pos = Number3(80, 1, -12*4), rot = Rotation(0, 0.2, 0), scale = 1},
        {pos = Number3(90, 1, -12*3), rot = Rotation(0, 0, 0), scale = 1},
        {pos = Number3(100, 1, -12*2), rot = Rotation(0, -1, 0), scale = 1},
        {pos = Number3(100, 1, -12*1), rot = Rotation(0, 0.2, 0), scale = 1},
        {pos = Number3(100, 1, 0), rot = Rotation(0, 0, 0), scale = 1},
        {pos = Number3(100, 1, 12), rot = Rotation(0, -1, 0), scale = 1},
        {pos = Number3(100, 1, 12*2), rot = Rotation(0, 2.1, 0), scale = 1},
        {pos = Number3(90, 1, 12*3), rot = Rotation(0, 0, 0), scale = 1},
        {pos = Number3(80, 1, 12*4), rot = Rotation(0, -1, 0), scale = 1},
        {pos = Number3(70, 1, 12*5), rot = Rotation(0, 2.1, 0), scale = 1},
        {pos = Number3(60, 1, 12*6), rot = Rotation(0, 0, 0), scale = 1},
        {pos = Number3(50, 1, 12*7), rot = Rotation(0, -2.1, 0), scale = 1},
        {pos = Number3(40, 1, 12*8), rot = Rotation(0, -1, 0), scale = 1},
        {pos = Number3(40, 1, 12*9), rot = Rotation(0, 0, 0), scale = 1},
    }

    menu.bushes = {}
    for k, v in pairs(bushes) do
        local bush = Shape(shapes.bush, {includeChildren = true})
        bush.Position = v.pos
        bush.Rotation = v.rot
        bush.Scale = v.scale
        bush:SetParent(World)
        bush.Shadow = true
        bush.Pivot.Y = 0

        table.insert(menu.bushes, bush)
    end
--[[
    for k, v in pairs(menu.trees) do
        v:SetParent(nil)
        v = nil
    end
]]
    local trees = {
        {pos = Number3(-49, 0, 60), rot = Rotation(0, 0.2, 0), scale = 0.75},
        {pos = Number3(-42, -0.5, 65), rot = Rotation(0, -2.9, 0), scale = 0.65},
        {pos = Number3(-31, -1, 65), rot = Rotation(0, -0.3, 0), scale = 0.7},
        {pos = Number3(-22, -0.5, 70), rot = Rotation(0, -1.2, 0), scale = 0.85},
        {pos = Number3(-10, -1, 70), rot = Rotation(0, -2.9, 0), scale = 0.65},
        {pos = Number3(0, -1.5, 65), rot = Rotation(0, 0.2, 0), scale = 0.75},
        {pos = Number3(8, -0.5, 70), rot = Rotation(0, 0, 0), scale = 0.8},

        {pos = Number3(-63, -2-2, 80), rot = Rotation(0, 0.3, 0), scale = 0.75},
        {pos = Number3(-56, -2-2, 80), rot = Rotation(0, -0.3, 0), scale = 0.8},
        {pos = Number3(-45, 0-2, 80), rot = Rotation(0, -1.2, 0), scale = 0.75},
        {pos = Number3(-40, -2, 85), rot = Rotation(0, 0.2, 0), scale = 0.75},
        {pos = Number3(-29, -1-2, 85), rot = Rotation(0, 0, 0), scale = 0.7},
        {pos = Number3(-25, -0.5-2, 90), rot = Rotation(0, 0, 0), scale = 0.85},
        {pos = Number3(-16, 0-2, 90), rot = Rotation(0, -2.9, 0), scale = 0.85},
        {pos = Number3(-5, -1.5-2, 85), rot = Rotation(0, 0.2, 0), scale = 0.75},
        {pos = Number3(2, -0.5-2, 80), rot = Rotation(0, -0.3, 0), scale = 0.8},

        {pos = Number3(-17, -3, -70), rot = Rotation(0, -0.2, 0), scale = 0.75},
        {pos = Number3(-8, -4, -70), rot = Rotation(0, 1.2, 0), scale = 0.85},
        {pos = Number3(0, -2, -70), rot = Rotation(0, 0.4, 0), scale = 0.95},
        {pos = Number3(9, -3, -70), rot = Rotation(0, 2.5, 0), scale = 0.75},
        {pos = Number3(18, -3, -70), rot = Rotation(0, 0, 0), scale = 0.85},
        {pos = Number3(25, -4, -70), rot = Rotation(0, -0.2, 0), scale = 0.75},
        {pos = Number3(34, -3, -67), rot = Rotation(0, 1.2, 0), scale = 0.7},
        {pos = Number3(42, -3, -67), rot = Rotation(0, 0.4, 0), scale = 0.85},
        {pos = Number3(50, -2, -63), rot = Rotation(0, 2.5, 0), scale = 0.75},
        {pos = Number3(57, -3, -63), rot = Rotation(0, -0.2, 0), scale = 0.7},

        {pos = Number3(-17+3, -3, -80), rot = Rotation(0, -1.2, 0), scale = 0.75},
        {pos = Number3(-8+7, -3, -80), rot = Rotation(0, 2.52, 0), scale = 0.85},
        {pos = Number3(0+2, -4, -80), rot = Rotation(0, 0.1, 0), scale = 0.95},
        {pos = Number3(9+7, -3, -80), rot = Rotation(0, 2.5, 0), scale = 0.75},
        {pos = Number3(18+7, -2, -80), rot = Rotation(0, 0, 0), scale = 0.85},
        {pos = Number3(25+5, -4, -80), rot = Rotation(0, -0.2, 0), scale = 0.75},
        {pos = Number3(34+3, -3, -78), rot = Rotation(0, 1.2, 0), scale = 0.7},
        {pos = Number3(42+1, -3, -78), rot = Rotation(0, 0.4, 0), scale = 0.85},
        {pos = Number3(50+2, -4, -74), rot = Rotation(0, 0.1, 0), scale = 0.75},
        {pos = Number3(57+7, -2, -74), rot = Rotation(0, -0.2, 0), scale = 0.7},

        {pos = Number3(-35, -3, -115), rot = Rotation(0, 1.1, 0), scale = 0.75},
        {pos = Number3(-45, -5, -110), rot = Rotation(0, -0.2, 0), scale = 0.85},
        {pos = Number3(-50, 0, -100), rot = Rotation(0, 0.4, 0), scale = 0.8},
        {pos = Number3(-55, -3, -96), rot = Rotation(0, -0.4, 0), scale = 0.85},
        {pos = Number3(-60, -5, -80), rot = Rotation(0, 0, 0), scale = 0.89},
        {pos = Number3(-65, 0, -70), rot = Rotation(0, 1.1, 0), scale = 0.83},
        {pos = Number3(-70, 0, -60), rot = Rotation(0, -0, 0), scale = 0.8},
        {pos = Number3(-80, -3, -45), rot = Rotation(0, 0, 0), scale = 0.75},
        {pos = Number3(-85, 0, -30), rot = Rotation(0, 1.1, 0), scale = 0.85},
        {pos = Number3(-90, -5, -15), rot = Rotation(0, -0.2, 0), scale = 0.83},
        {pos = Number3(-100, -2, 0), rot = Rotation(0, 0, 0), scale = 0.8},
        {pos = Number3(-100, -2, 15), rot = Rotation(0, -1.1, 0), scale = 0.86},
        {pos = Number3(-100, 0, 30), rot = Rotation(0, 0.2, 0), scale = 0.85},
        {pos = Number3(-95, -2, 45), rot = Rotation(0, -0.2, 0), scale = 0.75},
        {pos = Number3(-95, -3, 60), rot = Rotation(0, 1.1, 0), scale = 0.8},
        {pos = Number3(-90, -5, 75), rot = Rotation(0, 0, 0), scale = 0.85},
        {pos = Number3(-85, -2, 90), rot = Rotation(0, 0.4, 0), scale = 0.8},
        {pos = Number3(-80, 0, 105), rot = Rotation(0, -0.2, 0), scale = 0.7},
        {pos = Number3(-80, -3, 105), rot = Rotation(0, 0, 0), scale = 0.75},

        {pos = Number3(-67, -5, -57), rot = Rotation(0, 1.1, 0), scale = 0.85},
        {pos = Number3(-76, 0, -64), rot = Rotation(0, 0.2, 0), scale = 0.85},
        {pos = Number3(-86, -3, -72), rot = Rotation(0,-0.4, 0), scale = 0.9},
        {pos = Number3(-93, 0, -66), rot = Rotation(0, 1.1, 0), scale = 0.8},
        {pos = Number3(-100, 0, -59), rot = Rotation(0, 1.1, 0), scale = 0.9},
        {pos = Number3(-115, 0, -53), rot = Rotation(0, -0, 0), scale = 0.9},
        {pos = Number3(-120, -3, -45), rot = Rotation(0, 0, 0), scale = 0.85},
        {pos = Number3(-120, -2, -33), rot = Rotation(0, 1.1, 0), scale = 0.95},
        {pos = Number3(-125, -5, -13), rot = Rotation(0, -0.2, 0), scale = 0.8},
        {pos = Number3(-130, 0, 0), rot = Rotation(0, 0, 0), scale = 0.9},
        {pos = Number3(-130, -2, 13), rot = Rotation(0, -1.1, 0), scale = 0.8},
        {pos = Number3(-130, -3, 35), rot = Rotation(0, 0.2, 0), scale = 0.95},
        {pos = Number3(-125, 0, 43), rot = Rotation(0, -0.2, 0), scale = 0.85},
        
        {pos = Number3(20, 0, 74), rot = Rotation(0, 0.2, 0), scale = 0.8},
        {pos = Number3(26, 0, 70), rot = Rotation(0, 0, 0), scale = 0.65},
        {pos = Number3(33, 0, 68), rot = Rotation(0, 0, 0), scale = 0.7},
        {pos = Number3(38, 0, 62), rot = Rotation(0, -1.1, 0), scale = 0.8},
        {pos = Number3(44, 0, 56), rot = Rotation(0, 0.73, 0), scale = 0.65},
        {pos = Number3(50, 0, 50), rot = Rotation(0, 0.73, 0), scale = 0.7},
        {pos = Number3(58, 0, 42), rot = Rotation(0, 0, 0), scale = 0.75},
        {pos = Number3(66, 0, 34), rot = Rotation(0, -1.1, 0), scale = 0.8},
        {pos = Number3(74, 0, 26), rot = Rotation(0, 0, 0), scale = 0.65},
        {pos = Number3(76, 0, 18), rot = Rotation(0, -0.2, 0), scale = 0.75},
        {pos = Number3(78, 0, 10), rot = Rotation(0, 1.1, 0), scale = 0.7},
        {pos = Number3(80, 0, 2), rot = Rotation(0, -1.1, 0), scale = 0.75},
        {pos = Number3(78, 0, -6), rot = Rotation(0, 0.73, 0), scale = 0.65},
        {pos = Number3(78, 0, -14), rot = Rotation(0, 0, 0), scale = 0.75},
        {pos = Number3(76, 0, -22), rot = Rotation(0, 0.2, 0), scale = 0.8},
        {pos = Number3(74, 0, -30), rot = Rotation(0, 0.73, 0), scale = 0.8},
        {pos = Number3(70, 0, -38), rot = Rotation(0, -1.1, 0), scale = 0.7},
        {pos = Number3(66, 0, -46), rot = Rotation(0, 0.73, 0), scale = 0.65},
        {pos = Number3(60, 0, -52), rot = Rotation(0, 0, 0), scale = 0.75},
        {pos = Number3(62, 0, -58), rot = Rotation(0, -1.1, 0), scale = 0.7},
    }

    menu.trees = {}
    for k, v in pairs(trees) do
        local tree = Shape(shapes.tree, {includeChildren = true})
        tree.Position = v.pos
        tree.Rotation = v.rot
        tree.Scale = v.scale
        tree:SetParent(World)
        tree.Shadow = true
        tree.Pivot.Y = 0

        table.insert(menu.trees, tree)
    end

    HTTP:Get("https://cdn.pixabay.com/photo/2012/04/01/18/55/work-in-progress-24027_1280.png", function(res)
        if res.StatusCode ~= 200 then
            error("Error on downloading work in progress image: " .. res.StatusCode)
        end

        if menu.created then
            menu.workinprogress = Quad()
            menu.workinprogress.Color.A = 254
            menu.workinprogress.Image = res.Body
            menu.workinprogress.Width, menu.workinprogress.Height = 10, 10
            menu.workinprogress.Position = Number3(40, 2, 20)
            menu.workinprogress.Rotation = Rotation(0, math.pi/2-0.5, 0)
            menu.workinprogress:SetParent(World)
        end
    end)
end

return menu