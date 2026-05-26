cmake_minimum_required(VERSION 3.15)
project(AutoCAD_ARX_Plugin VERSION 1.0.0 LANGUAGES CXX)

# ============================================================================
# 配置区域 - 修改以下路径以适配你的环境
# ============================================================================

# ObjectARX SDK 根目录
set(OBJECTARX_ROOT "C:/Autodesk/Autodesk_ObjectARX_2019_Win_64_and_32_Bit")

# 输出目录
set(OUTPUT_DIR "${CMAKE_SOURCE_DIR}/bin")

# 目标 ARX 文件名（不含扩展名）
set(TARGET_NAME "MyPlugin")

# ============================================================================
# 以下通常无需修改
# ============================================================================

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 强制 x64 架构
if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
    message(FATAL_ERROR "This project requires x64 architecture")
endif()

# 检测 Visual Studio 编译器
if(NOT MSVC)
    message(FATAL_ERROR "This project requires Visual Studio (MSVC) compiler")
endif()

if(MSVC_VERSION LESS 1930 OR MSVC_VERSION GREATER_EQUAL 1940)
    message(WARNING "This project is configured for Visual Studio 2022 (MSVC 193x)")
endif()

# ObjectARX 2019 特定配置
set(OBJECTARX_INC "${OBJECTARX_ROOT}/inc")
set(OBJECTARX_LIB "${OBJECTARX_ROOT}/lib-x64")

# ObjectARX 2019 必需的库
set(OBJECTARX_LIBS
    acdb23.lib
    acge23.lib
    acgiapi.lib
    ac1st23.lib
    accore.lib
    acad.lib
    rxapi.lib
)

# 创建共享库（ARX 本质是 DLL）
add_library(${TARGET_NAME} SHARED)

# 自动扫描 src 目录下所有 cpp 文件
file(GLOB_RECURSE SOURCE_FILES
    "${CMAKE_SOURCE_DIR}/src/*.cpp"
    "${CMAKE_SOURCE_DIR}/src/*.cxx"
    "${CMAKE_SOURCE_DIR}/src/*.cc"
)

if(NOT SOURCE_FILES)
    message(FATAL_ERROR "No source files found in src/ directory")
endif()

target_sources(${TARGET_NAME} PRIVATE ${SOURCE_FILES})

# 包含头文件目录
target_include_directories(${TARGET_NAME} PRIVATE
    ${OBJECTARX_INC}
    ${CMAKE_SOURCE_DIR}/include
)

# 链接库目录
target_link_directories(${TARGET_NAME} PRIVATE
    ${OBJECTARX_LIB}
)

# 链接 ObjectARX 库
target_link_libraries(${TARGET_NAME} PRIVATE
    ${OBJECTARX_LIBS}
)

# 编译定义
target_compile_definitions(${TARGET_NAME} PRIVATE
    _WINDOWS
    _USRDLL
    _WINDLL
    _ACRXAPP
    WIN32_LEAN_AND_MEAN
    NOMINMAX
    UNICODE
    _UNICODE
)

# MSVC 编译选项
target_compile_options(${TARGET_NAME} PRIVATE
    /utf-8
    /W3
    /MP          # 多处理器编译
    /EHsc        # 异常处理
)

# 链接选项
set_target_properties(${TARGET_NAME} PROPERTIES
    OUTPUT_NAME "${TARGET_NAME}"
    PREFIX ""
    SUFFIX ".arx"
    RUNTIME_OUTPUT_DIRECTORY "${OUTPUT_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${OUTPUT_DIR}"
    LINK_FLAGS "/EXPORT:acrxGetApiVersion"
)

# 打印配置信息
message(STATUS "===========================================")
message(STATUS "AutoCAD ObjectARX 2019 Plugin Configuration")
message(STATUS "===========================================")
message(STATUS "ObjectARX Root : ${OBJECTARX_ROOT}")
message(STATUS "Target Name    : ${TARGET_NAME}.arx")
message(STATUS "Output Dir     : ${OUTPUT_DIR}")
message(STATUS "Source Files   : ${SOURCE_FILES}")
message(STATUS "Build Type     : ${CMAKE_BUILD_TYPE}")
message(STATUS "Generator      : ${CMAKE_GENERATOR}")
message(STATUS "===========================================")
