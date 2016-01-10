CMAKE_MINIMUM_REQUIRED(VERSION 2.8.9)
PROJECT(ibr_projects)


## Default install path; user doesn't have to specify
## will cause the GUI will be not updated, and unavailable for changing by user
SET(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/install)
MESSAGE(STATUS "Install path set to ${CMAKE_INSTALL_PREFIX}.")


## Include cmake stuff (functions/macros) : Modules files
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

## To maintain cmake versions compatibilities
include(cmake_policies)
setPolicies()


## Allow C++11
include(CheckCXXCompilerFlag)
get_filename_component(currentBuildTool ${CMAKE_BUILD_TOOL} NAME_WE)
if(${currentBuildTool} MATCHES "(msdev|devenv|nmake|MSBuild)")
    add_definitions(/W3 /DNOMINMAX)
    # "Warning level 4 generates a lot of warning messages for STL headers and is not currently recommended for that reason."
    # from support.microsoft.com
elseif(${currentBuildTool} MATCHES "(make|gmake)")
    add_definitions(-Wall -g)
	CHECK_CXX_COMPILER_FLAG("-std=gnu++11" COMPILER_SUPPORTS_CXX11)
	CHECK_CXX_COMPILER_FLAG("-std=gnu++0x" COMPILER_SUPPORTS_CXX0X)
	if(COMPILER_SUPPORTS_CXX11)
		add_definitions(-std=gnu++11)
	elseif(COMPILER_SUPPORTS_CXX0X)
		add_definitions(-std=gnu++0x)
	else()
		message(SEND_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
	endif()
elseif(APPLE) ## TODO: do a better test and send error on unsupported c++11 compiler
    add_definitions(-std=c++11 -stdlib=libc++)
endif()


## Set default build output binaries (used also in sub CMakeLists.txt) :
set(BIN_BUILT_DIR "bin")
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
	set(ARCHI_BUILT_DIR "x64")
	set(LIB_BUILT_DIR "lib64")
else()
	set(ARCHI_BUILT_DIR "x86")
	set(LIB_BUILT_DIR "lib")
endif()
if(DEFINED CMAKE_BUILD_TYPE) ## for mono config type (make/nmake/ninja based)
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/OUTPUTS/${ARCHI_BUILT_DIR}/${CMAKE_BUILD_TYPE}/${LIB_BUILT_DIR})
	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/OUTPUTS/${ARCHI_BUILT_DIR}/${CMAKE_BUILD_TYPE}/${LIB_BUILT_DIR})
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/OUTPUTS/${ARCHI_BUILT_DIR}/${CMAKE_BUILD_TYPE}/${BIN_BUILT_DIR})
	set(CMAKE_PDB_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/OUTPUTS/${ARCHI_BUILT_DIR}/${CMAKE_BUILD_TYPE}/${BIN_BUILT_DIR})
	if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
		set(CMAKE_DEBUG_POSTFIX "_d")
	elseif(${CMAKE_BUILD_TYPE} MATCHES "RelWithDebInfo")
		set(CMAKE_DEBUG_POSTFIX "_rwdi")
	elseif(${CMAKE_BUILD_TYPE} MATCHES "MinSizeRel")
		set(CMAKE_DEBUG_POSTFIX "_msr")
	endif()
endif()
foreach(CONFIG_TYPES ${CMAKE_CONFIGURATION_TYPES}) ## for multi config types (MSVC based)
	string(TOUPPER ${CONFIG_TYPES} CONFIG_TYPES_UC)
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CONFIG_TYPES_UC} ${CMAKE_BINARY_DIR}/OUTPUTS/${CONFIG_TYPES}/${LIB_BUILT_DIR})
	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CONFIG_TYPES_UC} ${CMAKE_BINARY_DIR}/OUTPUTS/${CONFIG_TYPES}/${LIB_BUILT_DIR})
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CONFIG_TYPES_UC} ${CMAKE_BINARY_DIR}/OUTPUTS/${CONFIG_TYPES}/${BIN_BUILT_DIR})
	set(CMAKE_PDB_OUTPUT_DIRECTORY_${CONFIG_TYPES_UC} ${CMAKE_BINARY_DIR}/OUTPUTS/${CONFIG_TYPES}/${BIN_BUILT_DIR})
	if(${CONFIG_TYPES} MATCHES "Debug")
		set(CMAKE_DEBUG_POSTFIX "_d")
	elseif(${CONFIG_TYPES} MATCHES "RelWithDebInfo")
		set(CMAKE_RELWITHDEBINFO_POSTFIX "_rwdi")
	elseif(${CONFIG_TYPES} MATCHES "MinSizeRel")
		set(CMAKE_MINSIZEREL_POSTFIX "_msr")
	endif()
endforeach()

## Include all projects
ADD_SUBDIRECTORY(src)


## handle documentation
#ADD_SUBDIRECTORY(doc)
