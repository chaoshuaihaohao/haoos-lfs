# 							更改grub字体

## .ttc字体文件和.ttf字体简介

​	TTC字体是TrueType字体集成文件(. TTC文件)，是在一单独文件结构中包含多种字体,以便更有效地共享轮廓数据,当多种字体共享同一笔画时,TTC技术可有效地减小字体文件的大小。
​	**TTC是几个TTF合成的字库**，安装后字体列表中会看到两个以上的字体。两个字体中大部分字都一样时，可以将两种字体做成一个TTC文件，现在常见的TTC字体，因为共享笔划数据，所以大多这个集合中的字体区别只是字符宽度不一样，以便适应不同的版面排版要求。
​	而TTF字体则只包含一种字型。
​	以下是关于TTC和TTF字体的英文解释：

  TTC：TrueType Collection file. A scheme where multiple TrueType fonts can be stored in a single file, typically used when only a subset of glyphs changes among different designs. They're used in Japanese fonts, where the Kana glyphs changebut the Kanji remain the same. 
  TTF：The recommended file extension for TrueType font files on the PC. On the Macintosh, exactly the same data is in an *'sfnt' resource. The recommended file extension for the TrueType flavour of *OpenType fonts is also TTF. (But Type 1 flavour OpenType fonts should have an OTF extension.) 

Linux各种应用程序支持的各种字体可以在`/usr/share/fonts/`目录下找到。

`/usr/share/fonts/truetype/`是TrueType字体目录。

## grub-mkfont命令

制作GRUB字体文件*.pf2。

```
uos@home:~/Desktop/字体$ sudo grub-mkfont --help
用法： grub-mkfont [OPTION...] [OPTIONS] FONT_FILES
将常见字体文件格式转换为PF2

 -a, --force-autohint    	强制自动提示	force autohint
 -b, --bold         		转换为粗体	convert to bold font
 -c, --asce=NUM       		设置字体上升	set font ascent
 -d, --desc=NUM       		设置字体下降	set font descent
 -i, --index=NUM       		选择面部索引	select face index
 -n, --name=NAME       		设置字体系列名称	set font family name
   --no-bitmap       		加载时忽略位图罢工	ignore bitmap strikes when loading
   --no-hinting      		禁用提示	disable hinting
 -o, --output=文件		   将输出保存到FILE [必需]	save output in FILE [required]
 -r, --range=FROM-TO[,FROM-TO]  设置字体范围	set font range
 -s, --size=SIZE       		设置字体大小		set font size
 -v, --verbose        		打印详细消息。		print verbose messages.
 -?, --help         		提供此帮助列表		give this help list
   --usage         			给出简短的用法信息	give a short usage message
 -V, --version        		打印程序版本		print program version

长选项的强制性或可选参数对于任何相应的短选项也是强制性的或可选的。
Report bugs to <bug-grub@gnu.org>.
```

\#案例

```
uos@home:~/Desktop/字体$ sudo grub-mkfont -o yinghuo.pf2 -n yinghuo ./yinghuo.ttc -v
Font name: yinghuo Regular 16
Max width: 46
Max height: 20
Font ascent: 17
Font descent: 6
Number of glyph: 34511
```

可通过-b选项，将字体转换为粗体。

## 给grub添加字体文件

grub目录架构如下：

```
/boot/grub
/boot/grub/fonts：存放grub字体的目录
```

将`/usr/share/fonts/truetype/`目录下的所有字体文件转换为.pf2文件

#可以使用如下脚本批量转换.ttf文件为.pf2文件：

```
for file in `find /usr/share/fonts/truetype/ -name *.ttf | xargs realpath | uniq` 
do
	cp $file ./ttf/
done

cd ttf
for file in `ls .` 
do
	name=`echo $file | awk -F '[.]' '{print $1}'`
	grub-mkfont -o ../pf2/$name.pf2 $file
done
```

## grub.cfg添加grub字体加载命令

grub提供了loadfont加载字体文件，如果没有loadfont命令，可以尝试：

```
insmod /boot/grub/i386-pc/loadfont.mod
```

加载该命令模块。

在grub.cfg前面添加`loadfont /boot/grub/fonts/<字体名>.pf2`即可：

```
loadfont /boot/grub/fonts/unifont.pf2
```

```
font=unicode
set gfxmode=auto
if loadfont $font ; then
	set gfxmode=1920x1080
	load_video
	insmod gfxterm
	set locale_dir=$prefix/locale
	set lang=zh_CN
	insmod gettext
	echo
fi
```

## 目前最好的字型设计开源软件fontforge

```
sudo apt install fontforge
```

通过该软件可以打开.ttf格式字体文件。



## 参考文献

[[Linux字体美化实战(Fontconfig配置)](http://www.jinbuguo.com/gui/linux_fontconfig.html)]

[[TTF文件的制作——打造属于自己的字体](https://www.cnblogs.com/yuanbao/archive/2010/04/28/1722608.html)]

[[unicode编码](http://www.unicode.org/charts/)]















## 