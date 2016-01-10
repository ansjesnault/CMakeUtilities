## CMAKE_DOCUMENTATION_START FindVRPN.cmake
## FindVRPN.cmake --- Search for an installed VRPN \\n
##  VRPN_INCLUDE_DIRS - where to find vrpn_Connection.h, etc.  \\n
##  (including QUAT_INCLUDE_DIR if QUAT_FOUND) \\n
##  \\n
##  VRPN_LIBRARIES          - List of libraries when using vrpn. \\n
##  (including QUAT_LIBRARY if QUAT_FOUND) \\n
##  VRPN_SERVER_LIBRARIES   - List of libraries when writing a vrpn server. \\n
##  (including QUAT_LIBRARY if QUAT_FOUND) \\n
##  \\n
##  VRPN_FOUND              - True if vrpn found \\n
## CMAKE_DOCUMENTATION_END

if(NOT VRPN_DIR)
    set(VRPN_DIR $ENV{VRPN_DIR} CACHE PATH "VRPN root dir")
endif()


#############
## Find QUAT
#############
set(QUAT_DIR $ENV{QUAT_DIR} CACHE PATH "QUAT root dir")
if(DEFINED VRPN_DIR AND NOT QUAT_DIR)
	set(QUAT_DIR "${VRPN_DIR}")
	mark_as_advanced(QUAT_DIR)
endif()

if (QUAT_INCLUDE_DIR)
  # Already in cache, be silent
  set(QUAT_FIND_QUIETLY TRUE)
endif (QUAT_INCLUDE_DIR)

find_path(QUAT_INCLUDE_DIR quat.h
    PATHS
        ${QUAT_DIR}
        ${VRPN_DIR}
        /usr/local
    PATH_SUFFIXES
	    include
	    include/vrpn
    )

find_library(QUAT_LIBRARY NAMES quat
        PATHS
            ${QUAT_DIR}/lib
			${QUAT_DIR}/lib64
            ${VRPN_DIR}/lib
            ${VRPN_DIR}/lib64
            /usr/local
            /usr/local/lib
            /usr/local/lib64
        PATH_SUFFIXES
	        Release
	        Debug
)


# handle the QUIETLY and REQUIRED arguments and set VRPN_FOUND to TRUE if 
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(QUAT DEFAULT_MSG QUAT_LIBRARY QUAT_INCLUDE_DIR)

IF(QUAT_FOUND)
  SET( QUAT_LIBRARIES ${QUAT_LIBRARY} )
ELSE(QUAT_FOUND)
  SET( QUAT_LIBRARIES )
ENDIF(QUAT_FOUND)

MARK_AS_ADVANCED( QUAT_LIBRARY QUAT_INCLUDE_DIR )


#############
## Find VRPN
#############
IF (VRPN_INCLUDE_DIR)
  # Already in cache, be silent
  SET(VRPN_FIND_QUIETLY TRUE)
ENDIF (VRPN_INCLUDE_DIR)

FIND_PATH(VRPN_INCLUDE_DIR vrpn_Connection.h
    PATHS
        ${VRPN_DIR}
        /usr/local
    PATH_SUFFIXES
	    include
	    include/vrpn
    )

find_library(VRPN_LIBRARY NAMES vrpn
        PATHS
            ${VRPN_DIR}/lib
            ${VRPN_DIR}/lib64
            /usr/local
            /usr/local/lib
            /usr/local/lib64
        PATH_SUFFIXES
	        Release
	        Debug
)

find_library(VRPN_SERVER_LIBRARY NAMES vrpnserver vrpn_phantom
        PATHS
            ${VRPN_DIR}/lib
            ${VRPN_DIR}/lib64
            /usr/local
            /usr/local/lib
            /usr/local/lib64
        PATH_SUFFIXES
	        Release
	        Debug
)

find_library(VRPN_ATMEL_LIBRARY NAMES vrpn_atmel
        PATHS
            ${VRPN_DIR}/lib
            ${VRPN_DIR}/lib64
            /usr/local
            /usr/local/lib
            /usr/local/lib64
        PATH_SUFFIXES
	        Release
	        Debug
)

find_library(VRPN_TIMECODE_GENERATOR_LIBRARY NAMES vrpn_timecode_generator timecode_generator
        PATHS
            ${VRPN_DIR}/lib
            ${VRPN_DIR}/lib64
            /usr/local
            /usr/local/lib
            /usr/local/lib64
        PATH_SUFFIXES
	        Release
	        Debug
)

MARK_AS_ADVANCED( VRPN_SERVER_LIBRARY VRPN_ATMEL_LIBRARY VRPN_TIMECODE_GENERATOR_LIBRARY)

# handle the QUIETLY and REQUIRED arguments and set VRPN_FOUND to TRUE if 
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(VRPN DEFAULT_MSG VRPN_LIBRARY VRPN_INCLUDE_DIR)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(VRPN_SERVER DEFAULT_MSG VRPN_SERVER_LIBRARY VRPN_INCLUDE_DIR)

IF(VRPN_FOUND)
  SET( VRPN_LIBRARIES ${VRPN_LIBRARY} ${QUAT_LIBRARIES})
  SET( VRPN_SERVER_LIBRARIES ${VRPN_SERVER_LIBRARY} ${QUAT_LIBRARIES})
  if (VRPN_ATMEL_LIBRARY)
      list(APPEND VRPN_LIBRARIES ${VRPN_ATMEL_LIBRARY})
      list(APPEND VRPN_SERVER_LIBRARIES ${VRPN_ATMEL_LIBRARY})
  endif (VRPN_ATMEL_LIBRARY)
  if (VRPN_TIMECODE_GENERATOR_LIBRARY)
      list(APPEND VRPN_LIBRARIES ${VRPN_TIMECODE_GENERATOR_LIBRARY})
      list(APPEND VRPN_SERVER_LIBRARIES ${VRPN_TIMECODE_GENERATOR_LIBRARY})
  endif (VRPN_TIMECODE_GENERATOR_LIBRARY)
  SET(VRPN_INCLUDE_DIRS ${VRPN_INCLUDE_DIR} ${QUAT_INCLUDE_DIR})
ELSE(VRPN_FOUND)
  SET( VRPN_LIBRARIES )
ENDIF(VRPN_FOUND)

MARK_AS_ADVANCED( VRPN_LIBRARY VRPN_INCLUDE_DIR )