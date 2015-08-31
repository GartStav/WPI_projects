all: client server

client: client.c data_link_layer.c

	gcc data_link_layer.c client.c -o client -lrt -L/opt/lib

server: server.c  data_link_layer.c 
	gcc data_link_layer.c  server.c -o server -lrt -L/opt/lib.
