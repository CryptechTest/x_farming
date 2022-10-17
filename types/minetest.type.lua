---https://github.com/sumneko/lua-language-server/wiki

---Minetest globals
---@class Minetest
---@field item_drop fun(itemstack: string|ItemStack, dropper: ObjectRef, pos: Vector): ItemStack Drop the item, returns the leftover itemstack
---@field get_us_time fun(): integer|number Returns time with microsecond precision. May not return wall time.
---@field get_modpath fun(modname: string): string|nil Returns the directory path for a mod, e.g. `"/home/user/.minetest/usermods/modname"`. Returns nil if the mod is not enabled or does not exist (not installed). Works regardless of whether the mod has been loaded yet. Useful for loading additional `.lua` modules or static data from a mod, or checking if a mod is enabled.
---@field check_player_privs fun(player_or_name: ObjectRef|string, privs: table|string[]): boolean Returns `bool, missing_privs`. A quickhand for checking privileges.  `player_or_name`: Either a Player object or the name of a player. `privs` is either a list of strings, e.g. `"priva", "privb"` or a table, e.g. `{ priva = true, privb = true }`.
---@field register_on_joinplayer fun(f: fun(player: ObjectRef, last_login: number|integer|nil)): nil Called when a player joins the game. `last_login`: The timestamp of the previous login, or nil if player is new
---@field register_tool fun(name: string, item_definition: ItemDef): nil Registers the item in the engine
---@field colorize fun(color: string, message: string): nil
---@field register_craft fun(recipe: CraftRecipeDef): nil
---@field register_craftitem fun(name: string, item_definition: ItemDef): nil
---@field add_entity fun(pos: Vector, name: string, staticdata?: string): ObjectRef|nil  Spawn Lua-defined entity at position. Returns `ObjectRef`, or `nil` if failed.
---@field get_node fun(pod: Vector): NodeDef Returns the node at the given position as table in the format `{name="node_name", param1=0, param2=0}`, returns `{name="ignore", param1=0, param2=0}` for unloaded areas.
---@field registered_nodes table<string, NodeDef|ItemDef> Map of registered node definitions, indexed by name
---@field after fun(time: number|integer, func: fun(...), ...): JobTable Call the function `func` after `time` seconds, may be fractional. Optional: Variable number of arguments that are passed to `func`.
---@field sound_play fun(spec: SimpleSoundSpec|string, parameters: SoundParamDef, ephemeral?: boolean): any Returns a `handle`. Ephemeral sounds will not return a handle and can't be stopped or faded. It is recommend to use this for short sounds that happen in response to player actions (e.g. door closing).
---@field add_particlespawner fun(particlespawner_definition: ParticlespawnerDef): number|integer Add a `ParticleSpawner`, an object that spawns an amount of particles over `time` seconds. Returns an `id`, and -1 if adding didn't succeed.
---@field register_globalstep fun(func: fun(dtime: number|integer)): nil Called every server step, usually interval of 0.1s
---@field get_connected_players fun(): ObjectRef[] Returns list of `ObjectRefs`
---@field serialize fun(t: table): string Convert a table containing tables, strings, numbers, booleans and `nil`s into string form readable by `minetest.deserialize`. Example: `serialize({foo="bar"})`, returns `'return { ["foo"] = "bar" }'`.
---@field dir_to_yaw fun(dir: Vector): number|integer Convert a vector into a yaw (angle)
---@field settings MinetestSettings Settings object containing all of the settings from the main config file (`minetest.conf`).
---@field register_entity fun(name: string, entity_definition: EntityDef): nil
---@field deserialize fun(s: string, safe?: boolean): table Returns a table. Convert a string returned by `minetest.serialize` into a table `string` is loaded in an empty sandbox environment. Will load functions if safe is false or omitted. Although these functions cannot directly access the global environment, they could bypass this restriction with maliciously crafted Lua bytecode if mod security is disabled. This function should not be used on untrusted data, regardless of the value of `safe`. It is fine to serialize then deserialize user-provided data, but directly providing user input to deserialize is always unsafe.
---@field raycast fun(pos1: Vector, pos2: Vector, objects: boolean, liquids: boolean): Raycast `pos1`: start of the ray, `pos2`: end of the ray, `objects`: if false, only nodes will be returned. Default is true. `liquids`: if false, liquid nodes (`liquidtype ~= "none"`) won't be returned. Default is false.
---@field calculate_knockback fun(player: ObjectRef, hitter: ObjectRef, time_from_last_punch: number|integer, tool_capabilities: ToolCapabilitiesDef, dir: Vector, distance: number|integer, damage: number|integer): integer|number Returns the amount of knockback applied on the punched player. Arguments are equivalent to `register_on_punchplayer`, except the following: `distance`: distance between puncher and punched player. This function can be overriden by mods that wish to modify this behaviour. You may want to cache and call the old function to allow multiple mods to change knockback behaviour.
---@field get_player_by_name fun(name: string): ObjectRef Get an `ObjectRef` to a player
---@field get_node_timer fun(pos: Vector): NodeTimerRef Get `NodeTimerRef`
---@field get_objects_inside_radius fun(pos: Vector, radius: number|integer): ObjectRef[] Returns a list of ObjectRefs. `radius`: using an euclidean metric.
---@field register_node fun(name: string, node_definition: NodeDef): nil
---@field get_meta fun(pos: Vector): NodeMetaRef Get a `NodeMetaRef` at that position
---@field pos_to_string fun(pos: Vector, decimal_places?: number|integer): string returns string `"(X,Y,Z)"`, `pos`: table {x=X, y=Y, z=Z}. Converts the position `pos` to a human-readable, printable string. `decimal_places`: number, if specified, the x, y and z values of the position are rounded to the given decimal place.
---@field get_node_light fun(pos: Vector, timeofday: number|integer|nil): number|integer|nil Gets the light value at the given position. Note that the light value "inside" the node at the given position is returned, so you usually want to get the light value of a neighbor. `pos`: The position where to measure the light. `timeofday`: `nil` for current time, `0` for night, `0.5` for day. Returns a number between `0` and `15` or `nil`. `nil` is returned e.g. when the map isn't loaded at `pos`.
---@field set_node fun(pos: Vector, node: SetNodeTable): nil Set node at position `pos`, `node`: table `{name=string, param1=number, param2=number}`, If param1 or param2 is omitted, it's set to `0`. e.g. `minetest.set_node({x=0, y=10, z=0}, {name="default:wood"})`
---@field place_schematic fun(pos: Vector, schematic, rotation?: '0'|'90'|'180'|'270'|'random', replacements?: table<string, string>, force_placement?: boolean, flags?: string): nil Place the schematic specified by schematic at `pos`. `rotation` can equal `"0"`, `"90"`, `"180"`, `"270"`, or `"random"`. If the `rotation` parameter is omitted, the schematic is not rotated. `replacements` = `{["old_name"] = "convert_to", ...}`. `force_placement` is a boolean indicating whether nodes other than `air` and `ignore` are replaced by the schematic. Returns nil if the schematic could not be loaded. **Warning**: Once you have loaded a schematic from a file, it will be cached. Future calls will always use the cached version and the replacement list defined for it, regardless of whether the file or the replacement list parameter have changed. The only way to load the file anew is to restart the server. `flags` is a flag field with the available flags: place_center_x, place_center_y, place_center_z
---@field log fun(level?: 'none'|'error'|'warning'|'action'|'info'|'verbose', text: string): nil
---@field get_item_group fun(name: string, group): any returns a rating. Get rating of a group of an item. (`0` means: not in group)
---@field get_biome_data fun(pos: Vector): BiomeData|nil
---@field get_biome_name fun(biome_id: string|number|integer): string|nil Returns the biome name string for the provided biome id, or `nil` on failure. If no biomes have been registered, such as in mgv6, returns `default`.
---@field find_nodes_in_area fun(pos1: Vector, pos2: Vector, nodenames: string|string[], grouped?: boolean): table `pos1` and `pos2` are the min and max positions of the area to search. `nodenames`: e.g. `{"ignore", "group:tree"}` or `"default:dirt"` If `grouped` is true the return value is a table indexed by node name which contains lists of positions. If `grouped` is false or absent the return values are as follows: first value: Table with all node positions, second value: Table with the count of each node with the node name as index, Area volume is limited to 4,096,000 nodes
---@field find_nodes_in_area_under_air fun(pos1: Vector, pos2: Vector, nodenames: string|string[]): table returns a list of positions. `nodenames`: e.g. `{"ignore", "group:tree"}` or `"default:dirt"`. Return value: Table with all node positions with a node air above. Area volume is limited to 4,096,000 nodes.
---@field registered_decorations table<any, DecorationDef> Map of registered decoration definitions, indexed by the `name` field. If `name` is nil, the key is the object handle returned by `minetest.register_schematic`.
---@field swap_node fun(pos: Vector, node: NodeDef): nil Set node at position, but don't remove metadata
---@field item_eat fun(hp_change: number, replace_with_item?: string): fun(itemstack: ItemStack, user: ObjectRef, pointed_thing: PointedThingDef) Returns `function(itemstack, user, pointed_thing)` as a function wrapper for `minetest.do_item_eat`. `replace_with_item` is the itemstring which is added to the inventory. If the player is eating a stack, then replace_with_item goes to a different spot.
---@field override_item fun(name: string, redefinition: ItemDef|NodeDef): nil Overrides fields of an item registered with register_node/tool/craftitem. Note: Item must already be defined, (opt)depend on the mod defining it. Example: `minetest.override_item("default:mese", {light_source=minetest.LIGHT_MAX})`
---@field register_decoration fun(decoration_definition: DecorationDef): number|integer Returns an integer object handle uniquely identifying the registered decoration on success. To get the decoration ID, use `minetest.get_decoration_id`. The order of decoration registrations determines the order of decoration generation.
---@field find_node_near fun(pos: Vector, radius: number, nodenames: string[], search_center?: boolean): Vector|nil returns pos or `nil`. `radius`: using a maximum metric, `nodenames`: e.g. `{"ignore", "group:tree"}` or `"default:dirt"`, `search_center` is an optional boolean (default: `false`) If true `pos` is also checked for the nodes
---@field remove_node fun(pos: Vector): nil By default it does the same as `minetest.set_node(pos, {name="air"})`
---@field get_node_or_nil fun(pos: Vector): NodeDef|nil Same as `get_node` but returns `nil` for unloaded areas.
---@field facedir_to_dir fun(facedir: number): Vector Convert a facedir back into a vector aimed directly out the "back" of a node.
---@field record_protection_violation fun(pos: Vector, name: string): nil This function calls functions registered with `minetest.register_on_protection_violation`.
---@field dir_to_facedir fun(dir: Vector, is6d?: any): number Convert a vector to a facedir value, used in `param2` for `paramtype2="facedir"`. passing something non-`nil`/`false` for the optional second parameter causes it to take the y component into account.
---@field register_lbm fun(lbm_definition: LbmDef): nil
---@field rotate_node fun(itemstack: ItemStack, placer: ObjectRef, pointed_thing: PointedThingDef): nil calls `rotate_and_place()` with `infinitestacks` set according to the state of the creative mode setting, checks for "sneak" to set the `invert_wall` parameter and `prevent_after_place` set to `true`.
---@field global_exists fun(name: string): nil Checks if a global variable has been set, without triggering a warning.
---@field register_alias fun(alias: string|MapgenAliasesV6|MapgenAliasesNonV6, original_name: string): nil Also use this to set the 'mapgen aliases' needed in a game for the core mapgens. See [Mapgen aliases] section above.
---@field register_alias_force fun(alias: string|MapgenAliasesV6|MapgenAliasesNonV6, original_name: string): nil
---@field add_item fun(pos: Vector, item: ItemStack): ObjectRef|nil Spawn item. Returns `ObjectRef`, or `nil` if failed.
---@field registered_items table<string, ItemDef> Map of registered items, indexed by name
---@field add_node fun(pos: Vector, node: SetNodeTable): nil alias to `minetest.set_node`, Set node at position `pos`, `node`: table `{name=string, param1=number, param2=number}`, If param1 or param2 is omitted, it's set to `0`. e.g. `minetest.set_node({x=0, y=10, z=0}, {name="default:wood"})`
---@field string_to_pos fun(string: string): Vector|nil If the string can't be parsed to a position, nothing is returned.
---@field chat_send_player fun(name: string, text: string): nil
---@field create_detached_inventory fun(name: string, callbacks: DetachedInventoryCallbacks, player_name?: string): InvRef Creates a detached inventory. If it already exists, it is cleared. `callbacks`: See [Detached inventory callbacks], `player_name`: Make detached inventory available to one player exclusively, by default they will be sent to every player (even if not used). Note that this parameter is mostly just a workaround and will be removed in future releases.
---@field get_mod_storage fun(): StorageRef Mod metadata: per mod metadata, saved automatically. Can be obtained via `minetest.get_mod_storage()` during load time.
---@field show_formspec fun(playername: string, formname: string, formspec: string): nil `playername`: name of player to show formspec, `formname`: name passed to `on_player_receive_fields` callbacks. It should follow the `"modname:<whatever>"` naming convention. `formspec`: formspec to display
---@field register_on_player_receive_fields fun(func: fun(player: ObjectRef, formname: string, fields: table)): nil Called when the server received input from `player` in a formspec with the given `formname`. Specifically, this is called on any of the following events: a button was pressed, Enter was pressed while the focus was on a text field, a checkbox was toggled, something was selected in a dropdown list, a different tab was selected, selection was changed in a textlist or table, an entry was double-clicked in a textlist or table, a scrollbar was moved, or the form was actively closed by the player.
---@field get_inventory fun(location: {['"type"']: 'player'|'node'|'detached', ['"name"']: string|nil, ['"pos"']: Vector|nil}): InvRef

