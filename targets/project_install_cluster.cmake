## pragma once
if(_PROJECT_INSTALL_CLUSTER_CMAKE_INCLUDED_)
  return()
endif()
set(_PROJECT_INSTALL_CLUSTER_CMAKE_INCLUDED_ true)

cmake_minimum_required(VERSION 2.8)

## CMAKE_DOCUMENTATION_START project_install_cluster 
##
##  Create a custom install-cluster target using \\ref cmake_install-cluster cmake script.\\n
##  If you are actualy on a cluster host (clusterHostRefName) which is connected
##  to the cluster, then we create the target using the slavesHostList.
##  \\code
##  project_install_cluster(<clusterHostRefName> SLAVES [slaveHostName1 slaveHostName2...] [VERBOSE])
##  \\endcode
##  see \\ref cmake_install-cluster cmake file script for more details.
##
## CMAKE_DOCUMENTATION_END
FUNCTION(PROJECT_INSTALL_CLUSTER clusterHostRefName )

    ##params: "PREFIX" "optionsArgs" "oneValueArgs" "multiValueArgs"
    cmake_parse_arguments(PROJECT_INSTALL_CLUSTER "CACHED;VERBOSE" "" "SLAVES" ${ARGN} )
    
    # use COMMAND hostname -f ?
    execute_process(COMMAND hostname OUTPUT_VARIABLE MY_HOSTNAME OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(PROJECT_INSTALL_CLUSTER_VERBOSE)
        message(STATUS "Try to create install-cluster target : ")
        message(STATUS "    MY_HOSTNAME = ${MY_HOSTNAME}")
    endif()

    if(${MY_HOSTNAME} MATCHES "${clusterHostRefName}")
        set(PROJECT_INSTALL_CLUSTER_SLAVES "${PROJECT_INSTALL_CLUSTER_SLAVES}" CACHE STRING "hosts slaves for cluster installation")
        if(PROJECT_INSTALL_CLUSTER_VERBOSE)
            message(STATUS "    ${MY_HOSTNAME} match with ${clusterHostRefName}")
            message(STATUS "    SLAVES = ${PROJECT_INSTALL_CLUSTER_SLAVES}")
        endif()

        configure_file( "cmaketools/customTargets/cmake_install-cluster.cmake.in"
                        "${CMAKE_BINARY_DIR}/cmake_install-cluster.cmake"
                        IMMEDIATE @ONLY # @ONLY is important !
        )
        add_custom_target(install-cluster 
            COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_install-cluster.cmake 
        )
        message(STATUS "***INFO***: You can use custom target: make install-cluster for this host.")

    else()

        if(PROJECT_INSTALL_CLUSTER_VERBOSE)
            message(STATUS "    ${MY_HOSTNAME} not match with ${clusterHostRefName}")
        endif()

    endif()

ENDFUNCTION()
