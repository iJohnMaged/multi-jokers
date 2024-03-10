patchedSparkly = false
jokerHook = initJokerHook()

if (sendDebugMessage == nil) then
    sendDebugMessage = function(_)
    end
end

table.insert(mods,
            {
            mod_id = "sparkly_joker",
            name = "Sparkly Joker",
            version = "0.1",
            author = "John Maged & Kyu",
            description = {
                "Adds the \"Sparkly Joker\""
            },
            enabled = true,
            on_post_update = function() 
                if not patchedSparkly then
                    
                    -----------------------------------------
                    sendDebugMessage("Adding sparkly joker to centers!")

                    jokerHook.addJoker(self, "j_sparkly", "Sparkly Joker", nil, true, 5, { x = 0, y = 0 }, nil, { extra = 4 }, {"{C:green}1 in 4{} chances to", "add a random {C:attention}edition{} to", "first played card of each hand"}, 2, true, true)

                    ---------------------------------------------
                    sendDebugMessage("Inserting sparkly_joker into calculate_joker!")
                    
                    local toReplaceLogic = "if self.ability.name == 'Hiker' then"

                    local replacementLogic = [[
                        local first_card = context.scoring_hand[1]
                        if self.ability.name == 'Sparkly Joker' and first_card == context.other_card then
                            local pseudo = pseudorandom('sparkly_joker')
                            local prob = G.GAME.probabilities.normal / 4
                            if pseudo < prob then
                                if first_card:get_edition() ~= nil then return nil end
                                local edition = poll_edition('sparkly_joker', nil, true, true)
                                G.E_MANAGER:add_event(Event({
                                    func = (function()
                                        first_card:set_edition(edition, true)
                                        return true
                                    end)
                                }))
                                local color = G.C.MULT
                                if edition ~= nil and edition.foil then color = G.C.CHIPS end
                                return {
                                    extra = { message = localize('k_upgrade_ex'), colour = color },
                                    colour = color,
                                    card = self
                                }
                            else
                                return {
                                    extra = { message = localize('k_nope_ex'), colour = color }
                                }
                            end
                        end

                        if self.ability.name == 'Hiker' then
                    ]]
                    
                    inject("card.lua", "Card:calculate_joker", toReplaceLogic:gsub("([^%w])", "%%%1"), replacementLogic)

                    ------------------------------------------------------
                    sendDebugMessage("Adding texture file for sparkly joker!")

                    local toReplaceAtlas = "{name = 'chips', path = \"resources/textures/\"..self.SETTINGS.GRAPHICS.texture_scaling..\"x/chips.png\",px=29,py=29}"

                    local replacementAtlas = [[
		                {name = 'sparkly_joker', path = "pack/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/j_sparkly.png",px=71,py=95},
                        {name = 'chips', path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/chips.png",px=29,py=29}
                    ]]

                    inject("game.lua", "Game:set_render_settings", toReplaceAtlas:gsub("([^%w])", "%%%1"), replacementAtlas)

                    
                    G:set_render_settings()

                    -------------------------------------------------------
                    sendDebugMessage("Adding sprite draw logic for sparkly joker!")

                    local toReplaceTexLoad = "elseif self.config.center.set == 'Voucher' and not self.config.center.unlocked and not self.params.bypass_discovery_center then"

                    local replacementTexLoad = [[
                        elseif _center.name == 'Sparkly Joker' then
                            self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["sparkly_joker"], j_sparkly)
                        elseif self.config.center.set == 'Voucher' and not self.config.center.unlocked and not self.params.bypass_discovery_center then
                    ]]

                    inject("card.lua", "Card:set_sprites", toReplaceTexLoad:gsub("([^%w])", "%%%1"), replacementTexLoad)

                    -------------------------------------------------------

                    patchedSparkly = true

                    sendDebugMessage("Patched sparkly joker mod!")
                end
            end
        }
)
