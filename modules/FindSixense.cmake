## CMAKE_DOCUMENTATION_START FindSixense.cmake
## - Try to find SIXENSE SDK (2012) \\n
## -- Once done this will define : \\n
## \\t		SIXENSE_FOUND - System has sixense \\n
## \\n
## \\t		SIXENSE_DEFINITIONS - Compiler switches required for using sixense \\n
## \\n
## \\t		SIXENSE_INCLUDE_DIR and SIXENSE_INCLUDE_DIRS - The sixense include directory \\n
## \\n
## \\t		SIXENSE_LIBRARIES and SIXENSE_STATIC_LIBRARIES - All (debug and optimized) filePathNames libraries needed to use sixense sdk \\n
## \\n
## \\t		SIXENSE_<CONFIG>_LIBRARIES_NAMES and SIXENSE_<CONFIG>_STATIC_LIBRARIES_NAMES 	- The fileNames libraries needed to use sixense sdk \\n
## \\t		SIXENSE_<CONFIG>_LIBRARIES_PATHS and SIXENSE_<CONFIG>_STATIC_LIBRARIES_PATHS	- The pathNames libraries needed to use sixense sdk \\n
## \\t		SIXENSE_<CONFIG>_LIBRARIES 		 and SIXENSE_<CONFIG>_STATIC_LIBRARIES 			- The filePathNames libraries needed to use sixense sdk \\n
## \\n
##	Each dissociated lib :  \\n
## \\t		SIXENSE_<CONFIG>_LIBRARY_NAME and SIXENSE_<CONFIG>_STATIC_LIBRARY_NAME 	- The fileName library needed to use sixense \\n
## \\t		SIXENSE_<CONFIG>_LIBRARY_PATH and SIXENSE_<CONFIG>_STATIC_LIBRARY_PATH	- The pathName library needed to use sixense \\n
## \\t		SIXENSE_<CONFIG>_LIBRARY	  and SIXENSE_<CONFIG>_STATIC_LIBRARY 		- The filePathName library needed to use sixense \\n
## \\n
## \\t		SIXENSE_UTILS_<CONFIG>_LIBRARY_NAME and SIXENSE_UTILS_<CONFIG>_STATIC_LIBRARY_NAME	- The fileName library needed to use sixense_utils \\n
## \\t		SIXENSE_UTILS_<CONFIG>_LIBRARY_PATH and SIXENSE_UTILS_<CONFIG>_STATIC_LIBRARY_PATH	- The pathName library needed to use sixense_utils \\n
## \\t		SIXENSE_UTILS_<CONFIG>_LIBRARY 		and SIXENSE_UTILS_<CONFIG>_STATIC_LIBRARY		- The filePathName library needed to use sixense_utils \\n
## Created/Updated by jesnault
## CMAKE_DOCUMENTATION_END

## VERBOSITY SETTINGS
option(SIXENSE_VERBOSE "Do you want cmake to be verbose during project searching?" false)
message(STATUS "SIXENSE_VERBOSE = ${SIXENSE_VERBOSE}")


## DEFINE SIXENSE_DIR root path
if(NOT SIXENSE_DIR)
	set(SIXENSE_DIR "$ENV{SIXENSE_DIR}" CACHE PATH "Sixense root directory")
endif()

if(NOT SIXENSE_DIR)
    message(WARNING "SIXENSE_DIR no set")
	return()
else()
	file(TO_CMAKE_PATH ${SIXENSE_DIR} SIXENSE_DIR)
endif()

if(SIXENSE_VERBOSE)
    message(STATUS "SIXENSE_DIR = ${SIXENSE_DIR}")
endif()


## FIND SIXENSE INCLUDE DIR
find_path(SIXENSE_INCLUDE_DIR 
   NAME		sixense.h	#use a file .h looks like important file to find the path directory
   PATHS 	${SIXENSE_DIR}/include
   )
set(SIXENSE_INCLUDE_DIRS ${SIXENSE_INCLUDE_DIR})
if(SIXENSE_VERBOSE)
    message(STATUS "SIXENSE_INCLUDE_DIRS = ${SIXENSE_INCLUDE_DIRS}")
endif()


