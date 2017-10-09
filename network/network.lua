
local NetworkManager = {
	remoteHost = "127.0.0.1",
	remotePort = "15100"
}

local UPDATE_PERIOD = 0.25 -- Time is seconds to update

local host, port = NetworkManager.remoteHost, NetworkManager.remotePort
local socket = require("socket")
local currentTime = 0
-- local udp = assert(socket.udp())

function NetworkManager:canUpdate(dt)
	currentTime = currentTime + dt
	if currentTime > UPDATE_PERIOD then
		currentTime = 0
		return true
	end
	return false
end

function NetworkManager:testRequest()
	print "Sending request"
	tcp = assert(socket.tcp())
	if(tcp:connect(host, port)) then
		sendMessage("Hello")
		response = getResponse()
		print("Received: " .. response)
		tcp:close()
	end

end

function sendMessage(message)
	assert(tcp:send(message .. "\n"))
end

function getResponse()
	response = ""
	while true do
		local line, err, partial = tcp:receive()
		line = line or partial
		if line then
			response = response .. line
		end
		if err == "closed" then break end
	end
	return response
end

return NetworkManager