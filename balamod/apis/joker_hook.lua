-- This code is temporary and a glance into what arachnei is working on at the moment.
-- Once they release their center hook api, i will remove this api here

mod_id = "joker_hook"
mod_name = "Joker Hook"
mod_version = "0.1"
mod_author = "arachnei"
function initJokerHook()
    local jokerHook = {}

    function jokerHook:addJoker(id, name, order, discovered, cost, pos, effect, config, desc, rarity, unlocked, blueprint_compat)
        --defaults
        id = id or "j_Joker_Placeholder" .. #G.P_CENTER_POOLS["Joker"] + 1
        name = name or "Joker Placeholder"
        order = order or #G.P_CENTER_POOLS["Joker"] + 1
        discovered = discovered or true
        cost = cost or 4
        pos = pos or { x = 0, y = 9 } --slutty sprite
        effect = effect or ""
        config = config or {}
        desc = desc or {"Placeholder"}
        rarity = rarity or 1
        unlocked = unlocked or true
        blueprint_compat = blueprint_compat or false
    
        --joker object
        local newJoker = {
            order = order,
            discovered = discovered,
            cost = cost,
            name = name,
            pos = pos,
            set = "Joker",
            config = config,
            key = id, 
            rarity = rarity, 
            unlocked = unlocked, 
            blueprint_compat = blueprint_compat,
            alerted = true
        }
    
        --add it to all the game tables
        table.insert(G.P_CENTER_POOLS["Joker"], newJoker)
        G.P_CENTERS[id] = newJoker
        table.insert(G.P_JOKER_RARITY_POOLS[rarity], newJoker)
        --table.insert(G.shop_jokers, newJoker)
    
        --add name + description to the localization object
        local newJokerText = {name=name, text=desc, text_parsed={}, name_parsed={}}
        for _, line in ipairs(desc) do
            newJokerText.text_parsed[#newJokerText.text_parsed+1] = loc_parse_string(line)
        end

        for _, line in ipairs(type(newJokerText.name) == 'table' and newJokerText.name or {newJoker.name}) do
            newJokerText.name_parsed[#newJokerText.name_parsed+1] = loc_parse_string(line)
        end
        
        G.localization.descriptions.Joker[id] = newJokerText

        return newJoker, newJokerText
    end

    return jokerHook
end