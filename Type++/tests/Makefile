SRC_FILES := $(wildcard ./*.cpp)

CC = $${LLVM_BUILD_DIR}/bin/clang++
CXX = $${LLVM_BUILD_DIR}/bin/clang++
COMMON_CXXFLAGS = -Wall -Wextra -pedantic -std=c++11 -O0 -g -Wno-uninitialized -Wno-return-type-c-linkage -Wno-string-plus-int -Wno-delete-non-abstract-non-virtual-dtor \
 -flto -fvisibility=hidden   -stdlib=libc++ -nostdinc++ -I$${LLVM_BUILD_DIR}/../build_collect/include/c++/v1 -I$${LLVM_BUILD_DIR}/../build_collect/include/x86_64-unknown-linux-gnu/c++/v1 -fuse-ld=lld 
CXXFLAGS_TYPEPLUS = $(COMMON_CXXFLAGS) -fsanitize=typeplus -mllvm -collect-profiling-data
CXXFLAGS_CFI = $(COMMON_CXXFLAGS) -fno-sanitize-trap=cfi-derived-cast,cfi-unrelated-cast -fsanitize-recover=cfi-derived-cast,cfi-unrelated-cast -fsanitize=cfi-derived-cast,cfi-unrelated-cast
LD_FLAGS = -stdlib=libc++ -fuse-ld=lld \
		   -Wl,-rpath,LIB_PATH \
		   -LLIB_PATH \
		   -Wl,-rpath,LIB_PATH/lib \
		   -LLIB_PATH/lib
COLLECT_LD_FLAGS=$(subst LIB_PATH,$${LLVM_BUILD_DIR}/../build_collect/collected_libs, ${LD_FLAGS})
INSTRUMENTED_LD_FLAGS=$(subst LIB_PATH,$${TYPEPLUS_LOG_PATH}, ${LD_FLAGS})
LD_FLAGS_CFI += $(LD_FLAGS) -fno-sanitize-trap=cfi-derived-cast,cfi-unrelated-cast -fsanitize-recover=cfi-derived-cast,cfi-unrelated-cast -fsanitize=cfi-derived-cast,cfi-unrelated-cast
                                    
CXXFLAGS_COLLECT = $(CXXFLAGS_TYPEPLUS) -mllvm -create-derived-cast-type-list -mllvm -create-unrelated-cast-type-list -mllvm -create-void-star-type-list
CXXFLAGS_INSTRUMENT = $(CXXFLAGS_TYPEPLUS) -mllvm -check-unrelated-casting -mllvm -check-base-to-derived-casting -mllvm -apply-vtable-standard -mllvm -cast-obj-opt  -mllvm -poly-classes

all: collect_classes lib instrumented run_instrumented
fast: collect_classes copylib instrumented run_instrumented
libdebug: collect_classes libDebug instrumented run_instrumented

hextype:
	echo $(SRC_FILES)
	echo $(BUILD_DIR)/bin/clang++
	../build/bin/clang++ $(SRC_FILES) $(CXX_VERSION) -o $(SRC_FILES).out -fsanitize=hextype
	./$(SRC_FILES).out
	rm -drf $(SRC_FILES).out


run_cfi: cfi
	./cfi

collect_classes: $(SRC_FILES) 
	$(CXX) $(CXXFLAGS_COLLECT) $(CXX_VERSION) $(COLLECT_LD_FLAGS) -o $@ $^
	python3 $(HOME)/LLVM-typepp/Type++/script/merge_typecasting_related_type.py $(TYPEPLUS_LOG_PATH) > $(TARGET_TYPE_LIST_PATH)

lib: 
	INSTALL_DIR=$${TYPEPLUS_LOG_PATH} BUILD_DIR=$${TYPEPLUS_LOG_PATH}/build $${TYPESAFETY_FOLDER}/../build_instrument.sh > /dev/null

libDebug: 
	INSTALL_DIR=$${TYPEPLUS_LOG_PATH} BUILD_DIR=$${TYPEPLUS_LOG_PATH}/build $${TYPESAFETY_FOLDER}/../build_instrument.sh  debug 

copylib:
	cp -r $(LLVM_BUILD_DIR)/lib/x86_64-unknown-linux-gnu $${TYPEPLUS_LOG_PATH}/lib

instrumented: $(SRC_FILES)
	set -x
	set -e
	$(CXX) $(CXXFLAGS_INSTRUMENT) $(CXX_VERSION) $(INSTRUMENTED_LD_FLAGS) -o $@ $^

cfi: $(SRC_FILES)
	$(CXX) $(CXXFLAGS_CFI) -o $@ $^

run_instrumented: instrumented
	LD_LIBRARY_PATH=$${TYPEPLUS_LOG_PATH}/lib  ./instrumented


clean:
	rm -drf collect_classes instrumented cfi log/*
	rm -drf $(SRC_FILES).out
