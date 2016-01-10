## CMAKE_DOCUMENTATION_START FindCholmod.cmake
## CMake file to locate CHOLMOD and its dependencies. \\n
## Variables : \\n
##   \\tCHOLMOD_FOUND         \\tTrue if Cholmod include and libraries were found \\n
##   \\tCHOLMOD_INCLUDE_DIRS  \\tPath containing cholmod.h (and suiteSparse_config.h on windows) \\n
##   \\tCHOLMOD_LIBRARIES     \\tAbsolute paths of Cholmod libs \\n
## CMAKE_DOCUMENTATION_END

if(NOT CHOLMOD_DIR)
    set(CHOLMOD_DIR "$ENV{CHOLMOD_DIR}" CACHE PATH "CHOLMOD root directory")
endif()
file(TO_CMAKE_PATH ${CHOLMOD_DIR} CHOLMOD_DIR)

IF(WIN32)
	if(NOT CHOLMOD_INCLUDE_DIR)
		FIND_PATH   (	CHOLMOD_INCLUDE_DIR	cholmod.h
						PATHS
							/opt/local/include
							
							/usr/include
							/usr/local/include
							/usr/include/suitesparse
							/usr/local/include/suitesparse
							
							${CHOLMOD_DIR}/include
							${CHOLMOD_DIR}/CHOLMOD/include
					)
	endif()				

	if(CHOLMOD_INCLUDE_DIR)
	    list(APPEND CHOLMOD_INCLUDE_DIRS ${CHOLMOD_INCLUDE_DIR})
		file(READ ${CHOLMOD_INCLUDE_DIR}/cholmod.h cholmodHeaderContent)
		string(REGEX MATCH "SuiteSparse_config.h" requieredSuiteSparseConfigHeader ${cholmodHeaderContent})
		if(requieredSuiteSparseConfigHeader)
			FIND_PATH   (	CHOLMOD_SUITESPARSECONFIG_INCLUDE_DIR	SuiteSparse_config.h
							PATHS
								/opt/local/include
								
								/usr/include
								/usr/local/include
								/usr/include/suitesparse
								/usr/local/include/suitesparse
								
								${CHOLMOD_DIR}/include
								${CHOLMOD_DIR}/SuiteSparse_config
						)
			if(NOT CHOLMOD_SUITESPARSECONFIG_INCLUDE_DIR)
				message(SEND_ERROR "Need to set CHOLMOD_SUITESPARSECONFIG_INCLUDE_DIR ,where we can find SuiteSparse_config.h")
		    else()
				list(APPEND CHOLMOD_INCLUDE_DIRS ${CHOLMOD_INCLUDE_DIR} ${CHOLMOD_SUITESPARSECONFIG_INCLUDE_DIR})
			endif()
		endif()
	endif()
	
	if(NOT CHOLMOD_LIBRARIES)	
		FIND_LIBRARY(	CHOLMOD_LIBRARIES 	
						NAMES CHOLMOD SuiteSparse
						PATHS 
							/opt/local/lib 
							
							/usr/lib64
							/usr/lib
							/usr/local/lib64
							/usr/local/lib
							
							${CHOLMOD_DIR}/lib64
							${CHOLMOD_DIR}/lib
					)
	endif()
ENDIF(WIN32)

IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  SET(CHOLMOD_LIB_SEARCH_PATH /opt/local/lib ${CHOLMOD_DIR}/lib $ENV{CHOLMOD_DIR}/lib)
  SET(CHOLMOD_INC_SEARCH_PATH /opt/local/include ${CHOLMOD_DIR}/include $ENV{CHOLMOD_DIR}/include)
  FIND_PATH   (CHOLMOD_INCLUDE_DIR  cholmod.h        PATHS ${CHOLMOD_INC_SEARCH_PATH})
  FIND_LIBRARY(CHOLMOD_LIBRARIES    libSuiteSparse.dylib PATHS ${CHOLMOD_LIB_SEARCH_PATH})
ENDIF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

IF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  SET(CHOLMOD_LIB_SEARCH_PATH /usr/lib64 /usr/lib /usr/local/lib64 /usr/local/lib ${CHOLMOD_DIR}/lib64 ${CHOLMOD_DIR}/lib $ENV{CHOLMOD_DIR}/lib64 $ENV{CHOLMOD_DIR}/lib)
  SET(CHOLMOD_INC_SEARCH_PATH /usr/include /usr/local/include /usr/include/suitesparse /usr/local/include/suitesparse ${CHOLMOD_DIR}/include $ENV{CHOLMOD_DIR}/include)
  FIND_PATH   (CHOLMOD_INCLUDE_DIR  cholmod.h     PATHS ${CHOLMOD_INC_SEARCH_PATH})
  FIND_LIBRARY(CHOLMOD_LIBRARIES    libcholmod.so PATHS ${CHOLMOD_LIB_SEARCH_PATH})
ENDIF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CHOLMOD REQUIRED_VARS CHOLMOD_INCLUDE_DIR CHOLMOD_LIBRARIES) ## Will set CHOLMOD_FOUND according to the existing REQUIRED_VARS

message(STATUS "You can now use CHOLMOD by using CHOLMOD_INCLUDE_DIRS and CHOLMOD_LIBRARIES cmake variables")
