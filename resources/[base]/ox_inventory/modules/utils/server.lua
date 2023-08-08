if not lib then return end

local Utils = {}

local webHook = GetConvar('inventory:webhook', 'https://discord.com/api/webhooks/1121786935342538852/NKnmsqpqy1F-q64L7olJXtc7wrj2R-24LI1nz_wrrXK7EozIhyUkZO8_ot313hUrAKFY')

if webHook ~= '' then
	local validHosts = {
		['i.imgur.com'] = true,
	}

	local validExtensions = {
		['png'] = true,
		['apng'] = true,
		['webp'] = true,
	}

	local headers = { ['Content-Type'] = 'application/json' }

	function Utils.IsValidImageUrl(url)
		local host, extension = url:match('^https?://([^/]+).+%.([%l]+)')
		return host and extension and validHosts[host] and validExtensions[extension]
	end

	---@param title string
	---@param message string
	---@param image string
	function Utils.DiscordEmbed(title, message, image, color)
		PerformHttpRequest(webHook, function() end, 'POST', json.encode({
			username = 'ox_inventory', embeds = {
				{
					title = title,
					color = color,
					footer = {
						text = os.date('%c'),
					},
					description = message,
					thumbnail = {
						url = image,
						width = 100,
					}
				}
			}
		}), headers)
	end
end

return Utils