---Minetest settings
---@class MinetestSettings
---@field get fun(self: MinetestSettings, key: string): string|number|integer Returns a value
---@field get_bool fun(self: MinetestSettings, key: string, default?: boolean): boolean|nil Returns a boolean. `default` is the value returned if `key` is not found. Returns `nil` if `key` is not found and `default` not specified.
---@field get_np_group fun(self: MinetestSettings, key: string): table Returns a NoiseParams table
---@field get_flags fun(self: MinetestSettings, key: string): table Returns `{flag = true/false, ...}` according to the set flags. Is currently limited to mapgen flags `mg_flags` and mapgen-specific flags like `mgv5_spflags`.
---@field set fun(self: MinetestSettings, key: string, value: string|integer|number): nil Setting names can't contain whitespace or any of `="{}#`. Setting values can't contain the sequence `\n"""`. Setting names starting with "secure." can't be set on the main settings object (`minetest.settings`).
---@field set_bool fun(self: MinetestSettings, key: string, value: boolean): nil Setting names can't contain whitespace or any of `="{}#`. Setting values can't contain the sequence `\n"""`. Setting names starting with "secure." can't be set on the main settings object (`minetest.settings`).
---@field set_np_group fun(self: MinetestSettings, key: string, value: table): nil `value` is a NoiseParams table.
---@field remove fun(self: MinetestSettings, key: string): boolean Returns a boolean (`true` for success)
---@field get_names fun(): table Returns `{key1,...}`
---@field write fun(): boolean Returns a boolean (`true` for success). Writes changes to file.
---@field to_table fun(): table Returns `{[key1]=value1,...}`

