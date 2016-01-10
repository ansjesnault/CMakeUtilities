cmake_minimum_required(VERSION 2.8)

## CMAKE_DOCUMENTATION_START GetBuild3rdParty.cmake 
##  This is an abstraction of cmake super project which integrate other cmake openSources projects. \n
##  With few lines of cmake you can control which 3rdParty cmake source project you want to : \n
##	* Download (from simple URL, or SCM tool)
##  * Build (on the fly before your project, you can ether control build options)
##  * Install (on the fly before the build of your project)
##  * Then configure your project using these new fresh 3rdParty built
##  Contain whole macro users can use in CMakeLists.txt for their project.
##  \\li see \\ref add_3rdParty use an external cmake project as dependence 
##  \\li see \\ref build_3rdParty_before to add the dependency without and build with multi-processors 
##  \\li see \\ref find_3rdparty
##  \\li see \\ref installation_3rdparty
## CMAKE_DOCUMENTATION_END

# pragma once
if(_3RD_PARTY_CMAKE_INCLUDED_)
  return()
endif()
set(_3RD_PARTY_CMAKE_INCLUDED_ true)


## CMAKE_DOCUMENTATION_START add_3rdParty
##
## Allow to download (given a GIT or SVN url), configure, build and install
## an external cmake project at your project make time and use it as dependency for your own project. \\n
## Have to use with \\ref find_3rdparty and \\ref build_3rdParty_before
##\\n
## The downloaded 3rdParty project is put in the SOURCE dir : by default same dir as DESTINATION dir.\\n
## The outOfSource CMake configuration for the 3rdParty project is done in DESTINATION dir :
## by default in ${CMAKE_BINARY_DIR}/3rdParty (within ${packageName}-build or ${packageName}-install dir).\\n
## When downloaded, each time you re-run make, you can update your 3rdParty and re-run all its next step
## before make your project : use UPDATE_COMMAND (by default to 'git fetch' for GIT repository).\\n
## You can specify custom CMake arguments by command line when cmake configure the 3rdParty project :
## use a list of cmake options with all options prefiwed by -D.\\n
## You can display more infos about this macro with VERBOSE option value to true.\\n
## You can print all result step of 3rdParty into log file (prevent to overload the terminal...)
## and check each log file.\\n
## You can add a custom final step to 3rdParty to generate a package of 3rdParty project with CPACK :
## if set to true, mapped your current CPack CMake variables to the 3rdParty project and generate
## package to the 3rdParty build DESTINATION.
##
##\\code
## add_3rdParty(packageName                                                          \n
##              GIT                 <gitUrl> |                                       \n
##              SVN                 <svnUrl>                                         \n
##              [ SOURCE            <sourceDownloadDir> ]                            \n
##              [ DESTINATION       <buildAndInstallDir> ]                           \n
##              [ UPDATE_COMMAND    <gitOrSvnCommand> ]                              \n
##              [ CMAKE_ARGS        <specificCmakeArgsPassingTo3rdPartyConfigure> ]  \n
##              [ VERBOSE           <debugBool> ]                                    \n
##              [ LOG               <generateLogFileForEachStepOf3rdParty> ]         \n
##              [ CPACK             <generatePackageFor3rdParty> ]                   \n
##              )
##\\endcode
##
## Example in your top level CMakeLists.txt :
##\\code
##  set(VRPN_DIR "" CACHE PATH "The directory containing the VRPN installation or the VRPN config file")\n
##  <...>                                                                                               \n
##  set(CMAKE_3RDPARTY_ARGS "-DVERBOSE=ON -DUSE_VRPN_SUPPORT=ON -DVRPN_DIR=\${VRPN_DIR}")               \n
##  include(GetBuild3rdParty)                                                                                   \n
##  ADD_3RDPARTY(MYSDK                                                                                  \n
##       GIT            ssh+git://myGitHost/myGitProject.git				                            \n
##       SOURCE         \${CMAKE_CURRENT_SOURCE_DIR}/3rdParty"                                          \n
##       DESTINATION    \${CMAKE_BINARY_DIR}/3rdParty"                                                  \n
##       CMAKE_ARGS     \${CMAKE_3RDPARTY_ARGS}                                                         \n
##       VERBOSE        \${VERBOSE}                                                                     \n
##  )                               \n
##  FIND_3RDPARTY(MYSDK)            \n
##  <...>                           \n
##  BUILD_3RDPARTY_BEFORE(MYSDK)    \n
##  add_subdirectory(src)           \n
##  <...>                           \n
##\\endcode
##    
## CMAKE_DOCUMENTATION_END
macro(ADD_3RDPARTY packageName)

    include(CMakeParseArguments)
    cmake_parse_arguments(3rdParty_${packageName}
                          ""    # option
                          "GIT;SVN;DESTINATION;SOURCE;UPDATE_COMMAND;VERBOSE;LOG;CPACK" # 1ValueOption
                          "CMAKE_ARGS" # multiValueOptions
                          ${ARGN} # remainsArgs
                          )
    
    ## default  dir # the url to download 3rdParty
    if(3rdParty_${packageName}_GIT)
        set(REPOSITORY GIT_REPOSITORY)
        set(3rdParty_${packageName}_URL ${3rdParty_${packageName}_GIT})
    else(3rdParty_${packageName}_SVN)
        set(REPOSITORY SVN_REPOSITORY)
        set(3rdParty_${packageName}_URL ${3rdParty_${packageName}_SVN})
    endif()
    
    ## default DESTINATION dir # Where build/install 3rdParty
    if( NOT 3rdParty_${packageName}_DESTINATION )
        set(3rdParty_${packageName}_DESTINATION "${CMAKE_BINARY_DIR}/3rdParty")        
    endif()
    
    ## default SOURCE dir # Where download/configure 3rdParty
    if( NOT 3rdParty_${packageName}_SOURCE )
        set(3rdParty_${packageName}_SOURCE ${3rdParty_${packageName}_DESTINATION})
    endif()
    
    ## default CMAKE_ARGS # cmake arguments for 3rdParty project
    if( NOT 3rdParty_${packageName}_CMAKE_ARGS )
        set(3rdParty_${packageName}_CMAKE_ARGS "" )
    else()
        # Check and use space separator for this field
        string(REPLACE " " ";" 3rdParty_${packageName}_CMAKE_ARGS ${3rdParty_${packageName}_CMAKE_ARGS})
    endif()
    
    ## default UPDATE_COMMAND # update command for 3rdParty project
    if( NOT 3rdParty_${packageName}_UPDATE_COMMAND )
        if(3rdParty_${packageName}_GIT)
            find_package(Git)
            if(GIT_EXECUTABLE)
                set(3rdParty_${packageName}_UPDATE_COMMAND ${GIT_EXECUTABLE} fetch) # default
            endif()
        endif()
    else()
        # Check and use space separator for this field
        string(REPLACE " " ";" 3rdParty_${packageName}_UPDATE_COMMAND ${3rdParty_${packageName}_UPDATE_COMMAND})
    endif()

    ## default VERBOSE # debug info
    if( NOT 3rdParty_${packageName}_VERBOSE  )
        set(3rdParty_${packageName}_VERBOSE false )
    endif()

    ## default LOG # print step of 3rdParty process project in log files
    if( NOT 3rdParty_${packageName}_LOG  )
        set(3rdParty_${packageName}_LOG true )
    endif()
    
    ## default CPACK # use cpack for the 3rdPartyProject
    if( NOT 3rdParty_${packageName}_CPACK  )
        set(3rdParty_${packageName}_CPACK false )
    endif()


    ## internal use (as function because won't to let these cmake variable in global scope)
    function(ADD_3RDPARTY_Impl )
    
        ## See doc here : http://www.kitware.com/products/html/BuildingExternalProjectsWithCMake2.8.html
        include(ExternalProject)

        if(${3rdParty_${packageName}_VERBOSE})
            message(STATUS "use 3rdParty.cmake for : ${packageName}")
        endif()
    
        #################### INIT VARIABLES FOR EXTERNAL PROJECT ###################################
        set(3rdParty_${packageName}_DOWNLOAD_DIR   "${3rdParty_${packageName}_SOURCE}")
        set(3rdParty_${packageName}_SOURCE_DIR     "${3rdParty_${packageName}_SOURCE}/${packageName}")
        # 3rdParty_${packageName}_STAMP_DIR :       Create a file at each validate step
        set(3rdParty_${packageName}_STAMP_DIR      "${3rdParty_${packageName}_SOURCE}/${packageName}-stamp")
        # 3rdParty_${packageName}_TMP_DIR :         Intermediate scripts used internly
        set(3rdParty_${packageName}_TMP_DIR        "${3rdParty_${packageName}_SOURCE}/${packageName}-tmp")
        set(3rdParty_${packageName}_BINARY_DIR     "${3rdParty_${packageName}_DESTINATION}/${packageName}-build")
        set(3rdParty_${packageName}_INSTALL_DIR    "${3rdParty_${packageName}_DESTINATION}/${packageName}-install")
        
        ## CPACK options, map CPACK options from superProject to 3rdParty project
        if(3rdParty_${packageName}_CPACK)
            set(3rdParty_${packageName}_CPACK_ARGS
                "-DCPACK_BINARY_DEB=${CPACK_BINARY_DEB}"
                "-DCPACK_BINARY_NSIS=${CPACK_BINARY_NSIS}"
                "-DCPACK_BINARY_RPM=${CPACK_BINARY_RPM}"
                "-DCPACK_BINARY_STGZ=${CPACK_BINARY_STGZ}"
                "-DCPACK_BINARY_TGZ=${CPACK_BINARY_TGZ}"
                "-DCPACK_BINARY_TZ=${CPACK_BINARY_TZ}"
                "-DCPACK_PACKAGING_INSTALL_PREFIX=${CPACK_PACKAGING_INSTALL_PREFIX}"
                "-DCPACK_SOURCE_TBZ2=${CPACK_SOURCE_TBZ2}"
                "-DCPACK_SOURCE_TGZ=${CPACK_SOURCE_TGZ}"
                "-DCPACK_SOURCE_TZ=${CPACK_SOURCE_TZ}"
                "-DCPACK_SOURCE_ZIP=${CPACK_SOURCE_ZIP}"
            )
        else()
            set(3rdParty_${packageName}_CPACK_ARGS "")
        endif()
        
        ## final CMAKE_ARGS
        set(3rdParty_${packageName}_CMAKE_ARGS     
                "-DCMAKE_INSTALL_PREFIX=${3rdParty_${packageName}_INSTALL_DIR}"
                "${3rdParty_${packageName}_CPACK_ARGS}"
                "${3rdParty_${packageName}_CMAKE_ARGS}"
        )
        

        ## VERBOSE
        if(${3rdParty_${packageName}_VERBOSE})
            message(STATUS "Download, update, configure, build and install 3rdParty settings for ${packageName}:")
            message(STATUS "3rdParty_${packageName}_URL = ${3rdParty_${packageName}_URL}")
            message(STATUS "3rdParty_${packageName}_SOURCE_DIR   = ${3rdParty_${packageName}_SOURCE_DIR}")
            message(STATUS "3rdParty_${packageName}_BINARY_DIR   = ${3rdParty_${packageName}_BINARY_DIR}")
            message(STATUS "3rdParty_${packageName}_INSTALL_DIR  = ${3rdParty_${packageName}_INSTALL_DIR}")
            message(STATUS "3rdParty_${packageName}_UPDATE_COMMAND = ${3rdParty_${packageName}_UPDATE_COMMAND}")
            
            set(3rdParty_${packageName}_CMAKE_ARGS_FIRSTLOOP true)
            foreach(dval ${3rdParty_${packageName}_CMAKE_ARGS})
                if(3rdParty_${packageName}_CMAKE_ARGS_FIRSTLOOP)
                    message(STATUS "3rdParty_${packageName}_CMAKE_ARGS   = ${dval}")
                    set(3rdParty_${packageName}_CMAKE_ARGS_FIRSTLOOP false)
                else()
                    message(STATUS "                      ${dval}")
                endif()
            endforeach()
            
        endif()
        
        ## LOG
        if(3rdParty_${packageName}_LOG)
            set(LOG_3RDPARTY
                #LOG_DOWNLOAD    1
                LOG_UPDATE      1
                LOG_CONFIGURE   1
                LOG_BUILD       1
                LOG_INSTALL     1
            )
        endif()

        
        ## Work around fix a drawback : Have to check (if we have already download and install the 3rdPArty)
        ## if the 3rdParty have change in order to update / re-build it if necessary 
        ## and prevent skip the target whereas project change.
        if( 3rdParty_${packageName}_UPDATE_COMMAND ) # re do the update step and all next steps
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E remove ${3rdParty_${packageName}_STAMP_DIR}/3RDPARTY_${packageName}-update
                RESULT_VARIABLE rv  OUTPUT_VARIABLE ov  ERROR_VARIABLE  ev
            )
        endif()
        if()# re do the configure step and all next steps
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E remove ${3rdParty_${packageName}_STAMP_DIR}/3RDPARTY_${packageName}-configure
                RESULT_VARIABLE rv  OUTPUT_VARIABLE ov  ERROR_VARIABLE  ev
            )
        endif()


        #################### EXTERNAL PROJECT ADD ##################################################
        ExternalProject_Add(    3RDPARTY_${packageName} # the custom target
            PREFIX              ${3rdParty_${packageName}_DESTINATION}
            TMP_DIR             ${3rdParty_${packageName}_TMP_DIR} 
            STAMP_DIR           ${3rdParty_${packageName}_STAMP_DIR}
           ##--Download step--------------
            DOWNLOAD_DIR        ${3rdParty_${packageName}_DOWNLOAD_DIR}
	        ${REPOSITORY}       ${3rdParty_${packageName}_URL}
           ##--Update/Patch step----------
            UPDATE_COMMAND      ${3rdParty_${packageName}_UPDATE_COMMAND}
           ##--Configure step-------------
            SOURCE_DIR          ${3rdParty_${packageName}_SOURCE_DIR}
	        CMAKE_ARGS          ${3rdParty_${packageName}_CMAKE_ARGS}
            #CMAKE_CACHE_ARGS
           ##--Build step-----------------
            BINARY_DIR          ${3rdParty_${packageName}_BINARY_DIR}
           ##--Install step---------------
            INSTALL_DIR         ${3rdParty_${packageName}_INSTALL_DIR}
           ##--Test step------------------
           ##--Output logging-------------
            ${LOG_3RDPARTY}
           ##--Custom targets-------------
        )

        # Work around prevent git to quit with error when cloning submodules (just warn instead)
        set(gitcloneCmakeFile "${3rdParty_${packageName}_TMP_DIR}/3RDPARTY_${packageName}-gitclone.cmake")
        if(EXISTS ${gitcloneCmakeFile})
            file(READ ${gitcloneCmakeFile} gicloneCmakeScriptContent)
            string(REPLACE  "FATAL_ERROR \"Failed to init submodules"   "WARNING \"Failed to init submodules" 
                            gicloneCmakeScriptOut                       ${gicloneCmakeScriptContent}
                  )
            string(REPLACE  "FATAL_ERROR \"Failed to update submodules" "WARNING \"Failed to update submodules"
                            gicloneCmakeScriptOut                       ${gicloneCmakeScriptOut}
                  )
            file(WRITE ${gitcloneCmakeFile} ${gicloneCmakeScriptOut})
        endif()


        #################### CUSTOM STEPS ##########################################################
        #--Custom configure step (after update step and before standard configure step )--
        ExternalProject_Add_Step(3RDPARTY_${packageName} after_patch
            COMMENT "--- update finished. Start configure ---"
            DEPENDEES update
            DEPENDERS configure
        )
        
        #--Custom build step (after configure step and before standard build step )--
        ExternalProject_Add_Step(3RDPARTY_${packageName} after_configure
            COMMENT "--- configure finished. Start build : Please wait until the next step ---"
            DEPENDEES configure
            DEPENDERS build
        )

        ## Work around run CPack for 3rdParty project
        ## get cpack command and use the mapped cpack options
        if( 3rdParty_${packageName}_CPACK )
            # Get cpack command
            get_filename_component(__cmake_path ${CMAKE_COMMAND} PATH)
            find_program(CPACK_COMMAND cpack ${__cmake_path})
            mark_as_advanced(CPACK_COMMAND)
            message(STATUS "Found CPack: ${CPACK_COMMAND}")
            if(NOT CPACK_COMMAND)
	            message(FATAL_ERROR "Need CPack!")
            endif()

            #--Custom cpack step (after standard install step)--
            ExternalProject_Add_Step(3RDPARTY_${packageName} cpack
                COMMENT "--- install finished. Start make package (using cpack options) ---"
                WORKING_DIRECTORY ${3rdParty_${packageName}_BINARY_DIR}
                COMMAND ${CPACK_COMMAND}
                DEPENDEES install
            )
        endif()


        ## Work around check the end process of the ExternalProject_Add cmd using output logfiles
        ## Get a list of all <3rdPartyTarget>-*-err.log files and see if we found some "errors" pattern
        if( 3rdParty_${packageName}_LOG )
            set(3rdParty_${packageName}_CHECK_CODE
                "
                file(GLOB errLogs \"${3rdParty_${packageName}_STAMP_DIR}/3RDPARTY_${packageName}-*-err.log\")
                message(STATUS \"check file path : ${3rdParty_${packageName}_STAMP_DIR}...\")
                #message(\"errLogs list file : \${errLogs}\")
                foreach( errLog \${errLogs})
                    file(READ \${errLog} contents) 
                    string(REGEX MATCH \".?error*\" output \"\${contents}\")
                    if(output)
                        message(\"${contents}\")
                        message(WARNING \"ExternalProject encountered an error : see \${errLog}\")
                    endif()
                endforeach()
                "
            )
            set(checkCmakeScript ${3rdParty_${packageName}_STAMP_DIR}/3RDPARTY_${packageName}_check.cmake)
            if(NOT EXISTS ${checkCmakeScript})
                file(WRITE ${checkCmakeScript} ${3rdParty_${packageName}_CHECK_CODE} )
            endif()
            if(${3rdParty_${packageName}_VERBOSE})
                message(STATUS "write check file into : ${checkCmakeScript}")
            endif()

            ## To get the right order (first finished 3rdParty targets)
            if( 3rdParty_${packageName}_CPACK )
                set(DependeesCheckCmakeTarget cpack)
            else()
                set(DependeesCheckCmakeTarget install)
            endif()
            ExternalProject_Add_Step(3RDPARTY_${packageName} check
                COMMENT "--- Check the 3rdParty project end process ---"
                COMMAND     ${CMAKE_COMMAND} -P ${checkCmakeScript}
                DEPENDEES   ${DependeesCheckCmakeTarget}
            )
        endif()


        ## To get the right order 
        # (first finished 3rdParty targets before start to rerun cmake for the current project)
        if( 3rdParty_${packageName}_LOG )
            set(DependeesRerunCmakeTarget check)
        else()
            set(DependeesRerunCmakeTarget install)
        endif()


        #################### FINAL STEP ##########################################################
        ## As ExternalProject_Add function is effective at the make time,
        ## we can't find 3rdParty at configure time (cannot use FindPackage)
        ## Work around re-run CMake just after 3rdParty installation is finished...
        ## So the first pass of cmake->make will install 3rdPArty
        ## and launch the second pass of cmake->make witch auto find 3rdParty (using our next macro)
        ExternalProject_Add_Step(3RDPARTY_${packageName} reruncmake
            COMMENT "--- Start re-run CMake ---"
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMAND     ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR}
            DEPENDEES   ${DependeesRerunCmakeTarget}
            #LOG 1
        )

    endfunction()

    ADD_3RDPARTY_Impl()

endmacro()


## CMAKE_DOCUMENTATION_START build_3rdParty_before
##
## This macro allow to introduce a dependency priority between
## the package3rdPartyName (as parameter) and your own project.         \\n
## In order to build (even with multi processors) you 3rdParty first.   \\n
##
## \\code
## build_3rdParty_before(package3rdPartyName)
## \\endcode
##
## Use this macro after others 3rdParty macros
## and just before your own 'add_subdirectory(src)'.\\n
## Make sure all your own targets project, and only your target (not from another project)
## are defined in CMakeLists.txt into your 'src' dir.\\n
## \\n
## This macro write a cmake script which overload :
## add_library() and add_executable() CMake functions to add the dependency with 3rdParty custom target,
## and directly include it into your current CMakeLists.txt to make effect the overload with this macro.
##
## CMAKE_DOCUMENTATION_END
macro(BUILD_3RDPARTY_BEFORE packageName )
    # generate custom cmake file to include it in order to add right dependencies
    set(3rdParty_overload_pre_ARGN "\${")
    set(3rdParty_overload_post_ARGN "}")
    set(3rdParty_${packageName}_OVERLOAD_CODE
    "
    ## We have to make sure the ${packageName} project is build before the current one.
    ## In case of giving a build command like 'make -j10' we may have some build dependence conflict...
    ## add_dependencies(<mycustomtarget> <myexternalproject>) introduce a build priority
    ##
    ## Here we overload some CMake command to introduce a build priority
    ## and avoid user to manuall modif all its sub-projects CMakLists.txt file of its current project.
    ## The original built-in CMake commands are prefixed with an underscore if overriding any of them.
    function(add_library _target)
        _add_library (\${_target} ${3rdParty_overload_pre_ARGN}ARGN${3rdParty_overload_post_ARGN})
        add_dependencies(\${_target} 3RDPARTY_${packageName})
    endfunction()

    function(add_executable _target)
        _add_executable (\${_target} ${3rdParty_overload_pre_ARGN}ARGN${3rdParty_overload_post_ARGN})
        add_dependencies(\${_target} 3RDPARTY_${packageName})
    endfunction()
    "
    )
    GET_3RDPARTY_TMP_DIR(${packageName} ${packageName}_TMP)
    file(WRITE  ${${packageName}_TMP}/3RDPARTY_${packageName}_overload.cmake
                ${3rdParty_${packageName}_OVERLOAD_CODE} )
    include(${${packageName}_TMP}/3RDPARTY_${packageName}_overload.cmake)
endmacro()


## CMAKE_DOCUMENTATION_START get_3rdparty_tmp_dir
##
## internal use. \\n
##\\code
## get_3rdparty_tmp_dir(packageName packageTmpDir_ret)
##\\endcode
## Provide a packageTmpDir_ret from the packageName
##
## CMAKE_DOCUMENTATION_END
function(GET_3RDPARTY_TMP_DIR packageName packageTmpDir_ret)
    include(ExternalProject)
    # 3RDPARTY<packageName> is the target convention
    ExternalProject_Get_Property(3RDPARTY_${packageName} tmp_dir)
    set(${packageTmpDir_ret} ${tmp_dir} PARENT_SCOPE)
endfunction()


## CMAKE_DOCUMENTATION_START get_3rdparty_source_dir
##
## internal use. \\n
##\\code
## get_3rdparty_source_dir(packageName packageSrcDir_ret)
##\\endcode
## Provide a packageSrcDir_ret from the packageName
##
## CMAKE_DOCUMENTATION_END
function(GET_3RDPARTY_SOURCE_DIR packageName packageSrcDir_ret)
    include(ExternalProject)
    # 3RDPARTY<packageName> is the target convention
    ExternalProject_Get_Property(3RDPARTY_${packageName} source_dir)
    set(${packageSrcDir_ret} ${source_dir} PARENT_SCOPE)
endfunction()


## CMAKE_DOCUMENTATION_START get_3rdparty_binary_dir
##
## internal use. \\n
##\\code
## get_3rdparty_binary_dir(packageName packageBinDir_ret)
##\\endcode
## Provide a packageBinDir_ret from the packageName
##
## CMAKE_DOCUMENTATION_END
function(GET_3RDPARTY_BINARY_DIR packageName packageBinDir_ret)
    include(ExternalProject)
    # 3RDPARTY_<packageName> is the target convention
    ExternalProject_Get_Property(3RDPARTY_${packageName} binary_dir)
    set(${packageBinDir_ret} ${binary_dir} PARENT_SCOPE)
endfunction()


## CMAKE_DOCUMENTATION_START get_3rdparty_install_dir
##
## internal use. \\n
##\\code
## get_3rdparty_install_dir(packageName packageInstDir_ret)
##\\endcode
## Provide a packageInstDir_ret from the packageName
##
## CMAKE_DOCUMENTATION_END
function(GET_3RDPARTY_INSTALL_DIR packageName packageInstDir_ret)
    include(ExternalProject)
    # 3RDPARTY_<packageName> is the target convention
    ExternalProject_Get_Property(3RDPARTY_${packageName} install_dir)
    set(${packageInstDir_ret} ${install_dir} PARENT_SCOPE)
endfunction()


## CMAKE_DOCUMENTATION_START find_3rdparty
##
##\\code
## find_3rdparty(packageName)
##\\endcode
## Use exactly like the find_package().\\n
## It set the <packageName>_DIR to find the 3RDPARTY package.
##
## CMAKE_DOCUMENTATION_END 
macro(FIND_3RDPARTY packageName)
    include(ExternalProject)
    if(${packageName}_DIR) # this varibale is important (without prefix)
        message(STATUS "3rdParty.cmake redifined the ${packageName}_DIR variable :")
    endif()
    GET_3RDPARTY_INSTALL_DIR(${packageName} ${packageName}_DIR)
    message(STATUS "${${packageName}_DIR}")
    find_package(${packageName} PATHS ${${packageName}_DIR} PATH_SUFFIXES cmake ${ARGN})
    message(STATUS "From FIND_3RDPARTY: ${packageName}_FOUND = ${${packageName}_FOUND}")
endmacro()


## CMAKE_DOCUMENTATION_START installation_3rdparty
##
## Allow to install the 3rdParty packageName to the given installPrefix.
##\\code
##installation_3rdparty(packageName installPrefix [CUSTOM_TARGET true|false])
##\\endcode
## CUSTOM_TARGET :\\n
## ->to true: create a separate target for the 3rdParty installation : then use make install-<packageName>.\\n 
## ->to false: install 3rdParty at make install time (with the superproject installation).\\n
##
## For uninstallation of 3rdParty : 
## the uninstall target from CMakeTools will remove all project from *_install_manifest.txt
##
## CMAKE_DOCUMENTATION_END 
function(INSTALLATION_3RDPARTY packageName installPrefix)

    include(CMakeParseArguments)
    cmake_parse_arguments(INST_${packageName} "" "CUSTOM_TARGET" "" ${ARGN} )

    # default CUSTOM_TARGET
    if(NOT DEFINED INST_CUSTOM_TARGET)
        set(INST_CUSTOM_TARGET true)
    endif()

    include(ExternalProject)
    GET_3RDPARTY_SOURCE_DIR(${packageName} ${packageName}_SOURCE_DIR)
    GET_3RDPARTY_BINARY_DIR(${packageName} ${packageName}_BINARY_DIR)
    GET_3RDPARTY_INSTALL_DIR(${packageName} ${packageName}_INSTALL_DIR)

    message(STATUS "Install ${packageName} 3rdParty project in : ${installPrefix}")
    set(${packageName}_INSTALL_CODE 
        "
        ## Re run 3rdParty CMake in order to re-install 3rdParty
        message(\"----Install ${packageName} to ${installPrefix} !\")
        execute_process(COMMAND ${CMAKE_COMMAND} 
                    -DCMAKE_INSTALL_PREFIX=${installPrefix}
                    ${${packageName}_SOURCE_DIR}
                    --build ${${packageName}_BINARY_DIR}
        )
        execute_process(WORKING_DIRECTORY ${${packageName}_BINARY_DIR}
                        COMMAND ${CMAKE_COMMAND} -P cmake_install.cmake
        )
        
        ## Provide a 3rdParty install manifest file used for uninstall
        file(READ  \"${${packageName}_BINARY_DIR}/install_manifest.txt\" install_manifest_content)
        file(WRITE \"${CMAKE_BINARY_DIR}/${packageName}_install_manifest.txt\" \"\${install_manifest_content}\")
        
        ## Re run 3rdParty CMake in order to reinit the 3rdParty installation config
        execute_process(COMMAND ${CMAKE_COMMAND} 
                    -DCMAKE_INSTALL_PREFIX=${${packageName}_INSTALL_DIR}
                    ${${packageName}_SOURCE_DIR}
                    --build ${${packageName}_BINARY_DIR}
        )
        "
    )

    if(NOT INST_CUSTOM_TARGET)
        ## used to embeded  3rdParty installation into the install target (make install)
        install(CODE ${${packageName}_INSTALL_CODE} )
        message(STATUS "***INFO***: Your install target will also install ${packageName} 3RDPARTY to : ${installPrefix}")
    else()
        ## used to create a 3rdParty target installation (make install-<packageName>)
        file(WRITE ${CMAKE_BINARY_DIR}/install-${packageName}.cmake ${${packageName}_INSTALL_CODE} )
        add_custom_target(install-${packageName}
            COMMAND ${CMAKE_COMMAND} -P ${CMAKE_BINARY_DIR}/install-${packageName}.cmake )
        message(STATUS "***INFO***: You can use make install-${packageName} to install ${packageName} 3RDPARTY to  : ${installPrefix}")
    endif()

endfunction()



## UNINSTALLATION_3RDPARTY MACRO :
## Provide the uninstall-<packageName> target
## So, after a make install or make install-<packageName> (the INSTALLATION_3RDPARTY), 
## you can run the make uninstall-<packageName>
#function(UNINSTALLATION_3RDPARTY packageName)
#
#    set(${packageName}_UNINSTALL_CODE 
#        "
#        include(${CMAKE_SOURCE_DIR}/cmaketools/customTargets/project_uninstall.cmake)
#        project_uninstall(\"${CMAKE_BINARY_DIR}/${packageName}_install_manifest.txt\") ## have to deal with the argument passed
#        "
#    )
#    file(WRITE ${CMAKE_BINARY_DIR}/cmake_uninstall_${packageName}.cmake ${${packageName}_UNINSTALL_CODE} )
#    add_custom_target(uninstall-${packageName}
#        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall_${packageName}.cmake)
#    message(STATUS "***INFO***: You can use make uninstall-${packageName} to uninstall ${packageName} 3RDPARTY from ${packageName}_install_manifest.txt")
#
#endfunction()

