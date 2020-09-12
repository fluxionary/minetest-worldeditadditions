local wea = worldeditadditions

-- Test command:
--	//multi //fp set1 1330 60 5455 //fp set2 1355 35 5430 //subdivide 10 10 10 fixlight //y

local function will_trigger_saferegion(name, cmd_name, args)
	if not worldedit.registered_commands[cmd_name] then return nil, "Error: That worldedit command could not be found (perhaps it hasn't been upgraded to worldedit.register_command() yet?)" end
	local def = worldedit.registered_commands[cmd_name]
	if not def.parse then return nil, "Error: No parse method found (this is a bug)." end
	
	local parsed = {def.parse(args)}
	local parse_success = table.remove(parsed, 1)
	if not success then return nil, table.remove(parsed, 1) end
	
	if not def.nodes_needed then return false end
	local success, result = def.nodes_needed(name, unpack(parsed))
	if not success then return nil, result end
	if result > 10000 then return true end
	return false
end

-- Counts the number of chunks in the given area.
-- TODO: Do the maths properly here instead of using a loop - the loop is *very* inefficient - especially for large areas
local function count_chunks(pos1, pos2, chunk_size)
	local count = 0
	for z = pos2.z, pos1.z, -chunk_size.z do
		for y = pos2.y, pos1.y, -chunk_size.y do
			for x = pos2.x, pos1.x, -chunk_size.x do
				count = count + 1
			end
		end
	end
	return count
end

worldedit.register_command("subdivide", {
	params = "<size_x> <size_y> <size_z> <command> <params>",
	description = "Subdivides the given worldedit area into chunks and runs a worldedit command multiple times to cover the defined region. Note that the given command must NOT be prepended with any forward slashes - just like //cubeapply.",
	privs = { worldedit = true },
	require_pos = 2,
	parse = function(params_text)
		local parts = wea.split(params_text, "%s+", false)
		
		if #parts < 4 then
			return false, "Error: Not enough arguments (try /help /subdivide)."
		end
		
		local chunk_size = {
			x = tonumber(parts[1]),
			y = tonumber(parts[2]),
			z = tonumber(parts[3])
		}
		
		if chunk_size.x == nil then return false, "Error: Invalid value for size_x (must be an integer)." end
		if chunk_size.y == nil then return false, "Error: Invalid value for size_y (must be an integer)." end
		if chunk_size.z == nil then return false, "Error: Invalid value for size_x (must be an integer)." end
		
		chunk_size.x = math.floor(chunk_size.x)
		chunk_size.y = math.floor(chunk_size.y)
		chunk_size.z = math.floor(chunk_size.z)
		
		local cmd_name = parts[4]
		
		if not worldedit.registered_commands[cmd_name] then
			return false, "Error: The worldedit command '"..parts[4].."' does not exist (try /help)."
		end
		
		-- success, chunk_size, command_name, args
		return true, chunk_size, parts[4], table.concat(parts, " ", 5)
	end,
	nodes_needed = function(name)
		return worldedit.volume(worldedit.pos1[name], worldedit.pos2[name])
	end,
	func = function(name, chunk_size, cmd_name, args)
		local time_total = worldeditadditions.get_ms_time()
		
		local pos1, pos2 = worldedit.sort_pos(worldedit.pos1[name], worldedit.pos2[name])
		local volume = worldedit.volume(pos1, pos2)
		
		local cmd = worldedit.registered_commands[cmd_name]
		if not minetest.check_player_privs(name, cmd.privs) then
			return false, "Error: Your privileges are unsufficient to run '"..cmd_name.."'."
		end
		
		local i = 1
		-- local chunks_total = math.ceil((pos2.x - pos1.x) / (chunk_size.x - 1))
		-- 	* math.ceil((pos2.y - pos1.y) / (chunk_size.y - 1))
		-- 	* math.ceil((pos2.z - pos1.z) / (chunk_size.z - 1))
		local chunks_total = count_chunks(pos1, pos2, chunk_size)
		
		local msg_prefix = "[ subdivide | "..table.concat({cmd_name, args}, " ").." ] "
		
		worldedit.player_notify(name,
			msg_prefix.."Starting - "
			-- ..wea.vector.tostring(pos1).." - "..wea.vector.tostring(pos2)
			.." chunk size: "..wea.vector.tostring(chunk_size)
			..", "..chunks_total.." chunks total"
			.." ("..volume.." nodes)"
		)
		
		chunk_size.x = chunk_size.x - 1 -- WorldEdit regions are inclusive
		chunk_size.y = chunk_size.y - 1 -- WorldEdit regions are inclusive
		chunk_size.z = chunk_size.z - 1 -- WorldEdit regions are inclusive
		
		
		local time_last_msg = worldeditadditions.get_ms_time()
		local time_chunks = {}
		for z = pos2.z, pos1.z, -(chunk_size.z + 1) do
			for y = pos2.y, pos1.y, -(chunk_size.y + 1) do
				for x = pos2.x, pos1.x, -(chunk_size.x + 1) do
					local c_pos2 = { x = x, y = y, z = z }
					local c_pos1 = {
						x = x - chunk_size.x,
						y = y - chunk_size.y,
						z = z - chunk_size.z
					}
					-- print("c1", wea.vector.tostring(c_pos1), "c2", wea.vector.tostring(c_pos2), "volume", worldedit.volume(c_pos1, c_pos2))
					if c_pos1.x < pos1.x then c_pos1.x = pos1.x end
					if c_pos1.y < pos1.y then c_pos1.y = pos1.y end
					if c_pos1.z < pos1.z then c_pos1.z = pos1.z end
					
					local time_this = worldeditadditions.get_ms_time()
					worldedit.player_notify_suppress(name)
					worldedit.pos1[name] = c_pos1
					worldedit.pos2[name] = c_pos2
					cmd.func(name, args)
					if will_trigger_saferegion(name, cmd_name, args) then
						minetest.chatcommands["/y"].func()
					end
					worldedit.player_notify_unsuppress(name)
					time_this = worldeditadditions.get_ms_time() - time_this
					table.insert(time_chunks, time_this)
					
					local time_average = wea.average(time_chunks)
					local eta = (chunks_total - i) * time_average
					print("eta", eta, "time_average", time_average, "chunks_left", chunks_total - i)
					
					-- Send updates every 2 seconds, and after the first 3 chunks are done
					if worldeditadditions.get_ms_time() - time_last_msg > 2 * 1000 or i == 3 then
						worldedit.player_notify(name,
							msg_prefix
							..i.." / "..chunks_total.." (~"
							..string.format("%.2f", (i / chunks_total) * 100).."%) complete | "
							.."last chunk: "..wea.human_time(time_this)
							..", average: "..wea.human_time(time_average)
							..", ETA: ~"..wea.human_time(eta)
						)
						time_last_msg = worldeditadditions.get_ms_time()
					end
					
					i = i + 1
				end
			end
		end
		i = i - 1
		worldedit.pos1[name] = pos1
		worldedit.pos2[name] = pos2
		time_total = worldeditadditions.get_ms_time() - time_total
		
		
		minetest.log("action", name.." used //subdivide at "..wea.vector.tostring(pos1).." - "..wea.vector.tostring(pos2)..", with "..i.." chunks and "..worldedit.volume(pos1, pos2).." total nodes in "..time_total.."s")
		return true, msg_prefix.."Complete: "..i.." chunks processed in "..wea.human_time(time_total)
	end
})