## CMAKE_DOCUMENTATION_START FindLeapMotion.cmake
## CMake module to find LeapMotion C++ SDK V1. \\n
## You can provide LEAP_DIR or LEAP_SDK as input to help to find. \\n
## \\n
## Provide: \\n
## \\n
## LEAP_INCLUDE_DIR \\n
## LEAP_INCLUDE_DIRS \\n
## \\n
## LEAP_LIBRARY_DEBUG \\n
## LEAP_LIBRARY_RELEASE \\n
## LEAP_LIBRARIES \\n
## \\n
## LEAP_DYNAMIC_LIBRARY_DEBUG \\n
## LEAP_DYNAMIC_LIBRARY_RELEASE \\n
## \\n
## Under windows, additional cmake variables: \\n
## LEAP_WIN_REDIST_DEBUG \\n
## LEAP_WIN_REDIST_RELEASE \\n
## LEAP_WIN_REDIST_DYNAMIC_LIBRARIES \\n
## \\n
## Example Usages:
## \\code
## find_package(LeapMotion QUIET) \n
## IF(LEAP_FOUND)\n
##  INCLUDE_DIRECTORIES(${LEAP_INCLUDE_DIR})\n
## ENDIF()
## \\endcode
## the macro: INSTALL_LEAP_DYNAMIC_LIB(config) [see detail on macro declaration] \\n
## Written by jesnault
## CMAKE_DOCUMENTATION_END

set(LEAP_POSSIBLE_PATHS
    ${LEAP_SDK} $ENV{LEAP_SDK}
    ${LEAP_DIR} $ENV{LEAP_DIR}
    ${LeapMotion_DIR} $ENV{LeapMotion_DIR}
)

find_path(LEAP_INCLUDE_DIR 
    NAMES Leap.h
    PATH_SUFFIXES "include"
    PATHS ${LEAP_POSSIBLE_PATHS}
)
set(LEAP_INCLUDE_DIRS ${LEAP_INCLUDE_DIR})

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(libSuffix "lib/x64")
else()
    set(libSuffix "lib/x86")
endif()

find_library(LEAP_LIBRARY_DEBUG
    NAMES Leapd
    PATH_SUFFIXES ${libSuffix}
    PATHS ${LEAP_POSSIBLE_PATHS}
)
find_library(LEAP_LIBRARY_RELEASE
    NAMES Leap
    PATH_SUFFIXES ${libSuffix}
    PATHS ${LEAP_POSSIBLE_PATHS}
)
set(LEAP_LIBRARIES debug ${LEAP_LIBRARY_DEBUG} optimized ${LEAP_LIBRARY_RELEASE})

set(CMAKE_FIND_LIBRARY_SUFFIXES_SAVE ${CMAKE_FIND_LIBRARY_SUFFIXES})
if (WIN32)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".dll")
elseif(APPLE)
else()
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".so")
endif()
find_library(LEAP_DYNAMIC_LIBRARY_DEBUG
    NAMES Leapd
    PATH_SUFFIXES ${libSuffix}
    PATHS ${LEAP_POSSIBLE_PATHS}
)
find_library(LEAP_DYNAMIC_LIBRARY_RELEASE
    NAMES Leap
    PATH_SUFFIXES ${libSuffix}
    PATHS ${LEAP_POSSIBLE_PATHS}
)
set(LEAP_DYNAMIC_LIBRARIES ${LEAP_DYNAMIC_LIBRARY_DEBUG} ${LEAP_DYNAMIC_LIBRARY_RELEASE})

if(WIN32)
	foreach(LEAP_WIN_REDIST_PATH ${LEAP_POSSIBLE_PATHS})
		file(GLOB LEAP_WIN_REDIST_DEBUG 	"${LEAP_WIN_REDIST_PATH}/${libSuffix}/[msvc]*d.dll")
		file(GLOB LEAP_WIN_REDIST_RELEASE	"${LEAP_WIN_REDIST_PATH}/${libSuffix}/[msvc]*[^d].dll")
	endforeach()
	set(LEAP_WIN_REDIST_DYNAMIC_LIBRARIES ${LEAP_WIN_REDIST_DEBUG} ${LEAP_WIN_REDIST_RELEASE})
