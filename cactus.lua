--[[
    X Farming. Extends Minetest farming mod with new plants, crops and ice fishing.
    Copyright (C) 2023 SaKeL <juraj.vajda@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to juraj.vajda@gmail.com
--]] local S = minetest.get_translator(minetest.get_current_modname())

-- Large cactus
minetest.register_decoration({
    name = 'x_farming:large_cactus',
    deco_type = 'schematic',
    place_on = {'default:desert_sand'},
    sidelen = 16,
    noise_params = {
        offset = -0.0003,
        scale = 0.0009,
        spread = {
            x = 200,
            y = 200,
            z = 200
        },
        seed = 230,
        octaves = 3,
        persist = 0.6
    },
    biomes = {'desert'},
    y_max = 48,
    y_min = 4,
    schematic = minetest.get_modpath('x_farming') .. '/schematics/x_farming_large_cactus_new.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random'
})

-- Large cactus legacy
minetest.register_decoration({
    name = 'x_farming:large_cactus',
    deco_type = 'schematic',
    place_on = {'default:desert_sand'},
    sidelen = 16,
    noise_params = {
        offset = -0.0003,
        scale = 0.001,
        spread = {
            x = 250,
            y = 250,
            z = 250
        },
        seed = 230,
        octaves = 3,
        persist = 0.6
    },
    biomes = {'desert'},
    y_max = 64,
    y_min = 28,
    schematic = minetest.get_modpath('x_farming') .. '/schematics/x_farming_large_cactus.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random'
})

minetest.register_decoration({
    name = 'x_farming:huge_cactus',
    deco_type = 'schematic',
    place_on = {'default:desert_sand'},
    sidelen = 16,
    noise_params = {
        offset = -0.0003,
        scale = 0.0009,
        spread = {
            x = 200,
            y = 200,
            z = 200
        },
        seed = 200,
        octaves = 3,
        persist = 0.7
    },
    biomes = {'desert'},
    y_max = 34,
    y_min = 12,
    schematic = minetest.get_modpath('x_farming') .. '/schematics/x_farming_huge_cactus.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random'
})

minetest.register_node('x_farming:cactus', {
    description = S('Cactus'),
    tiles = {'x_farming_cactus_top.png', 'x_farming_cactus_top.png', 'x_farming_cactus.png', 'x_farming_cactus.png',
             'x_farming_cactus.png^[transformFX', 'x_farming_cactus.png^[transformFX'},
	paramtype2 = "wallmounted",
    groups = {
        attached_node = 2,
        thorns = 3,
        cactus = 1,
        -- MTG
        choppy = 3,
        -- X Farming
        compost = 50,
        -- MCL
        handy = 1,
        deco_block = 1,
        dig_by_piston = 1,
        plant = 1,
        enderman_takable = 1,
        compostability = 50
    },
    sounds = x_farming.node_sound_wood_defaults(),
    --on_place = minetest.rotate_node,
	after_dig_node = function(pos, node, metadata, digger)
		default.dig_up(pos, node, digger)
	end,
})

minetest.register_node('x_farming:cactus_fruit', {
    description = S('Dragon Fruit'),
    short_description = S('Dragon Fruit'),
    inventory_image = 'x_farming_cactus_fruit_sides.png',
    is_ground_content = false,
    tiles = {'x_farming_cactus_fruit_top.png', 'x_farming_cactus_fruit_bottom.png', 'x_farming_cactus_fruit_sides.png',
             'x_farming_cactus_fruit_sides.png', 'x_farming_cactus_fruit_sides.png', 'x_farming_cactus_fruit_sides.png'},
    use_texture_alpha = 'clip',
    drawtype = 'nodebox',
    paramtype = 'light',
    node_box = {
        type = 'fixed',
        fixed = {{-0.25, -0.5, -0.25, 0.25, 0.0625, 0.25}}
    },
    selection_box = {
        type = 'fixed',
        fixed = {-0.25, -0.5, -0.25, 0.25, 0.0625, 0.25}
    },
    drop = {
        max_items = 1, -- Maximum number of items to drop.
        items = { -- Choose max_items randomly from this list.
        {
            items = {'x_farming:cactus_fruit_item'}, -- Items to drop.
            rarity = 1 -- Probability of dropping is 1 / rarity.
        }}
    },
    groups = {
        attached_node = 3,
        -- MTG
        choppy = 3,
        flammable = 2,
        not_in_creative_inventory = 1,
        leafdecay = 3,
        leafdecay_drop = 1,
        -- MCL
        handy = 1,
        deco_block = 1,
        dig_by_piston = 1,
        plant = 1,
        enderman_takable = 1,
        compostability = 50
    },
    sounds = x_farming.node_sound_wood_defaults(),
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if oldnode.param2 == 20 then
            minetest.set_node(pos, {
                name = 'x_farming:cactus_fruit_mark'
            })
            minetest.get_node_timer(pos):start(math.random(300, 1500))
        else
            local n = minetest.get_node({
                x = pos.x,
                y = pos.y - 1,
                z = pos.z
            })
            if n.name ~= 'default:cactus' then
                minetest.remove_node(pos)
            elseif minetest.get_node_light(pos) < 11 then
                minetest.get_node_timer(pos):start(200)
            elseif oldnode.param2 ~= 1 then
                minetest.set_node(pos, {
                    name = 'x_farming:cactus_fruit_mark'
                })
                minetest.get_node_timer(pos):start(math.random(30, 500))
                minetest.log("action", "Placing missing cactus fruit mark at: " .. minetest.pos_to_string(pos))
            end
        end
    end
})