--- Set node table
---@class SetNodeTable
---@field name string
---@field param1 number
---@field param2 number

--- Detached inventory callbacks
---@class DetachedInventoryCallbacks
---@field allow_move fun(inv: InvRef, from_list: string, from_index: number, to_list: string, to_index: number, count: number, player: ObjectRef): number Called when a player wants to move items inside the inventory. Return value: number of items allowed to move.
---@field allow_put fun(inv: InvRef, listname: string, index: number, stack: ItemStack, player: ObjectRef): number Called when a player wants to put something into the inventory. Return value: number of items allowed to put. Return value -1: Allow and don't modify item count in inventory.
---@field allow_take fun(inv: InvRef, listname: string, index: number, stack: ItemStack, player: ObjectRef): number Called when a player wants to take something out of the inventory. Return value: number of items allowed to take. Return value -1: Allow and don't modify item count in inventory.
---@field on_move fun(inv: InvRef, from_list: string, from_index: number, to_list: string, to_index: number, count: number, player: ObjectRef): nil
---@field on_put fun(inv: InvRef, listname: string, index: number, stack: ItemStack, player: ObjectRef): nil
---@field on_take fun(inv: InvRef, listname: string, index: number, stack: ItemStack, player: ObjectRef): nil Called after the actual action has happened, according to what was allowed. No return value.

