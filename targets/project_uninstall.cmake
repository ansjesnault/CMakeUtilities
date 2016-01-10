## pragma once
if(_PROJECT_UNINSTALL_CMAKE_INCLUDED_)
  return()
endif()
set(_PROJECT_UNINSTALL_CMAKE_INCLUDED_ true)

cmake_minimum_required(VERSION 2.8)

## CMAKE_DOCUMENTATION_START project_uninstall
##
##  Uninstall project using \\ref cmake_uninstall script.
##  \\code
##  project_uninstall()
##  \\endcode
##
## CMAKE_DOCUMENTATION_END
FUNCTION(PROJECT_UNINSTALL )
    configure_file(
        "cmaketools/customTargets/cmake_uninstall.cmake.in"
        "${CMAKE_BINARY_DIR}/cmake_uninstall.cmake"
        IMMEDIATE @ONLY
    )
    add_custom_target(uninstall
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
    )
    message(STATUS "***INFO***: You can use uninstall target after installation")
ENDFUNCTION()
