local f = {}

f.init = function(self, env, modules)
    self.env = env
    self.modules = modules
    rawset(self.env, "Framework", self)

    for i, module in ipairs(self.modules) do
        module:init(self.env)
    end
end

return f