endif()

set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES_SAVE})
find_package_handle_standard_args(LEAP DEFAULT_MSG 
    LEAP_LIBRARY_DEBUG   LEAP_LIBRARY_RELEASE
    LEAP_DYNAMIC_LIBRARY_DEBUG  LEAP_DYNAMIC_LIBRARY_RELEASE
    LEAP_INCLUDE_DIR
    )

if(NOT LEAP_FOUND)
	set(LEAP_DIR "" CACHE PATH "Root dir of LeapMotion")
endif()


## CMAKE_DOCUMENTATION_START INSTALL_LEAP_DYNAMIC_LIB
## Utility macro to help us to install standalone files \\n
## \\n
## WIN_REDIST 	\tflag option to install also visual studio redistribuable \\n
## DESTINATION	\tpath option to specify where to install (default to ${CNAKE_INSTALL_PREFIX}/bin) \\n
## COMPONENT	\talias option to specify the component name of installation \\n
## \\n
## Example usage :
## \\code
##  if(LEAP_FOUND) \n
## 		if(DEFINED CMAKE_BUILD_TYPE) ## for make / nmake config types \n
##			INSTALL_LEAP_DYNAMIC_LIB(${CMAKE_BUILD_TYPE} WIN_REDIST DESTINATION bin) \n
##		else() \n
##			foreach(CONFIG_TYPES ${CMAKE_CONFIGURATION_TYPES}) ## for multi config types (MSVC based) \n
##				INSTALL_LEAP_DYNAMIC_LIB(${CONFIG_TYPES} WIN_REDIST DESTINATION bin) \n
##			endforeach() \n
##		endif() \n
##	endif()
## \\endcode
## Written by jesnault
## CMAKE_DOCUMENTATION_END
macro(INSTALL_LEAP_DYNAMIC_LIB config)
	include(CMakeParseArguments)
	cmake_parse_arguments(instLeapDyn "WIN_REDIST" "" "DESTINATION;COMPONENT" ${ARGN}) ## both args are directory path
	
	if(NOT instLeapDyn_DESTINATION)
		set(instLeapDyn_DESTINATION bin)
	endif()
	
	if(NOT instLeapDyn_COMPONENT)
		set(instLeapDyn_COMPONENT )
	else()
		set(instLeapDyn_COMPONENT COMPONENT ${instLeapDyn_COMPONENT})
	endif()
	
	if(${config} MATCHES "Debug" AND LEAP_DYNAMIC_LIBRARY_DEBUG)
	
		if(EXISTS ${LEAP_DYNAMIC_LIBRARY_DEBUG})
			install(FILES ${LEAP_DYNAMIC_LIBRARY_DEBUG} DESTINATION ${instLeapDyn_DESTINATION} ${instLeapDyn_COMPONENT})
		endif()
		if(instLeapDyn_WIN_REDIST AND LEAP_WIN_REDIST_DEBUG)
			install(FILES ${LEAP_WIN_REDIST_DEBUG} DESTINATION ${instLeapDyn_DESTINATION} ${instLeapDyn_COMPONENT})
		endif()
		
	elseif(LEAP_DYNAMIC_LIBRARY_RELEASE)
	
		if(EXISTS ${LEAP_DYNAMIC_LIBRARY_RELEASE})
			install(FILES ${LEAP_DYNAMIC_LIBRARY_RELEASE} DESTINATION ${instLeapDyn_DESTINATION} ${instLeapDyn_COMPONENT})
		endif()
		if(instLeapDyn_WIN_REDIST AND LEAP_WIN_REDIST_RELEASE)
			install(FILES ${LEAP_WIN_REDIST_RELEASE} DESTINATION ${instLeapDyn_DESTINATION} ${instLeapDyn_COMPONENT})
		endif()
		
	endif()
	
endmacro()