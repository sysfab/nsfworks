local visualizer = {}

visualizer.create = function(weapon)
    local v = {}

    v.weapon = weapon

    v.window = ui:createFrame(Color(0, 0, 0, 125))
    v.window.parentDidResize = function(s)
        s.Width = Screen.Width
        s.Height = Screen.Height
    end
    v.window:parentDidResize()

    v.title = ui:createText(v.weapon.Name, Color(255, 255, 255))
    v.title:setParent(window)
    v.title.parentDidResize = function(s)
        s.pos = Number2(v.window.Width/2 - s.Width/2, v.window.Height - s.Height - 30)
    end
    v.title:parentDidResize()

    v.description = ui:createText(v.weapon.Description, Color(220, 220, 220))
    v.description:setParent(window)
    v.description.parentDidResize = function(s)
        s.pos = Number2(v.window.Width/2 - s.Width/2, v.window.Height - v.title.Height - 16 - s.Height - 30)
    end
    v.description:parentDidResize()

    for i, part in ipairs(v.weapon.Parts) do
        v["part "..part.Name] = ui:createFrame()
        local p = v["part "..part.Name]

        p.object.Image = {data = part.Texture, alpha=true}
        p.object.Color = Color(255, 255, 255, 255)
        p.parentDidResize = function(s)
            local wh = math.min(Screen.Width/2.6, Screen.Height/2.6)

            p.Width = wh
            p.Height = wh

            p.pos = Number2(Screen.Width/2-p.Width/2, Screen.Height/2-p.Height/2)
        end
        p:parentDidResize()
    end

    v.remove = function(self)
        self.window:remove()
        self.title:remove()
        self.description:remove()

        for i, part in ipairs(v.weapon.Parts) do
            local p = v["part "..part.Name]
            v["part "..part.Name] = nil
        end

        self.title = nil
        self.window = nil
        self.description = nil
    end

    return v
end

return visualizer