--- Job table
---@class JobTable
---@field cancel fun(self: JobTable) Cancels the job function from being called

--- Biome data
---@class BiomeData
---@field biome string|number|integer the biome id of the biome at that position
---@field heat string|number|integer the heat at the position
---@field humidity string|number|integer the humidity at the position

--- LBM (LoadingBlockModifier) definition. A loading block modifier (LBM) is used to define a function that is called for specific nodes (defined by `nodenames`) when a mapblock which contains such nodes gets activated (not loaded!)
---@class LbmDef
---@field label string Descriptive label for profiling purposes (optional). Definitions with identical labels will be listed as one.
---@field name string Identifier of the LBM, should follow the modname:<whatever> convention
---@field nodenames string[] List of node names to trigger the LBM on. Names of non-registered nodes and groups (as group:groupname) will work as well.
---@field run_at_every_load boolean Whether to run the LBM's action every time a block gets activated, and not only the first time the block gets activated after the LBM was introduced.
---@field action fun(pos: Vector, node: NodeDef): nil Function triggered for each qualifying node.

--- Sound parameters.
--- Looped sounds must either be connected to an object or played locationless to one player using `to_player = name`. A positional sound will only be heard by players that are within `max_hear_distance` of the sound position, at the start of the sound. `exclude_player = name` can be applied to locationless, positional and object-bound sounds to exclude a single player from hearing them.
---@class SoundParamDef
---@field to_player string Name
---@field gain number|integer
---@field fade number|integer Change to a value > 0 to fade the sound in
---@field pitch number|integer
---@field loop boolean
---@field pos Vector
---@field max_hear_distance number|integer
---@field object ObjectRef
---@field exclude_player string Name
