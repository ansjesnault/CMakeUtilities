## pragma once
if(_CHECK_GIT_SUBMODULES_CMAKE_INCLUDED_)
  return()
endif()
set(_CHECK_GIT_SUBMODULES_CMAKE_INCLUDED_ true)

cmake_minimum_required(VERSION 2.8)

## CMAKE_DOCUMENTATION_START checkGitSubmodules
##
## Check and get each git submodule dir to update if empty
## (for the first time you use cmake configure, after a clone).\\n
## It allow to auto check and get submodule, otherwise you have to launch a git submodule --init --recursive 
## after a git clone.\\n
##
##  Be careful, this function work only for public git submodule repo and not with an URL using SSH without local agent registered!
##
## CMAKE_DOCUMENTATION_END
function (checkGitSubmodules )
    if(EXISTS "${CMAKE_SOURCE_DIR}/.gitmodules")
        file(READ "${CMAKE_SOURCE_DIR}/.gitmodules" gitModulesContents)
        
        string(REGEX MATCHALL   "url = .*ssh"         gitModulesUrlsshLines "${gitModulesContents}")
        string(REGEX REPLACE    "url = .*(ssh)" "\\1" gitModulesUrlsshLines "${gitModulesUrlsshLines}")
        if(gitModulesUrlsshLines)
            message(WARNING "CMake found a git submodule with ssh URL : ${gitModulesUrlsshLines}
                    it can't be download without an ssh agent. 
                    Please use a public URL without SSH or init submodule by yourself.")
            break() ## I don't know how to deal with the asked ssh passphrase and another PID (using cmake &)
        endif()

        string(REGEX MATCHALL "path = [A-Za-z_0-9/-]+" gitModulesPathsLines "${gitModulesContents}")
        #message("gitModulesPathsLines = ${gitModulesPathsLines}")
        foreach(gitModulesPathsLine ${gitModulesPathsLines})
            string(REGEX REPLACE "path = ([A-Za-z_0-9/-]+)" "\\1" gitModulePath "${gitModulesPathsLine}")
            if(IS_DIRECTORY "${CMAKE_SOURCE_DIR}/${gitModulePath}")
                file(GLOB isEngagedModuleDir "${CMAKE_SOURCE_DIR}/${gitModulePath}/*")
                #message("gitModulePath = ${gitModulePath}")
                if(NOT isEngagedModuleDir)
                    find_package(Git)
                    #message("${GIT_EXECUTABLE}")
                    if(GIT_EXECUTABLE)
                        execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
                                        WORKING_DIRECTORY   ${CMAKE_SOURCE_DIR}
                                        OUTPUT_VARIABLE     submodule_update_output
                                        )
                        message(STATUS "${submodule_update_output}")
                    else()
                        message(WARNING "GIT_EXECUTABLE not found, submodule ${gitModulePath} cannot be initialised.")
                        message("You have to init git submodule by yourself.")
                    endif()
                    break()
                #else()
                    #message(STATUS "${gitModulePath} git submodule is already init")
                endif()
            else()
                message(WARNING "${CMAKE_SOURCE_DIR}/${gitModulePath} git submodule path is not found.")
                message("Create ${CMAKE_SOURCE_DIR}/${gitModulePath} dir or init git submodule by yourself.")
            endif()
        endforeach()
    endif()
endfunction()
