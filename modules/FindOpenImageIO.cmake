## CMAKE_DOCUMENTATION_START FindOpenImageIO.cmake
## Find the native OpenImageIO includes and library. \\n
## \\n
## This module defines : \\n
## 	\\t[in] 	\\tOPENIMAGEIO_DIR, The base directory to search for OpenImageIO (as cmake var or env var) \\n
## 	\\t[out] 	\\tOPENIMAGEIO_INCLUDE_DIR where to find openimageio.h \\n
## 	\\t[out] 	\\tOPENIMAGEIO_LIBRARIES, libraries to link against to use OpenImageIO \\n
##	\\t[out]	\\tOPENIMAGEIO_LIBRARY, the core lib \\n
##	\\t[out]	\\tOPENIMAGEIO_UTIL_LIBRARY, the util lib \\n
## 	\\t[out] 	\\tOPENIMAGEIO_FOUND, If false, do not try to use OpenImageIO. \\n
## \\n
## written by jerome.esnault
## CMAKE_DOCUMENTATION_END

if(NOT OPENIMAGEIO_DIR)
	if(NOT $ENV{OPENIMAGEIO_DIR} STREQUAL "")
		set(OPENIMAGEIO_DIR $ENV{OPENIMAGEIO_DIR} CACHE PATH "The root installation path to OpeImageIO (oiio)" FORCE)
	else()
		set(OPENIMAGEIO_DIR "" CACHE PATH "The root installation path to OpeImageIO (oiio)")
	endif()
endif()

set(PROGRAMFILESx86 "PROGRAMFILES(x86)")

set(_openimageio_SEARCH_DIRS
	${OPENIMAGEIO_DIR}
	/usr/local
	/sw 		# Fink
	/opt/local 	# DarwinPorts
	/opt/csw 	# Blastwave
	/opt/lib/oiio
	$ENV{PROGRAMFILES}/OpenColorIO
	$ENV{${PROGRAMFILESx86}}/OpenColorIO
	$ENV{ProgramW6432}/OpenColorIO
)

FIND_PATH(OPENIMAGEIO_INCLUDE_DIR
	NAMES 			OpenImageIO/imageio.h
	PATHS			${_openimageio_SEARCH_DIRS}
	PATH_SUFFIXES 	include
)

FIND_LIBRARY(OPENIMAGEIO_LIBRARY
	NAMES			OpenImageIO
	PATHS			${_openimageio_SEARCH_DIRS}
	PATH_SUFFIXES	lib64 lib
)

FIND_LIBRARY(OPENIMAGEIO_UTIL_LIBRARY
	NAMES			OpenImageIO_Util
	PATHS			${_openimageio_SEARCH_DIRS}
	PATH_SUFFIXES	lib64 lib
)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(OpenImageIO DEFAULT_MSG
	OPENIMAGEIO_LIBRARY
	OPENIMAGEIO_INCLUDE_DIR
)

if(OPENIMAGEIO_FOUND)
	set(OpenImageIO_FOUND ON)
	set(OPENIMAGEIO_INCLUDE_DIRS 	${OPENIMAGEIO_INCLUDE_DIR})
	set(OPENIMAGEIO_LIBRARIES 		${OPENIMAGEIO_LIBRARY})
	if(OPENIMAGEIO_UTIL_LIBRARY)
		list(APPEND OPENIMAGEIO_LIBRARIES ${OPENIMAGEIO_UTIL_LIBRARY})
	endif()
else()
	set(OpenImageIO_FOUND OFF)
endif()

mark_as_advanced(
	OPENIMAGEIO_INCLUDE_DIR
	OPENIMAGEIO_LIBRARY
	OPENIMAGEIO_UTIL_LIBRARY
)

## FIND tools
set(OPENIMAGEIO_TOOLS iconvert idiff igrep iinfo iv maketx oiiotool)
foreach(tool ${OPENIMAGEIO_TOOLS})
	string(TOUPPER ${tool} TOOL_UC)
	find_program(OPENIMAGEIO_${TOOL_UC}_CMD 
		NAMES 			${tool}
		PATHS			${_openimageio_SEARCH_DIRS}
		PATH_SUFFIXES 	bin lib64 lib
	)
	mark_as_advanced(OPENIMAGEIO_${TOOL_UC}_CMD)
endforeach()