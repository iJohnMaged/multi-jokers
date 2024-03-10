patchedMathHomework = false
jokerHook = initJokerHook()

if (sendDebugMessage == nil) then
    sendDebugMessage = function(_)
    end
end

table.insert(mods,
            {
            mod_id = "math_homework",
            name = "Math Homework",
            version = "0.1",
            author = "John Maged & Kyu",
            description = {
                "Adds the \"Math Homework\" Joker"
            },
            enabled = true,
            on_post_update = function() 
                if not patchedMathHomework then
                    
                    -----------------------------------------
                    sendDebugMessage("Adding math homework to centers!")

                    jokerHook.addJoker(self, "j_math_homework", "Math Homework", nil, true, 4, { x = 0, y = 0 }, nil, {extra = {mult = 15}}, {"{C:red}+15{} Mult if played hand", "contains only", "{C:attention}numbered Cards{}"}, 1, true, true)

                    ---------------------------------------------
                    sendDebugMessage("Inserting math_homework into calculate_joker!")
                    
                    local toReplaceLogic = "if self.ability.name == '8 Ball' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then"

                    local replacementLogic = [[
                        if self.ability.name == 'Math Homework' then
                            local onlyNumbered = true
                            for k, v in ipairs(context.full_hand) do
                                onlyNumbered = onlyNumbered and ((v.base.id >= 2 and v.base.id <= 10) or v.base.id == 14)
                            end
                            if not onlyNumbered then
                                return nil
                            end
                            return {
                                mult_mod = self.ability.extra.mult,
                                message = localize { type = 'variable', key = 'a_mult', vars = { self.ability.extra.mult } },
                                card = self,
                            }
                        end

                        if self.ability.name == '8 Ball' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    ]]
                    
                    inject("card.lua", "Card:calculate_joker", toReplaceLogic:gsub("([^%w])", "%%%1"), replacementLogic)

                    ------------------------------------------
                    sendDebugMessage("Adding texture file for math homework!")

                    local toReplaceAtlas = "{name = 'chips', path = \"resources/textures/\"..self.SETTINGS.GRAPHICS.texture_scaling..\"x/chips.png\",px=29,py=29}"

                    local replacementAtlas = [[
		                {name = 'math_homework', path = "pack/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/j_math_homework.png",px=71,py=95},
                        {name = 'chips', path = "resources/textures/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/chips.png",px=29,py=29}
                    ]]

                    inject("game.lua", "Game:set_render_settings", toReplaceAtlas:gsub("([^%w])", "%%%1"), replacementAtlas)


                    G:set_render_settings()

                    -------------------------------------------------------
                    sendDebugMessage("Adding sprite draw logic for math homework!")

                    local toReplaceTexLoad = "elseif self.config.center.set == 'Voucher' and not self.config.center.unlocked and not self.params.bypass_discovery_center then"

                    local replacementTexLoad = [[
                        elseif _center.name == 'Math Homework' then
                            self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["math_homework"], j_math_homework)
                        elseif self.config.center.set == 'Voucher' and not self.config.center.unlocked and not self.params.bypass_discovery_center then
                    ]]

                    inject("card.lua", "Card:set_sprites", toReplaceTexLoad:gsub("([^%w])", "%%%1"), replacementTexLoad)

                    -------------------------------------------------------

                    patchedMathHomework = true

                    sendDebugMessage("Patched math homework mod!")
                end
            end
        }
)