minetest.register_node('x_farming:cactus_fruit_mark', {
    description = S('Cactus Fruit Marker'),
    short_description = S('Cactus Fruit Marker'),
    inventory_image = 'x_farming_cactus_fruit_sides.png^x_farming_invisible_node_overlay.png',
    wield_image = 'x_farming_cactus_fruit_sides.png^x_farming_invisible_node_overlay.png',
    drawtype = 'airlike',
    paramtype = 'light',
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    drop = '',
    groups = {
        not_in_creative_inventory = 1,
        attached_node = 3
    },
    on_timer = function(pos, elapsed)
        local n = minetest.get_node(pos)
        if n.name ~= 'default:cactus' or n.name ~= 'x_farming:cactus' then
            minetest.remove_node(pos)
        elseif minetest.get_node_light(pos) < 11 then
            minetest.get_node_timer(pos):start(200)
        else
            minetest.set_node(pos, {
                name = 'x_farming:cactus_fruit',
                param2 = 20
            })
        end
    end
})

--  Fruit Item

local cactus_fruit_item_def = {
    description = S('Dragon Fruit') .. '\n' .. S('Compost chance') .. ': 65%\n' ..
        minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 2'),
    short_description = S('Dragon Fruit'),
    drawtype = 'plantlike',
    tiles = {'x_farming_cactus_fruit_item.png'},
    inventory_image = 'x_farming_cactus_fruit_item.png',
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then
            return itemstack
        end
        return minetest.item_eat(hunger_amount)(itemstack, user, pointed_thing)
    end,
    sounds = default.node_sound_leaves_defaults(),
    groups = {
        hunger_amount = 2,
        -- X Farming
        compost = 65,
        -- MCL
        food = 2,
        eatable = 1,
        compostability = 65
    },
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        minetest.set_node(pos, {
            name = 'x_farming:cactus_fruit',
            param2 = 1
        })
    end
}

minetest.register_node('x_farming:cactus_fruit_item', cactus_fruit_item_def)

minetest.register_node('x_farming:large_cactus_with_fruit_seedling', {
    description = S('Large Cactus with Fruit Seedling') .. '\n' .. S('Compost chance') .. ': 30%',
    short_description = S('Large Cactus with Fruit Seedling'),
    drawtype = 'plantlike',
    tiles = {'x_farming_large_cactus_with_fruit_seedling.png'},
    inventory_image = 'x_farming_large_cactus_with_fruit_seedling.png',
    wield_image = 'x_farming_large_cactus_with_fruit_seedling.png',
    paramtype = 'light',
    sunlight_propagates = true,
    walkable = false,
    selection_box = {
        type = 'fixed',
        fixed = {-5 / 16, -0.5, -5 / 16, 5 / 16, 0.5, 5 / 16}
    },
    groups = {
        thorns = 1,
        -- MTG
        choppy = 3,
        dig_immediate = 3,
        attached_node = 1,
        compost = 30,
        -- MCL
        handy = 1,
        deco_block = 1,
        dig_by_piston = 1,
        compostability = 30
    },
    sounds = x_farming.node_sound_wood_defaults(),
    on_place = function(itemstack, placer, pointed_thing)
        itemstack = x_farming.sapling_on_place(itemstack, placer, pointed_thing,
            'x_farming:large_cactus_with_fruit_seedling', {
                x = -3,
                y = 0,
                z = -3
            }, {
                x = 3,
                y = 6,
                z = 3
            }, 4)

        return itemstack
    end,
    on_construct = function(pos)
        -- Normal cactus farming adds 1 cactus node by ABM,
        -- interval 12s, chance 83.
        -- Consider starting with 5 cactus nodes. We make sure that growing a
        -- large cactus is not a faster way to produce new cactus nodes.
        -- Confirmed by experiment, when farming 5 cacti, on average 1 new
        -- cactus node is added on average every
        -- 83 / 5 = 16.6 intervals = 16.6 * 12 = 199.2s.
        -- Large cactus contains on average 14 cactus nodes.
        -- 14 * 199.2 = 2788.8s.
        -- Set random range to average to 2789s.
        minetest.get_node_timer(pos):start(math.random(1859, 3719))
    end,
    on_timer = function(pos, elapsed)
        local node_under = minetest.get_node_or_nil({
            x = pos.x,
            y = pos.y - 1,
            z = pos.z
        })
        if not node_under then
            -- Node under not yet loaded, try later
            minetest.get_node_timer(pos):start(300)
            return
        end

        if minetest.get_item_group(node_under.name, 'sand') == 0 then
            -- Seedling dies
            minetest.remove_node(pos)
            return
        end

        local light_level = minetest.get_node_light(pos)
        if not light_level or light_level < 13 then
            -- Too dark for growth, try later in case it's night
            minetest.get_node_timer(pos):start(300)
            return
        end

        minetest.log('action',
            'A large cactus seedling grows into a large' .. 'cactus at ' .. minetest.pos_to_string(pos))
        x_farming.grow_large_cactus(pos)
    end
})

