--  ██████  ██████  ███    ██ ██    ██  ██████  ██     ██    ██ ███████
-- ██      ██    ██ ████   ██ ██    ██ ██    ██ ██     ██    ██ ██
-- ██      ██    ██ ██ ██  ██ ██    ██ ██    ██ ██     ██    ██ █████
-- ██      ██    ██ ██  ██ ██  ██  ██  ██    ██ ██      ██  ██  ██
--  ██████  ██████  ██   ████   ████    ██████  ███████  ████   ███████
worldedit.register_command("convolve", {
	params = "<kernel> [<width>[,<height>]] [<sigma>]",
	description = "Advanced version of //smooth from we_env. Convolves over the defined region with the given kernel. Possible kernels: box, pascal, gaussian. The width & height (if specified) must be odd integers. If the height is not specified, it defaults to the width. gaussian should give the smoothest result, but the width & height must be identical. The sigma value is only applicable to gaussian kernels, and can be thought of as the 'smoothness' to apply.",
	privs = { worldedit = true },
	require_pos = 2,
	parse = function(params_text)
		if not params_text then params_text = "" end
		
		local parts = worldeditadditions.split(params_text, "%s+", false)
		
		local kernel_name = "gaussian"
		local width = 5
		local height = 5
		local sigma = nil
		
		if #parts >= 1 and #parts[1] > 0 then
			kernel_name = parts[1]
		end
		if #parts >= 2 then
			local parts_dimension = worldeditadditions.split(parts[2], ",%s*", false)
			width = tonumber(parts_dimension[1])
			if not width then
				return false, "Error: Invalid width (it must be a positive odd integer)."
			end
			if #parts_dimension >= 2 then
				height = tonumber(parts_dimension[2])
				if not height then
					return false, "Error: Invalid height (it must be a positive odd integer)."
				end
			else
				height = width
			end
		end
		if #parts >= 3 then
			sigma = tonumber(parts[3])
			if not sigma then
				return false, "Error: Invalid sigma value (it must be a valid number - floating point numbers are allowed)"
			end
		end
		
		return true, kernel_name, math.floor(width), math.floor(height), sigma
	end,
	nodes_needed = function(name)
		return worldedit.volume(worldedit.pos1[name], worldedit.pos2[name])
	end,
	func = function(name, kernel_name, kernel_width, kernel_height, sigma)
		local start_time = worldeditadditions.get_ms_time()
		
		local success, kernel = worldeditadditions.get_conv_kernel(kernel_name, kernel_width, kernel_height, sigma)
		if not success then return success, kernel end
		
		local kernel_size = {}
		kernel_size[0] = kernel_height
		kernel_size[1] = kernel_width
		
		local stats
		success, stats = worldeditadditions.convolve(
			worldedit.pos1[name], worldedit.pos2[name],
			kernel, kernel_size
		)
		if not success then return success, stats end
		
		local time_taken = worldeditadditions.get_ms_time() - start_time
		
		
		minetest.log("action", name.." used //convolve at "..worldeditadditions.vector.tostring(worldedit.pos1[name]).." - "..worldeditadditions.vector.tostring(worldedit.pos2[name])..", adding "..stats.added.." nodes and removing "..stats.removed.." nodes in "..time_taken.."s")
		return true, "Added "..stats.added.." and removed "..stats.removed.." nodes in " .. worldeditadditions.format.human_time(time_taken)
	end
})
