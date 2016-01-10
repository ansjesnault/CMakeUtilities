## CMAKE_DOCUMENTATION_START FindSuiteSparse.cmake
## CMake file to locate SuiteSparse and its useful composite projects. \\n
## The first developpement of this file was made fro Windows users who
## use the http://code.google.com/p/suitesparse-metis-for-windows/ \\n
## downloaded here : \\n
## svn checkout http://suitesparse-metis-for-windows.googlecode.com/svn/trunk/ suitesparse-metis-for-windows \\n
## Anyway, it chould be work also on linux (tested on fedora 17 when you installed suitesparse from yum) \\n
## \\n
## \\n
## Inputs variables this file can process (variable must be given before find_package(SUITESPARES ...) command) : \\n
##   * SuiteSparse_VERBOSE			Default to OFF \\n
##   * SuiteSparse_USE_LAPACK_BLAS	Default to OFF. If ON append to SuiteSparse_LIBRARIES the blas and lapack library \\n
##   Note: SuiteSparse lib usually requires linking to a blas and lapack library. \\n
## \\n
## \\n
## Help variables this file handle internaly : \\n
##   * SuiteSparse_SEARCH_LIB_POSTFIX		Is set in cache (as advanced) to look into the right lib/lib64 dir for libraries (user can change) \\n
## \\n
## \\n
## Variables this file provide :  \\n
##   * SuiteSparse_FOUND         			True if SuiteSparse given COMPONENTS include and libraries were found \\n
##   * SuiteSparse_INCLUDE_DIRS  			Paths containing SuiteSparse needed headers (depend on which COMPONENTS you gave) \\n
##   * SuiteSparse_LIBRARIES     			Absolute paths of SuiteSparse libs found (depend on which COMPONENTS you gave) \\n
##   If SuiteSparse_USE_LAPACK_BLAS is set to ON :  \\n
##   	* SuiteSparse_LAPACK_BLAS_LIBRARIES 	Which contain the libblas and liblapack libraries \\n
##   	On windows: \\n
##   		* SuiteSparse_LAPACK_BLAS_DLL		Which contain all requiered binaries for use libblas and liblapack \\n
## \\n
## \\n
## Detailed variables this file provide : \\n
##   * SuiteSparse_<UPPPER_CASE_COMPONENT>_FOUND		True if the given component to look for is found (INCLUDE DIR and LIBRARY) \\n
##   * SuiteSparse_<UPPPER_CASE_COMPONENT>_INCLUDE_DIR	The path directory where we can found all compenent header files \\n
##   * SuiteSparse_<UPPPER_CASE_COMPONENT>_LIBRARY		The file path to the component library \\n
##   Note: If a component is not found, a SuiteSparse_<UPPPER_CASE_COMPONENT>_DIR cache variable is set to allow user set the search directory. \\n
## \\n
## \\n
## Possible componnents to find are (maybe some others can be available): \\n
##   * AMD 		\\n
##   * CAMD 	\\n
##   * COLAMD 	\\n
##   * CCOLAMD 	\\n
##   * CHOLMOD	: this lib need all previous one. According to how it was build (a single static lib or a full dynamic one), you should looking for its dependencies. \\n
##   * metis (opt): may not be found (depend if suitesparse was build with metis or not) => required by CHOLMOD (optional) \\n
## \\n
## \\n
## How to use this file :  \\n
##   (opt) set(SuiteSparse_VERBOSE ON) \\n
##   (opt) set(SuiteSparse_USE_LAPACK_BLAS ON) \\n
##   ( 1 ) find_package(SuiteSparse) ## metis is not search by default because it's not a part of suitesparse (suitesparse can be built without metis) \\n
##   ( 2 ) find_package(SuiteSparse COMPONENTS metis CHOLMOD) 		## be careful, components are case sensitive \\n
##   ( 3 ) find_package(SuiteSparse COMPONENTS metis suitesparse)	## valid on windows (linux have no suitesparse library) \\n
##   ( 4 ) find_package(SuiteSparse COMPONENTS suitesparse) \\n
##  \\code
##    if(SuiteSparse_FOUND)
##       include_directories(${SuiteSparse_INCLUDE_DIRS})
##		 target_link_library(<myProject> ${SuiteSparse_LIBRARIES})
##	  endif()
##	\\endcode
## Created / Updaed by jesnault 2014
## CMAKE_DOCUMENTATION_END

