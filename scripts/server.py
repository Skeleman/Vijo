#!/usr/bin/env python
import json, sys
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer

PREFLIGHT_HEADERS = {
	'Access-Control-Allow-Headers': 'Content-Type',
	'Access-Control-Allow-Methods': 'PUT, POST, DELETE'
}

DEFAULT_HEADERS = {
	'Access-Control-Allow-Origin': '*'
}

class VijoHandler(BaseHTTPRequestHandler):
	def do_GET(self):
		self._emptyOK()

	def do_POST(self):
		self._emptyOK()

	def do_PUT(self):
		self._emptyOK()

	def do_OPTIONS(self):
		self._emptyOK()

	def _emptyOK(self):
		self.send_response(200)
		headers = PREFLIGHT_HEADERS
		headers.update(DEFAULT_HEADERS)
		for header, value in headers.iteritems():
			self.send_header(header, value)
		self.end_headers()
		self.wfile.write("")


def run(server_class=HTTPServer, handler_class=VijoHandler, port=8080):
	server_address = ('', port)
	httpd = server_class(server_address, handler_class)
	print 'Starting httpd...'
	try:
		httpd.serve_forever()
	except (KeyboardInterrupt, SystemExit):
		print "Done"

if __name__ == "__main__":
	if len(sys.argv) == 2:
		run(port=int(sys.argv[1]))
	else:
		run()
