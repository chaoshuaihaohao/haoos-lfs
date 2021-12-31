CC=gcc
CFLAGS=-g -O0
DLLFLAGS= -lxml2
EOBJ=./xml
SOURCE=$(wildcard *.c)
OBJS=$(patsubst %.c,%.o,$(SOURCE))
$(EOBJ):$(OBJS)
	sudo ln -svf /usr/include/libxml2/libxml   /usr/include/libxml
	C_INCLUDE_PATH=/usr/include/libxml2
	export C_INCLUDE_PATH
	#$(CC) $(CFLAGS) $(OBJS) $(DLLFLAGS) -o $(EOBJ)
	$(CC) $(CFLAGS) xml.c $(DLLFLAGS) -o $(EOBJ)
	$(CC) $(CFLAGS) blfs-xml.c $(DLLFLAGS) -o blfs-xml
clean:
	rm -f $(OBJS) $(EOBJ)