## check if global root SuiteSparse folder is set or not and cache it in order to let user fill it
if(NOT SuiteSparse_DIR)
    set(SuiteSparse_DIR "$ENV{SuiteSparse_DIR}" CACHE PATH "SuiteSparse root directory")
endif()
if(SuiteSparse_DIR)
	file(TO_CMAKE_PATH ${SuiteSparse_DIR} SuiteSparse_DIR)
endif()

## set default verbosity
if(NOT SuiteSparse_VERBOSE)
	set(SuiteSparse_VERBOSE OFF)
else()
	message(STATUS "Start to FindSuiteSparse.cmake :")
endif()


## set the LIB POSTFIX to find in a right directory according to what kind of compiler we use (32/64bits)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)  # Size in bytes!
	set(SuiteSparse_SEARCH_LIB_POSTFIX "64" CACHE STRING "suffix for 32/64 dir placement")
else()  # Size in bytes!
	set(SuiteSparse_SEARCH_LIB_POSTFIX "" CACHE STRING "suffix for 32/64 dir placement")
endif()
if(SuiteSparse_SEARCH_LIB_POSTFIX)
	mark_as_advanced(SuiteSparse_SEARCH_LIB_POSTFIX)
	if(SuiteSparse_VERBOSE)
		message(STATUS "   find_library will search inside lib${SuiteSparse_SEARCH_LIB_POSTFIX} directory (can be changed with SuiteSparse_SEARCH_LIB_POSTFIX)")
	endif()
endif()


