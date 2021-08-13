# 软件包适配指导文档



haoos搭配自研的包安装器pkg-install，将软件包适配拆分为三部分功能：

## *.info文件

描述软件包信息的文件。后续随着pkg-install工具的功能增强，该文件可能会包含更多的功能。

当前该文件包含了要安装的软件包的下载链接地址。

可通过`pkg-install -d <软件包名>`命令下载软件包到/sources/blfs-sources目录。

可通过`pkg-install -i <软件包名>`命令安装软件包。

## *.dep文件

描述要安装的软件包所依赖的软件包信息。需要填充依赖的软件包名。

## *.cmd文件

安装软件包的配置编译命令。

## 案例

### 安装nasm

#### nasm.info文件

```
Download: http://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.xz
Download: http://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05-xdoc.tar.xz
```

Download:后面需要跟空格‘　’，当前是根据空格作为分隔符来获取软件包的下载链接地址。

第一行是主软件包，第二行是文档压缩包。pkg-install会根据第一行的主软件包下载链接来转换pushd目录，从而执行安装命令。

#### nasm.dep文件

```
asciidoc
xmlto
```

nasm软件包依赖asciidoc和xmlto，pkg-install包安装器会解析该文件，通过匹配软件安装列表LIST文件，如果没有找到依赖包名，则说明没有安装，pkg-install会安装依赖包asciidoc和xmlto，然后才会安装nasm软件包。

#### nams.cmd文件

```
tar -xf $BLFS_SRC_DIR/nasm-2.15.05-xdoc.tar.xz --strip-components=1

./configure --prefix=/usr &&
make

make install

install -m755 -d         /usr/share/doc/nasm-2.15.05/html  &&
cp -v doc/html/*.html    /usr/share/doc/nasm-2.15.05/html  &&
cp -v doc/*.{txt,ps,pdf} /usr/share/doc/nasm-2.15.05
```

这是安装nasm软件包的命令。pkg-install工具预处理了目录的转换、还原和软件包的解压缩，

```
pushd /lfs/软件包名
	执行软件包安装命令
popd
```

