## CMAKE_DOCUMENTATION_START FindEmbree.cmake
## Important Note:\\n
## This is not an official Find*cmake. It has been written for searching through
## a custom path (EMBREE_DIR) before checking elsewhere. \\n
##
## This module defines : \\n
## 	\\t[in] 	\\tEMBREE_DIR, The base directory to search for EMBREE (as cmake var or env var) \\n
## 	\\t[out] 	\\tEMBREE_INCLUDE_DIR where to find EMBREE.h \\n
## 	\\t[out] 	\\tEMBREE_LIBRARIES, EMBREE_LIBRARY, libraries to link against to use EMBREE \\n
## 	\\t[out] 	\\tEMBREE_FOUND, If false, do not try to use EMBREE. \\n
##
## CMAKE_DOCUMENTATION_END


if(NOT EMBREE_DIR)
    set(EMBREE_DIR "$ENV{EMBREE_DIR}" CACHE PATH "EMBREE root directory")
endif()
if(EMBREE_DIR)
	file(TO_CMAKE_PATH ${EMBREE_DIR} EMBREE_DIR)
endif()


## set the LIB POSTFIX to find in a right directory according to what kind of compiler we use (32/64bits)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
	set(EMBREE_SEARCH_LIB "lib64")
	set(EMBREE_SEARCH_BIN "bin64")
	set(EMBREE_SEARCH_LIB_PATHSUFFIXE "x64")
else()
	set(EMBREE_SEARCH_LIB "lib32")
	set(EMBREE_SEARCH_BIN "bin32")
	set(EMBREE_SEARCH_LIB_PATHSUFFIXE "x86")
endif()

set(PROGRAMFILESx86 "PROGRAMFILES(x86)")

FIND_PATH(EMBREE_INCLUDE_DIR
	NAMES embree2/rtcore_geometry_user.h
	PATHS
		${EMBREE_DIR}
		## linux
		/usr
		/usr/local
		/opt/local
		## windows
		"$ENV{PROGRAMFILES}/EMBREE"
		"$ENV{${PROGRAMFILESx86}}/EMBREE"
		"$ENV{ProgramW6432}/EMBREE"
	PATH_SUFFIXES include
)

FIND_LIBRARY(EMBREE_LIBRARY
	NAMES embree
	PATHS
		${EMBREE_DIR}/${EMBREE_SEARCH_LIB}
		${EMBREE_DIR}/lib
		## linux
		/usr/${EMBREE_SEARCH_LIB}
		/usr/local/${EMBREE_SEARCH_LIB}
		/opt/local/${EMBREE_SEARCH_LIB}
		/usr/lib
		/usr/local/lib
		/opt/local/lib
		## windows
		"$ENV{PROGRAMFILES}/EMBREE/${EMBREE_SEARCH_LIB}"
		"$ENV{${PROGRAMFILESx86}}/EMBREE/${EMBREE_SEARCH_LIB}"
		"$ENV{ProgramW6432}/EMBREE/${EMBREE_SEARCH_LIB}"
		"$ENV{PROGRAMFILES}/EMBREE/lib"
		"$ENV{${PROGRAMFILESx86}}/EMBREE/lib"
		"$ENV{ProgramW6432}/EMBREE/lib"
	PATH_SUFFIXES ${EMBREE_SEARCH_LIB_PATHSUFFIXE}
)
set(EMBREE_LIBRARIES ${EMBREE_LIBRARY})

MARK_AS_ADVANCED(EMBREE_INCLUDE_DIR EMBREE_LIBRARIES)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(EMBREE
	REQUIRED_VARS EMBREE_INCLUDE_DIR EMBREE_LIBRARIES
	FAIL_MESSAGE "EMBREE wasn't found correctly. Set EMBREE_DIR to the root SDK installation directory."
)

if(NOT EMBREE_FOUND)
	set(EMBREE_DIR "" CACHE STRING "Path to EMBREE install directory")
endif()
