import re
import os
import kconfiglib


def build_makefile_node(sym):
    build_target(sym)
    build_dep_list(sym)
    build_run_cmd(sym)

def build_target(sym):
    for root, dirs, files in os.walk(path):
        for file in files:
            if re.search(r'[0-9]-\b{}\b$'.format(sym.name), file):
                file=file.strip()
                print(sym.name, ":", end='');
                global CHROOT
                CHROOT=f"{CHROOT} {sym.name}"

def build_dep_list(sym):
    dep_list = expr_items(sym.direct_dep)
    # 输出配置选项名称和依赖项
    for dep in dep_list:
        if dep.name != 'y':
            find_order_name(dep.name)
    print();
    
def find_order_name(name):
    for root, dirs, files in os.walk(path):
        for file in files:
            if re.search(r'[0-9]-\b{}\b$'.format(name), file):
                print(" ", name, end='');

def build_run_cmd(sym):
    for root, dirs, files in os.walk(path):
        for file in files:
            if re.search(r'[0-9]-\b{}\b$'.format(sym.name), file):
                file_path = os.path.join(root, file)  # 获取文件的绝对路径
                print("\t", file_path.replace("/mnt/build_dir",''))  # 添加这一行，打印文件的绝对路径


def build_CHROOT(sym):
    print("CHROOT: ")

from kconfiglib import Kconfig, Symbol, Choice, COMMENT, MENU, MenuNode, \
                       BOOL, TRISTATE, HEX, \
                       TRI_TO_STR, \
                       escape, unescape, \
                       expr_str, expr_items, split_expr, \
                       _ordered_unique, \
                       OR, AND, \
                       KconfigError
  
# 打开kconfig文件并创建Kconfig对象  
kconfig = Kconfig('cmd.txt')

path='/mnt/build_dir/jhalfs/blfs-commands/'
CHROOT="CHROOT: "

# 打开文件并读取所有行  
with open('blfs-configuration', 'r') as file:  
    for line in file:  
        if '=y' in line:
            target=line.replace('=y', '').strip()
            # 遍历所有配置选项.Kconfig has no order.  configuration has no order too.
            for sym in kconfig.unique_defined_syms:
                if target == sym.name:
                    build_makefile_node(sym)

print(CHROOT)
#---

