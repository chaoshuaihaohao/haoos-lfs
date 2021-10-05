#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <unistd.h>

#include <libxml/parser.h>
#include <libxml/tree.h>

#if 0
//To turn on/off Debug printf;
#define __DEBUG_PRINTF__
#endif

#ifdef __DEBUG_PRINTF__
#define DEBUG(format,...)           printf(""format"\n",  ##__VA_ARGS__ )
#else
#define DEBUG(format,...)
#endif

#if 0
/**
 * xmlParser 选项：
 *
 * 这是一组可以传递给 xmlReadDoc() 和类似调用的 XML 解析器选项。
 */
enum {
	XML_PARSE_RECOVER = 1 << 0,	/* 出错时恢复 */
	XML_PARSE_NOENT = 1 << 1,	/* 替换实体 */
	XML_PARSE_DTDLOAD = 1 << 2,	/* 加载外部子集 */ //遇到"http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd"这种会很卡
	XML_PARSE_DTDATTR = 1 << 3,	/* 默认 DTD 属性 */
	XML_PARSE_DTDVALID = 1 << 4,	/* 使用 DTD 验证 */
	XML_PARSE_NOERROR = 1 << 5,	/* 抑制错误报告 */
	XML_PARSE_NOWARNING = 1 << 6,	/* 禁止警告报告 */
	XML_PARSE_PEDANTIC = 1 << 7,	/* 迂腐的错误报告 */
	XML_PARSE_NOBLANKS = 1 << 8,	/* 删除空白节点 */
	XML_PARSE_SAX1 = 1 << 9,	/* 内部使用 SAX1 接口 */
	XML_PARSE_XINCLUDE = 1 << 10,	/* 实现 XInclude 替换 */
	XML_PARSE_NONET = 1 << 11,	/* 禁止网络访问 */
	XML_PARSE_NODICT = 1 << 12,	/* 不要重用上下文字典 */
	XML_PARSE_NSCLEAN = 1 << 13,	/* 删除多余的命名空间声明 */
	XML_PARSE_NOCDATA = 1 << 14,	/* 将 CDATA 合并为文本节点 */
	XML_PARSE_NOXINCNODE = 1 << 15,	/* 不生成 XINCLUDE START/END 节点 */
	XML_PARSE_COMPACT = 1 << 16,	/* 压缩小文本节点；之后不允许修改树（如果您尝试修改树，则可能会崩溃） */
	XML_PARSE_OLD10 = 1 << 17,	/* 在更新 5 之前使用 XML-1.0 解析 */
	XML_PARSE_NOBASEFIX = 1 << 18,	/* 不要修正 XINCLUDE xml:base uris */
	XML_PARSE_HUGE = 1 << 19,	/* 放宽解析器的任何硬编码限制 */
	XML_PARSE_OLDSAX = 1 << 20,	/* 2.7.0 之前使用 SAX2 接口解析 */
	XML_PARSE_IGNORE_ENC = 1 << 21,	/* 忽略内部文档编码提示 */
	XML_PARSE_BIG_LINES = 1 << 22	/* 在文本 PSVI 字段中存储大行数 */
} xmlParserOption;
#endif

char *const short_options = "t:n:";     //有参数的需要跟':'。
struct option long_options[] = {
	{ "node type", 1, NULL, 't' },
	{ "node name", 1, NULL, 'n' },
	{ 0, 0, 0, 0 },
};

static void usage()
{
	printf("Usage:\n"
	       "	./xml -n <cmd|pkg>\n"
	       "	cmd:解析.cmd内容\n"
	       "	pkg:解析.pkg内容\n"
	       );

}

