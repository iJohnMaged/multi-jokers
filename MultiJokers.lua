--- STEAMODDED HEADER
--- MOD_NAME: MultiJokersMod
--- MOD_ID: MultiJokersMod
--- MOD_AUTHOR: [John Maged, Multi, GoldenEpsilon]
--- MOD_DESCRIPTION: Adds a couple of custom jokers to the game.

----------------------------------------------
------------MOD CODE -------------------------

local MOD_ID = "MultiJokersMod";

-- Thanks GoldenEpsilon!
-- https://github.com/GoldenEpsilon/ShamPack/blob/main/ShamPack.lua
local set_spritesref = Card.set_sprites
function Card:set_sprites(_center, _front)
    set_spritesref(self, _center, _front);
    if _center then
        if _center.set then
            if (_center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher') and _center.atlas then
                self.children.center.atlas = G.ASSET_ATLAS
                    [(_center.atlas or (_center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher') and _center.set) or 'centers']
                self.children.center:set_sprite_pos(_center.pos)
            end
        end
    end
end

-- https://github.com/GoldenEpsilon/ShamPack/blob/main/ShamPack.lua
function add_item(mod_id, pool, id, data, desc)
    -- Add Sprite
    data.pos = { x = 0, y = 0 };
    data.key = id;
    data.atlas = mod_id .. id;
    SMODS.Sprite:new(mod_id .. id, SMODS.findModByID(mod_id).path, id .. ".png", 71, 95, "asset_atli"):register();

    data.key = id
    data.order = #G.P_CENTER_POOLS[pool] + 1
    G.P_CENTERS[id] = data
    table.insert(G.P_CENTER_POOLS[pool], data)

    if pool == "Joker" then
        table.insert(G.P_JOKER_RARITY_POOLS[data.rarity], data)
    end

    G.localization.descriptions[pool][id] = desc;
end

-- https://github.com/GoldenEpsilon/ShamPack/blob/main/ShamPack.lua
function refresh_items()
    for k, v in pairs(G.P_CENTER_POOLS) do
        table.sort(v, function(a, b) return a.order < b.order end)
    end

    -- Update localization
    for g_k, group in pairs(G.localization) do
        if g_k == 'descriptions' then
            for _, set in pairs(group) do
                for _, center in pairs(set) do
                    center.text_parsed = {}
                    for _, line in ipairs(center.text) do
                        center.text_parsed[#center.text_parsed + 1] = loc_parse_string(line)
                    end
                    center.name_parsed = {}
                    for _, line in ipairs(type(center.name) == 'table' and center.name or { center.name }) do
                        center.name_parsed[#center.name_parsed + 1] = loc_parse_string(line)
                    end
                    if center.unlock then
                        center.unlock_parsed = {}
                        for _, line in ipairs(center.unlock) do
                            center.unlock_parsed[#center.unlock_parsed + 1] = loc_parse_string(line)
                        end
                    end
                end
            end
        end
    end

    for k, v in pairs(G.P_JOKER_RARITY_POOLS) do
        table.sort(G.P_JOKER_RARITY_POOLS[k], function(a, b) return a.order < b.order end)
    end
end

function SMODS.INIT.MultiJokersMod()
    add_item(MOD_ID, "Joker", "j_math_homework", {
        unlocked = true,
        discovered = true,
        rarity = 1,
        cost = 4,
        name = "Math Homework",
        set = "Joker",
        config = {
            extra = { mult = 15 },
        },
    }, {
        name = "Math Homework",
        text = {
            "{C:red}+15{} Mult if played hand",
            "contains only",
            "{C:attention}numbered Cards{}"
        }
    });

    add_item(MOD_ID, "Joker", "j_collectors_item", {
        unlocked = true,
        discovered = true,
        rarity = 2,
        cost = 5,
        name = "Collector's Item",
        set = "Joker",
        config = {
            extra = 10,
        },
    }, {
        name = "Collector's Item",
        text = {
            "{C:blue}+10{} Chips for every",
            "unique {C:attention}Joker{}",
            "owned this run",
            "{C:inactive}(Currently {C:blue}+#1#{C:inactive})"
        }
    });

    add_item(MOD_ID, "Joker", "j_incremental", {
        unlocked = true,
        discovered = true,
        rarity = 2,
        cost = 5,
        name = "Incremental Joker",
        set = "Joker",
        config = {
            extra = {
                x_mult = 1
            },
        },
    }, {
        name = "Incremental Joker",
        text = {
            "{C:red}x1{} Mult gains {C:red}x0.1{}",
            "at end of round",
            "{C:inactive}(Currently {C:red}x#1#{C:inactive})"
        }
    });

    add_item(MOD_ID, "Joker", "j_sparkly", {
        unlocked = true,
        discovered = true,
        rarity = 2,
        cost = 5,
        name = "Sparkly Joker",
        set = "Joker",
        config = {
            extra = 4
        },
    }, {
        name = "Sparkly Joker",
        text = {
            "{C:green}1 in 4{} chances to",
            "add a random {C:attention}edition{} to",
            "first played card of each hand"
        }
    });

    add_item(MOD_ID, "Joker", "j_lottery_ticket", {
        unlocked = true,
        discovered = true,
        rarity = 2,
        cost = 5,
        name = "Lottery Ticket",
        set = "Joker",
        config = {
            extra = 4
        },
    }, {
        name = "Lottery Ticket",
        text = {
            "Jokers' sell value changes",
            "randomly every round",
        }
    });


    -- Apply our changes
    refresh_items();
end

function table_length(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local calculate_jokerref = Card.calculate_joker;
function Card:calculate_joker(context)
    local ret_val = calculate_jokerref(self, context);
    if self.ability.set == "Joker" and not self.debuff then
        if context.individual then
            if context.cardarea == G.play then
                local first_card = context.scoring_hand[1]
                if self.ability.name == 'Sparkly Joker' and first_card == context.other_card then
                    if pseudorandom('sparkly_joker') < G.GAME.probabilities.normal / self.ability.extra then
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
                    end
                end
            end
        end
        if context.cardarea == G.jokers then
            if context.before then end
            if context.joker_main then
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
                if self.ability.name == "Collector's Item" then
                    if G.GAME[MOD_ID .. "unique_jokers_owned"] then
                        local unique_jokers_owned = table_length(G.GAME[MOD_ID .. "unique_jokers_owned"])
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
            end
        end
        if context.end_of_round then
            if context.individual then
            elseif context.repetition then
            elseif not context.blueprint then
                if self.ability.name == 'Incremental Joker' then
                    self.ability.extra.x_mult = self.ability.extra.x_mult + 0.1
                    return {
                        message = localize('k_upgrade_ex'),
                        colour = G.C.RED
                    }
                end
                if self.ability.name == "Lottery Ticket" then
                    for i = 1, #G.jokers.cards do
                        local joker = G.jokers.cards[i]
                        local original_sell_cost = math.max(1, math.floor(joker.cost / 2)) +
                            (joker.ability.extra_value or 0)
                        joker.sell_cost = pseudorandom('lottery_ticket', 1, 3 * original_sell_cost)
                    end
                end
            end
        end
        if context.selling_self then
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
        end
    end
    return ret_val;
end

local add_to_deck_ref = Card.add_to_deck
function Card:add_to_deck()
    if G.GAME and self.ability.set == "Joker" then
        if G.GAME[MOD_ID .. "unique_jokers_owned"] == nil then
            G.GAME[MOD_ID .. "unique_jokers_owned"] = {}
        end
        G.GAME[MOD_ID .. "unique_jokers_owned"][self.ability.name] = true
    end
    return add_to_deck_ref(self)
end

local card_uiref = Card.generate_UIBox_ability_table;
function Card:generate_UIBox_ability_table()
    local badges = {}
    local card_type = self.ability.set or "None"
    local loc_vars = nil

    if self.ability.name == 'Incremental Joker' then
        loc_vars = { self.ability.extra.x_mult }
    end
    if self.ability.name == "Collector's Item" then
        if G.GAME[MOD_ID .. "unique_jokers_owned"] then
            local unique_jokers_owned = table_length(G.GAME[MOD_ID .. "unique_jokers_owned"])
            loc_vars = { unique_jokers_owned * self.ability.extra }
        else
        loc_vars = { 0 }
        end
    end

    if (card_type ~= 'Locked' and card_type ~= 'Undiscovered' and card_type ~= 'Default') or self.debuff then
        badges.card_type = card_type
    end
    if self.ability.set == 'Joker' and self.bypass_discovery_ui then
        badges.force_rarity = true
    end
    if self.edition then
        if self.edition.type == 'negative' and self.ability.consumeable then
            badges[#badges + 1] = 'negative_consumable'
        else
            badges[#badges + 1] = (self.edition.type == 'holo' and 'holographic' or self.edition.type)
        end
    end
    if self.seal then badges[#badges + 1] = string.lower(self.seal) .. '_seal' end
    if self.ability.eternal then badges[#badges + 1] = 'eternal' end
    if self.pinned then badges[#badges + 1] = 'pinned_left' end

    if self.sticker then
        loc_vars = loc_vars or {}; loc_vars.sticker = self.sticker
    end

    if self.ability.name == 'Incremental Joker' or self.ability.name == "Collector's Item" then
        return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, false, nil, nil)
    end

    return card_uiref(self)
end


----------------------------------------------
------------MOD CODE END----------------------
