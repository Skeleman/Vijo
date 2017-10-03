
local Network = {
	remoteUrl = "http://127.0.0.1:8080"
}

local http = require("socket.http")

function Network:testRequest()
	print "Sending request"
	r, c, h = http.request {
		method = "GET",
		url = Network.remoteUrl
	}
end

return Network