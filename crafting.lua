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
--]]
--
-- Crafting recipes & items
--

local S = minetest.get_translator(minetest.get_current_modname())

-- Cocoa
minetest.register_craft({
    output = 'dye:brown',
    recipe = {
        { 'x_farming:cocoa_bean' },
    }
})

minetest.register_craftitem('x_farming:cookie', {
    description = S('Cookie') .. '\n' .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 2'),
    inventory_image = 'x_farming_cookie.png',
    groups = { compost = 85, hunger_amount = 2 },
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then
            return itemstack
        end
        return minetest.item_eat(hunger_amount)(itemstack, user, pointed_thing)
    end,
})

minetest.register_craft({
    type = 'shapeless',
    output = 'x_farming:cookie 8',
    recipe = { 'farming:wheat', 'x_farming:cocoa_bean', 'farming:flour', 'x_farming:bottle_soymilk', 'group:food_sugar' }
})

minetest.register_craftitem('x_farming:chocolate', {
    description = S('Chocolate') .. '\n' .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 3'),
    inventory_image = 'x_farming_chocolate.png',
    groups = { compost = 65, hunger_amount = 3 },
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then
            return itemstack
        end
        return minetest.item_eat(hunger_amount)(itemstack, user, pointed_thing)
    end,
})

minetest.register_craft({
    output = 'x_farming:chocolate',
    recipe = {
        { '',              '',                     'x_farming:cocoa_bean' },
        { '',              'x_farming:cocoa_bean', '' },
        { 'default:paper', '',                     '' },
    }
})

-- Soup Bowl
minetest.register_craftitem('x_farming:bowl', {
    description = S('Empty Soup Bowl'),
    inventory_image = 'x_farming_bowl.png',
})

minetest.register_craft({
    output = 'x_farming:bowl 3',
    recipe = {
        { 'group:wood', '',           'group:wood' },
        { '',           'group:wood', '' }
    }
})


-- fish stew
minetest.register_craft({
    output = 'x_farming:fish_stew',
    recipe = {
        { '',                 'group:fish',            '' },
        { 'x_farming:carrot', 'x_farming:bakedpotato', 'group:food_salt' },
        { '',                 'x_farming:bowl',        '' }
    }
})

minetest.register_craft({
    output = 'x_farming:beetroot_soup',
    recipe = {
        { 'x_farming:beetroot', 'x_farming:beetroot', 'x_farming:beetroot' },
        { 'x_farming:beetroot', 'x_farming:beetroot', 'x_farming:beetroot' },
        { '',                   'x_farming:bowl',     '' }
    }
})

-- Carrot
local golden_carrot_desc = S('Golden Carrot') .. '\n' .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 10')

if x_farming.hbhunger ~= nil then
    golden_carrot_desc = golden_carrot_desc .. '\n' .. minetest.colorize(x_farming.colors.red, S('Heal') .. ': 10')
end

minetest.register_craftitem('x_farming:carrot_golden', {
    description = golden_carrot_desc,
    inventory_image = 'x_farming_carrot_golden.png',
    wield_image = 'x_farming_carrot_golden.png^[transformR270',
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then
            return itemstack
        end
        return minetest.item_eat(hunger_amount)(itemstack, user, pointed_thing)
    end,
    groups = {
        hunger_amount = 10
    }
})

minetest.register_craft({
    output = 'x_farming:carrot_golden',
    recipe = {
        { 'default:gold_lump', 'default:gold_lump', 'default:gold_lump' },
        { 'default:gold_lump', 'x_farming:carrot',  'default:gold_lump' },
        { 'default:gold_lump', 'default:gold_lump', 'default:gold_lump' }
    },
})

-- Coffee
minetest.register_craftitem('x_farming:bottle_coffee', {
    description = S('Coffee Bottle'),
    tiles = { 'x_farming_bottle_coffee.png' },
    inventory_image = 'x_farming_bottle_coffee.png',
    wield_image = 'x_farming_bottle_coffee.png',
    groups = { vessel = 1 },
})

minetest.register_craft({
    type = 'shapeless',
    output = 'x_farming:bottle_coffee',
    recipe = { 'x_farming:coffee', 'group:food_water' }
})

if x_farming.vessels then
    minetest.register_craft({
        type = 'cooking',
        cooktime = 7,
        output = 'x_farming:coffee_cup_hot',
        recipe = 'x_farming:bottle_coffee',
        replacements = { { 'x_farming:bottle_coffee', 'vessels:glass_bottle' } }
    })