x_farming.register_leafdecay({
    trunks = {'x_farming:cactus'},
    leaves = {'x_farming:cactus_fruit'},
    radius = 1
})

minetest.register_craft({
    output = 'x_farming:large_cactus_with_fruit_seedling',
    recipe = {{'', 'x_farming:cactus_fruit_item', ''},
              {'x_farming:cactus_fruit_item', 'group:cactus', 'x_farming:cactus_fruit_item'},
              {'', 'x_farming:cactus_fruit_item', ''}}
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'x_farming:large_cactus_with_fruit_seedling',
    burntime = 5
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'x_farming:cactus_fruit_item',
    burntime = 10
})

---crate
x_farming.register_crate('crate_cactus_fruit_item_3', {
    description = S('Cactus Fruit Crate'),
    short_description = S('Cactus Fruit Crate'),
    tiles = {'x_farming_crate_cactus_fruit_item_3.png'},
    _custom = {
        crate_item = 'x_farming:cactus_fruit_item'
    }
})

-- cactus damage
local function calculate_damage_multiplier(object)
    local ag = object.get_armor_groups and object:get_armor_groups()
    if not ag then
        return 0
    end
    if ag.immortal and ag.immortal > 0 then
        return 0
    end
    local ent = object:get_luaentity()
    if ent and ent.immortal then
        return 0
    end
    if ag.fleshy then
        return 0.01 * ag.fleshy
    end
    if ag.fleshy then
        return math.sqrt(0.01 * ag.fleshy)
    end
    return 0
end

local function apply_fractional_damage(o, dmg)
    local dmg_int = math.floor(dmg)
    -- The closer you are to getting one more damage point,
    -- the more likely it will be added.
    if math.random() < dmg - dmg_int then
        dmg_int = dmg_int + 1
    end
    if dmg_int > 0 then
        local new_hp = math.max(o:get_hp() - dmg_int, 0)
        o:set_hp(new_hp)
        return new_hp == 0
    end
    return false
end

local function calculate_object_center(object)
    if object:is_player() then
        return {
            x = 0,
            y = 1,
            z = 0
        }
    end
    return {
        x = 0,
        y = 0.5,
        z = 0
    }
end

local function dmg_object(pos, object, strength)
    -- local obj_pos = vector.add(object:get_pos(), calculate_object_center(object))
    local mul = calculate_damage_multiplier(object)
    local dmg = math.random(0.25, 1.0)
    if not dmg then
        return
    end
    -- abort if blocked
    if mul == 0 then
        return
    end
    apply_fractional_damage(object, dmg * mul)
end

minetest.register_abm({
    nodenames = {"group:thorns"},
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local strength = minetest.get_item_group(node.name, "thorns")
        local thorns_dmg_mult_sqrt = math.sqrt(1 / 0.2)
        local max_dist = math.min(0.375, strength * thorns_dmg_mult_sqrt)
        local abdomen_offset = 1;
        for _, o in pairs(minetest.get_objects_inside_radius(pos, max_dist + abdomen_offset)) do
            if o ~= nil and o:get_hp() > 0 then
                dmg_object(pos, o, strength)
            end
        end
    end
})

minetest.register_on_mods_loaded(function()
    local deco_place_on = {}
    local deco_biomes = {}

    -- MTG
    if minetest.get_modpath('default') then
        table.insert(deco_place_on, 'default:desert_sand')
        table.insert(deco_biomes, 'desert')
    end

    -- Everness
    if minetest.get_modpath('everness') then
        table.insert(deco_place_on, 'everness:forsaken_desert_sand')
        table.insert(deco_biomes, 'everness_forsaken_desert')
    end

    -- MCL
    if minetest.get_modpath('mcl_core') then
        table.insert(deco_place_on, 'mcl_core:sand')
        table.insert(deco_biomes, 'Desert')
    end

    if next(deco_place_on) and next(deco_biomes) then
        minetest.register_decoration({
            name = 'x_farming:large_cactus',
            deco_type = 'schematic',
            place_on = deco_place_on,
            sidelen = 16,
            noise_params = {
                offset = -0.0003,
                scale = 0.0009,
                spread = {
                    x = 200,
                    y = 200,
                    z = 200
                },
                seed = 230,
                octaves = 3,
                persist = 0.6
            },
            biomes = deco_biomes,
            y_max = 31000,
            y_min = 4,
            schematic = minetest.get_modpath('x_farming') .. '/schematics/x_farming_large_cactus.mts',
            flags = 'place_center_x, place_center_z',
            rotation = 'random'
        })
    end
end)
