local menu = {}
menu.created = false

function menu.create(self)
    if self.created == nil then
        error("menu.create() should be called with ':'!")
    end
    if self.created then
        error("menu:create() - menu currently created.")
    end
end

return menu