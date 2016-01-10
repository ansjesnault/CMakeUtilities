## CMAKE_DOCUMENTATION_START install_runtime.cmake
## This file is mainly used to allow a common runtime installation. \\n
## There are some utilities cmake functions to ease the generic deployement (abstract common usage of cmake)...\\n
## \\n
## You cannot run your programm automaticaly from your CMAKE_BINARY_DIR when you build
## as it will miss all dependencies and ressources files...\\n
## You have to run install target in order to test your programm.\\n
## \\n
## The only one function/macros you may use inside your sub-CMakeLists.txt (sub-project) is :\\n
## ******************\\n
## install_target macro => see documentation at the end of this file\\n
## ******************\\n
## It use these utilities cmake functions to abstract the installation in an uniform way for all sub-projects.\\n
##
## CMAKE_DOCUMENTATION_END
## Written by jesnault
if(__install_runtime_cmake_INCLUDED__)
	return()
else()
	set(__install_runtime_cmake_INCLUDED__ ON)
endif()

cmake_minimum_required(VERSION 3.0)

## CMAKE_DOCUMENTATION_START resourceFile
##
## Allow to write a resource config file which contain additional ressource paths
## (used by targets Resource system to load shaders and potentialy images, plugins and so on) \\n
## \\n
## ADD option list all the paths to add in the file (relative paths are interpreted relative to working dir of the executable) \\n
## INSTALL option to specify where we want to install this file \\n
## \\n
## Example usage: \\n
## \\code
## resourceFile(ADD "shaders" "${PROJECT_NAME}_rsc" INSTALL bin)
## \\endcode
## CMAKE_DOCUMENTATION_END
## Written by jesnault
macro(resourceFile )
	include(CMakeParseArguments)
	cmake_parse_arguments(rsc "" "INSTALL" "ADD" ${ARGN}) ## both args are directory path
	
	set(resourceFile "${CMAKE_BINARY_DIR}/resources.ini")
	
	if(rsc_ADD)
		unset(_RSC_FILE_CONTENT_LIST)
		if(EXISTS "${resourceFile}")
			file(READ "${resourceFile}" _RSC_FILE_CONTENT)
			string(REGEX REPLACE "\n" ";" _RSC_FILE_CONTENT_LIST "${_RSC_FILE_CONTENT}")
		endif()
		list(APPEND _RSC_FILE_CONTENT_LIST "${rsc_ADD}")
		list(REMOVE_DUPLICATES _RSC_FILE_CONTENT_LIST)
		file(WRITE "${resourceFile}" "")
		foreach(rscDir ${_RSC_FILE_CONTENT_LIST})
			file(APPEND "${resourceFile}" "${rscDir}\n")
		endforeach()
		unset(rsc_ADD)
	endif()
	
	if(rsc_INSTALL)
		install(FILES ${resourceFile} DESTINATION ${rsc_INSTALL})
		unset(rsc_INSTALL)
	endif()
	
	unset(resourceFile)
endmacro()


## CMAKE_DOCUMENTATION_START installPDB
## Install *.pdb generated file for the current cmake project 
## assuming the output target name is the cmake project name. \\n
## This macro is useful for crossplateform multi config mode. \\n
## \\n
## Usage Example:
## \\code
## 	if(DEFINED CMAKE_BUILD_TYPE)						## for make/nmake based \n
##		installPDB(${PROJECT_NAME} ${CMAKE_BUILD_TYPE} RUNTIME_DEST bin ARCHIVE_DEST lib LIBRARY_DEST lib)\n
## 	endif()\n
##	foreach(CONFIG_TYPES ${CMAKE_CONFIGURATION_TYPES}) 	## for multi config types (MSVC based)\n
##		installPDB(${PROJECT_NAME} ${CONFIG_TYPES} RUNTIME_DEST bin ARCHIVE_DEST lib LIBRARY_DEST lib)\n
##	endforeach()
## \\endcode
## CMAKE_DOCUMENTATION_END
## Written by Jerome Esnault
macro(installPDB targetName configType)
	include(CMakeParseArguments)
	cmake_parse_arguments(instpdb "" "COMPONENT" "ARCHIVE_DEST;LIBRARY_DEST;RUNTIME_DEST" ${ARGN}) ## both args are directory path
	
	if(NOT MSVC)
		return()
	endif()
	
    ## Check if DESTINATION are provided according to the TYPE of the given target (see install command doc to see correspodances)
    get_target_property(type ${targetName} TYPE)
    if(${type} MATCHES "EXECUTABLE" AND instpdb_RUNTIME_DEST)
        set(pdb_DESTINATION ${instpdb_RUNTIME_DEST})
    elseif(${type} MATCHES "STATIC_LIBRARY" AND instpdb_ARCHIVE_DEST)
        set(pdb_DESTINATION ${instpdb_ARCHIVE_DEST})
    elseif(${type} MATCHES "MODULE_LIBRARY" AND instpdb_LIBRARY_DEST)
        set(pdb_DESTINATION ${instpdb_LIBRARY_DEST})
    elseif(${type} MATCHES "SHARED_LIBRARY")
        if(WIN32 AND instpdb_RUNTIME_DEST)
            set(pdb_DESTINATION ${instpdb_RUNTIME_DEST})
        else()
            set(pdb_DESTINATION ${instpdb_LIBRARY_DEST})
        endif()
    endif()
    
    if(NOT pdb_DESTINATION)
		set(pdb_DESTINATION bin) ## default destination of the pdb file
	endif()
	
	if(NOT instpdb_COMPONENT)
		set(instpdb_COMPONENT )
	else()
		set(instpdb_COMPONENT COMPONENT ${instpdb_COMPONENT})
	endif()
	
	string(TOUPPER ${configType} CONFIG_TYPES_UC)
	get_target_property(PDB_PATH ${targetName} PDB_OUTPUT_DIRECTORY_${CONFIG_TYPES_UC})
	
	get_target_property(confModePostfix ${targetName} ${CONFIG_TYPES_UC}_POSTFIX)
	if(NOT confModePostfix)
		set(confModePostfix "")
	endif()
	set_target_properties(${targetName} PROPERTIES  PDB_NAME_${CONFIG_TYPES_UC} ${targetName}${confModePostfix})
	get_target_property(PDB_NAME ${targetName} PDB_NAME_${CONFIG_TYPES_UC})# if not set, this is empty
	
	if(EXISTS "${PDB_PATH}/${PDB_NAME}.pdb")
		install(FILES "${PDB_PATH}/${PDB_NAME}.pdb" DESTINATION ${pdb_DESTINATION} ${instpdb_COMPONENT})
	endif()