## SET SIXENSE ARCHI DIRS && SET ARCHI LIB POSTFIX
if(${CMAKE_SIZEOF_VOID_P} MATCHES 8) 		# we are on 64 bits architecture
	
	# ARCHI LIB POSTFIX by default
	set(SIXENSE_ARCHI_POSTFIX "_x64")
	
	# for MSVC compiler
	if(WIN32 AND CMAKE_CL_64)
		set(SIXENSE_ARCHI_DIR "x64")
	else()
		set(SIXENSE_ARCHI_DIR "win32")  # we want to build in 32 bits mode
		set(SIXENSE_ARCHI_POSTFIX "")	# so have to overload this variable
	endif()
	
	# for linux compiler
	if(UNIX)
		set(SIXENSE_ARCHI_DIR "linux_x64")
	endif()
	
	# for macOSX compiler
	IF(APPLE  AND ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
		set(SIXENSE_ARCHI_DIR "osx_x64")
	endif()
	
elseif(${CMAKE_SIZEOF_VOID_P} MATCHES 4) 	# we are on 32 bits architecture	

	# ARCHI LIB POSTFIX
	set(SIXENSE_ARCHI_POSTFIX "")
	
	# for MSVC compiler
	if(WIN32 AND NOT CMAKE_CL_64)
		set(SIXENSE_ARCHI_DIR "win32")
	endif()
	
	# for linux compiler
	if(UNIX)
		set(SIXENSE_ARCHI_DIR "linux")
	endif()
	
	# for macOSX compiler
	IF(APPLE  AND ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
		set(SIXENSE_ARCHI_DIR "osx")
	endif()
	
endif()
if(NOT SIXENSE_ARCHI_DIR)
	message(WARNING "Can't find SIXENSE_ARCHI_DIR")
endif()



## Internal used for define per config sixense libs.
## Use all previous SIXENSE_* cmake variable to 
## recompose the full path where we can find sixense libraries
## and recompose the full name of each sixense library
## based on the mainTargetLibName.
## define (for dynamic lib) :
## <mainTargetLibNameUpperCase>_<CONFIG>_LIBRARY_NAME
## <mainTargetLibNameUpperCase>_<CONFIG>_LIBRARY_PATH
## <mainTargetLibNameUpperCase>_<CONFIG>_LIBRARY
## define (for static lib) :
## <mainTargetLibNameUpperCase>_<CONFIG>_STATIC_LIBRARY_NAME
## <mainTargetLibNameUpperCase>_<CONFIG>_STATIC_LIBRARY_PATH
## <mainTargetLibNameUpperCase>_<CONFIG>_STATIC_LIBRARY
macro(find_sixense_libraries mainTargetLibName)

		string( TOUPPER ${mainTargetLibName} mainTargetLibName_UC )

		## SET SIXENSE CONFIG TYPE DIR && SET SIXENSE TYPE POSTFIX
		if(${CONFIG_TYPE_UC} MATCHES "DEBUG")
			set(SIXENSE_${CONFIG_TYPE_UC}_DIR "debug")
			set(SIXENSE_${CONFIG_TYPE_UC}_POSTFIX "d")
		else()
			set(SIXENSE_${CONFIG_TYPE_UC}_DIR "release")
			set(SIXENSE_${CONFIG_TYPE_UC}_POSTFIX "")
		endif()
		
		## FIND DYNAMIC SIXENSE LIBRARY
		set(${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_LIBRARY_NAME "${mainTargetLibName}${SIXENSE_${CONFIG_TYPE_UC}_POSTFIX}${SIXENSE_ARCHI_POSTFIX}")
		set(${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_LIBRARY_PATH "${SIXENSE_DIR}/lib/${SIXENSE_ARCHI_DIR}/${SIXENSE_${CONFIG_TYPE_UC}_DIR}_dll") # _dll postfix for dirname
		find_library(${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_LIBRARY
				NAMES	${${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_LIBRARY_NAME}
				PATHS	${${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_LIBRARY_PATH}
			)
		list(APPEND SIXENSE_${CONFIG_TYPE_UC}_LIBRARIES_NAMES	${${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_LIBRARY_NAME})
		list(APPEND SIXENSE_${CONFIG_TYPE_UC}_LIBRARIES_PATHS	${${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_LIBRARY_PATH})
		list(APPEND SIXENSE_${CONFIG_TYPE_UC}_LIBRARIES			${${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_LIBRARY})
		list(APPEND SIXENSE_LIBRARIES optimized ${SIXENSE_RELEASE_LIBRARIES} debug ${SIXENSE_DEBUG_LIBRARIES})
		
		## FIND STATIC SIXENSE LIBRARY
		set(${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_STATIC_LIBRARY_NAME "${mainTargetLibName}${SIXENSE_${CONFIG_TYPE_UC}_POSTFIX}_s${SIXENSE_ARCHI_POSTFIX}") # _s postfix for libname
		set(${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_STATIC_LIBRARY_PATH "${SIXENSE_DIR}/lib/${SIXENSE_ARCHI_DIR}/${SIXENSE_${CONFIG_TYPE_UC}_DIR}_static") # _static postfix for dirname
		find_library(${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_STATIC_LIBRARY
				NAMES	${${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_STATIC_LIBRARY_NAME}
				PATHS	${${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_STATIC_LIBRARY_PATH}
			)
		list(APPEND SIXENSE_${CONFIG_TYPE_UC}_STATIC_LIBRARIES_NAMES	${${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_STATIC_LIBRARY_NAME})
		list(APPEND SIXENSE_${CONFIG_TYPE_UC}_STATIC_LIBRARIES_PATHS	${${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_STATIC_LIBRARY_PATH})
		list(APPEND SIXENSE_${CONFIG_TYPE_UC}_STATIC_LIBRARIES			${${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_STATIC_LIBRARY})
		list(APPEND SIXENSE_STATIC_LIBRARIES optimized ${SIXENSE_RELEASE_STATIC_LIBRARY} debug ${SIXENSE_DEBUG_STATIC_LIBRARY})
		
		include(FindPackageHandleStandardArgs)
		find_package_handle_standard_args( SIXENSE DEFAULT_MSG
			${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_LIBRARY
			${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_STATIC_LIBRARY
			SIXENSE_INCLUDE_DIR
			)
		
		if(SIXENSE_VERBOSE)
			message(STATUS "${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_LIBRARY = ${${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_LIBRARY}")
			message(STATUS "${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_STATIC_LIBRARY = ${${mainTargetLibName_UC}_${CONFIG_TYPE_UC}_STATIC_LIBRARY}")
		endif()
		
endmacro()


## FIND SIXENSE LIBRARIES by CONFIG BUILD TYPE
# First, for one-config build (makefiles)
if(CMAKE_BUILD_TYPE AND NOT MSVC_IDE)
	string( TOUPPER ${CMAKE_BUILD_TYPE} CONFIG_TYPE_UC )
	find_sixense_libraries(sixense)
	find_sixense_libraries(sixense_utils)
endif()

# Second, for multi-config builds (visual studio based)
# WARNING : use of visual studio variable "ConfigurationName".
if(MSVC_IDE)
	foreach( OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES} )
		string( TOUPPER ${OUTPUTCONFIG} CONFIG_TYPE_UC )
		find_sixense_libraries(sixense)
		find_sixense_libraries(sixense_utils)
	endforeach()
endif()	
