## CMAKE_DOCUMENTATION_START FindASSIMP.cmake
## Try to find the ASSIMP library \\n
## Once done this will define : \\n
##
##  	\\ttASSIMP_FOUND 		\\t- system has ASSIMP \\n
##  	\\tASSIMP_INCLUDE_DIR 	\\t- The ASSIMP include directory\\n
##  	\\tASSIMP_LIBRARIES 	\\t- The libraries needed to use ASSIMP\\n
##  	\\tASSIMP_CMD 			\\t- the full path of ASSIMP executable\\n
##		\\tASSIMP_DYNAMIC_LIB	\\t- the Assimp dynamic lib (available only on windows as .dll file for the moment)\\n
##
## Written by jesnault
## Edited for using a bugfixed version of Assimp (2014)
## CMAKE_DOCUMENTATION_END

if(NOT ASSIMP_DIR)
    set(ASSIMP_DIR "$ENV{ASSIMP_DIR}" CACHE PATH "ASSIMP root directory")
endif()
if(ASSIMP_DIR)
	file(TO_CMAKE_PATH ${ASSIMP_DIR} ASSIMP_DIR)
endif()


## set the LIB POSTFIX to find in a right directory according to what kind of compiler we use (32/64bits)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
	set(ASSIMP_SEARCH_LIB "lib64")
	set(ASSIMP_SEARCH_BIN "bin64")
	set(ASSIMP_SEARCH_LIB_PATHSUFFIXE "x64")
else()
	set(ASSIMP_SEARCH_LIB "lib32")
	set(ASSIMP_SEARCH_BIN "bin32")
	set(ASSIMP_SEARCH_LIB_PATHSUFFIXE "x86")
endif()

set(PROGRAMFILESx86 "PROGRAMFILES(x86)")

FIND_PATH(ASSIMP_INCLUDE_DIR
	NAMES assimp/config.h
	PATHS
		${ASSIMP_DIR}
		## linux
		/usr
		/usr/local
		/opt/local
		## windows
		"$ENV{PROGRAMFILES}/Assimp"
		"$ENV{${PROGRAMFILESx86}}/Assimp"
		"$ENV{ProgramW6432}/Assimp"
	PATH_SUFFIXES include
)

FIND_LIBRARY(ASSIMP_LIBRARY
	NAMES assimp
	PATHS
		${ASSIMP_DIR}/${ASSIMP_SEARCH_LIB}
		${ASSIMP_DIR}/lib
		## linux
		/usr/${ASSIMP_SEARCH_LIB}
		/usr/local/${ASSIMP_SEARCH_LIB}
		/opt/local/${ASSIMP_SEARCH_LIB}
		/usr/lib
		/usr/local/lib
		/opt/local/lib
		## windows
		"$ENV{PROGRAMFILES}/Assimp/${ASSIMP_SEARCH_LIB}"
		"$ENV{${PROGRAMFILESx86}}/Assimp/${ASSIMP_SEARCH_LIB}"
		"$ENV{ProgramW6432}/Assimp/${ASSIMP_SEARCH_LIB}"
		"$ENV{PROGRAMFILES}/Assimp/lib"
		"$ENV{${PROGRAMFILESx86}}/Assimp/lib"
		"$ENV{ProgramW6432}/Assimp/lib"
	PATH_SUFFIXES ${ASSIMP_SEARCH_LIB_PATHSUFFIXE}
)
set(ASSIMP_LIBRARIES ${ASSIMP_LIBRARY})


if(ASSIMP_LIBRARY)
	get_filename_component(ASSIMP_LIBRARY_DIR ${ASSIMP_LIBRARY} PATH)
	file(GLOB ASSIMP_DYNAMIC_LIB "${ASSIMP_LIBRARY_DIR}/assimp*.dll")
	if(NOT ASSIMP_DYNAMIC_LIB)
		message("ASSIMP_DYNAMIC_LIB is missing... at ${ASSIMP_LIBRARY_DIR}")
	endif()
	set(ASSIMP_DYNAMIC_LIB ${ASSIMP_DYNAMIC_LIB} CACHE PATH "Windows dll location")
endif()

MARK_AS_ADVANCED(ASSIMP_DYNAMIC_LIB ASSIMP_INCLUDE_DIR ASSIMP_LIBRARIES)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(ASSIMP
	REQUIRED_VARS ASSIMP_INCLUDE_DIR ASSIMP_LIBRARIES
	FAIL_MESSAGE "ASSIMP wasn't found correctly. Set ASSIMP_DIR to the root SDK installation directory."
)

if(NOT ASSIMP_FOUND)
	set(ASSIMP_DIR "" CACHE STRING "Path to ASSIMP install directory")
endif()
