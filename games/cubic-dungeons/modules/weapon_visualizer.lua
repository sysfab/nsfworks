local visualizer = {}

visualizer.create(weapon)
    local v = {}

    v.window = ui:createFrame(Color(0, 0, 0, 125))
    v.window.parentDidResize = function(s)
        s.Width = Screen.Width
        s.Height = Screen.Height
    end
    v.window:parentDidResize()

    v.title = ui:createText(weapon.Name, Color(255, 255, 255))
    v.title:setParent(window)
    v.title.parentDidResize = function(s)
        s.pos = Number2(v.window.Width/2 - s.Width/2, v.window.Height - s.Height - 30)
    end
    v.title:parentDidResize()

    v.remove = function(self)
        self.window:remove()
        self.title:remove()

        self.title = nil
        self.window = nil
    end

    return v
end

return visualizer