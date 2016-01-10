## CMAKE_DOCUMENTATION_START FindGLEW.cmake
## Try to find the GLEW library \\n
## Once done this will define : \\n
##  \\tGLEW_FOUND 		\\t\\t- system has GLEW \\n
##  \\tGLEW_INCLUDE_DIR \\t- the GLEW include directory \\n
##  \\tGLEW_LIBRARIES 	\\t- The libraries needed to use GLEW \\n
## CMAKE_DOCUMENTATION_END

if(GLEW_INCLUDE_DIR AND GLEW_LIBRARIES)
  set(GLEW_FOUND TRUE)
else(GLEW_INCLUDE_DIR AND GLEW_LIBRARIES)
  FIND_PATH(GLEW_INCLUDE_DIR GL/glew.h
    /usr/include
    /usr/local/include
    /opt/local/include
    $ENV{GLEWROOT}/include
    $ENV{GLEW_ROOT}/include
    $ENV{GLEW_DIR}/include
    $ENV{GLEW_DIR}/inc
    [HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\8.0\\Setup\\VC]/PlatformSDK/Include
    )

  FIND_LIBRARY(GLEW_LIBRARY_RELEASE NAMES glew64 GLEW glew glew32
    PATHS
    /usr/lib
    /usr/lib64
    /usr/local/lib
    /usr/local/lib64
    /opt/local/lib
    $ENV{GLEWROOT}/lib
    $ENV{GLEW_ROOT}/lib
    $ENV{GLEW_DIR}/lib
	${GLEW_LIBRARY_DIR}
    [HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\8.0\\Setup\\VC]/PlatformSDK/Lib
	PATH_SUFFIXES Release
    DOC "glew library name"
    )
  FIND_LIBRARY(GLEW_LIBRARY_DEBUG NAMES glew64d GLEWd glewd glew32d
    PATHS
    /usr/lib
    /usr/lib64
    /usr/local/lib
    /usr/local/lib64
    /opt/local/lib
    $ENV{GLEWROOT}/lib
    $ENV{GLEW_ROOT}/lib
    $ENV{GLEW_DIR}/lib
	${GLEW_LIBRARY_DIR}
    [HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\8.0\\Setup\\VC]/PlatformSDK/Lib
	PATH_SUFFIXES Debug
    DOC "glew library name"
    )
	
	# In case only one of the compilation type is available for the library we force the other type to the only available one
	if(GLEW_LIBRARY_RELEASE)
		if(NOT GLEW_LIBRARY_DEBUG)
			set(GLEW_LIBRARY_DEBUG ${GLEW_LIBRARY_RELEASE} CACHE PATH "Path to a library." FORCE)
		endif()
	endif()
	if(GLEW_LIBRARY_DEBUG)
		if(NOT GLEW_LIBRARY_RELEASE)
			set(GLEW_LIBRARY_RELEASE ${GLEW_LIBRARY_DEBUG} CACHE PATH "Path to a library." FORCE)
		endif()
	endif()
	
	INCLUDE(FindPackageHandleStandardArgs)
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(GLEW DEFAULT_MSG GLEW_INCLUDE_DIR GLEW_LIBRARY_RELEASE GLEW_LIBRARY_DEBUG)
	
	IF(GLEW_FOUND)
	  SET(GLEW_LIBRARIES optimized "${GLEW_LIBRARY_RELEASE}" debug "${GLEW_LIBRARY_DEBUG}")
	ELSE()
	  SET(GLEW_LIBRARIES )
	ENDIF()
  
endif(GLEW_INCLUDE_DIR AND GLEW_LIBRARIES)
