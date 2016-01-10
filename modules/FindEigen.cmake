## CMAKE_DOCUMENTATION_START FindEigen.cmake
## Important Note:\\n
## This is not an official Find*cmake. It has been written for searching through
## a custom path (EIGEN3_DIR) before checking elsewhere.\\n
##
## This module defines :\\n
## 	\\t[in] 	\\tEIGEN3_DIR, The base directory to search for EIGEN3 (as cmake var or env var)\\n
## 	\\t[out] 	\\tEIGEN3_INCLUDE_DIR where to find EIGEN3.h\\n
## 	\\t[out] 	\\tEIGEN3_LIBRARIES, EIGEN3_LIBRARY, libraries to link against to use EIGEN3\\n
## 	\\t[out] 	\\tEIGEN3_FOUND, If false, do not try to use EIGEN3.\\n
##
## CMAKE_DOCUMENTATION_END


if(NOT EIGEN3_DIR)
    set(EIGEN3_DIR "$ENV{EIGEN3_DIR}" CACHE PATH "EIGEN3 root directory")
endif()
if(EIGEN3_DIR)
	file(TO_CMAKE_PATH ${EIGEN3_DIR} EIGEN3_DIR)
endif()


set(PROGRAMFILESx86 "PROGRAMFILES(x86)")

FIND_PATH(EIGEN3_INCLUDE_DIR
	NAMES signature_of_eigen3_matrix_library
	PATHS
		${EIGEN3_DIR}
		## linux
		/usr
		/usr/local
		/opt/local
		## windows
		"$ENV{PROGRAMFILES}/EIGEN3"
		"$ENV{${PROGRAMFILESx86}}/EIGEN3"
		"$ENV{ProgramW6432}/EIGEN3"
	PATH_SUFFIXES include
)

set(EIGEN3_LIBRARIES "")

MARK_AS_ADVANCED(EIGEN3_INCLUDE_DIR EIGEN3_LIBRARIES)

if (EIGEN3_INCLUDE_DIR)
  set(EIGEN3_FOUND true)
else()
  message(FATAL_ERROR "Eigen3 not found")
endif()

if(NOT EIGEN3_FOUND)
	set(EIGEN3_DIR "" CACHE STRING "Path to EIGEN3 install directory")
endif()