int main(int argc, char **argv)
{
	if (argc <= 2) {
		usage();
		return -1;
	}

	xmlDocPtr pdoc = NULL;
	xmlNodePtr proot = NULL, pcur = NULL, node = NULL, tmp = NULL;

/*****************打开xml文档********************/
	xmlKeepBlanksDefault(0);	//必须加上，防止程序把元素前后的空白文本符号当作一个node

	int options =
	    XML_PARSE_RECOVER | XML_PARSE_NOENT |
	    XML_PARSE_NOERROR | XML_PARSE_NOWARNING |
	    XML_PARSE_NOBLANKS | XML_PARSE_XINCLUDE | XML_PARSE_NODICT |
	    XML_PARSE_NSCLEAN | XML_PARSE_NOCDATA | XML_PARSE_COMPACT |
	    XML_PARSE_OLD10 | XML_PARSE_OLDSAX | XML_PARSE_HUGE |
	    XML_PARSE_BIG_LINES;
	pdoc = xmlReadFile(argv[argc - 1], "ISO-8859-1", options);	//libxml只能解析UTF-8格式数据
	if (pdoc == NULL) {
		printf("Error:can't open file!\n");
		exit(1);
	}

/*****************获取xml文档对象的根节对象********************/
	proot = xmlDocGetRootElement(pdoc);
	if (proot == NULL) {
		printf("error: file is empty!\n");
		exit(1);
	}
	DEBUG("proot name:%s\n", (char *)proot->name);

	int c;
	char *name;
	char *type;

          while ((c =                                                                                                                                                     
                  getopt_long(argc, argv, short_options, long_options,                                                                                                    
                              NULL)) != -1) {                                                                                                                             
                  switch (c) {                                                                                                                                            
                  case 't':                                                                                                                                               
			  type = optarg;
                          DEBUG("type name is %s\n", type);                                                                                                                     
                          break;                                                                                                                                          
                  case 'n':
			  name = optarg;
                          DEBUG("name is %s\n", name);                                                                                                                    
                          break;                                                                                                                                          
                  }                                                                                                                                                       
          }                                                                                                                                                               
/*****************遍历所有node of xml tree********************/
//先遍历node的所有child node,如果全遍历完了,再遍历上一级的next node.
//1--->
//    2--->
//         3--->
//    2.1-->
//         3.1--->
	pcur = proot->xmlChildrenNode;
	for (node = pcur; node != NULL;) {
//              if (node)
		DEBUG("node->name:%s\n", node->name);

		DEBUG("node->xmlChildrenNode:%p\n", node->xmlChildrenNode);
		DEBUG("node->next:%p\n", node->next);
#if 1
//如同标准C中的char类型一样，xmlChar也有动态内存分配，字符串操作等 相关函数。
//例如xmlMalloc是动态分配内存的函数；xmlFree是配套的释放内存函数；xmlStrcmp是字符串比较函数等。
//对于char* ch="book", xmlChar* xch=BAD_CAST(ch)或者xmlChar* xch=(const xmlChar *)(ch)
//对于xmlChar* xch=BAD_CAST("book")，char* ch=(char *)(xch)

		if (!strcmp(name, "cmd")) {
			if (!xmlStrcmp(node->name, BAD_CAST("userinput")) &&
			    !xmlStrcmp(node->parent->name, BAD_CAST("screen")) &&
			    !xmlStrcmp(node->children->name, BAD_CAST("text"))) {
				if (!node->properties || xmlStrcmp(node->properties->children->content, BAD_CAST("test")))
					printf("%s\n", ((char *)
							XML_GET_CONTENT(node->xmlChildrenNode)));
			}
			if (!xmlStrcmp(node->name, BAD_CAST("literal")) &&
			    !xmlStrcmp(node->parent->name, BAD_CAST("userinput"))) {
				printf("%s\n", ((char *)
						XML_GET_CONTENT(node->xmlChildrenNode)));
				if (node->next)
					printf("%s\n", ((char *)
							XML_GET_CONTENT(node->next)));
			}
		}

		if (!strcmp(name, "pkg")) {
			if (!xmlStrcmp(node->parent->name, BAD_CAST("varlistentry")) &&
			    !xmlStrcmp(node->name, BAD_CAST("term"))) {
				printf("%s\n", ((char *)
						XML_GET_CONTENT(node->xmlChildrenNode)));
			}
			if (!xmlStrcmp(node->parent->name, BAD_CAST("listitem")) &&
			    !xmlStrcmp(node->name, BAD_CAST("para"))) {
				printf("%s", ((char *)
						XML_GET_CONTENT(node->xmlChildrenNode)));	//para的子节点就是我们所需要的TEXT。
			}
			if (!xmlStrcmp(node->name, BAD_CAST("literal"))) {
				printf("%s\n", ((char *)
						XML_GET_CONTENT(node->xmlChildrenNode)));
			}
			if (!xmlStrcmp(node->name, BAD_CAST("ulink"))) {
				printf("%s\n", ((char *)
						XML_GET_CONTENT(node->properties->children)));
			}
		}
#endif
		//如果子节点不为空，继续解析子节点
		//如果子节点为空，就解析当前节点的下一个节点
		//      如果下一个节点还是为空，说明读到底了；
		//      则读当前节点的父节点的下一个节点（父节点不能是proot节点）
		//以TEXT节点为例
		if (node->xmlChildrenNode)
			node = node->xmlChildrenNode;
		else if (node->next)
			node = node->next;
		else {	//一直往上找,直到parent->next非空为止,或parent->next为空且parent=proot为止
			for (node = node->parent; node != proot; node = node->parent)
			{
				if (node->next) {
					node = node->next;
					break;
				}
			}
			if (node == proot) {
				node = NULL;
				goto __out;
			}
		}
	}

__out:
/*****************释放资源********************/
	xmlFreeDoc(pdoc);
	xmlCleanupParser();
	xmlMemoryDump();
	return 0;
}
