# pragma once
if(_VERBOSE_MESSAGES_CMAKE_INCLUDED_)
  return()
endif()
set(_VERBOSE_MESSAGES_CMAKE_INCLUDED_ true)

cmake_minimum_required(VERSION 2.8)

## CMAKE_DOCUMENTATION_START verbose_check 
##		VERBOSE_CHECK( verbose_variable verbose_type verbose_message ) 						\\n
## Author	: jesnault																		\\n
## Brief	: Macro to print a message type according to the verbosity var					\\n
## required	: -																				\\n
## Param 1	: VAR is the boolean variable the user has defined and which allow printing		\\n
## Param 2	: TYPE is the type of message : [STATUS | IMPORTANT | SEND_ERROR | FATAL_ERROR]	\\n
## Param 3	: MESSAGE is the user message which may contain variable to display				\\n
## Optional	: -																				\\n
## Usage	: VERBOSE_CHECK( myVerboseVar STATUS "this is a test with : ${myVar}")			\\n
## Description	: -																			\\n
## Infos	: -																				\\n
## CMAKE_DOCUMENTATION_END
function(VERBOSE_CHECK VAR TYPE MESSAGE)
	if(${VAR})
		if(${TYPE} MATCHES IMPORTANT)
			message(${MESSAGE})
		else()
			message(${TYPE} ${MESSAGE})
		endif()
	endif()
endfunction()

## CMAKE_DOCUMENTATION_START
##		VERBOSE( message 					\\n
##			[MESSAGES mess1 mess2 ...] 		\\n
##			[TYPE type]						\\n
##			[VAR var] )						\\n
## Author	: jesnault						\\n
## Brief	: Macro to print messages using the VERBOSE_MESS macro	\\n
## required	: VERBOSE_CHECK maro									\\n
## Param 1	: is the first message									\\n
## Optional 1	: MESSAGES is the following messages				\\n
## Optional 2	: TYPE is the type of the message : [STATUS | IMPORTANT | WARNING | SEND_ERROR | FATAL_ERROR] 	\\n
##		  (if type isn't specified the default usage is STATUS)													\\n
## Optional 3	: VAR is the variable which allow the printing													\\n
##		  (if variable isn't specified the default usage is VERBOSE_CMAKE)										\\n
## Usage 1	: VERBOSE("Hello alone")																			\\n
## Usage 2	: VERBOSE("Hello-without type specified" MESSAGES "1" "2" "3")										\\n
## Usage 3	: VERBOSE("Hello-with type SEND_ERROR specified" MESSAGES "1" "2" "3" TYPE SEND_ERROR)				\\n
## Usage 4	: VERBOSE("Hello" TYPE STATUS MESSAGES "defined type before next messages")							\\n
## Usage 6	: SET(VERB true)																					\\n
## 		  VERBOSE("Hello-new verbose var : VERB = ${VERB}" VAR VERB)											\\n
## Usage 7	: VERBOSE("Goodbye-on error" VAR VERB TYPE FATAL_ERROR)												\\n
## CMAKE_DOCUMENTATION_END
include(${CMAKE_ROOT}/Modules/CMakeParseArguments.cmake)

function(VERBOSE MESSAGE)
	set(options "")
    set(oneValueArgs TYPE VAR)
    set(multiValueArgs MESSAGES)
    cmake_parse_arguments(VERB "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	# Remain args
	#message("VERB_UNPARSED_ARGUMENTS = ${VERB_UNPARSED_ARGUMENTS}")

	# Defined the default variable which allow verbosity
	if(NOT DEFINED VERB_VAR)
		SET(VERB_VAR VERBOSE)
	endif()

	# Defined the default variable which define verbosity type
	if(NOT DEFINED VERB_TYPE)
		SET(VERB_TYPE STATUS)
	endif()
	
	# Defined the list MESSAGE
	LIST(INSERT VERB_MESSAGES 0 ${MESSAGE}) 

	# Search matching type and print message
	LIST(APPEND MESSAGE_TYPE STATUS SEND_ERROR FATAL_ERROR IMPORTANT)
	LIST(FIND MESSAGE_TYPE ${VERB_TYPE} RESULT)
	if(RESULT GREATER -1)
		foreach(MESS ${VERB_MESSAGES})
			VERBOSE_CHECK(${VERB_VAR} ${VERB_TYPE} ${MESS})
		endforeach()
	endif()
endfunction()