endmacro()


## CMAKE_DOCUMENTATION_START installTargetProject
## Add additional target to install a project independently and based on its component
## configMode is used to prevent default Release installation (we want also to install in other build/config type)
## CMAKE_DOCUMENTATION_END
## Written by Jerome Esnault
macro(installTargetProject targetOfProject targetOfInstallProject componentName)
 	if(DEFINED CMAKE_BUILD_TYPE) ## for make/nmake based
		set(configMode ${CMAKE_BUILD_TYPE})
	elseif(MSVC)
		## $(Configuration) will be one of the following : Debug, Release, MinSizeRel, RelWithDebInfo
		set(configMode $(Configuration))
 	endif()
	if(configMode)
        get_target_property(srcFiles ${targetOfProject} SOURCES)        
		add_custom_target(	${targetOfInstallProject} #ALL
							${CMAKE_COMMAND} -DBUILD_TYPE=${configMode} -DCOMPONENT=${componentName} -P ${CMAKE_BINARY_DIR}/cmake_install.cmake
							DEPENDS ${srcFiles}
							COMMENT "run the installation only for ${targetOfProject} (component ${componentName})" VERBATIM
							)
		add_dependencies(	${targetOfInstallProject} ${targetOfProject})
	endif()
endmacro()		

## CMAKE_DOCUMENTATION_START install_runtime
## CMAKE install all requiered dependencies for an application (included system OS files like msvc*.dll for example) \\n
## \\code
## install_runtime(<installedFilePathTargetAppToResolve> \n
##      [TARGET                 name]		\n
##      [PLUGINS 				name 		[nameN ...] [PLUGIN_PATH_NAME currentPathName [FROM_REL_PATH matchDirFromCurrentPathName] [PLUGIN_PATH_DEST installDir] ]\n
##      [PLUGINS 				...] 		\n
##      [DIRS 					path 		[pathN ...] ]	 		\n
##		[TARGET_LIBRARIES  		filePath	[filePathN ...] ]		\n
##		[TARGET_PACKAGES   		packageName [packageNameN ...] ]	\n
##		[COMPONENT				installComponentName]				\n
##		[PLAUSIBLES_POSTFIX		Debug_postfix [MinSizeRel_postfix relWithDebInfo_postfix ...] ] \n
##      [VERBOSE]               \n
## )
##\\endcode
## installedFilePathTargetAppToResolve : the final installed targetApp absolute full file path name you want to resolve \\n
## \\n
## TARGET           :   The target app we want to install. If given, it's used to look for link libraries paths (best choice to use, strongly advised to use it)\\n
## \\n
## PLUGINS 			: 	Some application built use/load some plugins which can't be detect inside its binary,
##						so, here you can specify which plugins the application use/load in order to install them
##						and resolve also there dependencies.\\n
## 		\tWith PLUGINS multi FLAGS 	:\\n
## 	 	\t\tPLUGIN_PATH_NAME 	: The current plugin full file path we want to install \\n
##		\t\tFROM_REL_PATH		: [optional: default only the file is kept] From which matching dir of the plugin path we want to install (keep the directories structure) \\n
##		\t\tPLUGIN_PATH_DEST	: [optional: default relative to executable directory] Where (full path to the install directory) we will install the plugin file (or file path)\\n
## \\n
## DIRS 			:	A list of directories to looking for dependencies \\n
## TARGET_LIBRARIES :	DEPRECATED (use TARGET flag instead) : The cmake content variables used for the target_link_libraries(<targetApp> ...) \\n
## TARGET_PACKAGES 	: 	DEPRECATED (use TARGET flag instead) : The cmake package names used for the findPackage(...) for your targetApp \\n
##						ADVICE: This flag add entries in cache (like: <packageName>_DIR), it could be useful to fill these variable! \\n
## COMPONENT		:	(default to runtime) Is the component name associated to the installation \\n
##						It is used when you want to install separatly some part of your projets (see install cmake doc) \\n
## VERBOSE			: 	For debug or to get more informations in the output console \\n
## \\n
## Usage:
## \\code
##	 install_runtime(${CMAKE_INSTALL_PREFIX}/${EXECUTABLE_NAME}${CMAKE_EXECUTABLE_SUFFIX} \n
##		VERBOSE 					\n
##      TARGET  ${PROJECT_NAME}		\n
##      PLAUSIBLES_POSTFIX  _d		\n
##      PLUGINS						\n
##		    PLUGIN_PATH_NAME    ${PLUGIN_PATH_NAME}${CMAKE_SHARED_MODULE_SUFFIX} ## will be installed (default exec path if no PLUGINS_DEST) and then will be resolved 	\n
##			FROM_REL_PATH		plugins ## optional, used especially for keeping qt plugins tree structure																\n
##          PLUGIN_PATH_DEST    ${CMAKE_INSTALL_PREFIX}/plugins ## (or relative path 'plugins' will be interpreted relative to installed executable)					\n
##		DIRS				${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_BINARY_DIR}							\n
##		TARGET_LIBRARIES	${OPENGL_LIBRARIES}         ## DEPRECATED (use TARGET flag instead)		\n
##							${GLEW_LIBRARIES}			\n
##							${GLUT_LIBRARIES}			\n
##							${Boost_LIBRARIES}			\n
##							${SuiteSparse_LIBRARIES}	\n
##							${CGAL_LIBRARIES}			\n
##		TARGET_PACKAGES		OPENGL                      ## DEPRECATED (use TARGET flag instead)		\n
##							GLEW						\n
##							GLUT						\n
##							CGAL						\n
##							Boost 						\n
##							SuiteSparse					\n
##	)
## \\endcode
## For plugins part, it use our internal parse_arguments_multi.cmake
## CMAKE_DOCUMENTATION_END
## Written by Jerome Esnault
function(install_runtime installedFilePathTargetAppToResolve)

	include(CMakeParseArguments)
    set(optionsArgs "VERBOSE")
    set(oneValueArgs "COMPONENT")
    set(multiValueArgs "DIRS;PLUGINS;TARGET_LIBRARIES;TARGET_PACKAGES;TARGET;PLAUSIBLES_POSTFIX")
    cmake_parse_arguments(inst_run "${optionsArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	
    if(IS_ABSOLUTE ${installedFilePathTargetAppToResolve})
    else()
        set(installedFilePathTargetAppToResolve ${CMAKE_INSTALL_PREFIX}/${installedFilePathTargetAppToResolve})
    endif()
    
	get_filename_component(EXEC_NAME ${installedFilePathTargetAppToResolve} NAME_WE)
	get_filename_component(EXEC_PATH ${installedFilePathTargetAppToResolve} PATH)
	
	if(NOT inst_run_COMPONENT)
		set(inst_run_COMPONENT runtime)
	endif()
	
    
    ## Try to append as more possible as possible paths to find dependencies (deprecated since we can use target_properties to get back paths)
    set(libPaths )
	foreach(libraryFileName ${inst_run_TARGET_LIBRARIES})
		if(IS_DIRECTORY "${libraryFileName}")
			list(APPEND libPaths "${libraryFileName}")
		else()
			get_filename_component(libpath "${libraryFileName}" PATH)
			if(EXISTS "${libpath}")
				list(APPEND libPaths "${libpath}")
			endif()
		endif()
	endforeach()
    
    ## This macro is used internaly here to recursilvely get path of LINK_LIBRARIES of each non imported target
    ## Typically if you have 2 internal dependencies between cmake targets, we want cmake to be able to get back path where are these dependencies
    macro(recurseDepList target)
        get_target_property(linkLibs ${target} LINK_LIBRARIES)
        foreach(lib ${linkLibs})
            string(FIND ${lib} ">" strId) ## cmake is using generator-expression?
            if(TARGET ${lib})
                ## it's not a path but a single target name
                ## for build-target which are part of the current cmake configuration : nothing to do as cmake already know the output path
                ## for imported target, we need to look for theire imported location
                get_target_property(imported ${lib} IMPORTED)
                if(imported)
                    get_target_property(imp_loc ${lib} IMPORTED_LOCATION)
                    if(imp_loc)
                        get_filename_component(imp_loc ${imp_loc} PATH)
                        list(APPEND taregetLibPath ${imp_loc})
                    endif()
                    get_target_property(loc ${lib} LOCATION)
                    if(loc)
                        get_filename_component(loc ${loc} PATH)
                        list(APPEND taregetLibPath ${loc})
                    endif()
                else()
                    recurseDepList(${lib})
                endif()
            elseif(NOT ${strId} MATCHES -1) ## mean cmake use generator-expression (CMAKE VERSION > 3.0)
                string(REGEX MATCH      ">:[A-Za-z_:/.0-9-]+"           taregetLibPath ${lib})
                string(REGEX REPLACE    ">:([A-Za-z_:/.0-9-]+)" "\\1"   taregetLibPath ${taregetLibPath})
                get_filename_component(taregetLibPath ${taregetLibPath} PATH)
            elseif(EXISTS ${lib})
                set(taregetLibPath ${lib})
                get_filename_component(taregetLibPath ${taregetLibPath} PATH)
            else()
                message(STATUS "[install_runtime] skip link library : ${lib} , of target ${target}")
            endif()
            if(taregetLibPath)
                list(APPEND targetLinkLibsPathList ${taregetLibPath})
            endif()
        endforeach()
        if(targetLinkLibsPathList)
            list(REMOVE_DUPLICATES targetLinkLibsPathList)
        endif()
    endmacro()
    if(inst_run_TARGET)
        recurseDepList(${inst_run_TARGET})
        if(targetLinkLibsPathList)
            list(APPEND libPaths ${targetLinkLibsPathList})
        endif()
    endif()
    
	if(libPaths)
		list(REMOVE_DUPLICATES libPaths)
        foreach(libPath ${libPaths})
            get_filename_component(path ${libPath} PATH)
            list(APPEND libPaths ${path})
        endforeach()
	endif()
    
    
	## possible speciale dir(s) according to the build system and OS
	if(CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(BUILD_TYPES_FOR_DLL "x64")
		if(WIN32)
			list(APPEND BUILD_TYPES_FOR_DLL "Win64")
		endif()
	else()
		set(BUILD_TYPES_FOR_DLL "x86")
		if(WIN32)
			list(APPEND BUILD_TYPES_FOR_DLL "Win32")
		endif()
	endif()

    
	## Try to append as more as possible paths to find dependencies (here, mainly for *.dll)
	foreach(dir ${inst_run_DIRS} ${libPaths})
		if(EXISTS "${dir}/bin")
			list(APPEND inst_run_DIRS "${dir}/bin")
        elseif(EXISTS "${dir}")
            list(APPEND inst_run_DIRS "${dir}")
		endif()
	endforeach()
    list(REMOVE_DUPLICATES inst_run_DIRS)
	foreach(dir ${inst_run_DIRS})
		if(EXISTS "${dir}")
			list(APPEND argDirs ${dir})
			foreach(BUILD_TYPE_FOR_DLL ${BUILD_TYPES_FOR_DLL})
				if(EXISTS "${dir}/${BUILD_TYPE_FOR_DLL}")
					list(APPEND argDirs "${dir}/${BUILD_TYPE_FOR_DLL}")
				endif()
				foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES}) ## for windows multi-generator (MSVC)
					if(EXISTS "${dir}/${BUILD_TYPE_FOR_DLL}/${OUTPUTCONFIG}")
						list(APPEND argDirs "${dir}/${BUILD_TYPE_FOR_DLL}/${OUTPUTCONFIG}")
					endif()
				endforeach()
				if(CMAKE_BUILD_TYPE) ## for single generator (makefiles)
					if(EXISTS "${dir}/${BUILD_TYPE_FOR_DLL}/${CMAKE_BUILD_TYPE}")
						list(APPEND argDirs "${dir}/${BUILD_TYPE_FOR_DLL}/${CMAKE_BUILD_TYPE}")
					endif()
				endif()
			endforeach()
			foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES}) ## for windows multi-generator (MSVC)
				if(EXISTS "${dir}/${OUTPUTCONFIG}")
					list(APPEND argDirs "${dir}/${OUTPUTCONFIG}")
				endif()
				foreach(BUILD_TYPE_FOR_DLL ${BUILD_TYPES_FOR_DLL})
					if(EXISTS "${dir}/${OUTPUTCONFIG}/${BUILD_TYPE_FOR_DLL}")
						list(APPEND argDirs "${dir}/${OUTPUTCONFIG}/${BUILD_TYPE_FOR_DLL}")
					endif()
				endforeach()
			endforeach()
			if(CMAKE_BUILD_TYPE) ## for single generator (makefiles)
				if(EXISTS "${dir}/${CMAKE_BUILD_TYPE}")
					list(APPEND argDirs "${dir}/${CMAKE_BUILD_TYPE}")
				endif()
				foreach(BUILD_TYPE_FOR_DLL ${BUILD_TYPES_FOR_DLL})
					if(EXISTS "${dir}/${CMAKE_BUILD_TYPE}/${BUILD_TYPE_FOR_DLL}")
						list(APPEND argDirs "${dir}/${CMAKE_BUILD_TYPE}/${BUILD_TYPE_FOR_DLL}")
					endif()
				endforeach()
			endif()
		endif()
	endforeach()
	if(argDirs)
		list(REMOVE_DUPLICATES argDirs)
	endif()
	
	
	## Try to append as more possible paths to find dependencies (here, mainly for *.dll)
	foreach(packageName ${inst_run_TARGET_PACKAGES})
		if(EXISTS "${${packageName}_DIR}")
			list(APPEND packageDirs ${${packageName}_DIR})
			list(APPEND packageDirs ${${packageName}_DIR}/bin)
			foreach(BUILD_TYPE_FOR_DLL ${BUILD_TYPES_FOR_DLL})
				if(EXISTS "${${packageName}_DIR}/bin/${BUILD_TYPE_FOR_DLL}")
					list(APPEND packageDirs "${${packageName}_DIR}/bin/${BUILD_TYPE_FOR_DLL}")
				endif()
				foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES}) ## for windows multi-generator (MSVC)
					if(EXISTS "${${packageName}_DIR}/bin/${BUILD_TYPE_FOR_DLL}/${OUTPUTCONFIG}")
						list(APPEND packageDirs "${${packageName}_DIR}/bin/${BUILD_TYPE_FOR_DLL}/${OUTPUTCONFIG}")
					endif()
				endforeach()
				if(CMAKE_BUILD_TYPE) ## for single generator (makefiles)
					if(EXISTS "${${packageName}_DIR}/bin/${BUILD_TYPE_FOR_DLL}/${CMAKE_BUILD_TYPE}")
						list(APPEND packageDirs "${${packageName}_DIR}/bin/${BUILD_TYPE_FOR_DLL}/${CMAKE_BUILD_TYPE}")
					endif()
				endif()
			endforeach()
			foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES}) ## for windows multi-generator (MSVC)
				if(EXISTS "${${packageName}_DIR}/bin/${OUTPUTCONFIG}")
					list(APPEND packageDirs "${${packageName}_DIR}/bin/${OUTPUTCONFIG}")
				endif()
				foreach(BUILD_TYPE_FOR_DLL ${BUILD_TYPES_FOR_DLL})
					if(EXISTS "${${packageName}_DIR}/bin/${OUTPUTCONFIG}/${BUILD_TYPE_FOR_DLL}")
						list(APPEND packageDirs "${${packageName}_DIR}/bin/${OUTPUTCONFIG}/${BUILD_TYPE_FOR_DLL}")
					endif()
				endforeach()
			endforeach()
			if(CMAKE_BUILD_TYPE) ## for single generator (makefiles)
				if(EXISTS "${${packageName}_DIR}/bin/${CMAKE_BUILD_TYPE}")
					list(APPEND packageDirs "${${packageName}_DIR}/bin/${CMAKE_BUILD_TYPE}")
				endif()
				foreach(BUILD_TYPE_FOR_DLL ${BUILD_TYPES_FOR_DLL})
					if(EXISTS "${${packageName}_DIR}/bin/${CMAKE_BUILD_TYPE}/${BUILD_TYPE_FOR_DLL}")
						list(APPEND packageDirs "${${packageName}_DIR}/bin/${CMAKE_BUILD_TYPE}/${BUILD_TYPE_FOR_DLL}")
					endif()
				endforeach()
			endif()
		else()
			set(${packageName}_DIR "$ENV{${packageName}_DIR}" CACHE PATH "${packageName}_DIR root directory for looking for dirs containning *.dll")
		endif()
	endforeach()
	if(packageDirs)
		list(REMOVE_DUPLICATES packageDirs)
	endif()
    

	set(dirsToLookFor "${EXEC_PATH}")
	if(packageDirs)
		list(APPEND dirsToLookFor ${packageDirs})
	endif()
	if(argDirs)
		list(APPEND dirsToLookFor ${argDirs})
	endif()
	
    
    ## handle plugins
	set(pluginsList "")    
    include(parse_arguments_multi) ## this function will process recursively items of the sub-list [default print messages]
    function(parse_arguments_multi_function results)
        cmake_parse_arguments(pamf "VERBOSE" "PLUGIN_PATH_DEST;FROM_REL_PATH;EXEC_PATH;COMPONENT" "" ${ARGN}) ## EXEC_PATH and COMPONENT are for exclusive internal use
		list(REMOVE_DUPLICATES pamf_UNPARSED_ARGUMENTS)
        foreach(PLUGIN_PATH_NAME ${pamf_UNPARSED_ARGUMENTS})
            if(EXISTS ${PLUGIN_PATH_NAME})
                if(IS_DIRECTORY ${PLUGIN_PATH_NAME})
                    if(pamf_VERBOSE)
                        message(WARNING "${PLUGIN_PATH_NAME} IS_DIRECTORY, cannot installed a directory, please give a path filename")
                    endif()
                else()
                    if(NOT pamf_PLUGIN_PATH_DEST)
                        set(PLUGIN_PATH_DEST ${pamf_EXEC_PATH}) ## the default dest value
					else()
						set(PLUGIN_PATH_DEST ${pamf_PLUGIN_PATH_DEST})
                    endif()
					
					if(pamf_FROM_REL_PATH)
						file(TO_CMAKE_PATH ${PLUGIN_PATH_NAME} PLUGIN_PATH_NAME)
						get_filename_component(PLUGIN_PATH ${PLUGIN_PATH_NAME} PATH)
						unset(PLUGIN_PATH_LIST)
						unset(PLUGIN_PATH_LIST_COUNT)
						unset(PLUGIN_REL_PATH_LIST)
						unset(PLUGIN_REL_PATH)
						string(REPLACE "/" ";" PLUGIN_PATH_LIST ${PLUGIN_PATH}) ## create a list of dir
						list(FIND 	PLUGIN_PATH_LIST ${pamf_FROM_REL_PATH} id)
						list(LENGTH PLUGIN_PATH_LIST PLUGIN_PATH_LIST_COUNT)
						if(${id} GREATER 0)
							math(EXPR id "${id}+1") ## matches relative path not include
							math(EXPR PLUGIN_PATH_LIST_COUNT "${PLUGIN_PATH_LIST_COUNT}-1") ## the end of the list
							foreach(i RANGE ${id} ${PLUGIN_PATH_LIST_COUNT})
								list(GET 	PLUGIN_PATH_LIST 	${i} out)
								list(APPEND PLUGIN_REL_PATH_LIST 	${out})
							endforeach()
							foreach(dir ${PLUGIN_REL_PATH_LIST})
								set(PLUGIN_REL_PATH "${PLUGIN_REL_PATH}/${dir}")
							endforeach()
						endif()
						set(PLUGIN_PATH_DEST ${PLUGIN_PATH_DEST}${PLUGIN_REL_PATH})
					endif()
					
                    install(FILES ${PLUGIN_PATH_NAME} DESTINATION ${PLUGIN_PATH_DEST} COMPONENT ${pamf_COMPONENT})
                    get_filename_component(pluginName ${PLUGIN_PATH_NAME} NAME)
                    if(IS_ABSOLUTE ${PLUGIN_PATH_DEST})
                    else()
                        set(PLUGIN_PATH_DEST ${CMAKE_INSTALL_PREFIX}/${PLUGIN_PATH_DEST})
                    endif()
                    list(APPEND pluginsList ${PLUGIN_PATH_DEST}/${pluginName})
                endif()
            else()
                message(WARNING "You need to provide a valid PLUGIN_PATH_NAME")
                set(pluginsList )
            endif()
        endforeach()
        set(${results} ${pluginsList} PARENT_SCOPE)
    endfunction()
    
    if(inst_run_VERBOSE)
        list(APPEND extra_flags_to_add VERBOSE)
    endif()
    list(APPEND extra_flags_to_add EXEC_PATH ${EXEC_PATH} COMPONENT ${inst_run_COMPONENT}) ## for internal use inside overloaded function   
    list(LENGTH inst_run_PLUGINS inst_run_PLUGINS_count)
    if(${inst_run_PLUGINS_count} GREATER 0)
        parse_arguments_multi(PLUGIN_PATH_NAME inst_run_PLUGINS ${inst_run_PLUGINS} ## see internal overload parse_arguments_multi_function for processing each sub-list
                                NEED_RESULTS ${inst_run_PLUGINS_count}  ## this is used to check when we are in the first loop (in order to reset parse_arguments_multi_results)
                                EXTRAS_FLAGS ${extra_flags_to_add}      ## this is used to allow catching additional internal flags of our overloaded function
        )
    endif()
    
    #message(parse_arguments_multi_results = ${parse_arguments_multi_results})
    list(APPEND pluginsList ${parse_arguments_multi_results})
    
    
	
	## Install rules for required system runtimes such as MSVCRxx.dll
	set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP ON)
	include(InstallRequiredSystemLibraries)
	if(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS)
		install(FILES 			${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}
				DESTINATION 	${EXEC_PATH}
				COMPONENT   	${inst_run_COMPONENT}
		)
	endif()
	
	## print what we are doing to do
	if(inst_run_VERBOSE)
		message(STATUS "[install_runtime] On install target call, cmake will try to resolve dependencies for given app:\n ${installedFilePathTargetAppToResolve} (with plausible postfix: ${inst_run_PLAUSIBLES_POSTFIX})")
		if(pluginsList)
			message(STATUS "   and also for plugins :")
			foreach(plugin ${pluginsList})
				message(STATUS "      ${plugin}")
			endforeach()
		endif()
		message(STATUS "   Looking for dependencies into:")
		foreach(dir ${dirsToLookFor})
			message(STATUS "      ${dir}")
		endforeach()
	endif()

	## Install rules for requiered dependencies libs/plugins for the target app
    ## will resolve all installed target files with config modes postfixes
	install(CODE 
		"
		set(inst_run_PLAUSIBLES_POSTFIX ${inst_run_PLAUSIBLES_POSTFIX})
		if(inst_run_PLAUSIBLES_POSTFIX)
			unset(installedFilePathTargetAppToResolve)
			foreach(postfix \${inst_run_PLAUSIBLES_POSTFIX}) ## if postfix exist
				if(EXISTS \"${EXEC_PATH}/${EXEC_NAME}\${postfix}${CMAKE_EXECUTABLE_SUFFIX}\")
					list(APPEND installedFilePathTargetAppToResolve \"${EXEC_PATH}/${EXEC_NAME}\${postfix}${CMAKE_EXECUTABLE_SUFFIX}\")
				endif()
			endforeach()
			if(EXISTS \"${EXEC_PATH}/${EXEC_NAME}${CMAKE_EXECUTABLE_SUFFIX}\") ## special case if no postfix for this config (eg:release)
				list(APPEND installedFilePathTargetAppToResolve \"${EXEC_PATH}/${EXEC_NAME}${CMAKE_EXECUTABLE_SUFFIX}\")
			endif()
			if(NOT installedFilePathTargetAppToResolve)
				message(SEND_ERROR \"The arg passed to install_runtime is empty, check PLAUSIBLES_POSTFIX option.\")
			endif()
		endif()
		include(BundleUtilities)
		foreach(app \${installedFilePathTargetAppToResolve})
			fixup_bundle(\"\${app}\"   \"${pluginsList}\"   \"${dirsToLookFor}\")
		endforeach()
		"
	   COMPONENT ${inst_run_COMPONENT}
	)
	
endfunction()



## CMAKE_DOCUMENTATION_START install_target
## Hight level macro to install in an homogen way all our targets (it use some functions inside this file) \\n
## \\n
## RSC_FILE_ADD : [opt] is used to auto write/append relative paths of target ressources into a common file \\n
## INSTALL_PDB  : [opt] is used to auto install PDB file (when using MSVC according to the target type)  \\n
## QT5_PLUGINS  : [opt] is used only if Qt5 components are found in target link libraries. See Qt5ImportedLocation doc \\n
## STANDALONE   : [opt] bool ON/OFF var to call install_runtime or not (for bundle resolution) \\n
##       DIRS   : [opt] used if STANDALONE set to ON, see install_runtime doc \\n
##       PLUGINS: [opt] used if STANDALONE set to ON, see install_runtime doc \\n
## MSVC_CMD     : [opt] used to specify an absolute filePathName application to launch with the MSVC IDE Debugger associated to this target (project file) \\n
## MSVC_ARGS    : [opt] load the MSVC debugger with correct settings (app path, args, working dir) \\n
## \\n
## CMAKE_DOCUMENTATION_END
## Written by jesnault
macro(install_target target)
    include(CMakeParseArguments)
	cmake_parse_arguments(Inst${target} "VERBOSE;INSTALL_PDB" "COMPONENT;MSVC_ARGS;STANDALONE" "RSC_FILE_ADD;QT5_PLUGINS;DIRS;PLUGINS" ${ARGN})
    
    if(Inst${target}_RSC_FILE_ADD)
        resourceFile(ADD "${Inst${target}_RSC_FILE_ADD}" INSTALL bin)
    endif()
    
    if(Inst${target}_COMPONENT)
        set(installCompArg COMPONENT ${Inst${target}_COMPONENT})
        ## Create a custom install target based on COMPONENT
        installTargetProject(${target} ${Inst${target}_COMPONENT} ${Inst${target}_COMPONENT})
    endif()
    
    ## Specify default installation rules
    install(TARGETS	${target}
        LIBRARY		DESTINATION lib ${installCompArg}
        ARCHIVE		DESTINATION lib ${installCompArg}	
        RUNTIME 	DESTINATION bin ${installCompArg}	
        RESOURCE 	DESTINATION bin/${Inst${target}_RSC_FILE_ADD}
    )
    
    if(Inst${target}_INSTALL_PDB)
        if(DEFINED CMAKE_BUILD_TYPE)						## for make/nmake based
            installPDB(${target} ${CMAKE_BUILD_TYPE} LIBRARY_DEST lib ARCHIVE_DEST lib RUNTIME_DEST bin)
        endif()
        foreach(CONFIG_TYPES ${CMAKE_CONFIGURATION_TYPES}) 	## for multi config types (MSVC based)
            installPDB(${target} ${CONFIG_TYPES}  LIBRARY_DEST lib ARCHIVE_DEST lib RUNTIME_DEST bin)
        endforeach()
    endif()
    
    ## try to detect Qt5 dependencies, if found, install will take it into concideration (BIN path and plugins for STANDALONE mode)
    get_target_property(linkLibs ${target} LINK_LIBRARIES)
    foreach(lib ${linkLibs})
        if(TARGET ${lib})
            get_target_property(imported ${lib} IMPORTED)
            if(imported)
                string(REGEX MATCH "Qt5::[A-Za-z_:/.0-9-]+" Qt5Target ${lib})
                if(Qt5Target)
                    list(APPEND Qt5Components ${Qt5Target} )
                endif()
            endif()
        endif()
    endforeach()
    if(Qt5Components)
        include(Qt5ImportedLocation)
        if(NOT Inst${target}_QT5_PLUGINS)
            set(Inst${target}_QT5_PLUGINS ${Qt5Gui_PLUGINS})
        endif()
        Qt5ImportedLocation(QT5_DYN_LIB_DIR QT5_DYN_LIBS QT5_PLUGINS_FILESPATHS 
            QT5_COMPONENTS  ${Qt5Components}
            QT5_PLUGINS     ${Inst${target}_QT5_PLUGINS}
        )
        ## Create Qt5 qt.conf to specify where plugins will be installed (default plugins installed (if STANDALONE is set) are Qt5Gui_PLUGINS)
        if(QT5_PLUGINS_FILESPATHS)
            set(QT_PLUGIN_DIR_NAME Qt5Plugins)
            if(NOT EXISTS ${CMAKE_BINARY_DIR}/qt.conf)
                file(WRITE ${CMAKE_BINARY_DIR}/qt.conf "[Paths]\nPlugins=${QT_PLUGIN_DIR_NAME}")
            endif()
            install(FILES ${CMAKE_BINARY_DIR}/qt.conf DESTINATION bin ${installCompArg})
            set(Qt5PluginsInstallArgs PLUGIN_PATH_NAME ${QT5_PLUGINS_FILESPATHS} FROM_REL_PATH plugins PLUGIN_PATH_DEST bin/${QT_PLUGIN_DIR_NAME}) ## Qt5 plugins will be installed here
        endif()
    endif()
    
    ## install dynamic necessary dependencies
    if(Inst${target}_STANDALONE)
        get_target_property(type ${target} TYPE)
        if(${type} MATCHES "EXECUTABLE")
        
            if(Inst${target}_VERBOSE)
                set(VERBOSE VERBOSE)
            else()
                set(VERBOSE )
            endif()
            get_target_property(dPostfix 	${target} DEBUG_POSTFIX)
            get_target_property(rwdiPostfix ${target} RELWITHDEBINFO_POSTFIX)
            get_target_property(mzrPostfix 	${target} MINSIZEREL_POSTFIX)
            install_runtime(bin/${target}${CMAKE_EXECUTABLE_SUFFIX} ## default relative to CMAKE_INSTALL_PREFIX
                ${VERBOSE}
                TARGET              ${target}
                ${installCompArg}
                PLAUSIBLES_POSTFIX	"${dPostfix}" "${rwdiPostfix}" "${mzrPostfix}"
                PLUGINS	## will be installed
                    ${Qt5PluginsInstallArgs}
                    ${Inst${target}_PLUGINS}
                DIRS				${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
                                    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}
                                    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}
                                    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO}
                                    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL}
                                    ${QT5_DYN_LIB_DIR}
                                    ${Inst${target}_DIRS}
            )
        else()
            message(WARNING "STANDALONE option is only compatible with EXECUTABLES target type. Skip the STANDALONE installation process.")
        endif()
    endif()
    
    ## Provide a way to directly load the MSVC debugger with correct settings
    if(MSVC)
        if(Inst${target}_MSVC_CMD)  ## command absolute filePathName is optional as the default is to use the installed target file application
            set(msvcCmdArg  COMMAND ${Inst${target}_MSVC_CMD}) ## flag following by the value (both to pass to the MSVCsetUserCommand function)
        endif()
        if(Inst${target}_MSVC_ARGS) ## args (between quotes) are optional
            set(msvcArgsArg ARGS ${Inst${target}_MSVC_ARGS})   ## flag following by the value (both to pass to the MSVCsetUserCommand function)
        endif()
        get_target_property(type ${target} TYPE)
        if( (Inst${target}_MSVC_CMD OR Inst${target}_MSVC_ARGS) OR (${type} MATCHES "EXECUTABLE") )        
            include(MSVCsetUserCommand)
            MSVCsetUserCommand(	${target}
                PATH 			"${CMAKE_INSTALL_PREFIX}/bin" ##FILE option not necessary since it deduced from targetName
                ${msvcCmdArg}
                ${msvcArgsArg}
                WORKING_DIR		"${CMAKE_INSTALL_PREFIX}/bin"
            )
        elseif(NOT ${type} MATCHES "EXECUTABLE")
            #message("Cannot set MSVCsetUserCommand with target ${target} without COMMAND parameter as it is not an executable (skip it)")
        endif()
    endif()
    
endmacro()