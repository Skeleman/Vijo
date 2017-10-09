
local Network = {
	remoteHost = "127.0.0.1",
	remotePort = "15100"
}

local host, port = Network.remoteHost, Network.remotePort
local socket = require("socket")
-- local udp = assert(socket.udp())

function Network:testRequest()
	print "Sending request"
	tcp = assert(socket.tcp())
	assert(tcp:connect(host, port));
	-- note the newline below
	assert(tcp:send("hello world\n"));
	-- udp:sendto("This is a test", host, port)

	-- print(udp:receive())

	while true do
		local s, status, partial = tcp:receive()
		print(s or partial)
		if status == "closed" then break end
	end
	print("Done receiving")
	tcp:close()
end

return Network