else
    minetest.register_craft({
        type = 'cooking',
        cooktime = 7,
        output = 'x_farming:coffee_cup_hot',
        recipe = 'x_farming:bottle_coffee',
        replacements = { { 'x_farming:bottle_coffee', 'x_farming:glass_bottle' } }
    })
end

-- backwards compatibility
minetest.register_alias('x_farming:coffee_cup', 'x_farming:bottle_coffee')

-- Corn
minetest.register_craftitem('x_farming:corn_pop', {
    description = S('Popped corn') .. '\n' .. S('Compost chance') .. ': 50%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 1'),
    short_description = S('Popped corn'),
    inventory_image = 'x_farming_corn_pop.png',
    groups = { compost = 50, hunger_amount = 1 },
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then
            return itemstack
        end
        return minetest.item_eat(hunger_amount)(itemstack, user, pointed_thing)
    end,
})

minetest.register_craft({
    type = 'cooking',
    cooktime = 10,
    output = 'x_farming:corn_pop',
    recipe = 'x_farming:corn'
})

minetest.register_craft({
    output = 'x_farming:corn_popcorn',
    recipe = {
        { 'x_farming:corn_pop', 'x_farming:corn_pop', 'x_farming:corn_pop' },
        { 'default:paper',      'group:food_salt',    'default:paper' },
        { 'default:paper',      'default:paper',      'default:paper' },
    }
})

-- Melon
local golden_melon_desc = S('Golden Melon') .. '\n' .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 10')

if x_farming.hbhunger ~= nil then
    golden_melon_desc = golden_melon_desc .. '\n' .. minetest.colorize(x_farming.colors.red, S('Heal') .. ': 10')
end

minetest.register_craftitem('x_farming:golden_melon', {
    description = golden_melon_desc,
    inventory_image = 'x_farming_golden_melon.png',
    wield_image = 'x_farming_golden_melon.png^[transformR90',
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then
            return itemstack
        end
        return minetest.item_eat(hunger_amount)(itemstack, user, pointed_thing)
    end,
    groups = {
        hunger_amount = 10
    }
})

minetest.register_craft({
    output = 'x_farming:golden_melon',
    recipe = {
        { 'default:gold_lump', 'default:gold_lump', 'default:gold_lump' },
        { 'default:gold_lump', 'x_farming:melon',   'default:gold_lump' },
        { 'default:gold_lump', 'default:gold_lump', 'default:gold_lump' }
    },
})

minetest.register_craft({
    output = 'x_farming:melon_block',
    recipe = {
        { 'x_farming:melon', 'x_farming:melon', 'x_farming:melon' },
        { 'x_farming:melon', 'x_farming:melon', 'x_farming:melon' },
        { 'x_farming:melon', 'x_farming:melon', 'x_farming:melon' }
    },
})

-- Obsidian Wart
minetest.register_craftitem('x_farming:wart_brick', {
    description = S('Wart Brick'),
    inventory_image = 'x_farming_wart_brick.png',
})

minetest.register_craft({
    type = 'cooking',
    cooktime = 10,
    output = 'x_farming:wart_brick',
    recipe = 'x_farming:obsidian_wart'
})

minetest.register_craft({
    output = 'x_farming:wart_block',
    groups = { compost = 85 },
    recipe = {
        { 'x_farming:obsidian_wart', 'x_farming:obsidian_wart', 'x_farming:obsidian_wart' },
        { 'x_farming:obsidian_wart', 'x_farming:obsidian_wart', 'x_farming:obsidian_wart' },
        { 'x_farming:obsidian_wart', 'x_farming:obsidian_wart', 'x_farming:obsidian_wart' }
    }
})

minetest.register_craft({
    output = 'x_farming:wart_brick_block',
    recipe = {
        { 'x_farming:wart_brick', 'x_farming:wart_brick', '' },
        { 'x_farming:wart_brick', 'x_farming:wart_brick', '' }
    }
})

minetest.register_craft({
    output = 'x_farming:wart_red_brick_block',
    recipe = {
        { 'x_farming:obsidian_wart', 'x_farming:wart_brick',    '' },
        { 'x_farming:wart_brick',    'x_farming:obsidian_wart', '' }
    },
})

minetest.register_craft({
    output = 'x_farming:wartrack 4',
    recipe = {
        { 'x_farming:wart_block', 'x_farming:wart_block', '' },
        { 'x_farming:wart_block', 'x_farming:wart_block', '' }
    },
})

