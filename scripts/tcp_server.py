import socket
import threading
import time

bind_ip = '' # FIXME: listen on all interfaces until for now
bind_port = 15100
closing = False

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((bind_ip, bind_port))

server.settimeout(0.2)
server.listen(5)  # max backlog of connections

print 'Listening on {}:{}'.format(bind_ip, bind_port)


def handle_client_connection(client_socket):
	request = client_socket.recv(1024)
	print 'Received {}'.format(request)
	client_socket.send('ACK!')
	client_socket.close()

while True:
	if closing:
		break
	try:
		client_sock, address = server.accept()
	except socket.timeout as e:
		continue
	except KeyboardInterrupt:
		print "Shutting down server"
		server.close()
		break

	print 'Accepted connection from {}:{}'.format(address[0], address[1])
	client_handler = threading.Thread(
		target=handle_client_connection,
		args=(client_sock,)  # without comma you'd get a... TypeError: handle_client_connection() argument after * must be a sequence, not _socketobject
	)
	client_handler.start()

