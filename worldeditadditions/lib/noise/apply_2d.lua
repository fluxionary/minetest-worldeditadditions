local wea = worldeditadditions


--- Applies the given noise field to the given heightmap.
-- Mutates the given heightmap.
-- @param	heightmap		number[]			A table of ZERO indexed numbers representing the heghtmap - see worldeditadditions.make_heightmap().
-- @param	noise			number[]			An table identical in structure to the heightmap containing the noise values to apply.
-- @param	heightmap_size	{x:number,z:number}	A 2d vector representing the size of the heightmap.
-- @param	region_height	number				The height of the defined region.
-- @param	apply_mode		string				The apply mode to use to apply the noise to the heightmap.
-- @returns	bool[,string]	A boolean value representing whether the application was successful or not. If false, then an error message as a string is also returned describing the error that occurred.
function worldeditadditions.noise.apply_2d(heightmap, noise, heightmap_size, pos1, pos2, apply_mode)
	if type(apply_mode) ~= "string" and type(apply_mode) ~= "number" then
		return false, "Error: Expected value of type string or number for apply_mode, but received value of type "..type(apply_mode)
	end
	
	local region_height = pos2.y - pos1.y
	
	print("NOISE\n")
	worldeditadditions.format.array_2d(noise, heightmap_size.x)
	
	
	local height = tonumber(apply_mode)
	
	print("HEIGHT", height)
	
	for z = heightmap_size.z - 1, 0, -1 do
		for x = heightmap_size.x - 1, 0, -1 do
			local i = (z * heightmap_size.x) + x
			
			if apply_mode == "add" then
				heightmap[i] = wea.round(heightmap[i] + noise[i])
			elseif apply_mode == "multiply" then
				heightmap[i] = wea.round(heightmap[i] * noise[i])
			elseif height then
				-- Rescale from 0 - 1 to -1 - +1
				local rescaled = (noise[i] * 2) - 1
				-- print("DEBUG x", x, "z", z, "rescaled 1", rescaled)
				-- Rescale to match the height specified
				rescaled = rescaled * height
				-- print("DEBUG x", x, "z", z, "rescaled 2", rescaled)
				rescaled = math.floor(wea.clamp(
					heightmap[i] + rescaled,
					0, region_height
				))
				-- print("DEBUG x", x, "z", z, "before", heightmap[i], "after", rescaled)
				heightmap[i] = rescaled
			else
				return false, "Error: Unknown apply mode '"..apply_mode.."'"
			end
		end
	end
	
	return true
end
