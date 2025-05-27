set(HEXTYPE_SOURCES
  typeplus.cpp
  )
set(HEXTYPE_HEADERS
  typeplus.h)

include_directories(..)

set(HEXTYPE_CFLAGS ${SANITIZER_COMMON_CFLAGS} -DCMAKE_CXX_STANDARD=17)

add_custom_target(typeplus)

add_compiler_rt_runtime(clang_rt.typeplus
        STATIC
        ARCHS x86_64
        SOURCES ${HEXTYPE_SOURCES}
        CFLAGS ${HEXTYPE_CFLAGS}
        ADDITIONAL_HEADERS ${HEXTYPE_HEADERS}
        PARENT_TARGET typeplus)

add_sanitizer_rt_symbols(clang_rt.typeplus)

add_dependencies(compiler-rt typeplus)