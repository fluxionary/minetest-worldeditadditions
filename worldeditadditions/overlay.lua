--- Overlap command. Places a specified node on top of each column.
-- @module worldeditadditions.overlay

function worldeditadditions.overlay(pos1, pos2, target_node)
	pos1, pos2 = worldedit.sort_pos(pos1, pos2)
	-- pos2 will always have the highest co-ordinates now
	
	-- Fetch the nodes in the specified area
	local manip, area = worldedit.manip_helpers.init(pos1, pos2)
	local data = manip:get_data()
	
	local node_id_air = minetest.get_content_id("air")
	local node_id_target = minetest.get_content_id(target_node)
	
	minetest.log("action", "pos1: " .. worldeditadditions.vector.tostring(pos1))
	minetest.log("action", "pos2: " .. worldeditadditions.vector.tostring(pos2))
	
	-- z y x is the preferred loop order, but that isn't really possible here
	
	local changes = { updated = 0, skipped_columns = 0 }
	for z = pos2.z, pos1.z, -1 do
		for x = pos2.x, pos1.x, -1 do
			local found_air = false
			local placed_node = false
			
			for y = pos2.y, pos1.y, -1 do
				if data[area:index(x, y, z)] ~= node_id_air then
					if found_air then
						-- We've found an air block previously, so it must be above us
						-- Replace the node above us with the target block
						data[area:index(x, y + 1, z)] = node_id_target
						changes.updated = changes.updated + 1
						placed_node = true
						break -- Move on to the next column
					end
				else
					found_air = true
				end
			end
			
			if not placed_node then
				changes.skipped_columns = changes.skipped_columns + 1
			end
		end
	end
	
	
	-- Save the modified nodes back to disk & return
	worldedit.manip_helpers.finish(manip, data)
	
	return changes
end
