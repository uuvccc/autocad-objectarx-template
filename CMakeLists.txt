cmake_minimum_required(VERSION 3.0)
project(AutoCAD_ARX_Plugin VERSION 1.0.0 LANGUAGES CXX)

# ============================================================================
# 配置区域 - 修改以下路径以适配你的环境
# ============================================================================

# ObjectARX SDK 根目录（按优先级查找）：
#   1. CMake 命令行 -DOBJECTARX_ROOT=...
#   2. 环境变量 OBJECTARX_ROOT
#   3. 此处默认值
set(OBJECTARX_ROOT "" CACHE PATH "ObjectARX SDK root directory")
if(NOT OBJECTARX_ROOT)
    if(DEFINED ENV{OBJECTARX_ROOT})
        set(OBJECTARX_ROOT "$ENV{OBJECTARX_ROOT}" CACHE PATH "ObjectARX SDK root directory" FORCE)
    else()
        message(FATAL_ERROR
            "OBJECTARX_ROOT is not set.\n"
            "  Set it via cmake -DOBJECTARX_ROOT=<path> or environment variable OBJECTARX_ROOT."
        )
    endif()
endif()

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

# 自动检测 ObjectARX 版本号（从 inc/目录头文件或 lib-x64/目录提取）
# ObjectARX 库文件名中的数字后缀随版本变化，如 acdb23, acdb24 等
function(detect_arx_lib_version ARX_ROOT ARX_INC OUT_VAR)
    # 优先从 acdbMM.lib 文件名提取版本号
    file(GLOB _acdb_libs "${ARX_ROOT}/lib-x64/acdb*.lib")
    if(_acdb_libs)
        list(GET _acdb_libs 0 _first_lib)
        get_filename_component(_lib_name "${_first_lib}" NAME_WE)
        string(REGEX MATCH "[0-9]+" _ver "${_lib_name}")
        if(_ver)
            set(${OUT_VAR} "${_ver}" PARENT_SCOPE)
            message(STATUS "Auto-detected ObjectARX lib version: ${_ver}")
            return()
        endif()
    endif()
    # 回退：尝试从 acdbMFC.lib 提取
    file(GLOB _acdbmfc_libs "${ARX_ROOT}/lib-x64/acdbmfc*.lib")
    if(_acdbmfc_libs)
        list(GET _acdbmfc_libs 0 _first_lib)
        get_filename_component(_lib_name "${_first_lib}" NAME_WE)
        string(REGEX MATCH "[0-9]+" _ver "${_lib_name}")
        if(_ver)
            set(${OUT_VAR} "${_ver}" PARENT_SCOPE)
            message(STATUS "Auto-detected ObjectARX lib version: ${_ver}")
            return()
        endif()
    endif()
    # 最终回退：让用户手动指定
    set(${OUT_VAR} "" PARENT_SCOPE)
endfunction()

detect_arx_lib_version("${OBJECTARX_ROOT}" "${OBJECTARX_INC}" ARX_LIB_VER)

# 允许用户手动覆盖版本号: -DARX_LIB_VER=23
set(ARX_LIB_VER "${ARX_LIB_VER}" CACHE STRING "ObjectARX library version suffix (e.g. 23 for acdb23)")
if(NOT ARX_LIB_VER)
    message(FATAL_ERROR
        "Could not auto-detect ObjectARX lib version.\n"
        "  Please set it via cmake -DARX_LIB_VER=<number> (e.g. 23 for acdb23.lib)"
    )
endif()

# ObjectARX 路径配置
set(OBJECTARX_INC "${OBJECTARX_ROOT}/inc")
set(OBJECTARX_LIB "${OBJECTARX_ROOT}/lib-x64")

# ObjectARX 必需的库（版本号自动适配）
set(OBJECTARX_LIBS
    acdb${ARX_LIB_VER}.lib
    acge${ARX_LIB_VER}.lib
    acgiapi.lib
    ac1st${ARX_LIB_VER}.lib
    accore.lib
    acad.lib
    rxapi.lib
)

# 自动扫描 src 目录下所有 cpp 文件
file(GLOB_RECURSE SOURCE_FILES
    "${CMAKE_SOURCE_DIR}/src/*.cpp"
    "${CMAKE_SOURCE_DIR}/src/*.cxx"
    "${CMAKE_SOURCE_DIR}/src/*.cc"
)

if(NOT SOURCE_FILES)
    message(FATAL_ERROR "No source files found in src/ directory")
endif()

# 创建共享库（ARX 本质是 DLL）
add_library(${TARGET_NAME} SHARED ${SOURCE_FILES})

# 包含头文件目录
target_include_directories(${TARGET_NAME} PRIVATE
    ${OBJECTARX_INC}
    ${CMAKE_SOURCE_DIR}/include
)

# 链接库目录
link_directories(${OBJECTARX_LIB})

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
message(STATUS "AutoCAD ObjectARX Plugin Configuration")
message(STATUS "===========================================")
message(STATUS "ObjectARX Root : ${OBJECTARX_ROOT}")
message(STATUS "ARX Lib Version: ${ARX_LIB_VER}")
message(STATUS "Target Name    : ${TARGET_NAME}.arx")
message(STATUS "Output Dir     : ${OUTPUT_DIR}")
message(STATUS "Source Files   : ${SOURCE_FILES}")
message(STATUS "Build Type     : ${CMAKE_BUILD_TYPE}")
message(STATUS "Generator      : ${CMAKE_GENERATOR}")
message(STATUS "MSVC Version   : ${MSVC_VERSION}")
message(STATUS "===========================================")
