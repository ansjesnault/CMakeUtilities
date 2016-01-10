## CMAKE_DOCUMENTATION_START FindCGAL.cmake
## Find the CGAL includes and client library.\\n
## This module defines:\\n
##  \\tCGAL_INCLUDE_DIR, where to find CGAL.h \\n
##  \\tCGAL_LIBRARIES, the libraries needed to use CGAL. \\n
##  \\tCGAL_FOUND, If false, do not try to use CGAL. \\n
## CMAKE_DOCUMENTATION_END
## Written by Jerome Esnault
	
## set the LIB POSTFIX to find in a right directory according to what kind of compiler we use (32/64bits)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)  # Size in bytes!
	set(CGAL_SEARCH_LIB_POSTFIX "64" CACHE STRING "suffix for 32/64 dir placement")
else()
	set(CGAL_SEARCH_LIB_POSTFIX "" CACHE STRING "suffix for 32/64 dir placement")
endif()

	if(CGAL_INCLUDE_DIR AND CGAL_LIBRARIES)
		set(CGAL_FOUND TRUE)
	else()
		FIND_PATH(CGAL_INCLUDE_DIR 
			NAMES	CGAL/basic.h
			PATHS
				${CGAL_DIR}
				/usr
				/usr/local
				$ENV{ProgramFiles}/CGAL/*
				$ENV{SystemDrive}/CGAL/*
			PATH_SUFFIXES include
		)
		  find_library(CGAL_LIBRARIES 
			NAMES CGAL libCGAL
			PATHS
				${CGAL_DIR}
				/usr
				/usr/local
				/usr/lib${CGAL_SEARCH_LIB_POSTFIX}/CGAL
				$ENV{ProgramFiles}/CGAL/*
				$ENV{SystemDrive}/CGAL/*
			PATH_SUFFIXES lib${CGAL_SEARCH_LIB_POSTFIX} lib
		)	
	endif()
	
	include(FindPackageHandleStandardArgs)
	find_package_handle_standard_args(CGAL REQUIRED_VARS CGAL_INCLUDE_DIR CGAL_LIBRARIES)

    ## Workaround rouding optimisation
    if(UNIX)
        list(FIND CMAKE_CXX_FLAGS "-frounding-math" id)
        if(id MATCHES "-1")
            ## 'CGAL::Assertion_exception' what():  CGAL ERROR: assertion violation! 
            ## Expr: -CGAL_IA_MUL(-1.1, 10.1) != CGAL_IA_MUL(1.1, 10.1)
            ## So need to add this flag to build with GCC
            SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -frounding-math")
        endif()
    endif()