## This utility macro is used to find all suitesparse projects by giving its name
## Since the name structure is the same for lib name and include dir name,
## we can use a generic way to find all of these with simple cmake lines of code
macro(SuiteSparse_FIND_COMPONENTS )

	## On windows : we absolutly need SuiteSparse_config.h every time for all projects
	if(WIN32)
		list(FIND SuiteSparse_FIND_COMPONENTS "SuiteSparse_config" SS_config_index)
		if(${SS_config_index} MATCHES "-1")
			list(APPEND SuiteSparse_FIND_COMPONENTS SuiteSparse_config)
			if(SuiteSparse_VERBOSE)
				message(STATUS "   On windows, we absolutly need SuiteSparse_config.h every time for all projects : add SuiteSparse_config component to look for")
			endif()
		endif()
	endif()

	## special check for suitesparse component (allow to find on windows but not on linux because doesn't exist)
	list(FIND SuiteSparse_FIND_COMPONENTS "suitesparse" ss_index)
	if(${ss_index} MATCHES "-1")
		## do nothing, the user didn't provide the suisparse componnent
	else()
		if(WIN32)
			## do nothing, the user provide the suisparse componnent we will try to find
		else()
			list(REMOVE_AT SuiteSparse_FIND_COMPONENTS ${ss_index})
			if(SuiteSparse_VERBOSE)
				message(STATUS "   On this plateform : suitesparse lib doesn't exist (only on windows), so skip this component")
			endif()
		endif()
	endif()
		
	## Look for each component the same way :
	##  * For include dir the reference file is the <component>.h
	##	* for library fileName the reference is the <component> itself (cmake will prepend/append necessary prefix/suffix according to the plateform)
	foreach(suitesparseComp ${SuiteSparse_FIND_COMPONENTS})

		## used to construct specific cmake variables (in upper case) according to the component, but also used for find_*()
		string(TOUPPER ${suitesparseComp} suitesparseCompUC)
		string(TOLOWER ${suitesparseComp} suitesparseCompLC)

		## try to find include dir (looking for very important header file)
		find_path(SuiteSparse_${suitesparseCompUC}_INCLUDE_DIR	
			NAMES 			${suitesparseComp}.h ${suitesparseCompLC}.h ${suitesparseCompUC}.h
						${suitesparseComp}.hpp ${suitesparseCompLC}.hpp ${suitesparseCompUC}.hpp
			PATHS			/opt/local/include
						/usr/include
						/usr/local/include
						/usr/include/suitesparse
						/usr/local/include/suitesparse
						/usr/include/${suitesparseComp}
						/usr/local/include/${suitesparseComp}
						${SuiteSparse_DIR}/include
						${SuiteSparse_DIR}/include/suitesparse
						${SuiteSparse_DIR}/suitesparse/include
						${SuiteSparse_DIR}/include/${suitesparseComp}
						${SuiteSparse_DIR}/${suitesparseComp}/include
						${${suitesparseCompUC}_DIR}/include
						${${suitesparseCompUC}_DIR}/${suitesparseComp}/include
						${${suitesparseCompUC}_DIR}
		)
		## check if found
		if(NOT SuiteSparse_${suitesparseCompUC}_INCLUDE_DIR)
			message(WARNING "   Failed to find ${suitesparseComp} :\nSuiteSparse_${suitesparseCompUC}_INCLUDE_DIR not found.\nCheck you write correctly the component name (case sensitive),\nor set the SuiteSparse_${suitesparseCompUC}_DIR to look inside")
		else()
			list(APPEND SuiteSparse_INCLUDE_DIRS	${SuiteSparse_${suitesparseCompUC}_INCLUDE_DIR})
		endif()

		## try to find filepath lib name (looking for very important lib file)
		find_library(SuiteSparse_${suitesparseCompUC}_LIBRARY_RELEASE 
			NAMES 			lib${suitesparseComp} 	lib${suitesparseCompLC} lib${suitesparseCompUC}
							${suitesparseComp} 		${suitesparseCompLC} 	${suitesparseCompUC}
			PATHS 			/opt/local/lib${SuiteSparse_SEARCH_LIB_POSTFIX} 		
							/usr/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
							/usr/local/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
							${SuiteSparse_DIR}/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
							${${suitesparseCompUC}_DIR}/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
							${${suitesparseCompUC}_DIR}
			PATH_SUFFIXES	Release
		)
		find_library(SuiteSparse_${suitesparseCompUC}_LIBRARY_DEBUG 
			NAMES 			${suitesparseComp}d		${suitesparseCompLC}d 		${suitesparseCompUC}d
							lib${suitesparseComp}d 	lib${suitesparseCompLC}d 	lib${suitesparseCompUC}d
			PATHS 			/opt/local/lib${SuiteSparse_SEARCH_LIB_POSTFIX} 		
							/usr/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
							/usr/local/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
							${SuiteSparse_DIR}/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
							${${suitesparseCompUC}_DIR}/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
							${${suitesparseCompUC}_DIR}
			PATH_SUFFIXES	Debug
		)
		
		## check and auto complete release with debug if release missing and vice versa
		if(SuiteSparse_${suitesparseCompUC}_LIBRARY_RELEASE)
			if(NOT SuiteSparse_${suitesparseCompUC}_LIBRARY_DEBUG)
				set(SuiteSparse_${suitesparseCompUC}_LIBRARY_DEBUG ${SuiteSparse_${suitesparseCompUC}_LIBRARY_RELEASE} CACHE PATH "Path to a library." FORCE)
			endif()
		endif()
		if(SuiteSparse_${suitesparseCompUC}_LIBRARY_DEBUG)
			if(NOT SuiteSparse_${suitesparseCompUC}_LIBRARY_RELEASE)
				set(SuiteSparse_${suitesparseCompUC}_LIBRARY_RELEASE ${SuiteSparse_${suitesparseCompUC}_LIBRARY_DEBUG} CACHE PATH "Path to a library." FORCE)
			endif()
		endif()
		
		## check and append the and SuiteSparse_LIBRARIES list, and warn if not found (release and debug) otherwise
		if(NOT SuiteSparse_${suitesparseCompUC}_LIBRARY_RELEASE AND NOT SuiteSparse_${suitesparseCompUC}_LIBRARY_DEBUG)
			message(WARNING "   Failed to find ${suitesparseComp} :
			Check you write correctly the component name (case sensitive),
			or set the SuiteSparse_${suitesparseCompUC}_DIR to look inside,
			or set directly SuiteSparse_${suitesparseCompUC}_LIBRARY_DEBUG and SuiteSparse_${suitesparseCompUC}_LIBRARY_RELEASE
			")
		else()
			list(APPEND SuiteSparse_LIBRARIES	optimized "${SuiteSparse_${suitesparseCompUC}_LIBRARY_RELEASE}" debug "${SuiteSparse_${suitesparseCompUC}_LIBRARY_DEBUG}")
		endif()
		
		## here we allow to find at least the include OR the lib dir and just warn if one of both missing
		if(NOT SuiteSparse_${suitesparseCompUC}_INCLUDE_DIR AND NOT SuiteSparse_${suitesparseCompUC}_LIBRARY_RELEASE)
			set(SuiteSparse_${suitesparseCompUC}_FOUND OFF)
		else()
			set(SuiteSparse_${suitesparseCompUC}_FOUND ON)
		endif()
		
		## if one of both (include dir or filepath lib), then we provide a new cmake cache variable for the search. Otherwise we don't need anymore to expose all intermediates variables
		if(NOT SuiteSparse_${suitesparseCompUC}_FOUND)
			set(SuiteSparse_${suitesparseCompUC}_DIR "$ENV{SuiteSparse_${suitesparseCompUC}_DIR}" CACHE PATH "${suitesparseComp} root directory")
		else()
			mark_as_advanced(SuiteSparse_${suitesparseCompUC}_INCLUDE_DIR)
			mark_as_advanced(SuiteSparse_${suitesparseCompUC}_LIBRARY_RELEASE)
			mark_as_advanced(SuiteSparse_${suitesparseCompUC}_LIBRARY_DEBUG)
			if(DEFINED SuiteSparse_${suitesparseCompUC}_DIR)
				mark_as_advanced(SuiteSparse_${suitesparseCompUC}_DIR)
			endif()
		endif()

		if(SuiteSparse_VERBOSE)
			message(STATUS "   SuiteSparse_${suitesparseCompUC}_FOUND = ${SuiteSparse_${suitesparseCompUC}_FOUND} : ")
			message(STATUS "      * SuiteSparse_${suitesparseCompUC}_INCLUDE_DIR = ${SuiteSparse_${suitesparseCompUC}_INCLUDE_DIR}")
			message(STATUS "      * SuiteSparse_${suitesparseCompUC}_LIBRARY_DEBUG = ${SuiteSparse_${suitesparseCompUC}_LIBRARY_DEBUG}")
			message(STATUS "      * SuiteSparse_${suitesparseCompUC}_LIBRARY_RELEASE = ${SuiteSparse_${suitesparseCompUC}_LIBRARY_RELEASE}")
		endif()
		
		list(APPEND SuiteSparse_FOUND_LIST SuiteSparse_${suitesparseCompUC}_FOUND)
		
		## special definition needed for metis
		if(${suitesparseComp} MATCHES "metis")
			set(SuiteSparse_${suitesparseCompUC}_DEFINITIONS "-DNPARTITION")
			add_definitions(${SuiteSparse_${suitesparseCompUC}_DEFINITIONS})
			if(SuiteSparse_VERBOSE)
				message(STATUS "      * SuiteSparse_${suitesparseCompUC}_DEFINITIONS = ${SuiteSparse_${suitesparseCompUC}_DEFINITIONS}")
			endif()
		endif()
		
	endforeach()
	
	
	## set the final SuiteSparse_FOUND based on all previous components found (status)
	foreach(componentToCheck ${SuiteSparse_FOUND_LIST})
		set(SuiteSparse_FOUND ON)
		if(NOT ${componentToCheck})
			set(SuiteSparse_FOUND OFF)
			break() ## one component not found is enought to failed
		endif()
	endforeach()
endmacro()

## Default behavior if user don't use the COMPONENTS flag in find_package(SuiteSparse ...) command
if(NOT SuiteSparse_FIND_COMPONENTS)
	list(APPEND SuiteSparse_FIND_COMPONENTS AMD CAMD CCOLAMD COLAMD CHOLMOD SPQR LDL BTF KLU)  ## suitesparse and metis are not searched by default (special case)
endif()

SuiteSparse_FIND_COMPONENTS()

## check if we have to find also blas and lapack lib for SuiteSparse
if(SuiteSparse_USE_LAPACK_BLAS)

	## set additional search dirs
	set(ADDITIONAL_SEARCH_DIRS 
		${SuiteSparse_DIR}/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
		${SuiteSparse_DIR}/lapack_windows/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
		${SuiteSparse_DIR}/lapack_windows/x${SuiteSparse_SEARCH_LIB_POSTFIX}
		${SuiteSparse_DIR}/blas_windows/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
		${SuiteSparse_DIR}/blas_windows/x${SuiteSparse_SEARCH_LIB_POSTFIX}
		${SuiteSparse_DIR}/lib${SuiteSparse_SEARCH_LIB_POSTFIX}/lapack_windows
		${SuiteSparse_DIR}/lib${SuiteSparse_SEARCH_LIB_POSTFIX}/blas_windows
		${SuiteSparse_DIR}/lib${SuiteSparse_SEARCH_LIB_POSTFIX}/lapack_blas_windows
		${SuiteSparse_DIR}/lapack_blas_windows
		${SuiteSparse_DIR}/lapack_blas_windows/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
	)

	## try to find blas lib
	find_library(SuiteSparse_BLAS_LIBRARY 
		NAMES 			blas cblas libblas
		PATHS 			/opt/local/lib${SuiteSparse_SEARCH_LIB_POSTFIX}		
						/usr/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
						/usr/local/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
						${SuiteSparse_BLAS_DIR}/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
						${SuiteSparse_BLAS_DIR}
						${ADDITIONAL_SEARCH_DIRS}
		PATH_SUFFIXES	Release Debug
	)
	if(NOT SuiteSparse_BLAS_LIBRARY)
		message(SEND_ERROR "   Failed to find SuiteSparse_BLAS_LIBRARY.Set it manually or set the SuiteSparse_BLAS_DIR to looking for it inside.")
		set(SuiteSparse_BLAS_DIR "$ENV{SuiteSparse_BLAS_DIR}" CACHE PATH "blas root directory")
	else()
		if(DEFINED SuiteSparse_BLAS_DIR)
			mark_as_advanced(SuiteSparse_BLAS_DIR)
		endif()
		list(APPEND SuiteSparse_LAPACK_BLAS_LIBRARIES ${SuiteSparse_BLAS_LIBRARY})
	endif()
	
	## try to find lapack lib
	find_library(SuiteSparse_LAPACK_LIBRARY 
		NAMES 			lapack liblapack
		PATHS 			/opt/local/lib${SuiteSparse_SEARCH_LIB_POSTFIX}		
						/usr/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
						/usr/local/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
						${SuiteSparse_LAPACK_DIR}/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
						${SuiteSparse_LAPACK_DIR}
						${ADDITIONAL_SEARCH_DIRS}
		PATH_SUFFIXES	Release Debug
	)
	if(NOT SuiteSparse_LAPACK_LIBRARY)
		message(SEND_ERROR "   Failed to find SuiteSparse_LAPACK_LIBRARY.Set it manually or set the SuiteSparse_LAPACK_DIR to looking for it inside.")
		set(SuiteSparse_LAPACK_DIR "$ENV{SuiteSparse_LAPACK_DIR}" CACHE PATH "lapack root directory")
	else()
		if(DEFINED SuiteSparse_LAPACK_DIR)
			mark_as_advanced(SuiteSparse_LAPACK_DIR)
		endif()
		list(APPEND SuiteSparse_LAPACK_BLAS_LIBRARIES ${SuiteSparse_LAPACK_LIBRARY})
	endif()
		
	## well, now append to the SuiteSparse_LIBRARIES and print infos if VERBOSE
	if(SuiteSparse_LAPACK_BLAS_LIBRARIES)
		list(APPEND SuiteSparse_LIBRARIES	${SuiteSparse_LAPACK_BLAS_LIBRARIES})
		if(SuiteSparse_VERBOSE)
			message(STATUS "   SuiteSparse_USE_LAPACK_BLAS = ${SuiteSparse_USE_LAPACK_BLAS} : ")
			message(STATUS "      * SuiteSparse_LAPACK_BLAS_LIBRARIES : ")
			foreach(lib ${SuiteSparse_LAPACK_BLAS_LIBRARIES})
				message(STATUS "         ${lib}")
			endforeach()
		endif()
	endif()
	
	## Now looking for *.dll => note that this is not a safe way to get it...
	if(WIN32)
		if(${SuiteSparse_SEARCH_LIB_POSTFIX} MATCHES "64")
			set(SuiteSparse_SEARCH_BIN_POSTFIX_1 "x64")
			set(SuiteSparse_SEARCH_BIN_POSTFIX_2 "Win64")
		else()
			set(SuiteSparse_SEARCH_BIN_POSTFIX_1 "x86")
			set(SuiteSparse_SEARCH_BIN_POSTFIX_2 "Win32")
		endif()
		
		set(SuiteSparse_DLL_SEARCH_DIRS
			${SuiteSparse_LAPACK_DIR}/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
			${SuiteSparse_LAPACK_DIR}
			${SuiteSparse_LAPACK_DIR}/bin
			${SuiteSparse_LAPACK_DIR}/bin/${SuiteSparse_SEARCH_BIN_POSTFIX_1}
			${SuiteSparse_LAPACK_DIR}/bin/${SuiteSparse_SEARCH_BIN_POSTFIX_2}
			${SuiteSparse_LAPACK_DIR}/bin/Release/${SuiteSparse_SEARCH_BIN_POSTFIX_1}
			${SuiteSparse_LAPACK_DIR}/bin/Debug/${SuiteSparse_SEARCH_BIN_POSTFIX_2}
			${SuiteSparse_LAPACK_DIR}/lib${SuiteSparse_SEARCH_LIB_POSTFIX}
			${SuiteSparse_BLAS_DIR}
			${SuiteSparse_BLAS_DIR}/bin
			${SuiteSparse_BLAS_DIR}/bin/${SuiteSparse_SEARCH_BIN_POSTFIX_1}
			${SuiteSparse_BLAS_DIR}/bin/${SuiteSparse_SEARCH_BIN_POSTFIX_2}
			${SuiteSparse_BLAS_DIR}/bin/Release/${SuiteSparse_SEARCH_BIN_POSTFIX_1}
			${SuiteSparse_BLAS_DIR}/bin/Debug/${SuiteSparse_SEARCH_BIN_POSTFIX_2}
			${ADDITIONAL_SEARCH_DIRS}
			"$ENV{Path}"
		)
		set(dllPatternFileList "libblas" "liblapack" "libgcc_s_" "libgfortran" "libquadmath")
		foreach(dllPattern ${dllPatternFileList})
			string(TOUPPER ${dllPattern} dllPatternUC)
			foreach(searchDir ${SuiteSparse_DLL_SEARCH_DIRS})
				file(GLOB SuiteSparse_DLL_${dllPatternUC} "${searchDir}/${dllPattern}*.dll") ## append the *.dll
				list(LENGTH SuiteSparse_DLL_${dllPatternUC} resultCount)
				if(${resultCount} GREATER "0" )
					list(APPEND SuiteSparse_LAPACK_BLAS_DLL ${SuiteSparse_DLL_${dllPatternUC}})
					break()
				endif()
			endforeach()
		endforeach()
		
		if(SuiteSparse_VERBOSE)
			message(STATUS "      * SuiteSparse_LAPACK_BLAS_DLL : ")
			foreach(dll ${SuiteSparse_LAPACK_BLAS_DLL})
				message(STATUS "         ${dll}")
			endforeach()
		endif()
		
	endif()
	
endif()

if(SuiteSparse_INCLUDE_DIRS)
	list(REMOVE_DUPLICATES SuiteSparse_INCLUDE_DIRS)
endif()
if(SuiteSparse_LIBRARIES)
	list(REMOVE_DUPLICATES SuiteSparse_LIBRARIES)
endif()

if(SuiteSparse_LAPACK_BLAS_LIBRARIES)
	list(REMOVE_DUPLICATES SuiteSparse_LAPACK_BLAS_LIBRARIES)
endif()

if(SuiteSparse_LAPACK_BLAS_DLL)
	list(REMOVE_DUPLICATES SuiteSparse_LAPACK_BLAS_DLL)
endif()

if(SuiteSparse_VERBOSE)
	message(STATUS "Finish to FindSuiteSparse.cmake => SuiteSparse_FOUND=${SuiteSparse_FOUND}")
endif()
