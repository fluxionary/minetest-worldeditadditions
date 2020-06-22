--- Makes an associative table of node_name => weight into a list of node ids.
-- Node names with a heigher weight are repeated more times.
function worldeditadditions.make_weighted(tbl)
	local result = {}
	for node_name, weight in pairs(tbl) do
		local next_id = minetest.get_content_id(node_name)
		print("[make_weighted] seen "..node_name.." @ weight "..weight.." → id "..next_id)
		for i = 1, weight do
			table.insert(result, next_id)
		end
	end
	return result, #result
end

--- Unwinds a list of { node = string, weight = number } tables into a list of node ids.
-- The node ids will be repeated multiple times according to their weights
-- (e.g. an entry with a weight of 2 will be repeated twice).
-- @param	list		table[]		The list to unwind.
-- @return	number[],number			The unwound list of node ids, follows by the number of node ids in total.
function worldeditadditions.unwind_node_list(list)
	local result = {}
	for i,item in ipairs(list) do
		local node_id = minetest.get_content_id(item.node)
		for i = 1, item.weight do
			table.insert(result, node_id)
		end
	end
	return result, #result
end

local node_id_air = minetest.get_content_id("air")
local node_id_ignore = minetest.get_content_id("ignore")

--- Determines whether the given node/content id is an airlike node or not.
-- @param	id		number	The content/node id to check.
-- @return	bool	Whether the given node/content id is an airlike node or not.
function worldeditadditions.is_airlike(id)
	--  Do a fast check against air and ignore
	if id == node_id_air then
		return true
	elseif id == node_id_ignore then -- ignore = not loaded yet IIRC (so it could be anything)
		return false
	end
	
	-- If the node isn't registered, then it might not be an air node
	if not minetest.registered_nodes[id] then return false end
	if minetest.registered_nodes[id].sunlight_propagates == true then
		return true
	end
	-- Check for membership of the airlike group
	local name = minetest.get_name_from_content_id(id)
	local airlike_value = minetest.get_item_group(name, "airlike")
	if airlike_value ~= nil and airlike_value > 0 then
		return true
	end
	-- Just in case
	if worldeditadditions.string_starts(this_node_name, "wielded_light") then
		return true
	end
	-- Just in case
	return false
end

--- Determines whether the given node/content id is a liquid-ish node or not.
-- @param	id		number	The content/node id to check.
-- @return	bool	Whether the given node/content id is a liquid-ish node or not.
function worldeditadditions.is_liquidlike(id)
	print("[is_liquidlike]")
	if id == node_id_ignore then return false end
	
	local node_name = minetest.get_name_from_content_id(id)
	if node_name == nil or not minetest.registered_nodes[node_name] then return false end
	
	local liquidtype = minetest.registered_nodes[node_name].liquidtype
	print("[is_liquidlike]", "id", id, "liquidtype", liquidtype)
	
	if liquidtype == nil or liquidtype == "none" then return false end
	-- If it's not none, then it has to be a liquid as the only other values are source and flowing
	return true
end

--- Given a manip object and associates, generates a 2D x/z heightmap.
-- Note that pos1 and pos2 should have already been pushed through
-- worldedit.sort_pos(pos1, pos2) before passing them to this function.
-- @param	pos1	Vector		Position 1 of the region to operate on
-- @param	pos2	Vector		Position 2 of the region to operate on
-- @param	manip	VoxelManip	The VoxelManip object.
-- @param	area	area		The associated area object.
-- @param	data	table		The associated data object.
-- @return	table	The ZERO-indexed heightmap data (as 1 single flat array).
function worldeditadditions.make_heightmap(pos1, pos2, manip, area, data)
	-- z y x (in reverse for little-endian machines) is the preferred loop order, but that isn't really possible here
	
	local heightmap = {}
	local hi = 0
	local changes = { updated = 0, skipped_columns = 0 }
	for z = pos1.z, pos2.z, 1 do
		for x = pos1.x, pos2.x, 1 do
			local found_node = false
			-- Scan each column top to bottom
			for y = pos2.y+1, pos1.y, -1 do
				local i = area:index(x, y, z)
				if not worldeditadditions.is_airlike(data[i]) then
					-- It's the first non-airlike node in this column
					-- Start heightmap values from 1 (i.e. there's at least 1 node in the column)
					heightmap[hi] = (y - pos1.y) + 1 
					found_node = true
					break
				end
			end
			
			if not found_node then heightmap[hi] = -1 end
			hi = hi + 1
		end
	end
	
	return heightmap
end