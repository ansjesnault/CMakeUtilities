## CMAKE_DOCUMENTATION_START FindTinyXML.cmake
## Usage :
## \\code
##   find_package(TinyXml)
##   find_package(TinyXml REQUIRED COMPONENTS STL)
## \\endcode
## Created/updated by jesnault while last cmake version was 3.0.2
## CMAKE_DOCUMENTATION_END

if(NOT TinyXml_DIR)
    set(TinyXml_DIR "$ENV{TinyXml_DIR}" CACHE PATH "TinyXml root directory")
endif()
if(TinyXml_DIR)
	file(TO_CMAKE_PATH ${TinyXml_DIR} TinyXml_DIR)
endif()

## set default verbosity
if(NOT TinyXml_VERBOSE)
	set(TinyXml_VERBOSE OFF)
else()
	message(STATUS "Start to FindTinyXml.cmake :")
endif()


## set the LIB POSTFIX to find in a right directory according to what kind of compiler we use (32/64bits)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)  # Size in bytes!
	set(TinyXml_SEARCH_LIB_POSTFIX "64" CACHE STRING "suffix for 32/64 dir placement")
else()  # Size in bytes!
	set(TinyXml_SEARCH_LIB_POSTFIX "" CACHE STRING "suffix for 32/64 dir placement")
endif()
if(TinyXml_SEARCH_LIB_POSTFIX)
	mark_as_advanced(TinyXml_SEARCH_LIB_POSTFIX)
	if(TinyXml_VERBOSE)
		message(STATUS "   find_library will search inside lib${TinyXml_SEARCH_LIB_POSTFIX} directory (can be changed with TinyXml_SEARCH_LIB_POSTFIX)")
	endif()
endif()

if(TinyXml_DIR)
	file(TO_CMAKE_PATH ${TinyXml_DIR} TinyXml_DIR)
    
		FIND_PATH(TinyXml_INCLUDE_DIR 
		NAMES tinyxml.h
		PATHS ${TinyXml_DIR}/include
		)
        
        set(TinyXml_libName     tinyxml)
        set(TinyXml_DEBUG_DIR   Debugtinyxml)
        set(TinyXml_RELEASE_DIR Releasetinyxml)
        if(TinyXml_FIND_REQUIRED)
            if(TinyXml_FIND_REQUIRED_STL)
                set(TinyXml_libName     tinyxmlSTL)
                set(TinyXml_DEBUG_DIR   DebugtinyxmlSTL)
                set(TinyXml_RELEASE_DIR ReleasetinyxmlSTL)
                add_definitions(-DTIXML_USE_STL)
            endif()
        endif()
    
        unset(TinyXml_LIBRARY_RELEASE CACHE)
		find_library(TinyXml_LIBRARY_RELEASE 
			NAMES 			${TinyXml_libName}
			PATHS 			${TinyXml_DIR}/lib${TinyXml_SEARCH_LIB_POSTFIX}
			PATH_SUFFIXES	${TinyXml_RELEASE_DIR}
		)
        unset(TinyXml_LIBRARY_DEBUG CACHE)
		find_library(TinyXml_LIBRARY_DEBUG 
			NAMES 			${TinyXml_libName}
			PATHS 			${TinyXml_DIR}/lib${TinyXml_SEARCH_LIB_POSTFIX}
			PATH_SUFFIXES	${TinyXml_DEBUG_DIR}
		)
        
		set(TinyXml_LIBRARIES optimized ${TinyXml_LIBRARY_RELEASE} debug ${TinyXml_LIBRARY_DEBUG})
		
		if(TinyXml_INCLUDE_DIR AND TinyXml_LIBRARIES)
			set(TinyXml_FOUND TRUE)
		endif()
	  
		if(TinyXml_FOUND)
			if(NOT TinyXml_FIND_QUIETLY)
				message(STATUS "Found TinyXml: ${TinyXml_LIBRARIES}")
			endif()
		else()
			if(TinyXml_FIND_REQUIRED)
			  message(FATAL_ERROR "could NOT find TinyXml")
			endif()
		endif()
		MARK_AS_ADVANCED(TinyXml_INCLUDE_DIR TinyXml_LIBRARIES)
		
else()
		message("Specify TinyXml_DIR")
endif()