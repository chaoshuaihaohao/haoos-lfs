# 一个包是如何发给另一台机器的

网络

#模型一:两台机器千兆网口通过有线对连

一台机器作为客户端(ip 192.168.1.11),另一台机器作为服务端 (ip 192.168.1.12)

#TCP传输

客户端应用编程,net-client.c

```
#include <stdio.h>
#include <string.h>		//bzero
#include <stdlib.h>		//exit

#include <unistd.h>		//read,close
#include <netinet/in.h>		//IPPROTO_TCP
#include <arpa/inet.h>		//htons,htonl

#include <sys/types.h>
#include <sys/socket.h>		//socket,bind

#include <getopt.h>

void usage()
{
	printf("Usage:\n"
	       "\t-i <host ip>\t\t:set the server ip\n"
	       "\t-p <port>\t\t:set the server port\n"
	       "\t-m <message string>\t:set the message to send\n");
}

char *l_opt_arg;
char* const short_options = "i:p:m:";
struct option long_options[] = {
	{"host ip", 1, NULL, 'i' },
	{"port", 1, NULL, 'p' },
	{"msg", 1, NULL, 'm' },
	{0, 0, 0, 0 },
};

int main(int argc, char *argv[])
{
	if (argc < 4) {
	//	fprintf(stderr, "Usage: %s host port msg...\n", argv[0]);
		usage();
		exit(EXIT_FAILURE);
	}

	int c;
	char *server_ip = "192.168.1.22";	// 服务器ip地址
	unsigned short port = 8000;	// 服务器的端口号
	char *msg = NULL;
	while ((c = getopt_long(argc, argv, short_options, long_options, NULL)) != -1)
	{
		switch (c)
		{
		case 'i':
			l_opt_arg = optarg;
			printf("i:%s\n", l_opt_arg);
			server_ip = l_opt_arg;
			break;
		case 'p':
			l_opt_arg = optarg;
			printf("p:%s\n", l_opt_arg);
			port = atoi(l_opt_arg);
			break;
		case 'm':
			l_opt_arg = optarg;
			printf("m:%s\n", l_opt_arg);
			msg = l_opt_arg;
			break;
		default:
			usage();
			exit(EXIT_FAILURE);
		}
	}

	int sockfd;
	sockfd = socket(AF_INET, SOCK_STREAM, 0);	// 创建通信端点：套接字
	if (sockfd < 0) {
		perror("socket");
		exit(-1);
	}

	struct sockaddr_in server_addr;
	bzero(&server_addr, sizeof(server_addr));	// 初始化服务器地址
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(port);
	//将点分格式ip转换为二进制格式
	inet_pton(AF_INET, server_ip, &server_addr.sin_addr);

	int err_log = connect(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)); // 主动连接服务器
	if (err_log != 0) {
		perror("connect");
		close(sockfd);
		exit(-1);
	}
	send(sockfd, msg, strlen(msg), 0);	// 向服务器发送信息
	close(sockfd);
	return 0;
}
```

服务端应用编程:net-server.c

```
#include <stdio.h>
#include <string.h>		//bzero
#include <stdlib.h>		//exit

#include <unistd.h>		//read,close
#include <sys/types.h>
#include <sys/socket.h>		//socket,bind
#include <arpa/inet.h>		//htons,htonl

//#include <netinet/in.h>

int main(int argc, char *argv[])
{
	unsigned short port = 8000;
	if (argv[1] != NULL)
		port = atoi(argv[1]);

	int sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if (sockfd < 0) {
		perror("socket");
		exit(-1);
	}

	struct sockaddr_in my_addr;
	bzero(&my_addr, sizeof(my_addr));
	my_addr.sin_family = AF_INET;
	my_addr.sin_port = htons(port);
	my_addr.sin_addr.s_addr = htonl(INADDR_ANY);

	int err_log =
	    bind(sockfd, (struct sockaddr *)&my_addr, sizeof(my_addr));
	if (err_log != 0) {
		perror("binding");
		close(sockfd);
		exit(-1);
	}

#if 0
	err_log = listen(sockfd, 1);	// 等待队列为2
#else
	err_log = listen(sockfd, 0);	// 等待队列为1
#endif
	if (err_log != 0) {
		perror("listen");
		close(sockfd);
		exit(-1);
	}
	printf("listen client @port=%d...\n", port);

	int i = 0;

	while (1) {
		struct sockaddr_in client_addr;
		char client_ip[INET_ADDRSTRLEN] = { 0 };
		socklen_t cliaddr_len = sizeof(client_addr);

		int connfd;
		connfd =
		    accept(sockfd, (struct sockaddr *)&client_addr,
			   &cliaddr_len);
		if (connfd < 0) {
			perror("accept");
			continue;
		}

		inet_ntop(AF_INET, &client_addr.sin_addr, client_ip,
			  INET_ADDRSTRLEN);
		printf("-----------%d------\n", ++i);
		printf("client ip: %s, port: %d\n", client_ip,
		       ntohs(client_addr.sin_port));

		char recv_buf[500] = { 0 };
		while (recv(connfd, recv_buf, sizeof(recv_buf), 0) > 0) {
			printf("recv data: %s\n", recv_buf);
			break;
		}

		close(connfd);	//关闭已连接套接字
		printf("client closed!\n");
	}
	close(sockfd);		//关闭监听套接字
	return 0;
}
```

Makefile

```
all:
	gcc -o net-client net-client.c
	gcc -o net-server net-server.c

clean:
	rm net-client net-server
```

客户端发送helloworld给服务端,服务端恢复good.



./net-client -i 127.0.0.1 -p 8000 -m helloworld





以netperf为例

src/netperf.c

