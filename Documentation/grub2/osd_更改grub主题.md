# 				更改grub2主题

## 1.下载grub主题包

主题下载可到[这里](https://www.gnome-look.org/browse/cat/109/order/latest)

wget -c https://www.gnome-look.org/p/1429443/startdownload?file_id=1610800674&file_name=Cyberpunk-Theme-v0.5-1080.zip&file_type=application/zip&file_size=2683464

## 2.创建themes文件夹

```
$sudo mkdir /boot/grub/themes
```

## 3.解压并移动到/boot/grub/themes/下

```
$sudo tar -xf 主题包 
$sudo cp 主题包名 /boot/grub/themes/
```

## 4.修改配置文件

```
$sudo vim /etc/grub.d/00_header
```

#在注释下添加
GRUB-THEME="/boot/grub/themes/主题包下的theme.txt"

## 5.修改grub.cfg文件

```
loadfont ($root)/boot/grub/themes/Cyberpunk/Blender_Pro_Book_12.pf2                     
loadfont ($root)/boot/grub/themes/Cyberpunk/Blender_Pro_Book_14.pf2                     
loadfont ($root)/boot/grub/themes/Cyberpunk/Blender_Pro_Book_16.pf2                     
loadfont ($root)/boot/grub/themes/Cyberpunk/Blender_Pro_Book_24.pf2                     
loadfont ($root)/boot/grub/themes/Cyberpunk/Blender_Pro_Book_32.pf2                     
loadfont ($root)/boot/grub/themes/Cyberpunk/Blender_Pro_Book_48.pf2                     
loadfont ($root)/boot/grub/themes/Cyberpunk/terminus-12.pf2                             
loadfont ($root)/boot/grub/themes/Cyberpunk/terminus-14.pf2                             
loadfont ($root)/boot/grub/themes/Cyberpunk/terminus-16.pf2                             
loadfont ($root)/boot/grub/themes/Cyberpunk/terminus-18.pf2                             
insmod png                                                                              
set theme=($root)/boot/grub/themes/Cyberpunk/theme.txt                                  
export theme
```

增加如上内容加载Cyberpunk主题对应的字体等文件。