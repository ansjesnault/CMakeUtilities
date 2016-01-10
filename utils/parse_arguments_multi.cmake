## Created/updated by jesnault while last cmake version was 3.0.2

## pragma once
if(NOT WIN32 OR __parse_arguments_multi_cmake_INCLUDED__)
	return()
else()
	set(__parse_arguments_multi_cmake_INCLUDED__ ON)
endif()

cmake_minimum_required(VERSION 3.0)

## CMAKE_DOCUMENTATION_START parse_arguments_multi 
##
## This macro allow to process repeating multi value args from a given function which use cmake_parse_arguments module. \\n
## \\n
## cmake_parse_arguments multi args standard behavior:
## \\code
##    function(foo) 						\n
##        include(CMakeParseArguments) 		\n
##        cmake_parse_arguments(arg "" "" "MULTI" ${ARGN}) \n
##        foreach(item IN LISTS arg_MULTI) 	\n
##            message(STATUS "${item}") 	\n
##        endforeach() 						\n
##    endfunction() 						\n
##    foo(MULTI x y MULTI z w)
## \\endcode
##  The above code outputs 'z' and 'w'. It originally expected it to output all of 'x' 'y' 'z' 'w'.\\n
## \\n
## Using this macro inside a function which want to handle repeating multi args values
## will recursively iterate onto the multi tags list to process each sub list. \\n
## It take as 1st argument the subTag flag to separate sub list from the main multi list.\\n
## It take as 2nd argument the nameList of the main multi list (the multiValuesArgs from cmake_parse_arguments: here it is MULTI in the example)
## and that's why it is important that it should be a macro and not a function (to get access to external variable).\\n
## Then you give the content of this list allowing to be processed by the macro.\\n
## \\n
## parse_arguments_multi macro call a parse_arguments_multi_function which do actually the process from the given sub-list.\\n
## By default this function only print infos about what variables you are trying to pass/process (only verbose messages),
## but, by overloading this cmake function, you will be able to externalize the process of your multi argument list.\\n
## \\n
## Usage (into a function) : 
## \\code
## parse_arguments_multi(<multiArgsSubTag> <multiArgsList> <multiArgsListContent>  	\n
##      [NEED_RESULTS <multiArgsListSize>] [EXTRAS_FLAGS <...> <...> ...] 			\n
## )
## \\endcode
## \\n
## Simple usage example [user point of view]:
## \\code
## foo(MULTI 		\n
##    SUB_MULTI x y \n
##    SUB_MULTI z w \n
## )
## \\endcode
## \\n
## Simple usage example [inside a function]:
## \\code
##    function(foo) 										\n
##        include(CMakeParseArguments) 						\n
##        cmake_parse_arguments(arg "" "" "MULTI" ${ARGN}) 	\n
##        include(parse_arguments_multi) 					\n
##        function(parse_arguments_multi_function ) 		\n
##          #message("I'm an overloaded cmake function used by parse_arguments_multi") 	\n
##          #message("I'm processing first part of my sub list: ${ARGN}") 				\n
##          message("ARGV0=${ARGV0}") 	\n
##          message("ARGV1=${ARGV1}") 	\n
##        endfunction() 				\n
##        parse_arguments_multi(SUB_MULTI arg_MULTI ${arg_MULTI}) ## this function will process recusively items of the sub-list [default print messages] \n
##    endfunction()
## \\endcode
##  Will print: \\n
##      ARGV0=z \\n
##      ARGV1=w \\n
##      ARGV0=x \\n
##      ARGV1=y \\n
## \\n
## WARNING : DO NEVER ADD EXTRA THINGS TO parse_arguments_multi MACRO : \\n
##          parse_arguments_multi(SUB_MULTI arg_MULTI ${arg_MULTI} EXTRAS foo bar SOMTHING) => will failed !! \\n
## use EXTRAS_FLAGS instead !! \\n
## \\n
## Advanced usage example [user point of view]:
## \\code
## bar(C:/prout/test.exe VERBOSE  						\n
##      PLUGINS											\n
##          PLUGIN_PATH_NAME x      PLUGIN_PATH_DEST w 	\n
##          PLUGIN_PATH_NAME a b    PLUGIN_PATH_DEST y	\n
##          PLUGIN_PATH_NAME c							\n
## )
## \\endcode
## \\n
## Advanced usage example [inside a function]:
## \\code
##    function(bar execFilePathName)								\n
##        include(CMakeParseArguments)								\n
##        cmake_parse_arguments(arg "VERBOSE" "" "PLUGINS" ${ARGN})	\n
## 																	\n
##        include(parse_arguments_multi)							\n
##        function(parse_arguments_multi_function results)			\n
##            cmake_parse_arguments(pamf "VERBOSE" "PLUGIN_PATH_DEST;EXEC_PATH" "" ${ARGN}) ## EXEC_PATH is for internal use 	\n
##            message("")																										\n
##            message("I'm an overloaded cmake function used by parse_arguments_multi from install_runtime function")			\n
##            message("I'm processing first part of my sub list: ${ARGN}")														\n
##            message("PLUGIN_PATH_NAME = ${pamf_UNPARSED_ARGUMENTS}")															\n
##            message(pamf_VERBOSE = ${pamf_VERBOSE})																			\n
##            message("pamf_PLUGIN_PATH_DEST = ${pamf_PLUGIN_PATH_DEST}")														\n
##            message(pamf_EXEC_PATH = ${pamf_EXEC_PATH})																		\n
##            if(NOT ${pamf_PLUGIN_PATH_DEST})																					\n
##              set(pamf_PLUGIN_PATH_DEST ${pamf_EXEC_PATH})																	\n
##            endif()																											\n
##            foreach(plugin ${pamf_UNPARSED_ARGUMENTS})																		\n
##              get_filename_component(pluginName ${plugin} NAME)																\n
##              list(APPEND pluginsList ${pamf_PLUGIN_PATH_DEST}/${pluginName})													\n
##            endforeach()																										\n
##            set(${results} ${pluginsList} PARENT_SCOPE)																		\n
##        endfunction()																											\n
## 																																\n
##        if(arg_VERBOSE)																										\n
##            list(APPEND extra_flags_to_add VERBOSE) ## here we transmit the VERNOSE flag										\n
##        endif()																												\n
##        get_filename_component(EXEC_PATH ${execFilePathName} PATH) ## will be the default value if PLUGIN_PATH_DEST option is not provided \n
##        list(APPEND extra_flags_to_add EXEC_PATH ${EXEC_PATH})  				\n
##        list(LENGTH arg_PLUGINS arg_PLUGINS_count)							\n
##        parse_arguments_multi(PLUGIN_PATH_NAME arg_PLUGINS ${arg_PLUGINS}		\n
##                            NEED_RESULTS ${arg_PLUGINS_count}  ## this is used to check when we are in the first loop (in order to reset parse_arguments_multi_results) 	\n
##                            EXTRAS_FLAGS ${extra_flags_to_add} ## this is used to allow catching VERBOSE and PLUGIN_PATH_DEST flags of our overloaded function			\n
##        ) 		\n
##    endfunction() \n
##    message(parse_arguments_multi_results = ${parse_arguments_multi_results}) ## list of the whole pluginsList \n
##    #Will print w/x;a/y;b/y;C:/prout/c
## \\endcode
## \\n
##  NOTE that here, since our overloaded function need to provide a result list, we use the other parse_arguments_multi_function signature (the which one with a results arg)
##
## CMAKE_DOCUMENTATION_END
function(parse_arguments_multi_function_default) ## used in case of you want to reset the default behavior of this function process
    message("[default function] parse_arguments_multi_function(ARGC=${ARGC} ARGV=${ARGV} ARGN=${ARGN})")
    message("This function is used by parse_arguments_multi and have to be overloaded to process sub list of muluti values args")
