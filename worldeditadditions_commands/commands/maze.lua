local we_c = worldeditadditions_commands

-- ███    ███  █████  ███████ ███████
-- ████  ████ ██   ██    ███  ██
-- ██ ████ ██ ███████   ███   █████
-- ██  ██  ██ ██   ██  ███    ██
-- ██      ██ ██   ██ ███████ ███████

local function parse_params_maze(params_text, is_3d)
	if not params_text then
		return nil, nil, nil, nil
	end
	
	local parts = we_c.split(params_text, "%s+", false)
	
	local replace_node = parts[1]
	local seed = os.time()
	local path_length = 2
	local path_width = 1
	local path_depth = 1
	
	local param_index_seed = 4
	if is_3d then param_index_seed = 5 end
	
	
	if #parts >= 2 then
		path_length = tonumber(parts[2])
	end
	if #parts >= 3 then
		path_width = tonumber(parts[3])
	end
	if #parts >= 4 and is_3d then
		path_depth = tonumber(parts[4])
	end
	if #parts >= param_index_seed then
		seed = tonumber(parts[param_index_seed])
		if not seed then
			return false, "Error: Invalid seed value (seeds may only be integers)."
		end
	end
	
	replace_node = worldedit.normalize_nodename(replace_node)
	
	if not replace_node then
		return false, "Error: Invalid node name for replace_node"
	end
	
	return true, replace_node, seed, path_length, path_width, path_depth
end

worldedit.register_command("maze", {
	params = "<replace_node> [<path_length> [<path_width> [<seed>]]]",
	description = "Generates a maze covering the currently selected area (must be at least 3x3 on the x,z axes) with replace_node as the walls. Optionally takes a (integer) seed and the path length and width (see the documentation in the worldeditadditions README for more information).",
	privs = { worldedit = true },
	require_pos = 2,
	parse = function(params_text)
		local success, replace_node, seed, path_length, path_width = parse_params_maze(params_text, false)
		return success, replace_node, seed, path_length, path_width
	end,
	nodes_needed = function(name)
		-- Note that we could take in additional parameters from the return value of parse (minue the success bool there), but we don't actually need them here
		return worldedit.volume(worldedit.pos1[name], worldedit.pos2[name])
	end,
	func = function(name, replace_node, seed, path_length, path_width)
		local start_time = os.clock()
		local replaced = worldeditadditions.maze2d(worldedit.pos1[name], worldedit.pos2[name], replace_node, seed, path_length, path_width)
		local time_taken = os.clock() - start_time
		
		minetest.log("action", name .. " used //maze at " .. worldeditadditions.vector.tostring(worldedit.pos1[name]) .. ", replacing " .. replaced .. " nodes in " .. time_taken .. "s")
		return true, replaced .. " nodes replaced in " .. time_taken .. "s"
	end
})



-- ███    ███  █████  ███████ ███████     ██████  ██████
-- ████  ████ ██   ██    ███  ██               ██ ██   ██
-- ██ ████ ██ ███████   ███   █████        █████  ██   ██
-- ██  ██  ██ ██   ██  ███    ██               ██ ██   ██
-- ██      ██ ██   ██ ███████ ███████     ██████  ██████

worldedit.register_command("maze3d", {
	params = "<replace_node> [<path_length> [<path_width> [<path_depth> [<seed>]]]]",
	description = "Generates a 3d maze covering the currently selected area (must be at least 3x3x3) with replace_node as the walls. Optionally takes a (integer) seed and the path length, width, and depth (see the documentation in the worldeditadditions README for more information).",
	privs = { worldedit = true },
	requre_pos = 2,
	parse = function(params_text)
		local values = {parse_params_maze(params_text, true)}
		return unpack(values)
	end,
	nodes_needed = function(name)
		return worldedit.volume(worldedit.pos1[name], worldedit.pos2[name])
	end,
	func = function(name, replace_node, seed, path_length, path_width, path_depth)
		local start_time = os.clock()
		local replaced = worldeditadditions.maze3d(worldedit.pos1[name], worldedit.pos2[name], replace_node, seed, path_length, path_width, path_depth)
		local time_taken = os.clock() - start_time
		
		
		minetest.log("action", name .. " used //maze at " .. worldeditadditions.vector.tostring(worldedit.pos1[name]) .. ", replacing " .. replaced .. " nodes in " .. time_taken .. "s")
		return true, replaced .. " nodes replaced in " .. time_taken .. "s"
	end
})