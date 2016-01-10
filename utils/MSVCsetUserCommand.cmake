# pragma once
if(__MSVCsetUserCommand_cmake_INCLUDED__)
	return()
else()
	set(__MSVCsetUserCommand_cmake_INCLUDED__ ON)
endif()

## CMAKE_DOCUMENTATION_START MSVCsetUserCommand
##
## Allow to configure the Debugger settings of visual studio 	\\n
## Note: Using this command under linux doesn't affect anything \\n
## On run Debug Windows local : visual will try to load a specific COMMAND with ARGS in the provided WORKING_DIR \\n
## \\n
## usage:
## \\code
## MSVCsetUserCommand(	<targetName> 			\n
##    COMMAND 			<myCustomAppTpLaunch>	\n
##    ARGS 				<associatedArguments> 	\n
##    WORKING_DIR		<whereStartTheProgram>	\n
## )
## \\endcode
## \\n
## Warning 1 : All arugments () must be passed under quotes 			\\n
## Warning 2 : WORKING_DIR path arg have to finish with remain slah '/' \\n
## \\n
## Example: \\n
## \\code
## include(MSVCsetUserCommand) 											\n
## MSVCsetUserCommand(	UnityRenderingPlugin 							\n
## 	  COMMAND 			"C:/Program Files (x86)/Unity/Editor/Unity.exe"	\n
## 	  ARGS				"-force-opengl -projectPath \"${CMAKE_HOME_DIRECTORY}/UnityPlugins/RenderingPluginExample/UnityProject\""	\n
## 	  WORKING_DIR		"${CMAKE_HOME_DIRECTORY}/UnityPlugins/RenderingPluginExample/UnityProject/" \n
## 	  VERBOSE \n
## )
## \\endcode
## CMAKE_DOCUMENTATION_END
function(MSVCsetUserCommand targetName)

	include(CMakeParseArguments)
    cmake_parse_arguments(MSVCsuc "VERBOSE" "COMMAND;ARGS;WORKING_DIR" "" ${ARGN} )
	
	## If no arguments are given, do not create an unecessary .vcxproj.user file
	set(MSVCsuc_DEFAULT ON)
	
	if(NOT MSVCsuc_COMMAND)
		set(MSVCsuc_COMMAND "$(TargetPath)")
	elseif(MSVCsuc_DEFAULT)
		set(MSVCsuc_DEFAULT OFF)
	endif()
	
	if(MSVCsuc_WORKING_DIR)
		file(TO_NATIVE_PATH ${MSVCsuc_WORKING_DIR} MSVCsuc_WORKING_DIR)
	else()
		set(MSVCsuc_WORKING_DIR "$(ProjectDir)")
	elseif(MSVCsuc_DEFAULT)
		set(MSVCsuc_DEFAULT OFF)
	endif()
	
	if(NOT MSVCsuc_ARGS)
		set(MSVCsuc_ARGS "")
	elseif(MSVCsuc_DEFAULT)
		set(MSVCsuc_DEFAULT OFF)
	endif()
	
	if(MSVC10 OR (MSVC AND MSVC_VERSION GREATER 1600)) # 2010 or newer
	
		if(CMAKE_SIZEOF_VOID_P EQUAL 8)
			set(PLATEFORM_BITS x64)
		else()
			set(PLATEFORM_BITS Win32)
		endif()
		
		if(NOT MSVCsuc_DEFAULT AND PLATEFORM_BITS)
		
			file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${targetName}.vcxproj.user"
		"<?xml version=\"1.0\" encoding=\"utf-8\"?>
<Project ToolsVersion=\"4.0\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">
  <PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='Release|${PLATEFORM_BITS}'\">
    <LocalDebuggerCommand>${MSVCsuc_COMMAND}</LocalDebuggerCommand>
    <LocalDebuggerCommandArguments>${MSVCsuc_ARGS}</LocalDebuggerCommandArguments>
    <DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>
	<LocalDebuggerWorkingDirectory>${MSVCsuc_WORKING_DIR}</LocalDebuggerWorkingDirectory>
  </PropertyGroup>
  <PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='Debug|${PLATEFORM_BITS}'\">
    <LocalDebuggerCommand>${MSVCsuc_COMMAND}</LocalDebuggerCommand>
    <LocalDebuggerCommandArguments>${MSVCsuc_ARGS}</LocalDebuggerCommandArguments>
    <DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>
    <LocalDebuggerWorkingDirectory>${MSVCsuc_WORKING_DIR}</LocalDebuggerWorkingDirectory>
  </PropertyGroup>
    <PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='MinSizeRel|${PLATEFORM_BITS}'\">
    <LocalDebuggerCommand>${MSVCsuc_COMMAND}</LocalDebuggerCommand>
    <LocalDebuggerCommandArguments>${MSVCsuc_ARGS}</LocalDebuggerCommandArguments>
    <DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>
    <LocalDebuggerWorkingDirectory>${MSVCsuc_WORKING_DIR}</LocalDebuggerWorkingDirectory>
  </PropertyGroup>
    <PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='RelWithDebInfo|${PLATEFORM_BITS}'\">
    <LocalDebuggerCommand>${MSVCsuc_COMMAND}</LocalDebuggerCommand>
    <LocalDebuggerCommandArguments>${MSVCsuc_ARGS}</LocalDebuggerCommandArguments>
    <DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>
    <LocalDebuggerWorkingDirectory>${MSVCsuc_WORKING_DIR}</LocalDebuggerWorkingDirectory>
  </PropertyGroup>
</Project>"
			)
			if(MSVCsuc_VERBOSE)
				message(STATUS "Write ${CMAKE_CURRENT_BINARY_DIR}/${targetName}.vcxproj.user file")
				message(STATUS "   to execute ${MSVCsuc_COMMAND} ${MSVCsuc_ARGS}")
				message(STATUS "   from derectory ${MSVCsuc_WORKING_DIR}")
				message(STATUS "   on visual studio run debugger button")
			endif()
			
		else()
			message(WARNING "PLATEFORM_BITS is undefined...")
		endif()
		
	else()
		if(MSVCsuc_VERBOSE)
			message(WARNING "MSVCsetUserCommand is disable because too old MSVC is used (need MSVC10 2010 or newer)")
		endif()
	endif()
	
endfunction()