endfunction()

function(parse_arguments_multi_function )   ## => the function to overload
    parse_arguments_multi_function_default(${ARGN})
endfunction()

## first default signature above
##------------------------------
## second results signature behind

function(parse_arguments_multi_function_default result) ## used in case of you want to reset the default behavior of this function process
    message("[default function] parse_arguments_multi_function(ARGC=${ARGC} ARGV=${ARGV} ARGN=${ARGN})")
    message("This function is used by parse_arguments_multi and have to be overloaded to process sub list of muluti values args")
endfunction()

function(parse_arguments_multi_function result)   ## => the function to overload
    parse_arguments_multi_function_default(result ${ARGN})
endfunction()

## => the macro to use inside your function which use cmake_parse_arguments
macro(parse_arguments_multi multiArgsSubTag multiArgsList #<${multiArgsList}> the content of the list
)
    include(CMakeParseArguments)
    cmake_parse_arguments(_pam "" "NEED_RESULTS" "${multiArgsSubTag};EXTRAS_FLAGS" ${ARGN})
    
    ## multiArgsList is the name of the list used by the multiValuesOption flag from the cmake_parse_arguments of the user function
    ## that's why we absolutly need to use MACRO here (and also for passing parse_arguments_multi_results when NEED_RESULTS flag is set)
    
    ## for debugging
    #message("")
    #message("[parse_arguments_multi] => ARGN = ${ARGN}")
    #message("_pam_NEED_RESULTS=${_pam_NEED_RESULTS}")
    #message("_pam_EXTRAS_FLAGS=${_pam_EXTRAS_FLAGS}")
    #foreach(var ${_pam_${multiArgsSubTag}})
    #    message("arg=${var}")
    #endforeach()
    
    ## check and init
    list(LENGTH ${multiArgsList} globalListCount)
    math(EXPR globalListCount "${globalListCount}-1") ## because it will contain [multiArgsSubTag + ${multiArgsList}]
    if(_pam_NEED_RESULTS)
        if(${globalListCount} EQUAL ${_pam_NEED_RESULTS})
            ## first time we enter into this macro (because we call it recursively)
            unset(parse_arguments_multi_results)
        endif()
    endif()
    
    ## process the part of the multi agrs list
    ## ${ARGN} shouldn't be passed to the function in order to avoid missmatch size list ${multiArgsList} and _pam_${multiArgsSubTag}
    ## if you want to pass extra internal flags from your function to this callback, use EXTRAS_FLAGS
    if(_pam_NEED_RESULTS)
        parse_arguments_multi_function(parse_arguments_multi_function_result ${_pam_${multiArgsSubTag}} ${_pam_EXTRAS_FLAGS})
        list(APPEND parse_arguments_multi_results ${parse_arguments_multi_function_result})
    else()
        parse_arguments_multi_function(${_pam_${multiArgsSubTag}} ${_pam_EXTRAS_FLAGS})
    endif()

    ## remove just processed items from the main list to process (multiArgsList)
    list(REVERSE ${multiArgsList})
    list(LENGTH _pam_${multiArgsSubTag} subTagListCount)
    unset(ids)
    foreach(id  RANGE ${subTagListCount})
         list(APPEND ids ${id})
    endforeach()
    list(REMOVE_AT  ${multiArgsList} ${ids})
    list(REVERSE    ${multiArgsList})
    
    ## test if remain sub multi list to process (recursive call) or finish the process
    list(LENGTH ${multiArgsList} mainTagListCount)
    if(${mainTagListCount} GREATER 1)
        ## do not pass ${ARGN} just because it will re pass the initial 2 inputs args and we wont as they was consumed (in order to avoir conflicts)
        parse_arguments_multi(${multiArgsSubTag} ${multiArgsList} ${${multiArgsList}} 
                                NEED_RESULTS ${_pam_NEED_RESULTS} EXTRAS_FLAGS ${_pam_EXTRAS_FLAGS}
            )
    endif()
endmacro()