## CMAKE_DOCUMENTATION_START systemFilesTools.cmake
##
## Contain whole macros/functions users can use in CMakeLists.txt for handle theire tree project.
##
##  \\li see \\ref conditional_add_subdirectory. 
##  \\li see \\ref list_subdirectories
##  \\li see \\ref is_empty
##
## CMAKE_DOCUMENTATION_END

## pragma once
if(_SYSTEM_FILES_TOOLS_CMAKE_INCLUDED_)
  return()
endif()
set(_SYSTEM_FILES_TOOLS_CMAKE_INCLUDED_ true)

cmake_minimum_required(VERSION 2.8)

include(${CMAKE_ROOT}/Modules/CMakeParseArguments.cmake)

## CMAKE_DOCUMENTATION_START conditional_add_subdirectory 
##
##  Add a subdirectory after checking the dependency found and the option set.
## 
## \\code
## CONDITIONAL_ADD_SUBDIRECTORY(<subdirectoryName> 	\n
##      [DEPENDS name1 [name2 ...]] 				\n
##      [OPTIONS name1 [name2 ...]] 				\n
##      [VERBOSE]                   				\n
## )
## \\endcode
##  You can use without any dependencies or options to check.
## CMAKE_DOCUMENTATION_END
function(CONDITIONAL_ADD_SUBDIRECTORY subdirectory)
    set(optionsArgs "VERBOSE")
    set(oneValueArgs "")
    set(multiValueArgs "DEPENDS;OPTIONS")
    cmake_parse_arguments(CAS "${optionsArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    # Check dependencies
	set(missingDep_list "") # empty list where missing dependencies will be appended    
	foreach(depend ${CAS_DEPENDS})
		string(TOUPPER ${depend}_FOUND upper_name)
		if(NOT ${upper_name} AND NOT ${depend}_FOUND)
			list(APPEND missingDep_list ${depend})
		endif()
	endforeach()
	if(missingDep_list AND CAS_VERBOSE)
		message (STATUS "subdirectory : ${subdirectory} will NOT be built because of missing dependencies : ${missingDep_list}")
	endif()
	
	# Check options
    set(missingOpt_list "") # empty list where missing options will be appended
    set(opt_list "") # list of valid options
	foreach(opt ${CAS_OPTIONS})
		if(NOT ${opt})
			list(APPEND missingOpt_list ${opt})
        else()
            list(APPEND opt_list ${opt})
		endif()
	endforeach()
	if(missingOpt_list AND CAS_VERBOSE)
	    message(STATUS "subdirectory : ${subdirectory} will NOT be built because of missing options : ${missingOpt_list}")
	endif()
	
	# add subdir	
	if(NOT missingDep_list AND NOT missingOpt_list)
	    if(CAS_VERBOSE)
		    message (STATUS "add_subdirectory(${subdirectory})")
		endif()
    	add_subdirectory(${subdirectory})
    else()
        if(opt_list AND missingDep_list)
            message("subdirectory : ${subdirectory} will NOT be built.")
            message("You set ${opt_list} but missing dependencies : ${missingDep_list}")
        endif()
	endif()
endfunction()


###############################################################################


## CMAKE_DOCUMENTATION_START list_subdirectories 
##  Allow to list subdirectories from the curentdir.
##  \\code
##      list_subdirectories(<curentDir> <resultListSubDirs>)
##  \\endcode
##  \\TODO : make a RECUSIVE option?
##
## CMAKE_DOCUMENTATION_END
macro(LIST_SUBDIRECTORIES curentDir resultListSubDirs)
  file(GLOB paths "${curentDir}/*")
  set(list_of_dirs "")
  foreach(path ${paths})
    if(IS_DIRECTORY ${path})
        set(list_of_dirs ${list_of_dirs} ${path})
    endif()
  endforeach()
  set(${resultListSubDirs} ${list_of_dirs})
endmacro()


###############################################################################


## CMAKE_DOCUMENTATION_START is_empty 
##  Check if a directory or a file is empty.
##  \\code
##      is_empty(<path> <resultContent>)
##  \\endcode
## CMAKE_DOCUMENTATION_END
macro(IS_EMPTY path resultContent)
    if(IS_DIRECTORY "${path}")
        file(GLOB ${resultContent} "${path}/*")
        #message("${path} is a directory and contain : ${resultContent}")
    elseif(EXISTS "${path}")
        file(READ ${resultContent} "${path}")
        #message("${path} is a file and contain : ${resultContent}")
    endif()
endmacro()
