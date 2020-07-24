--[[ Renaming Notes
- user_id could be renamed to client_id, but it can also be kept as is.
- server_url should be renamed to server_uri.
- 
]]--

CloudBackup = gideros.class()

function CloudBackup:init(server_url, user_id, tag)
	self.server_url = server_url
	self.user_id = user_id
	self.tag = tag
end

function CloudBackup:storeData(on_complete_function, on_fail_function, data)
	local url = self.server_url .. "store_data.php?uid=" .. self.user_id .. "&tag=" .. self.tag
	local loader = UrlLoader.new(url, UrlLoader.POST, nil, data)

	loader:addEventListener(
		Event.COMPLETE,
		function(event)
			local end_of_date = event.data:find(",")
			
			local backup_date = tonumber(event.data:sub(1,end_of_date-1))
			local error_message = event.data:sub(end_of_date+1)
			
			on_complete_function(backup_date, error_message)
		end
	)
end