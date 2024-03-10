patchedLotteryTicket = false
jokerHook = initJokerHook()

if (sendDebugMessage == nil) then
    sendDebugMessage = function(_)
    end
end

table.insert(mods,
            {
            mod_id = "lottery_ticket",
            name = "Lottery Ticket",
            version = "0.1",
            author = "John Maged & Kyu",
            description = {
                "Adds the \"Lottery Ticket\""
            },
            enabled = true,
            on_post_update = function() 
                if not patchedLotteryTicket then
                    
                    -----------------------------------------
                    sendDebugMessage("Adding lottery ticket to centers!")

                    jokerHook.addJoker(self, "j_lottery_ticket", "Lottery Ticket", nil, true, 5, { x = 0, y = 0 }, nil, {extra = {x_mult = 1}}, {"Jokers' sell value changes", "randomly every round"}, 2, true, true)

                    ---------------------------------------------
                    sendDebugMessage("Inserting lottery_ticket into calculate_joker!")
                    
                    local toReplaceLogic = "if self.ability.name == 'Luchador' then"

                    local replacementLogic = [[
                        if self.ability.name == "Lottery Ticket" then
                            -- Undo effect
                            for i = 1, #G.jokers.cards do
                                local joker = G.jokers.cards[i]
                                if joker ~= self then
                                    local original_sell_cost = math.max(1, math.floor(joker.cost / 2)) +
                                        (joker.ability.extra_value or 0)
                                    joker.sell_cost = original_sell_cost
                                end
                            end
                        end

                        if self.ability.name == 'Luchador' then
                    ]]
                    
                    inject("card.lua", "Card:calculate_joker", toReplaceLogic:gsub("([^%w])", "%%%1"), replacementLogic)

                    -- -------------------------------------------------------

                    local toReplaceLogic2 = "if self.ability.name == 'Campfire' and G.GAME.blind.boss and self.ability.x_mult > 1 then"

                    local replacementLogic2 = [[
                        if self.ability.name == "Lottery Ticket" then
                            for i = 1, #G.jokers.cards do
                                local joker = G.jokers.cards[i]
                                local original_sell_cost = math.max(1, math.floor(joker.cost / 2)) +
                                    (joker.ability.extra_value or 0)
                                joker.sell_cost = pseudorandom('lottery_ticket', 1, 3 * original_sell_cost)
                            end
                        end

                        if self.ability.name == 'Campfire' and G.GAME.blind.boss and self.ability.x_mult > 1 then
                    ]]

                    inject("card.lua", "Card:calculate_joker", toReplaceLogic2:gsub("([^%w])", "%%%1"), replacementLogic2)

                    ------------------------------------------

                    sendDebugMessage("Patching UI box text for lottery ticket")

                    local toReplaceUI = "if not self.bypass_lock and self.config.center.unlocked ~= false and"

                    local replacementUI = [[
                        if self.ability.name == 'Lottery Ticket' then
                            loc_vars = { self.ability.extra.x_mult }
                        end

                        if not self.bypass_lock and self.config.center.unlocked ~= false and
                    ]]

                    inject("card.lua", "Card:generate_UIBox_ability_table", toReplaceUI:gsub("([^%w])", "%%%1"), replacementUI)

                    -----------------------------------------------

                    local toReplaceUI2 = "return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, hide_desc, main_start, main_end)"

                    local replacementUI2 = [[
                        if self.ability.name == 'Lottery Ticket' or self.ability.name == "Collector's Item" then
                            return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, false, nil, nil)
                        end
                        
                        return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, hide_desc, main_start, main_end)
                    ]]

                    inject("card.lua", "Card:generate_UIBox_ability_table", toReplaceUI2:gsub("([^%w])", "%%%1"), replacementUI2)

                    ------------------------------------------

                    sendDebugMessage("Adding texture file for lottery ticket!")

                    local toReplaceAtlas = "{name = 'chips', path = \"resources/textures/\"..self.SETTINGS.GRAPHICS.texture_scaling..\"x/chips.png\",px=29,py=29}"

                    local replacementAtlas = [[
		                {name = 'lottery_ticket', path = "pack/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/j_lottery_ticket.png",px=71,py=95},
                        {name = 'chips', path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/chips.png",px=29,py=29}
                    ]]

                    inject("game.lua", "Game:set_render_settings", toReplaceAtlas:gsub("([^%w])", "%%%1"), replacementAtlas)

                    G:set_render_settings()

                    -------------------------------------------------------
                    sendDebugMessage("Adding sprite draw logic for lottery ticket!")

                    local toReplaceTexLoad = "elseif self.config.center.set == 'Voucher' and not self.config.center.unlocked and not self.params.bypass_discovery_center then"

                    local replacementTexLoad = [[
                        elseif _center.name == 'Lottery Ticket' then
                            self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["lottery_ticket"], j_lottery_ticket)
                        elseif self.config.center.set == 'Voucher' and not self.config.center.unlocked and not self.params.bypass_discovery_center then
                    ]]

                    inject("card.lua", "Card:set_sprites", toReplaceTexLoad:gsub("([^%w])", "%%%1"), replacementTexLoad)

                    -------------------------------------------------------

                    patchedLotteryTicket = true

                    sendDebugMessage("Patched lottery ticket mod!")
                end
            end
        }
)
