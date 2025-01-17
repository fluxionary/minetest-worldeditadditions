local wea_c = worldeditadditions_core
local wea = worldeditadditions
local Vector3 = wea_c.Vector3

local function parse_stage2(name, parts)
	local success, vpos1, vpos2 = wea_c.parse.axes(
		parts,
		wea_c.player_dir(name)
	)
	
	if not success then return success, vpos1 end
	
	-- In this case, we aren't interested in keeping the multidirectional shape changing information insomuch as an offset to which we should shift the region's contents to.
	local offset = vpos1 + vpos2
	
	if offset == Vector3.new() then 
		return false, "Refusing to copy region a distance of 0 nodes"
	end
	
	return true, offset:floor()
end

--  ██████  ██████  ██████  ██    ██
-- ██      ██    ██ ██   ██  ██  ██
-- ██      ██    ██ ██████    ████
-- ██      ██    ██ ██         ██
--  ██████  ██████  ██         ██
worldeditadditions_core.register_command("copy+", { -- TODO: Make this an override
	params = "<axis:x|y|z|-x|-y|-z|?|front|back|left|right|up|down> <count> [<axis> <count> [...]]",
	description = "Copies the defined region to another location - potentially across multiple axes at once.",
	privs = { worldedit = true },
	require_pos = 2,
	parse = function(params_text)
		if not params_text then params_text = "" end
		
		local parts = wea_c.split_shell(params_text)
		
		return true, parts
	end,
	nodes_needed = function(name)
		return worldedit.volume(worldedit.pos1[name], worldedit.pos2[name])
	end,
	func = function(name, parts)
		local start_time = wea_c.get_ms_time()
		
		local success_a, copy_offset = parse_stage2(name, parts)
		if not success_a then return success_a, copy_offset end
		
		local source_pos1 = Vector3.clone(worldedit.pos1[name])
		local source_pos2 = Vector3.clone(worldedit.pos2[name])
		
		local target_pos1 = source_pos1 + copy_offset
		local target_pos2 = source_pos2 + copy_offset
		
		local success_b, nodes_modified = wea.copy(
			source_pos1, source_pos2,
			target_pos1, target_pos2
		)
		if not success_b then return success_b, nodes_modified end
		
		local time_taken = wea_c.get_ms_time() - start_time
		
		
		minetest.log("action", name.." used //copy from "..source_pos1.." - "..source_pos2.." to "..target_pos1.." - "..target_pos2..", modifying "..nodes_modified.." nodes in "..wea_c.format.human_time(time_taken))
		return true, nodes_modified.." nodes copied using offset "..copy_offset.." in "..wea_c.format.human_time(time_taken)
	end
})
