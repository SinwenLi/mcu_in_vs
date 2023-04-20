# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
 
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(TARGET_TRIPLET "arm-none-eabi-")
 
# do some windows specific logic 一些特定于Windows的逻辑
# 执行一个或多个子进程。
# COMMAND CMake使用操作系统的APIs直接执行子进程。所有的参数逐字传递。
# 没有中间脚本被使用
# 将二进制文件变成window可执行文件
if(WIN32)
    set(TOOLCHAIN_EXT ".exe")
    execute_process(
        COMMAND ${CMAKE_CURRENT_LIST_DIR}/vswhere.exe -latest -requires Component.MDD.Linux.GCC.arm -find **/gcc_arm/bin
        OUTPUT_VARIABLE VSWHERE_PATH
    )
else()
    set(TOOLCHAIN_EXT "")
endif(WIN32)
 
# default to Release build 默认为发布构建
if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE "Debug" CACHE STRING
            "Choose the type of build, options are: Debug Release."
            FORCE)
endif()
 
# 查找程序 arm-none-eabi-gcc.exe
find_program(COMPILER_ON_PATH "${TARGET_TRIPLET}gcc${TOOLCHAIN_EXT}")
 
if(DEFINED ENV{ARM_GCC_PATH}) 
    # use the environment variable first  首先使用环境变量  
    file(TO_CMAKE_PATH $ENV{ARM_GCC_PATH} ARM_TOOLCHAIN_PATH)
    message(STATUS "Using ENV variable ARM_GCC_PATH = ${ARM_TOOLCHAIN_PATH}")
elseif(COMPILER_ON_PATH) 
    # then check on the current path 然后检查当前路径
    get_filename_component(ARM_TOOLCHAIN_PATH ${COMPILER_ON_PATH} DIRECTORY)
    message(STATUS "Using ARM GCC from path = ${ARM_TOOLCHAIN_PATH}")
elseif(DEFINED VSWHERE_PATH) 
    # try and find if its installed with visual studio
    # 试着看看它是否安装了visual studio
    file(TO_CMAKE_PATH ${VSWHERE_PATH} ARM_TOOLCHAIN_PATH)
    string(STRIP ${ARM_TOOLCHAIN_PATH} ARM_TOOLCHAIN_PATH)
    message(STATUS "Using Visual Studio install ${ARM_TOOLCHAIN_PATH} yes")
# else() 
#     # otherwise just default to the standard installation
#     set(ARM_TOOLCHAIN_PATH "C:/Program Files (x86)/GNU Tools Arm Embedded/9 2019-q4-major/bin")
#     message(STATUS "Using ARM GCC from default Windows toolchain directory ${ARM_TOOLCHAIN_PATH}")
endif()
 
# perform compiler test with the static library 使用静态库执行编译器测试
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
 
# 设置编译工具的路径 arm-none-eabi-gcc.exe
# D:\Program Files (x86)\GNU Arm Embedded Toolchain\10 2020-q4-major\bin
set(CMAKE_C_COMPILER    ${ARM_TOOLCHAIN_PATH}/${TARGET_TRIPLET}gcc${TOOLCHAIN_EXT})
set(CMAKE_CXX_COMPILER  ${ARM_TOOLCHAIN_PATH}/${TARGET_TRIPLET}g++${TOOLCHAIN_EXT})
set(CMAKE_ASM_COMPILER  ${ARM_TOOLCHAIN_PATH}/${TARGET_TRIPLET}gcc${TOOLCHAIN_EXT})
set(CMAKE_LINKER        ${ARM_TOOLCHAIN_PATH}/${TARGET_TRIPLET}gcc${TOOLCHAIN_EXT})
set(CMAKE_SIZE_UTIL     ${ARM_TOOLCHAIN_PATH}/${TARGET_TRIPLET}size${TOOLCHAIN_EXT})
set(CMAKE_OBJCOPY       ${ARM_TOOLCHAIN_PATH}/${TARGET_TRIPLET}objcopy${TOOLCHAIN_EXT})
set(CMAKE_OBJDUMP       ${ARM_TOOLCHAIN_PATH}/${TARGET_TRIPLET}objdump${TOOLCHAIN_EXT})
set(CMAKE_NM_UTIL       ${ARM_TOOLCHAIN_PATH}/${TARGET_TRIPLET}nm${TOOLCHAIN_EXT})
 
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
 
set(CMAKE_COMMON_FLAGS " -fdiagnostics-color=always -ffunction-sections -fdata-sections -Wunused -Wuninitialized -Wall")
set(CMAKE_C_FLAGS 	"${MCPU_FLAGS} ${VFP_FLAGS} ${SPECS_FLAGS} ${CMAKE_COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS "${MCPU_FLAGS} ${VFP_FLAGS} ${SPECS_FLAGS} ${CMAKE_COMMON_FLAGS}")
set(CMAKE_ASM_FLAGS " -Wa,-mimplicit-it=thumb -mcpu=cortex-m4 -x assembler-with-cpp ${VFP_FLAGS} ${SPECS_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${LD_FLAGS} -Wl,--gc-sections,-print-memory-usage")
 
set(CMAKE_C_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_CXX_ASM_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_C_ASM_FLAGS_DEBUG "-g3")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "")
 
set(CMAKE_C_FLAGS_RELEASE "-O3")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")
set(CMAKE_ASM_FLAGS_RELEASE "")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto")