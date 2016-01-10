## CMAKE_DOCUMENTATION_START FindJPEG.cmake
## Important Note: \\n
## This is not an official Find*cmake. It has been written for searching through
## a custom path (JPEG_DIR) before checking elsewhere. \\n
## This module defines : \\n
## 	\\t[in] 	\\tJPEG_DIR, The base directory to search for JPEG (as cmake var or env var) \\n
## 	\\t[out] 	\\tJPEG_INCLUDE_DIR where to find jpeg.h \\n
## 	\\t[out] 	\\tJPEG_LIBRARIES, JPEG_LIBRARY, libraries to link against to use JPEG \\n
## 	\\t[out] 	\\tJPEG_FOUND, If false, do not try to use JPEG. \\n
## CMAKE_DOCUMENTATION_END

if(NOT JPEG_DIR)
    set(JPEG_DIR "$ENV{JPEG_DIR}" CACHE PATH "JPEG root directory")
endif()
if(JPEG_DIR)
	file(TO_CMAKE_PATH ${JPEG_DIR} JPEG_DIR)
endif()


## set the LIB POSTFIX to find in a right directory according to what kind of compiler we use (32/64bits)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
	set(JPEG_SEARCH_LIB "lib64")
	set(JPEG_SEARCH_BIN "bin64")
	set(JPEG_SEARCH_LIB_PATHSUFFIXE "x64")
else()
	set(JPEG_SEARCH_LIB "lib32")
	set(JPEG_SEARCH_BIN "bin32")
	set(JPEG_SEARCH_LIB_PATHSUFFIXE "x86")
endif()

set(PROGRAMFILESx86 "PROGRAMFILES(x86)")

FIND_PATH(JPEG_INCLUDE_DIR
	NAMES jpeglib.h
	PATHS
		${JPEG_DIR}
		## linux
		/usr
		/usr/local
		/opt/local
		## windows
		"$ENV{PROGRAMFILES}/jpeg"
		"$ENV{${PROGRAMFILESx86}}/jpeg"
		"$ENV{ProgramW6432}/jpeg"
	PATH_SUFFIXES include
  NO_DEFAULT_PATH
)

FIND_LIBRARY(JPEG_LIBRARY
	NAMES jpeg
	PATHS
		${JPEG_DIR}/${JPEG_SEARCH_LIB}
		${JPEG_DIR}/lib
		## linux
		/usr/${JPEG_SEARCH_LIB}
		/usr/local/${JPEG_SEARCH_LIB}
		/opt/local/${JPEG_SEARCH_LIB}
		/usr/lib
		/usr/local/lib
		/opt/local/lib
		## windows
		"$ENV{PROGRAMFILES}/JPEG/${JPEG_SEARCH_LIB}"
		"$ENV{${PROGRAMFILESx86}}/JPEG/${JPEG_SEARCH_LIB}"
		"$ENV{ProgramW6432}/JPEG/${JPEG_SEARCH_LIB}"
		"$ENV{PROGRAMFILES}/JPEG/lib"
		"$ENV{${PROGRAMFILESx86}}/JPEG/lib"
		"$ENV{ProgramW6432}/JPEG/lib"
	PATH_SUFFIXES ${JPEG_SEARCH_LIB_PATHSUFFIXE}
  NO_DEFAULT_PATH
)
set(JPEG_LIBRARIES ${JPEG_LIBRARY})

MARK_AS_ADVANCED(JPEG_INCLUDE_DIR JPEG_LIBRARIES)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(JPEG
	REQUIRED_VARS JPEG_INCLUDE_DIR JPEG_LIBRARIES
	FAIL_MESSAGE "JPEG wasn't found correctly. Set JPEG_DIR to the root SDK installation directory."
)

if(NOT JPEG_FOUND)
	set(JPEG_DIR "" CACHE STRING "Path to JPEG install directory")
endif()
