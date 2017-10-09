import socket
import threading
from multiprocessing.dummy import Pool as ThreadPool
import time

class TcpServer(object):
	LISTEN_TIMEOUT = 0.5
	MAX_CONNECTIONS = 5

	def __init__(self, host = '', port = 15100):
		self.listenIp = host
		self.listenPort = port

		self.server = socket.socket(
			socket.AF_INET,
			socket.SOCK_STREAM
		)

	def listen(self):
		connectInfo = (self.listenIp, self.listenPort)
		self.server.bind(connectInfo)

		self.server.settimeout(self.LISTEN_TIMEOUT)
		self.server.listen(self.MAX_CONNECTIONS)

		print 'Listening on {}:{}'.format(*connectInfo)
		self._doListen()

	def _doListen(self):
		while True:
			try:
				client_socket, address = self.server.accept()

				print 'Accepted connection from {}:{}'.format(address[0], address[1])
				client_handler = threading.Thread(
					target=self.connectionHandler,
					args=(client_socket,)
				)
				client_handler.start()
			except socket.timeout:
				continue
			except KeyboardInterrupt:
				print 'Shutting down server'
				try:
					self.server.shutdown(socket.SHUT_RDWR)
				except:
					pass
				self.server.close()
				break
			except:
				pass

	def connectionHandler(self, client_socket):
		# FIXME: What should this value be?
		request = client_socket.recv(1024)
		print 'Received {}'.format(request)
		client_socket.send('ACK!')
		client_socket.close()

if __name__ == '__main__':
	gameServer = TcpServer()
	gameServer.listen()

