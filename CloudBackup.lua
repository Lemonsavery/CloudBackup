CloudBackup = gideros.class()

CloudBackup.OK = 0
CloudBackup.ERROR = 1

CloudBackup.STATUS_OK = 1
CloudBackup.STATUS_INVALID_STATE = 2


function CloudBackup:init(server_url, user_id, tag)
	-- Constructor
	self.server_url = server_url
	self.user_id = user_id
	self.tag = tag

	-- Checks member variables for validity.
	self.status = CloudBackup.STATUS_OK
	self.status_message = ""

	function url_safe(string)
		local safe = nil
		-- if string contains a character in the unsafe list, safe=false
		safe = true
		return safe
	end

	if self.tag ~= nil then
		if type(self.tag) ~= type("") then
			if ~url_safe(self.tag) then
				self.status = CloudBackup.STATUS_INVALID_STATE
				self.status_message = "tag contains characters unsafe for URL"
			end
			self.status = CloudBackup.STATUS_INVALID_STATE
			self.status_message = "tag not string - tag must be string"
		end
	else
		self.status = CloudBackup.STATUS_INVALID_STATE
		self.status_message = "tag is nil - tag must be string"
	end

	if self.user_id ~= nil then
		if type(self.user_id) ~= type("") then
			if ~url_safe(self.user_id) then
				self.status = CloudBackup.STATUS_INVALID_STATE
				self.status_message = "user_id contains characters unsafe for URL"
			end
			self.status = CloudBackup.STATUS_INVALID_STATE
			self.status_message = "user_id not string - user_id must be string"
		end
	else
		self.status = CloudBackup.STATUS_INVALID_STATE
		self.status_message = "user_id is nil - user_id must be string"
	end

	if self.server_url ~= nil then
		if type(self.server_url) == type("") then
			if string.sub(self.server_url, -1) ~= "/" then
				self.status = CloudBackup.STATUS_INVALID_STATE
				self.status_message = "server_url doesn't end in / - server_url must end in /"
			end
		else
			self.status = CloudBackup.STATUS_INVALID_STATE
			self.status_message = "server_url not string - server_url must be string"
		end
	else
		self.status = CloudBackup.STATUS_INVALID_STATE
		self.status_message = "server_url is nil - server_url must be string"
	end
end


function CloudBackup:storeData(on_complete_function, on_fail_function, data)
	local error = CloudBackup.OK
	local error_message = ""

	if self.status == CloudBackup.STATUS_OK then
		if type(data) == type("") then
			local url = self.server_url .. "store_data.php?uid=" .. self.user_id .. "&tag=" .. self.tag

			local loader = UrlLoader.new(url, UrlLoader.POST, nil, data)

			if type(on_complete_function) == type(type) then
				loader:addEventListener(
					Event.COMPLETE,
					function(event)
						local backup_date = 0

						if event ~= nil then
							if type(event.data) == type("") then
								local end_of_date = event.data:find(",")

								if end_of_date ~= nil then
									backup_date = tonumber(event.data:sub(1,end_of_date-1))
									if backup_date ~= nil then
										-- Error handling for all server-side errors.
										error_message = event.data:sub(end_of_date+1)
									else
										backup_date = 0
										error_message = "recieved backup_date containing non-numeric character(s) - (" .. event.data:sub(1,end_of_date-1) .. ")"
									end
								else
									error_message = "recieved incorrectly formatted data"
								end
							else
								error_message = "event.data is not a string"
							end
						else
							error_message = "event object is missing"
						end

						on_complete_function(backup_date, error_message)
					end
				)
			end

			if type(on_fail_function) == type(type) then
				loader:addEventListener(
					-- Error handling for inability to reach host.
					Event.ERROR,
					on_fail_function
				)
			end

		else
			error = CloudBackup.ERROR
			if data == nil then
				error_message = "data is nil - data must be string"
			else
				error_message = "data not string - data must be string"
			end
		end
	else
		error = CloudBackup.ERROR
		error_message = self.status_message
	end

	return error, error_message
end


