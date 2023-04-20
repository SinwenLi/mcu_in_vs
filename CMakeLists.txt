# No operating system
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
cmake_minimum_required(VERSION 3.0.0)

# specify cross compilers and tools
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_AR arm-none-eabi-ar)
set(CMAKE_OBJCOPY arm-none-eabi-objcopy)
set(CMAKE_OBJDUMP arm-none-eabi-objdump)
set(SIZE arm-none-eabi-size)
# skip compiler checks
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

project(Test_TEMPLATE C CXX ASM)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)

add_compile_options(-mcpu=cortex-m4 -mthumb -mthumb-interwork)
add_compile_options(-ffunction-sections -fdata-sections -fno-common -fmessage-length=0)

# uncomment to mitigate c++17 absolute addresses warnings
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-register")

# Enable assembler files preprocessing
add_compile_options($<$<COMPILE_LANGUAGE:ASM>:-x$<SEMICOLON>assembler-with-cpp>)

if ("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
    message(STATUS "Maximum optimization for speed")
    add_compile_options(-Ofast)
elseif ("${CMAKE_BUILD_TYPE}" STREQUAL "RelWithDebInfo")
    message(STATUS "Maximum optimization for speed, debug info included")
    add_compile_options(-Ofast -g)
elseif ("${CMAKE_BUILD_TYPE}" STREQUAL "MinSizeRel")
    message(STATUS "Maximum optimization for size")
    add_compile_options(-Os)
else ()
    message(STATUS "Minimal optimization, debug info included")
    add_compile_options(-Og -g)
endif ()

include_directories(
    ./
    #${CMAKE_SOURCE_DIR}/drivers/CMSIS/Include
    #${CMAKE_SOURCE_DIR}/drivers/CMSIS/Device/ST/STM32F1xx/Include
    #${CMAKE_SOURCE_DIR}/drivers/STM32F1xx_HAL_Driver/Inc
    #${CMAKE_SOURCE_DIR}/drivers/STM32F1xx_HAL_Driver/Inc/Legacy
    #${CMAKE_SOURCE_DIR}/main
    ${CMAKE_SOURCE_DIR}/Libraries/CMSIS
    ${CMAKE_SOURCE_DIR}/Libraries/STM32F4xx_StdPeriph_Driver/inc
    ${CMAKE_SOURCE_DIR}/User
    ${CMAKE_SOURCE_DIR}/Public
    ${CMAKE_SOURCE_DIR}/app/led
    ${CMAKE_SOURCE_DIR}/app/touch_key
)
#add_definitions(-DUSE_HAL_DRIVER -D__MICROLIB -DSTM32F1 -DSTM32F1xx -DSTM32F103xB)
add_definitions(-DUSE_STDPERIPH_DRIVER -D__MICROLIB -DSTM32F4 -DSTM32F4xx -DSTM32F407 -D STM32F40_41xxx)
#set(HSE_VALUE 8000000)

#aux_source_directory(${CMAKE_SOURCE_DIR}/drivers/STM32F1xx_HAL_Driver/Src HAL_DRIVER)
#aux_source_directory(${CMAKE_SOURCE_DIR}/drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates SYSTEM)
#aux_source_directory(${CMAKE_SOURCE_DIR}/main MAIN)

aux_source_directory(${CMAKE_SOURCE_DIR}/Libraries/CMSIS CMSIS_F4)
aux_source_directory(${CMAKE_SOURCE_DIR}/Libraries/STM32F4xx_StdPeriph_Driver/src STM32F4_STD_DRIVER)
aux_source_directory(${CMAKE_SOURCE_DIR}/User TEST_USER)
aux_source_directory(${CMAKE_SOURCE_DIR}/Public PUBLIC)
aux_source_directory(${CMAKE_SOURCE_DIR}/app/led APP_LED)
aux_source_directory(${CMAKE_SOURCE_DIR}/app/touch_key APP_TOUCHKEY)

#set(STARTUP       ${CMAKE_SOURCE_DIR}/drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/startup_stm32f103xb.s)
set(STARTUP ${CMAKE_SOURCE_DIR}/Libraries/CMSIS/startup_stm32f40_41xxx.S)

#set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/linker/STM32F103XB_FLASH.ld)
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/STM32F407_FLASH.ld)

add_link_options(-Wl,-gc-sections,--print-memory-usage,-Map=${PROJECT_BINARY_DIR}/${PROJECT_NAME}.map)
add_link_options(-mcpu=cortex-m4 -mthumb -mthumb-interwork --specs=nosys.specs)
add_link_options(-T ${LINKER_SCRIPT})

#add_executable(${PROJECT_NAME}.elf ${HAL_DRIVER} ${SYSTEM} ${MAIN} ${STARTUP} ${LINKER_SCRIPT})
add_executable(${PROJECT_NAME}.elf ${CMSIS_F4} ${STM32F4_STD_DRIVER} ${TEST_USER} ${PUBLIC} ${APP_LED} ${APP_TOUCHKEY} ${STARTUP} ${LINKER_SCRIPT})

set(HEX_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.hex)
set(BIN_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.bin)

add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -Oihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${HEX_FILE}
        COMMAND ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:${PROJECT_NAME}.elf> ${BIN_FILE}
        COMMENT "Building ${HEX_FILE}
Building ${BIN_FILE}")
