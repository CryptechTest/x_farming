---https://github.com/sumneko/lua-language-server/wiki

--An `InvRef` is a reference to an inventory.
---@class InvRef
---@field add_item fun(self: InvRef, listname: string, stack: string|ItemStack): ItemStack Add item somewhere in list, returns leftover `ItemStack`.
---@field contains_item fun(self: InvRef, listname: string, stack: string|ItemStack, match_meta?: boolean): boolean Returns `true` if the stack of items can be fully taken from the list. If `match_meta` is false, only the items' names are compared, default: `false`
---@field get_list fun(self: InvRef, listname: string): ItemStack[] Return full list, list of `ItemStack`s
---@field room_for_item fun(self: InvRef, listname: string, stack: string|ItemStack): boolean Returns `true` if the stack of items can be fully added to the list
---@field set_stack fun(self: InvRef, listname: string, i: integer, stack: string|ItemStack): nil Copy `stack` to index `i` in list
---@field is_empty fun(self: InvRef, listname: string): boolean Return `true` if list is empty
---@field get_size fun(self: InvRef, listname: string): integer Get size of a list
---@field set_size fun(self: InvRef, listname: string, size: integer): boolean Set size of a list, returns `false` on error, e.g. invalid `listname` or `size`
---@field get_width fun(self: InvRef, listname: string): boolean Get width of a list
---@field set_width fun(self: InvRef, listname: string, width: integer): nil Set width of list; currently used for crafting
---@field get_stack fun(self: InvRef, listname: string, i: integer): ItemStack Get a copy of stack index `i` in list
---@field set_list fun(self: InvRef, listname: string, list: ItemStack[]): nil Set full list, size will not change
---@field get_lists fun(): table Returns table that maps listnames to inventory lists
---@field set_lists fun(self: InvRef, lists: table): nil Sets inventory lists, size will not change
---@field remove_item fun(self: InvRef, listname: string, stack: string|ItemStack): nil Take as many items as specified from the list, returns the items that were actually removed, as an `ItemStack`, note that any item metadata is ignored, so attempting to remove a specific unique item this way will likely remove the wrong one, to do that use `set_stack` with an empty `ItemStack`.
---@field get_location fun(self: InvRef): {['type']: 'player'|'node'|'detached'|'undefined', ['name']: string|nil, ['pos']: Vector|nil} returns a location compatible to `minetest.get_inventory(location)`. returns `{type="undefined"}` in case location is not known