-- Potato
minetest.register_craftitem('x_farming:bakedpotato', {
    description = S('Baked Potato') .. '\n' .. S('Compost chance') .. ': 85%\n'
        .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': 6'),
    short_description = S('Baked Potato'),
    groups = { compost = 85, hunger_amount = 6 },
    inventory_image = 'x_farming_potato_baked.png',
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then
            return itemstack
        end
        return minetest.item_eat(hunger_amount)(itemstack, user, pointed_thing)
    end,
})

local poisonouspotato_desc = S('Poisonous Potato') .. '\n'
    .. minetest.colorize(x_farming.colors.brown, S('Hunger') .. ': -6')

if x_farming.hbhunger ~= nil then
    poisonouspotato_desc = poisonouspotato_desc .. '\n'
        .. minetest.colorize(x_farming.colors.green, S('Poison') .. ': 5')
end

minetest.register_craftitem('x_farming:poisonouspotato', {
    description = poisonouspotato_desc,
    inventory_image = 'x_farming_potato_poisonous.png',
    on_use = function(itemstack, user, pointed_thing)
        local hunger_amount = minetest.get_item_group(itemstack:get_name(), "hunger_amount") or 0
        if hunger_amount == 0 then
            return itemstack
        end
        return minetest.item_eat(hunger_amount)(itemstack, user, pointed_thing)
    end,
    groups = {
        hunger_amount = -6
    }
})

minetest.register_craft({
    type = 'cooking',
    cooktime = 10,
    output = 'x_farming:bakedpotato',
    recipe = 'x_farming:potato'
})

-- Pumpkin
-- pumpkin lantern recipe
minetest.register_craft({
    output = 'x_farming:pumpkin_lantern',
    recipe = {
        { '', '',                        '' },
        { '', 'x_farming:pumpkin_block', '' },
        { '', 'default:torch',           '' }
    },
})

-- pumpkin pie crafting recipe
minetest.register_craft({
    type = 'shapeless',
    output = 'x_farming:pumpkin_pie',
    recipe = { 'x_farming:pumpkin_block', 'farming:flour', 'x_farming:bottle_soymilk', 'group:food_sugar' }
})

-- pumpkin as fuel (better than cactus)
minetest.register_craft({
    type = 'fuel',
    recipe = 'x_farming:pumpkin_block',
    burntime = 20,
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'x_farming:pumpkin_lantern',
    burntime = 20,
})

-- Bottle Water
minetest.register_craftitem('x_farming:bottle_water', {
    description = S('Water Bottle'),
    tiles = { 'x_farming_bottle_water.png' },
    inventory_image = 'x_farming_bottle_water.png',
    wield_image = 'x_farming_bottle_water.png',
    groups = { vessel = 1, food_water = 1 },
})

if x_farming.vessels then
    minetest.register_craft({
        type = 'shapeless',
        output = 'x_farming:bottle_water 5',
        recipe = {
            'vessels:glass_bottle', 'vessels:glass_bottle', 'vessels:glass_bottle',
            'vessels:glass_bottle', 'vessels:glass_bottle', 'bucket:bucket_water'
        },
        replacements = { { 'bucket:water_bucket', 'bucket:bucket_empty' } },
    })

    --minetest.register_craft({
    --    type = 'shapeless',
    --    output = 'x_farming:bottle_water 5',
    --    recipe = {
    --        'vessels:glass_bottle', 'vessels:glass_bottle', 'vessels:glass_bottle',
    --        'vessels:glass_bottle', 'vessels:glass_bottle', 'x_farming:seed_salt'
    --    },
    --    replacements = { { 'x_farming:seed_salt', 'x_farming:seed_salt' } },
    --})
else
    minetest.register_craft({
        type = 'shapeless',
        output = 'x_farming:bottle_water 5',
        recipe = {
            'x_farming:glass_bottle', 'x_farming:glass_bottle', 'x_farming:glass_bottle',
            'x_farming:glass_bottle', 'x_farming:glass_bottle', 'bucket:bucket_water'
        },
        replacements = { { 'bucket:water_bucket', 'bucket:bucket_empty' } },
    })

    --minetest.register_craft({
    --    type = 'shapeless',
    --    output = 'x_farming:bottle_water 5',
    --    recipe = {
    --        'x_farming:glass_bottle', 'x_farming:glass_bottle', 'x_farming:glass_bottle',
    --        'x_farming:glass_bottle', 'x_farming:glass_bottle', 'x_farming:seed_salt'
    --    },
    --    replacements = { { 'x_farming:seed_salt', 'x_farming:seed_salt' } },
    --})
end

-- Donuts
minetest.register_craft({
    type = 'shapeless',
    output = 'x_farming:donut',
    recipe = { 'x_farming:bottle_soymilk', 'group:food_sugar', 'farming:flour' }
})

