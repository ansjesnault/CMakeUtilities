## CMAKE_DOCUMENTATION_START FindTIFF.cmake
## Important Note: \\n
## This is not an official Find*cmake. It has been written for searching through
## a custom path (TIFF_DIR) before checking elsewhere.\\n
## \\n
## This module defines :\\n
## 	\\t[in] 	\\tTIFF_DIR, The base directory to search for TIFF (as cmake var or env var)\\n
## 	\\t[out] 	\\tTIFF_INCLUDE_DIR where to find TIFF.h\\n
## 	\\t[out] 	\\tTIFF_LIBRARIES, TIFF_LIBRARY, libraries to link against to use TIFF\\n
## 	\\t[out] 	\\tTIFF_FOUND, If false, do not try to use TIFF.\\n
## CMAKE_DOCUMENTATION_END


if(NOT TIFF_DIR)
    set(TIFF_DIR "$ENV{TIFF_DIR}" CACHE PATH "TIFF root directory")
endif()
if(TIFF_DIR)
	file(TO_CMAKE_PATH ${TIFF_DIR} TIFF_DIR)
endif()


## set the LIB POSTFIX to find in a right directory according to what kind of compiler we use (32/64bits)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
	set(TIFF_SEARCH_LIB "lib64")
	set(TIFF_SEARCH_BIN "bin64")
	set(TIFF_SEARCH_LIB_PATHSUFFIXE "x64")
else()
	set(TIFF_SEARCH_LIB "lib32")
	set(TIFF_SEARCH_BIN "bin32")
	set(TIFF_SEARCH_LIB_PATHSUFFIXE "x86")
endif()

set(PROGRAMFILESx86 "PROGRAMFILES(x86)")

FIND_PATH(TIFF_INCLUDE_DIR
	NAMES tif_config.h
	PATHS
		${TIFF_DIR}
		## linux
		/usr
		/usr/local
		/opt/local
		## windows
		"$ENV{PROGRAMFILES}/TIFF"
		"$ENV{${PROGRAMFILESx86}}/TIFF"
		"$ENV{ProgramW6432}/TIFF"
	PATH_SUFFIXES include
  NO_DEFAULT_PATH
)

FIND_LIBRARY(TIFF_LIBRARY
	NAMES libtiff
	PATHS
		${TIFF_DIR}/${TIFF_SEARCH_LIB}
		${TIFF_DIR}/lib
		## linux
		/usr/${TIFF_SEARCH_LIB}
		/usr/local/${TIFF_SEARCH_LIB}
		/opt/local/${TIFF_SEARCH_LIB}
		/usr/lib
		/usr/local/lib
		/opt/local/lib
		## windows
		"$ENV{PROGRAMFILES}/TIFF/${TIFF_SEARCH_LIB}"
		"$ENV{${PROGRAMFILESx86}}/TIFF/${TIFF_SEARCH_LIB}"
		"$ENV{ProgramW6432}/TIFF/${TIFF_SEARCH_LIB}"
		"$ENV{PROGRAMFILES}/TIFF/lib"
		"$ENV{${PROGRAMFILESx86}}/TIFF/lib"
		"$ENV{ProgramW6432}/TIFF/lib"
	PATH_SUFFIXES ${TIFF_SEARCH_LIB_PATHSUFFIXE}
  NO_DEFAULT_PATH
)
set(TIFF_LIBRARIES ${TIFF_LIBRARY})

MARK_AS_ADVANCED(TIFF_INCLUDE_DIR TIFF_LIBRARIES)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(TIFF
	REQUIRED_VARS TIFF_INCLUDE_DIR TIFF_LIBRARIES
	FAIL_MESSAGE "TIFF wasn't found correctly. Set TIFF_DIR to the root SDK installation directory."
)

if(NOT TIFF_FOUND)
	set(TIFF_DIR "" CACHE STRING "Path to TIFF install directory")
endif()
