-- Statistics
-- Statistics module

local stat = {}

stat.init = function(self, env)
	self.env = env
	rawset(env, "Stats", self)

    if IsServer then
        self.kvs = KeyValueStore("NSFWFramework_Statistics")
        self.kvs:Get("initialized", "players", "global", function(success, results)
            if success then
                if results.initialized ~= true then
                    self.kvs:Set("initialized", true, "players", JSON:Encode({}), "global", JSON:Encode({"times_launched": 1}), function(success)
                        if not success then
                            error("Statistics - failed to init [1]", 3)
                        end
                    end)
                else
                    local new_global = JSON:Decode(results.global)
                    new_global.times_launched = new_global.times_launched + 1
                    self.kvs:Set("global", JSON:Encode(new_global), function(success)
                        if not success then
                            error("Statistics - failed to init [2]", 3)
                        end
                    end)
                end
            end
        end)
        self.joinListener = LocalEvent:Listen(LocalEvent.Name.OnPlayerJoin, function(player)
            self.kvs:Get("players", function(success, results)
                if success then
                    local new_players = JSON:Decode(results.players)
                    local player_data = new_players[player.Username]
                    if player_data == nil then
                        player_data = {times_joined = 1, first_joined = os.date()}
                    else
                        player_data.times_joined = player_data.times_joined + 1
                    end
                    new_players[player.Username] = player_data
                    self.kvs:Set("players", JSON:Encode(new_players), function(success)
                        if not success then
                            error("Statistics - failed to set players [4]", 3)
                        end
                    end)
                else
                    error("Statistics - failed to get players [3]", 3)
                end
            end)
        end)
    end
end

return stat