minetest.register_craft({
    type = 'shapeless',
    output = 'x_farming:donut_chocolate',
    recipe = { 'x_farming:bottle_soymilk', 'group:food_sugar', 'farming:flour', 'x_farming:cocoa_bean' }
})

-- Fries

minetest.register_craft({
    output = 'x_farming:fries',
    recipe = {
        { '',              '',                      'group:food_salt' },
        { '',              'x_farming:bakedpotato', '' },
        { 'default:paper', '',                      '' }
    },
})

-- Ice Fishing

minetest.register_craft({
    output = 'x_farming:seed_icefishing',
    recipe = {
        { 'group:wool', 'farming:string', 'group:stick' },
        { '',           'farming:string', 'group:stick' },
        { '',           'farming:string', 'group:stick' }
    },
})

minetest.register_craft({
    output = 'dye:black 4',
    recipe = {
        { 'x_farming:black_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:blue 4',
    recipe = {
        { 'x_farming:blue_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:brown 4',
    recipe = {
        { 'x_farming:brown_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:cyan 4',
    recipe = {
        { 'x_farming:cyan_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:dark_grey 4',
    recipe = {
        { 'x_farming:gray_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:grey 4',
    recipe = {
        { 'x_farming:light_gray_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:dark_green 4',
    recipe = {
        { 'x_farming:green_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:green 4',
    recipe = {
        { 'x_farming:lime_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:magenta 4',
    recipe = {
        { 'x_farming:magenta_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:orange 4',
    recipe = {
        { 'x_farming:orange_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:pink 4',
    recipe = {
        { 'x_farming:pink_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:violet 4',
    recipe = {
        { 'x_farming:purple_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:red 4',
    recipe = {
        { 'x_farming:red_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:white 4',
    recipe = {
        { 'x_farming:white_seashroom' }
    }
})

minetest.register_craft({
    output = 'dye:yellow 4',
    recipe = {
        { 'x_farming:yellow_seashroom' }
    }
})

minetest.register_craft({
    output = 'default:diamond',
    recipe = {
        { 'x_farming:diamond_angler' }
    }
})

minetest.register_craft({
    output = 'default:gold_lump',
    recipe = {
        { 'x_farming:goldfish' }
    }
})

minetest.register_craft({
    output = 'default:gold_ingot',
    recipe = {
        { 'x_farming:true_goldfish' }
    }
})

minetest.register_craft({
    output = 'default:iron_lump',
    recipe = {
        { 'x_farming:ironfish' }
    }
})

minetest.register_craft({
    output = 'x_farming:seed_pumpkin',
    recipe = {
        { 'x_farming:pumpkinseed' }
    }
})


-- crates and bags
minetest.register_craft({
    output = 'x_farming:crate_empty',
    recipe = {
        { 'group:wood', 'group:stick', 'group:wood' },
        { 'group:wood', 'group:stick', 'group:wood' },
        { 'group:wood', 'group:wood',  'group:wood' }
    }
})

minetest.register_craft({
    output = 'x_farming:bag_empty',
    recipe = {
        { 'farming:straw', '',              'farming:straw' },
        { 'farming:straw', '',              'farming:straw' },
        { 'farming:straw', 'farming:straw', 'farming:straw' }
    }
})

-- composter
minetest.register_craft({
    output = 'x_farming:composter_1',
    recipe = {
        { 'group:wood', 'group:fence', 'group:wood' },
        { 'group:wood', 'group:fence', 'group:wood' },
        { 'group:wood', 'group:wood',  'group:wood' }
    }
})

-- Cactus brick
minetest.register_craft({
    output = 'x_farming:cactus_brick',
    recipe = {
        { 'x_farming:cactus_fruit_item', 'x_farming:cactus_fruit_item' },
        { 'x_farming:cactus_fruit_item', 'x_farming:cactus_fruit_item' },
    }
})

-- Scarecrow
minetest.register_craft({
    output = 'x_farming:scarecrow',
    recipe = {
        { '',              'x_farming:pumpkin_block', '' },
        { 'farming:straw', 'group:wool',              'farming:straw' },
        { '',              'group:wood',              '' },
    }
})

-- Christmas tree
minetest.register_craft({
    output = 'x_farming:christmas_tree_sapling',
    recipe = {
        { 'default:goldblock', 'default:meselamp',     'default:goldblock' },
        { 'wool:green',        'default:pine_sapling', 'wool:blue' },
        { 'wool:yellow',       'default:pine_sapling', 'wool:red' }
    }
})
