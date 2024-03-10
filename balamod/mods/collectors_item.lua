patchedCollectorsItem = false
jokerHook = initJokerHook()

if (sendDebugMessage == nil) then
    sendDebugMessage = function(_)
    end
end

table.insert(mods,
            {
            mod_id = "collectors_item",
            name = "Collector's Item",
            version = "0.1",
            author = "John Maged & Kyu",
            description = {
                "Adds the \"Collector's Item\""
            },
            enabled = true,
            on_post_update = function() 
                if not patchedCollectorsItem then
                    
                    -----------------------------------------
                    sendDebugMessage("Adding collector's item to centers!")

                    jokerHook.addJoker(self, "j_collectors_item", "Collector's Item", nil, true, 5, { x = 0, y = 0 }, nil, {extra = 10}, {"{C:blue}+10{} Chips for every", "unique {C:attention}Joker{}", "owned this run", "{C:inactive}(Currently {C:blue}+#1#{C:inactive})"}, 2, true, true)

                    ---------------------------------------------
                    sendDebugMessage("Inserting collectors_item into calculate_joker!")
                    
                    local toReplaceLogic = "if self.ability.name == '8 Ball' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then"

                    local replacementLogic = [[
                        if self.ability.name == "Collector's Item" then
                            if G.GAME[mod_id .. "unique_jokers_owned"] then
                                local unique_jokers_owned = table_length(G.GAME[mod_id .. "unique_jokers_owned"])
                                return {
                                    chip_mod = self.ability.extra * unique_jokers_owned,
                                    card = self,
                                    message = localize { type = 'variable', key = 'a_chips', vars = { unique_jokers_owned * self.ability.extra } },
                                }
                            end
                        end
                        if self.ability.name == "Incremental Joker" then
                            if self.ability.extra.x_mult > 1 then
                                return {
                                    message = localize { type = 'variable', key = 'a_xmult', vars = { self.ability.extra.x_mult } },
                                    Xmult_mod = self.ability.extra.x_mult
                                }
                            end
                            return nil
                        end

                        if self.ability.name == '8 Ball' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    ]]
                    
                    inject("card.lua", "Card:calculate_joker", toReplaceLogic:gsub("([^%w])", "%%%1"), replacementLogic)

                    -------------------------------------------------------

                    -- local toReplaceLogic2 = "if self.ability.name == 'Campfire' and G.GAME.blind.boss and self.ability.x_mult > 1 then"

                    -- local replacementLogic2 = [[
                    --     if self.ability.name == 'Collector's Item' then
                    --         self.ability.extra.x_mult = self.ability.extra.x_mult + 0.1
                    --         return {
                    --             message = localize('k_upgrade_ex'),
                    --             colour = G.C.RED
                    --         }
                    --     end

                    --     if self.ability.name == 'Campfire' and G.GAME.blind.boss and self.ability.x_mult > 1 then
                    -- ]]

                    -- inject("card.lua", "Card:calculate_joker", toReplaceLogic2:gsub("([^%w])", "%%%1"), replacementLogic2)

                    ------------------------------------------

                    sendDebugMessage("Patching UI box text for collector's item")

                    local toReplaceUI = "if not self.bypass_lock and self.config.center.unlocked ~= false and"

                    local replacementUI = [[
                        if self.ability.name == "Collector's Item" then
                            if G.GAME[mod_id .. "unique_jokers_owned"] then
                                local unique_jokers_owned = table_length(G.GAME[mod_id .. "unique_jokers_owned"])
                                loc_vars = { unique_jokers_owned * self.ability.extra }
                            else
                            loc_vars = { 0 }
                            end
                        end

                        if not self.bypass_lock and self.config.center.unlocked ~= false and
                    ]]

                    inject("card.lua", "Card:generate_UIBox_ability_table", toReplaceUI:gsub("([^%w])", "%%%1"), replacementUI)

                    -----------------------------------------------

                    local toReplaceUI2 = "return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, hide_desc, main_start, main_end)"

                    local replacementUI2 = [[
                        if self.ability.name == "Collector's Item" then
                            return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, false, nil, nil)
                        end
                        
                        return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, hide_desc, main_start, main_end)
                    ]]

                    inject("card.lua", "Card:generate_UIBox_ability_table", toReplaceUI2:gsub("([^%w])", "%%%1"), replacementUI2)

                    ------------------------------------------

                    sendDebugMessage("Adding texture file for collector's item!")

                    local toReplaceAtlas = "{name = 'chips', path = \"resources/textures/\"..self.SETTINGS.GRAPHICS.texture_scaling..\"x/chips.png\",px=29,py=29}"

                    local replacementAtlas = [[
		                {name = 'collectors_item', path = "pack/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/j_collectors_item.png",px=71,py=95},
                        {name = 'chips', path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/chips.png",px=29,py=29}
                    ]]

                    inject("game.lua", "Game:set_render_settings", toReplaceAtlas:gsub("([^%w])", "%%%1"), replacementAtlas)


                    G:set_render_settings()

                    -------------------------------------------------------
                    sendDebugMessage("Adding sprite draw logic for collector's item!")

                    local toReplaceTexLoad = "elseif self.config.center.set == 'Voucher' and not self.config.center.unlocked and not self.params.bypass_discovery_center then"

                    local replacementTexLoad = [[
                        elseif _center.name == "Collector's Item" then
                            self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["collectors_item"], j_collectors_item)
                        elseif self.config.center.set == 'Voucher' and not self.config.center.unlocked and not self.params.bypass_discovery_center then
                    ]]

                    inject("card.lua", "Card:set_sprites", toReplaceTexLoad:gsub("([^%w])", "%%%1"), replacementTexLoad)

                    -------------------------------------------------------
                    sendDebugMessage("Adding counting logic to add_to_deck for Collector's Item")
                    local replacementCounting = [[
                        if G.GAME and self.ability.set == "Joker" then
                            if G.GAME[mod_id .. "unique_jokers_owned"] == nil then
                                G.GAME[mod_id .. "unique_jokers_owned"] = {}
                            end
                            G.GAME[mod_id .. "unique_jokers_owned"][self.ability.name] = true
                        end
                    ]]

                    injectHead("card.lua", "Card:add_to_deck", replacementCounting)

                    patchedCollectorsItem = true

                    sendDebugMessage("Patched collector's item mod!")
                end
            end
        }
)