function CloudBackup:retrieveData(on_complete_function, on_fail_function)
	local error = CloudBackup.OK
	local error_message = ""

	if self.status == CloudBackup.STATUS_OK then
		local url = self.server_url .. "get_data.php?uid=" .. self.user_id .. "&tag=" .. self.tag

		local loader = UrlLoader.new(url)

		if type(on_complete_function) == type(type) then
			loader:addEventListener(
				Event.COMPLETE,
				function(event)
					local backup_date, retrieved_data = 0, ""

					if event ~= nil then
						if type(event.data) == type("") then
							local end_of_date, end_of_error = nil, nil
							end_of_date = event.data:find(",")
							if end_of_date ~= nil then
								end_of_error = event.data:find(",",end_of_date+1)
							end

							if end_of_date ~= nil and end_of_error ~= nil then
								backup_date = tonumber(event.data:sub(1,end_of_date-1))
								if backup_date ~= nil then
									-- Error handling for all server-side errors.
									error_message = event.data:sub(end_of_date+1,end_of_error-1)
									retrieved_data = event.data:sub(end_of_error+1)
								else
									backup_date = 0
									error_message = "recieved backup_date containing non-numeric character(s) - (" .. event.data:sub(1,end_of_date-1) .. ")"
								end
							else
								error_message = "recieved incorrectly formatted data"
							end
						else
							error_message = "event.data is not a string"
						end
					else
						error_message = "event object is missing"
					end

					on_complete_function(backup_date, error_message, retrieved_data)
				end
			)
		end

		if type(on_fail_function) == type(type) then
			loader:addEventListener(
				-- Error handling for inability to reach host.
				Event.ERROR,
				on_fail_function
			)
		end

	else
		error = CloudBackup.ERROR
		error_message = self.status_message
	end

	return error, error_message
end


function CloudBackup:getBackupDate(on_complete_function, on_fail_function)
	local error = CloudBackup.OK
	local error_message = ""

	if self.status == CloudBackup.STATUS_OK then
		local url = self.server_url .. "get_date.php?uid=" .. self.user_id .. "&tag=" .. self.tag

		local loader = UrlLoader.new(url)

		if type(on_complete_function) == type(type) then
			loader:addEventListener(
				Event.COMPLETE,
				function(event)
					local backup_date = 0

					if event ~= nil then
						if type(event.data) == type("") then
							local end_of_date = event.data:find(",")

							if end_of_date ~= nil then
								backup_date = tonumber(event.data:sub(1,end_of_date-1))
								if backup_date ~= nil then
									-- Error handling for all server-side errors.
									error_message = event.data:sub(end_of_date+1)
								else
									backup_date = 0
									error_message = "recieved backup_date containing non-numeric character(s) - (" .. event.data:sub(1,end_of_date-1) .. ")"
								end
							else
								error_message = "recieved incorrectly formatted data"
							end
						else
							error_message = "event.data is not a string"
						end
					else
						error_message = "event object is missing"
					end

					on_complete_function(backup_date, error_message)
				end
			)
		end

		if type(on_fail_function) == type(type) then
			loader:addEventListener(
				-- Error handling for inability to reach host.
				Event.ERROR,
				on_fail_function
			)
		end

	else
		error = CloudBackup.ERROR
		error_message = self.status_message
	end

	return error, error_message
end


function CloudBackup:getTags(on_complete_function, on_fail_function)
	local error = CloudBackup.OK
	local error_message = ""

	if self.status == CloudBackup.STATUS_OK then
		local url = self.server_url .. "get_tags.php?uid=" .. self.user_id

		local loader = UrlLoader.new(url)

		if type(on_complete_function) == type(type) then
			loader:addEventListener(
				Event.COMPLETE,
				function(event)
					local tags = {}

					if event ~= nil then
						if type(event.data) == type("") then
							local end_of_message = event.data:find("<")

							if end_of_message ~= nil then
								-- Error handling for all server-side errors.
								error_message = event.data:sub(1,end_of_message-1)

								local tag_start = end_of_message
								local tag_end = event.data:find("<",tag_start+1)
								local tag_index = 1
								while tag_end ~= nil do
									tags[tag_index] = event.data:sub(tag_start+1,tag_end-1)
									tag_index = tag_index + 1
									tag_start = tag_end
									tag_end = event.data:find("<",tag_start+1)
								end
								tags[tag_index] = event.data:sub(tag_start+1)
							else
								error_message = "recieved incorrectly formatted data"
							end
						else
							error_message = "event.data is not a string"
						end
					else
						error_message = "event object is missing"
					end

					on_complete_function(error_message, tags)
				end
			)
		end

		if type(on_fail_function) == type(type) then
			loader:addEventListener(
				-- Error handling for inability to reach host.
				Event.ERROR,
				on_fail_function
			)
		end

	else
		error = CloudBackup.ERROR
		error_message = self.status_message
	end

	return error, error_message
end


function originateTable(server_url)
	if server_url ~= nil then
		if type(server_url) == type("") then
			-- This is just a potentially helpful convenience when setting the server_url.
			if string.sub(server_url, -1) ~= "/" then
				server_url = server_url .. "/"
			end
		else
			print("server_url not string - server_url must be string")
		end
	else
		print("server_url nil - server_url cannot be nil")
	end

	local url = server_url .. "originate_table.php"
	local loader = UrlLoader.new(url)

	loader:addEventListener(
		Event.COMPLETE,
		function(event)
			print(event.data)
		end
	)
	loader:addEventListener(
		Event.ERROR,
		function(event)
			print("could not connect to url")
		end
	)
end
