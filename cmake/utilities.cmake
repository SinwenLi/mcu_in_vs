# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
# 低于最低版本报错，平常是警告
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
 
# Create the bin output 创建二进制输出文件
# function(<name>[arg1 [arg2 [arg3 ...]]])
#           COMMAND1(ARGS ...)
#           COMMAND2(ARGS ...)
#           ...
#           endfunction(<name>)
# 定义一个函数名为<name>，参数名为arg1 arg2 arg3(…)。 
# 函数体内的命令直到函数被调用的时候才会去执行。
# 其中ARGC变量表示传递给函数的参数个数。
# ARGV0, ARGV1, ARGV2代表传递给函数的实际参数。 
# ARGN代表超出最后一个预期参数的参数列表，
# 例如，函数原型声明时，只接受一个参数，那么调用函数时传递给函数的参数列表中，
# 从第二个参数（如果有的话）开始就会保存到ARGN。
# 
# 在很多时候，需要在cmake中创建一些目标，如clean、copy等等，
# 这就需要通过add_custom_target来指定。
# 同时，add_custom_command可以用来完成对add_custom_target生成的target的补充。
# add_custom_target(Name [ALL] [command1 [args1...]]
#                   [COMMAND command2 [args2...] ...]
#                   [DEPENDS depend depend depend ... ]
#                   [BYPRODUCTS [files...]]
#                   [WORKING_DIRECTORY dir]
#                   [COMMENT comment]
#                   [JOB_POOL job_pool]
#                   [VERBATIM] [USES_TERMINAL]
#                   [COMMAND_EXPAND_LISTS]
#                   [SOURCES src1 [src2...]])
# 
# ALL：表明该目标会被添加到默认的构建目标，使得它每次都被运行；
# COMMAND：指定要在构建时执行的命令行；
# DEPENDS：指定命令所依赖的文件；
# COMMENT：在构建时执行命令之前显示给定消息；
# WORKING_DIRECTORY：使用给定的当前工作目录执行命令。如果它是相对路径，它将相对于对应于当前源目录的构建树目录；
# BYPRODUCTS：指定命令预期产生的文件。
#
# 调用arm-none-eabi-objcopy.exe
# D:\Program Files (x86)\GNU Arm Embedded Toolchain\10 2020-q4-major\bin
# 将elf转换为bin hex
# 带路径的文件 指令 源文件 生成文件
function(create_bin_output TARGET)
    add_custom_target(${TARGET}.bin ALL 
        DEPENDS ${TARGET}
        COMMAND ${CMAKE_OBJCOPY} -Obinary ${TARGET}.elf ${TARGET}.bin)
endfunction()
 
# Creates output in hex format 创建八进制输出文件
function(create_hex_output TARGET)
    add_custom_target(${TARGET}.hex ALL 
    DEPENDS ${TARGET} 
    COMMAND ${CMAKE_OBJCOPY} -Oihex ${TARGET}.elf ${TARGET}.hex)
endfunction()
 
# Add custom command to print firmware size in Berkley format
# 添加自定义命令以伯克利格式打印固件大小
function(firmware_size TARGET)
    add_custom_target(${TARGET}.size ALL 
        DEPENDS ${TARGET} 
        # COMMAND ${CMAKE_SIZE_UTIL} -B ${TARGET}.elf
        COMMAND ${CMAKE_SIZE_UTIL}  ${TARGET}.elf
        # COMMAND ${CMAKE_SIZE_UTIL} -B ${TARGET}.hex
        # COMMAND ${CMAKE_SIZE_UTIL} --format=berkeley ${TARGET}.elf ${TARGET}.hex
        )
endfunction()
 
# Output size of symbols in the resulting elf
# 打印十六进制文件大小
function(symbol_size TARGET)
    add_custom_target(${TARGET}.nm ALL
        DEPENDS ${TARGET}
        COMMAND ${CMAKE_NM_UTIL} --print-size --size-sort --radix=d ${TARGET}.elf)
endfunction()