tar -xf $BLFS_SRC_DIR/clang-11.1.0.src.tar.xz -C tools &&
mv tools/clang-11.1.0.src tools/clang

tar -xf $BLFS_SRC_DIR/compiler-rt-11.1.0.src.tar.xz -C projects &&
mv projects/compiler-rt-11.1.0.src projects/compiler-rt

grep -rl '#!.*python' | xargs sed -i '1s/python$/python3/'

#通过运行以下命令来 安装LLVM：
mkdir -v build &&
pushd       build &&
CC=gcc CXX=g++                                  \
cmake -DCMAKE_INSTALL_PREFIX=/usr               \
      -DLLVM_ENABLE_FFI=ON                      \
      -DCMAKE_BUILD_TYPE=Release                \
      -DLLVM_BUILD_LLVM_DYLIB=ON                \
      -DLLVM_LINK_LLVM_DYLIB=ON                 \
      -DLLVM_ENABLE_RTTI=ON                     \
      -DLLVM_TARGETS_TO_BUILD="host;AMDGPU;BPF" \
      -DLLVM_BUILD_TESTS=ON                     \
      -DLLVM_BINUTILS_INCDIR=/usr/include       \
      -Wno-dev -G Ninja ..                      &&
ninja

#如果您已经安装了Sphinx和 recommonmark，并希望生成html文档和手册页，请发出以下命令：
#cmake -DLLVM_BUILD_DOCS=ON            \
#      -DLLVM_ENABLE_SPHINX=ON         \
#      -DSPHINX_WARNINGS_AS_ERRORS=OFF \
#      -Wno-dev -G Ninja ..            &&
#ninja docs-llvm-html  docs-llvm-man

#也可以构建clang文档：
#ninja docs-clang-html docs-clang-man

#要测试结果，请发出：
#ninja check-all

ninja install

#如果您已经构建了llvm文档，请以root 用户身份运行以下命令来安装它：
#install -v -m644 docs/man/* /usr/share/man/man1             &&
install -v -d -m755 /usr/share/doc/llvm-11.1.0/llvm-html     &&
cp -Rv docs/html/* /usr/share/doc/llvm-11.1.0/llvm-html

#如果您已经建立了clang文档，则可以用相同的方式（与root 用户相同）进行安装：
#install -v -m644 tools/clang/docs/man/* /usr/share/man/man1 &&
install -v -d -m755 /usr/share/doc/llvm-11.1.0/clang-html    &&
cp -Rv tools/clang/docs/html/* /usr/share/doc/llvm-11.1.0/clang-html

popd