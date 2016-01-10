## CMAKE_DOCUMENTATION_START FindSPACEWARE.cmake
## - Find the 3D mouse Spaceware SDK (2013/2014) \\n
## \\t	SPACEWARE_DIR						- Can be set to allow this script to look for SDK into this directory. \\n
## \\t 	SPACEWARE_FOUND         			- ON if found. \\n
## \\t 	SPACEWARE_INCLUDE_DIR   			- Full path to include headers directory. \\n
## \\n
## \\t 	SPACEWARE_SIAPP_LIBRARY_DEBUG		- Full path to siapp library (debug one). \\n
## \\t 	SPACEWARE_SIAPP_LIBRARY_RELEASE		- Full path to siapp library (release one). \\n
## \\n
## \\t 	SPACEWARE_SIAPPMT_LIBRARY_DEBUG		- Full path to siapp library (debug one). \\n
## \\t 	SPACEWARE_SIAPPMT_LIBRARY_RELEASE	- Full path to siapp library (release one). \\n
## \\n
## \\t 	SPACEWARE_SPWMATH_LIBRARY_DEBUG		- Full path to siapp library (debug one). \\n
## \\t 	SPACEWARE_SPWMATH_LIBRARY_RELEASE	- Full path to siapp library (release one). \\n
## \\n
## \\t 	SPACEWARE_SPWMATHMT_LIBRARY_DEBUG	- Full path to siapp library (debug one). \\n
## \\t 	SPACEWARE_SPWMATHMT_LIBRARY_RELEASE	- Full path to siapp library (release one). \\n
## \\n
## \\t	SPACEWARE_LIBRARIES					- The full cmake command line using all libraries found \\n
## \\n
## Written by jerome.esnault
## CMAKE_DOCUMENTATION_END

set(PROGRAMFILESx86 "PROGRAMFILES(x86)")

set(SPACEWARE_TO_LOOK_FOR 
	${SPACEWARE_DIR}
	## linux
	/usr
	/usr/local
	/opt/local
	## Windows
	"$ENV{PROGRAMFILES}/3DxWareSDK"
	"$ENV{${PROGRAMFILESx86}}/3DxWareSDK"
	"$ENV{ProgramW6432}/3DxWareSDK"
)

find_path(SPACEWARE_INCLUDE_DIR
	NAMES 			si.h
	PATHS			${SPACEWARE_TO_LOOK_FOR}
	PATH_SUFFIXES 	include Inc
)

## set the LIB POSTFIX to find in a right directory according to what kind of compiler we use (32/64bits)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)  ## Size in bytes!
	set(SPACEWARE_SEARCH_LIB "x64")
else()
	set(SPACEWARE_SEARCH_LIB "x86")
endif()

set(SPACEWARE_LIB_LIST 	siapp siappMT spwmath spwmathMT)
foreach(libname ${SPACEWARE_LIB_LIST})
	string(TOUPPER ${libname} libnameUC)
	FIND_LIBRARY(SPACEWARE_${libnameUC}_LIBRARY_DEBUG
		NAMES 			${libname}D
		PATHS 			${SPACEWARE_TO_LOOK_FOR}
		PATH_SUFFIXES 	Lib/${SPACEWARE_SEARCH_LIB} lib ${SPACEWARE_SEARCH_LIB}
	)
	if(SPACEWARE_${libnameUC}_LIBRARY_DEBUG)
		list(APPEND SPACEWARE_LIBRARIES debug "${SPACEWARE_${libnameUC}_LIBRARY_DEBUG}")
	endif()
	FIND_LIBRARY(SPACEWARE_${libnameUC}_LIBRARY_RELEASE
		NAMES 			${libname}
		PATHS 			${SPACEWARE_TO_LOOK_FOR}
		PATH_SUFFIXES 	Lib/${SPACEWARE_SEARCH_LIB} lib ${SPACEWARE_SEARCH_LIB}
	)
	if(SPACEWARE_${libnameUC}_LIBRARY_RELEASE)
		list(APPEND SPACEWARE_LIBRARIES optimized "${SPACEWARE_${libnameUC}_LIBRARY_RELEASE}")
	endif()
endforeach()

find_path(SPACEWARE_LIBRARY_DIR
	NAMES 			siapp${CMAKE_LINK_LIBRARY_SUFFIX}
	PATHS			${SPACEWARE_TO_LOOK_FOR}
	PATH_SUFFIXES 	Lib/${SPACEWARE_SEARCH_LIB} lib ${SPACEWARE_SEARCH_LIB}
)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(SPACEWARE
	REQUIRED_VARS SPACEWARE_INCLUDE_DIR SPACEWARE_SIAPP_LIBRARY_RELEASE SPACEWARE_LIBRARY_DIR
	FAIL_MESSAGE "SPACEWARE wasn't found correctly. Set SPACEWARE_DIR to the root dir."
)

if(NOT SPACEWARE_FOUND)
	set(SPACEWARE_DIR "" CACHE PATH "Where your 3DxWareSDK is.")
endif()