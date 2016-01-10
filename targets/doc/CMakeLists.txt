#########################################################
# Include doxygen documentation target
#########################################################
option(BUILD_DOXY_DOC "build doxygen documentation" OFF)
if(BUILD_DOXY_DOC)
	find_package(Doxygen)
	if(NOT DOXYGEN_FOUND)
		message(WARNING "Doxygen not found, unable to generate documentation")
	else()
		set(DOXY_DOC_DEST_DIR               ${CMAKE_BINARY_DIR}) 	    ## used in the doxyfile.in
        set(DOXY_DOC_INPUT_ROOT_DIRS        ${CMAKE_HOME_DIRECTORY})    ## used in the doxyfile.in
        set(DOXY_DOC_EXCLUDE_PATTERNS_DIRS  ${CMAKE_BINARY_DIR})        ## used in the doxyfile.in
        set(DOXY_DOC_COMMON_IMG_PATH        ${CMAKE_CURRENT_SOURCE_DIR})## used in the doxyfile.in
		## TODO parse sub dirs to append all sub doc dirs from sub projects
		## typicaly for storing images or doxygen pages...
		configure_file(doxyfile.in 				${CMAKE_BINARY_DIR}/doxyfile 			 @ONLY)
		configure_file(doxyfileUpdate.cmake.in	${CMAKE_BINARY_DIR}/doxyfileUpdate.cmake @ONLY)
		add_custom_target(doxyDoc ${CMAKE_COMMAND} -P ${CMAKE_BINARY_DIR}/doxyfileUpdate.cmake
			COMMAND ${DOXYGEN_EXECUTABLE} "${CMAKE_BINARY_DIR}/doxyfile"
			WORKING_DIRECTORY ${CMAKE_HOME_DIRECTORY}
			COMMENT "Building user's documentation into doxyDoc build dir..."
		)
	endif()
endif()
