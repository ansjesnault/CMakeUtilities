## CMAKE_DOCUMENTATION_START project_tools.cmake 
##  Contain whole macro users can use in CMakeLists.txt for their project.
##  \\li see \\ref project_init to init variables from your top CMakeLists.txt project. 
##  \\li see \\ref project_add to add a sub-project from your sub-CMakeLists.txt. 
##  \\li see \\ref project_install to install target(s) from your sub-project. 
##  \\li see \\ref project_export to export your project to be used by other projects. 
##  \\li see \\ref project_cpack to package your project with cpack.
##
## \\b Exemple of using the whole necessary macros inside a cmake project : \\n
##\\n
## In your top root CMakeLists.txt :
## \\code
##
##  cmake_minimum_required(VERSION 2.8)                                                             \n
##  project(YOUR_PROJECT_TREE)                                                                      \n
##  list(APPEND CMAKE_MODULE_PATH "\${CMAKE_SOURCE_DIR}/cmake"                                      \n 
##      "\${CMAKE_SOURCE_DIR}/cmaketools")                                                          \n
##      "\${CMAKE_SOURCE_DIR}/cmaketools/finders")                                                  \n
##      "\${CMAKE_SOURCE_DIR}/cmaketools/macros")                                                   \n
##      "\${CMAKE_SOURCE_DIR}/cmaketools/projectUtilities")                                         \n
##  option(VERBOSE "Verbose execution" false)                                                       \n
##                                                                                                  \n
##  <add your options, resolve dependencies and add_definitions here>                               \n
##  find_package( <PACKAGE> )                                                                       \n
##  add_definitions(-DHAS_<PACKAGE>)                                                                \n
##                                                                                                  \n
## <here we start to use our macros with concrete examples>                                         \n
## include(project_tools)                                                                           \n
## project_init(\${CMAKE_PROJECT_NAME} 0 5 0                                                        \n
##    RPATH               true                                                                      \n
##    EXPORT_DEFINTIONS   \${CMAKE_BINARY_DIR}/include/Config.h                                     \n
##    EXPORT              myProject                                                                 \n
##    VERBOSE                                                                                       \n
## )                                                                                                \n
##                                                                                                  \n
## include_directories(                                                                             \n
##        \${CMAKE_SOURCE_DIR}/src       <your source dir>                                          \n
##        \${CMAKE_SOURCE_DIR}/src/libs  <your source libs dir>                                     \n
##        \${CMAKE_BINARY_DIR}/include   <your binary include dir, to use Config.h in your code>    \n
## )                                                                                                \n
## add_subdirectory(src) <cmake enter and process in all sub-dir => sub-project>                    \n
## project_export(\${CMAKE_PROJECT_NAME} <YOUR_PACKAGE_NAME> <YOUR_LOWER_CASE_PACKAGE_NAME>-config.cmake)\n
##
## \\endcode
##
##\\n
##
## In your libs subproject dir CMakeLists.txt :
## \\code
##
## project_add(<YOUR_SUBPROJECT> LIBS VERBOSE)          \n
## list(APPEND \${PROJECT_NAME}_HEADERS <YOUR_HEADERS>) \n
## list(APPEND \${PROJECT_NAME}_HEADERS <YOUR_SOURCES>) \n
## add_library(<YOUR_TARGET, generaly \${PROJECT_NAME}> \${\${PROJECT_NAME}_HEADERS} \${\${PROJECT_NAME}_SOURCES})\n
## target_link_libraries(<YOUR_TARGET, generaly \${PROJECT_NAME}> <PATH_FILE_LIB FOUND ABOVE>\n
## project_install(\${PROJECT_NAME} <YOUR_TARGET, generaly \${PROJECT_NAME}>)\n
##
## \\endcode
## CMAKE_DOCUMENTATION_END

if(_PROJECT_TOOLS_CMAKE_INCLUDED_)
  return()
endif()
set(_PROJECT_TOOLS_CMAKE_INCLUDED_ true)

cmake_minimum_required(VERSION 2.8.4)

## CMAKE_DOCUMENTATION_START cmakeProjectUtilitiesPath
## Global variable use in \\ref project_tools as internal variable. \\n
## Where we can find the whole file utilities used by macros/functions indide \\ref project_tools file.\\n
## note: \\n
##  \\li Important for \\ref project_add macro which requierd Export.h.in file (see \\ref Export).
##  \\li Important for \\ref project_export macro which requierd PackageConfig.cmake.in file (see \\ref PackageConfig) and UsePackage.cmake.in file (see \\ref UsePackage)..
## CMAKE_DOCUMENTATION_END
set(cmakeProjectUtilitiesPath "${CMAKE_SOURCE_DIR}/cmaketools/projectUtilities")

include(${CMAKE_ROOT}/Modules/CMakeParseArguments.cmake)

## CMAKE_DOCUMENTATION_START project_init 
##  usage: \\b FIRST. The initialisation of the version, outputs paths,
##  rpath and export variables for the project.
##  \\code
##  project_init(<masterProjectName> <version_major> <version_minor> <version_build> \n
##      [RPATH]             <bool>                      \n
##      [EXPORT_DEFINTIONS] <PathFileNameDestination>   \n
##      [EXPORT]            <exportProjectName>         \n
##      [VERBOSE]                                       \n
##  )
##  \\endcode
##  MUST be used only ONCE and BEFORE all others PROJECT_* macros.                      \\n
##  All varibales set in this macro are global (availables anywhere in CMakeLists.txt). \\n
##  This means that you can redefine a variable to overload its value => be carefule!   \\n
##\\n
##
## This MACRO DEFINE :
##  \\li VERSION_MAJOR
##  \\li VERSION_MINOR
##  \\li VERSION_BUILD
##  \\li VERSION
##  \\li SOVERSION
##  \\li LIB_POSTFIX
##  \\li LIBRARY_OUTPUT_DIRECTORY set to lib[64] under linux and bin under windows AND its CMAKE_LIBRARY_OUTPUT_DIRECTORY
##  \\li ARCHIVE_OUTPUT_DIRECTORY set to lib[64] AND its CMAKE_ARCHIVE_OUTPUT_DIRECTORY
##  \\li RUNTIME_OUTPUT_DIRECTORY set to bin AND its CMAKE_RUNTIME_OUTPUT_DIRECTORY
## \\n\\n
##
## This MACRO use params :
##  \\li    masterProjectName is only used as internal varibale (use \${CMAKE_PROJECT_NAME} ).
##  \\li    version_major, version_minor, version_build are version used by \\ref project_install
##          from any sub-project to install all project target.
##  \\li    RPATH option is used for UNIX system to allow executables/dynamics_libraries to 
##          find requiered files (before looking for environement varibale).
##  \\li    EXPORT_DEFINITION call \\ref project_export_definitions to write a file which
##          contain all project definitions.
##  \\li    EXPORT allow to set the global variable EXPORT_PROJECT_NAME which is used by
##          \\ref project_install from any sub-project and \\ref project_export to export
##          all project targets in a cmake file for using by another project. 
##
## CMAKE_DOCUMENTATION_END
MACRO(PROJECT_INIT masterProjectName version_major version_minor version_build)

    ##params: "PREFIX" "optionsArgs" "oneValueArgs" "multiValueArgs"
    cmake_parse_arguments(${masterProjectName}_INIT "VERBOSE" "EXPORT;RPATH;EXPORT_DEFINTIONS" "" ${ARGN} )

    ## VERSION variables (globals)
    set(VERSION_MAJOR ${version_major}) # can use CMAKE_MAJOR_VERSION ?
    set(VERSION_MINOR ${version_minor}) # can use CMAKE_MINOR_VERSION ?
    set(VERSION_BUILD ${version_build}) # can use CMAKE_PATCH_VERSION ?
    # and can use CMAKE_TWEAK_VERSION ?
    set(SOVERSION     "${VERSION_MAJOR}.${VERSION_MINOR}") # can use CMAKE_VERSION instead of VERSION?
    set(VERSION   "${VERSION_BUILD}")
    add_definitions(-DVERSION_MAJOR=${VERSION_MAJOR} -DVERSION_MINOR=${VERSION_MINOR} -DVERSION=${VERSION})

    ## POSTFIX for lib dir
    if(UNIX AND NOT WIN32 AND NOT APPLE)
      if(CMAKE_SIZEOF_VOID_P MATCHES "8")
          set(LIB_POSTFIX "64" CACHE STRING "suffix for 32/64 dir placement")
          mark_as_advanced(LIB_POSTFIX)
      endif()
    endif()
    if(NOT DEFINED LIB_POSTFIX)
        set(LIB_POSTFIX "")
    endif()

    ## OUTPUT paths
    set(PUBLIC_HEADER_OUTPUT_PREFIX include)
    if(WIN32)
      set(RUNTIME_OUTPUT_DIRECTORY bin)
      set(LIBRARY_OUTPUT_DIRECTORY bin)
      set(ARCHIVE_OUTPUT_DIRECTORY lib)
    else()
      set(RUNTIME_OUTPUT_DIRECTORY bin)
      set(LIBRARY_OUTPUT_DIRECTORY lib${LIB_POSTFIX})
      set(ARCHIVE_OUTPUT_DIRECTORY lib${LIB_POSTFIX})
    endif()
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY    ${CMAKE_BINARY_DIR}/${LIBRARY_OUTPUT_DIRECTORY})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY    ${CMAKE_BINARY_DIR}/${ARCHIVE_OUTPUT_DIRECTORY})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY    ${CMAKE_BINARY_DIR}/${RUNTIME_OUTPUT_DIRECTORY})
    
    ## the RPATH to be used when installing, but only if it's not a system directory
    if(DEFINED ${masterProjectName}_INIT_RPATH)
        set(CMAKE_INSTALL_RPATH_USE_LINK_PATH true)
    else()
        set(CMAKE_SKIP_RPATH true)
    endif()
    if(UNIX AND CMAKE_INSTALL_RPATH_USE_LINK_PATH AND NOT CMAKE_SKIP_RPATH)
        list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES 
            "${CMAKE_INSTALL_PREFIX}/${LIBRARY_OUTPUT_DIRECTORY}" isSystemDir 
        )
        if("${isSystemDir}" STREQUAL "-1")
           list(APPEND CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${LIBRARY_OUTPUT_DIRECTORY}")
        endif()
    endif()

    ## create a header config file which contain all definitions
    if(DEFINED ${masterProjectName}_INIT_EXPORT_DEFINTIONS)
        project_export_definitions(${${masterProjectName}_INIT_EXPORT_DEFINTIONS})
    endif()

    ## define EXPORT_PROJECT_NAME variable for later use by PROJECT_EXPORT macro
    if(DEFINED ${masterProjectName}_INIT_EXPORT)
        set(EXPORT_PROJECT_NAME "${${masterProjectName}_INIT_EXPORT}")
    endif()

    ## verbosity
    if(${masterProjectName}_INIT_VERBOSE)
        message(STATUS "The project ${masterProjectName} have : ")
        message(STATUS "    VERSION : ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_BUILD}")
        message(STATUS "    OUTPUT LIBRARY : ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
        message(STATUS "    OUTPUT ARCHIVE : ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
        message(STATUS "    OUTPUT RUNTIME : ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
        if(UNIX AND CMAKE_INSTALL_RPATH_USE_LINK_PATH)
            message(STATUS "    Use RPATH : ${CMAKE_INSTALL_RPATH}")
        endif()
        if(DEFINED ${masterProjectName}_INIT_EXPORT_DEFINTIONS)
            message(STATUS "    HAVE PROJECT DEFINITIONS here : ${${masterProjectName}_INIT_EXPORT_DEFINTIONS}")
        endif()
        if(DEFINED ${masterProjectName}_INIT_EXPORT)
            message(STATUS "EXPORT ${${masterProjectName}_INIT_EXPORT} project")
            message(STATUS "You can use the PROJECT_EXPORT macro")
        endif()
    endif()

ENDMACRO()


###############################################################################


## CMAKE_DOCUMENTATION_START project_export_definitions 
##
## Depend of variables set into project_init macro but can still be use independently using options.\\n
## Create or append a file with pathName : <PathFileNameDestination> 
## which will contain all project definitions variables (header extension file is expected)\\n
##  \\code
##  project_export_definitions(<PathFileNameDestination>\n
##  VERSION_MAJOR       <numberMajor> \n
##  VERSION_MINOR       <numberMinor> \n
##  VERSION_BUILD       <numberBuild> \n
##  VERBOSE
##)
##  \\endcode
##\\n
## Write VERSION definition :
##      \\li    #define VERSION_MAJOR \${VERSION_MAJOR}
##      \\li    #define VERSION_MINOR \${VERSION_MINOR}
##      \\li    #define VERSION_BUILD \${VERSION_BUILD}
##      \\li    #define VERSION \${VERSION}.\${VERSION_BUILD}
##\\n
## Write then all definitions found from COMPILE_DEFINITIONS cmake property 
## (#define HAS_* and so on...)\\n
##\\n
## So you have to call this function after all your add_definition() command
## to have a complete list of définitions!\\n
## This function is used in \\ref project_init.
## So, if you call the \\ref project_init with the correct option and after all your add_definition instructions, 
## you don't need to use this function.
##\\n
## Make sure your <PathFileNameDestination> directory is part of your
## include_directories to use it in your code! \n
##
## note: To know if we have to append the file with these informations
## (or if not necessary), we looking for the matching regex expression :
## "Generated by cmake" in the file.
##
##  If you won't use the project_init macros but want to use this project_export_definitions interesting feature, 
##  you have to set the following options variables before call this macro or use directly theses additional options : \\n
##  * VERSION_MAJOR       <numberMajor>     \\n
##  * VERSION_MINOR       <numberMinor>     \\n
##  * VERSION_BUILD       <numberBuild>   
##
## CMAKE_DOCUMENTATION_END
FUNCTION(PROJECT_EXPORT_DEFINITIONS PathFileNameDestination)

    ##params: "PREFIX" "optionsArgs" "oneValueArgs" "multiValueArgs"
    cmake_parse_arguments(${projectName}_INSTALL "VERBOSE" "VERSION_MAJOR;VERSION_MINOR;VERSION_BUILD" "" ${ARGN} )
           
           
    #####################
    ## Set infos to write
    #####################       
    list(APPEND definitionsToWrite "//Generated by cmake - start\n//Set project VERSION/DEFINITIONS\n")

    ## set project version
    # check the variables needed but not necessary for this function
    if(NOT DEFINED VERSION_MAJOR OR NOT DEFINED VERSION_MINOR OR NOT DEFINED VERSION_BUILD) # first check variables from project_init
        if(    NOT DEFINED ${projectName}_INSTALL_VERSION_MAJOR
            OR NOT DEFINED ${projectName}_INSTALL_VERSION_MINOR
            OR NOT DEFINED ${projectName}_INSTALL_VERSION_BUILD ) # second check variables from options
            message(WARNING "From PROJECT_EXPORT_DEFINITIONS( ${PathFileNameDestination} : ")
            message("You have not set all VERSION_* variables.")
            message("The result ${PathFileNameDestination} will not contain VERSION informations")
        endif()
    endif()
    list(APPEND definitionsToWrite 
        "#define VERSION_MAJOR ${VERSION_MAJOR}\n"
        "#define VERSION_MINOR ${VERSION_MINOR}\n"
        "#define VERSION_BUILD ${VERSION_BUILD}\n"
        "#define VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_BUILD}\n\n"
    )

    ## set project definitions
    get_directory_property(cmakeProjectDefinitions COMPILE_DEFINITIONS)
    foreach(cmakeProjectDef ${cmakeProjectDefinitions})
        list(APPEND definitionsToWrite "#define ${cmakeProjectDef}\n")
    endforeach()
    
    list(APPEND definitionsToWrite "//Generated by cmake - end\n")
    string(REGEX REPLACE ";" "" definitionsToWrite "${definitionsToWrite}") ## to remove ; at each line
    
    
    #####################
    ## Get other infos than definition/version from this file
    #####################
    if(EXISTS "${PathFileNameDestination}")
        file(READ ${PathFileNameDestination} fileContent)
        set(sectionStarted false)
        string(REGEX REPLACE "\r?\n" ";" fileContent "${fileContent}")
        foreach(line ${fileContent})

            ## find the start balise
            string(REGEX MATCH "Generated by cmake - start" matchStart ${line})
            if( matchStart AND NOT sectionStarted )
                set(sectionStarted true)
            endif()

            ## find the end balise
            string(REGEX MATCH "Generated by cmake - end" matchEnd ${line})
            if( matchEnd AND sectionStarted )
                set(sectionStarted false)
            endif()

            ## Extract info between balises
            if( sectionStarted AND NOT matchStart AND NOT matchEnd)
                list(APPEND definitionContent ${line})
            elseif(NOT sectionStarted AND NOT matchStart AND NOT matchEnd)
                list(APPEND otherInfoContent ${line})
            endif()

        endforeach()
        string(REGEX REPLACE ";" "" definitionContent "${definitionContent}") ## to remove ; at each line
        string(REGEX REPLACE ";" "\n" otherInfoContent "${otherInfoContent}") ## to remove ; at each line
    endif()
    
    #####################
    ## Re-write file
    #####################
    file(WRITE ${PathFileNameDestination} "${definitionsToWrite}\n\n${otherInfoContent}")

ENDFUNCTION()


###############################################################################

## CMAKE_DOCUMENTATION_START project_append_output_path 
##
## Depend of variables set into project_init macro
## When you have called the \\ref project_init once, some cmake output paths varibales
## are set like the : 
##  \\li PUBLIC_HEADER_OUTPUT_PREFIX to include
##  \\li LIBRARY_OUTPUT_DIRECTORY to lib or lib64 or bin (wind)
##  \\li ARCHIVE_OUTPUT_DIRECTORY to lib or lib64
##  \\li RUNTIME_OUTPUT_DIRECTORY to bin
##  This macro allow to change these variables with an additional subdirectory.\\n
##
## \\code
## project_append_output_path( <masterProjectName>\n
##  [LIBRARY_DIR additionalDir] \n
##  [ARCHIVE_DIR additionalDir] \n
##  [RUNTIME_DIR additionalDir] \n
##  [INCLUDE_DIR additionalDir] \n
##  [VERBOSE] \n
## )
## \\endcode
## additionalDir variables are interpreted as relative to the *_OUTPUT_DIRECTORY variables.
## masterProjectName is only used as internal varibale (you can use \\${CMAKE_PROJECT_NAME} ).
##
## CMAKE_DOCUMENTATION_END
MACRO(PROJECT_APPEND_OUTPUT_PATH masterProjectName)
    
    ##params: "PREFIX" "optionsArgs" "oneValueArgs" "multiValueArgs"
    cmake_parse_arguments(${masterProjectName}_OUT_PATH "VERBOSE" "LIBRARY_DIR;ARCHIVE_DIR;RUNTIME_DIR;INCLUDE_DIR" "" ${ARGN} )

    if(${masterProjectName}_OUT_PATH_VERBOSE)
        message(STATUS "Change output path : (from ${CMAKE_CURRENT_LIST_FILE}) ")
    endif()

    if(${masterProjectName}_OUT_PATH_LIBRARY_DIR)
        set(LIBRARY_OUTPUT_DIRECTORY ${LIBRARY_OUTPUT_DIRECTORY}/${${masterProjectName}_OUT_PATH_LIBRARY_DIR})   
        set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${LIBRARY_OUTPUT_DIRECTORY})
        if(${masterProjectName}_OUT_PATH_VERBOSE)
            message(STATUS " new CMAKE_LIBRARY_OUTPUT_DIRECTORY = ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
        endif()
    endif()

    if(${masterProjectName}_OUT_PATH_ARCHIVE_DIR)
        set(ARCHIVE_OUTPUT_DIRECTORY ${ARCHIVE_OUTPUT_DIRECTORY}/${${masterProjectName}_OUT_PATH_ARCHIVE_DIR})   
        set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${ARCHIVE_OUTPUT_DIRECTORY})
        if(${masterProjectName}_OUT_PATH_VERBOSE)
            message(STATUS " new CMAKE_ARCHIVE_OUTPUT_DIRECTORY = ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
        endif()
    endif()

    if(${masterProjectName}_OUT_PATH_RUNTIME_DIR)
        set(RUNTIME_OUTPUT_DIRECTORY ${RUNTIME_OUTPUT_DIRECTORY}/${${masterProjectName}_OUT_PATH_RUNTIME_DIR})   
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${RUNTIME_OUTPUT_DIRECTORY})
        if(${masterProjectName}_OUT_PATH_VERBOSE)
            message(STATUS " new CMAKE_RUNTIME_OUTPUT_DIRECTORY = ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
        endif()
    endif()

    if(${masterProjectName}_OUT_PATH_INCLUDE_DIR)
        set(PUBLIC_HEADER_OUTPUT_PREFIX ${PUBLIC_HEADER_OUTPUT_PREFIX}/${${masterProjectName}_OUT_PATH_INCLUDE_DIR})
        if(${masterProjectName}_OUT_PATH_VERBOSE)
            message(STATUS " new PUBLIC_HEADER_OUTPUT_PREFIX = ${PUBLIC_HEADER_OUTPUT_PREFIX}")
        endif()
    endif()

ENDMACRO()


###############################################################################


## CMAKE_DOCUMENTATION_START project_add 
##  Usage: \\b SECOND. Add a sub-project.\\n
##  This macro can be used independently from other macro from this file.
##  \\code
##  project_add(<projectName> [LIBS | APPS | PLUGINS] [VERBOSE])
##  \\endcode
##  Use instead of the project(<name>) cmake command when you want to add a new sub-project.    \\n
##  The projectName is follow by the <TYPE> of project (LIBS, APPS, PLUGINS).                   \\n
## CMAKE_DOCUMENTATION_END
MACRO(PROJECT_ADD projectName)

    ##params: "PREFIX" "optionsArgs" "oneValueArgs" "multiValueArgs"
    cmake_parse_arguments(${projectName}_ADD "APPS;LIBS;PLUGINS;VERBOSE" "" "" ${ARGN} )
    
    project(${projectName}) # define PROJECT_NAME cmake variable to ${projectName}

ENDMACRO()


###############################################################################


## CMAKE_DOCUMENTATION_START Export.h.in
##  Used by \\ref project_install from \\ref project_tools to handle windows visual studio import/export.\\n
##  Under Windows, for shared libraries (DLL) we need to define export on
##  compilation or import on use (like a third party project).                                       \\n
##  We exploit here the fact that cmake auto set xxx_EXPORTS (with S) on compilation.
## CMAKE_DOCUMENTATION_END


###############################################################################


## CMAKE_DOCUMENTATION_START project_install 
##  Usage: \\b THIRD. Installation stuff for your target in your sub-project.\\n
##  Depend of variables set into \\ref project_add macro.
##  \\code
##  project_install(<projectName> <target> [VERBOSE])
##  \\endcode
##  Use this macro at the end of your sub-project CMakeLists.txt file.  \\n
##  It use variables set by \\ref project_init                         \\n
##  For CMAKE VERSION after 2.8.6, this macro generate an export header file to deal with C++ WIN32 export symboles. \\n
##  For CMAKE VERSION before 2.8.6, see \\ref project_add to add the export header file. \\n
##  Allow to versionning the target.                                \\n
##  Allow to postfix all output target name according to what configuration is being built.
##  (it also append all executables targets name because by default cmake use it for libraries targets but not for executable). \\n
##    This macro define : \\n
##    CMAKE_DEBUG_POSTFIX to "d" for CMAKE_BUILD_TYPE=debug;\\n
##    CMAKE_RELEASE_POSTFIX to "" for CMAKE_BUILD_TYPE=Release;\\n
##    CMAKE_RELWITHDEBINFO_POSTFIX to "" for CMAKE_BUILD_TYPE=RelWithDebInfo;\\n
##    CMAKE_MINSIZEREL_POSTFIX to "" for CMAKE_BUILD_TYPE=MinSizeRel;\\n
##  Allow to define install destination.                            \\n
##  Allow to export this target if we found an exportProjectName.   \\n
##  TODO : 
##  \\li Custom DESTINATION as parameter?
##  \\li COMPONENT option ?
##  \\li add set_target_properties( <targetName> PROPERTIES <INSTALL_RPATH> <pathsList>) ?
##  \\li remove Export.h.in which is now deprecated since cmake 2.8.6 from project_add  and keep generate_export_header macro
## CMAKE_DOCUMENTATION_END
MACRO(PROJECT_INSTALL projectName target)
    
    ##params: "PREFIX" "optionsArgs" "oneValueArgs" "multiValueArgs"
    cmake_parse_arguments(${projectName}_INSTALL "VERBOSE" "" "" ${ARGN} )
    
    if(${projectName}_INSTALL_VERBOSE)
        message(STATUS "project_install The target ${target} : ")
    endif() 
    

    get_target_property(TARGET_TYPE ${target} TYPE)


    string(TOUPPER ${target} target_name_uc) # used in Export.h.in
    string(TOLOWER ${target} target_name_lc)
    ## here we deal with export/import dll under windows (cmake > 2.8.6)
    # generate_export_header function can only be used with libraries
    if(${TARGET_TYPE} STREQUAL "STATIC_LIBRARY" OR ${TARGET_TYPE} STREQUAL "SHARED_LIBRARY")

        if(${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.${CMAKE_PATCH_VERSION} VERSION_GREATER 2.8.5)
            if(${projectName}_INSTALL_VERBOSE)
                message(STATUS "CMake version greater than 2.8.4, use GenerateExportHeader macro") # introduce into 2.8.6
            endif()
            include(GenerateExportHeader)
            # default target name lower case to define the export file name
            # default target upper case to define the export macro name in the generated file
            generate_export_header(${target})

            # Trick: centralise all files into ${CMAKE_BINARY_DIR}/include
            configure_file( ${CMAKE_CURRENT_BINARY_DIR}/${target_name_lc}_export.h
                            ${CMAKE_BINARY_DIR}/include/${target_name_lc}_export.h
                            COPYONLY )
            execute_process(COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/${target_name_lc}_export.h)
        else()
            configure_file(${cmakeProjectUtilitiesPath}/Export.h.in ${CMAKE_BINARY_DIR}/include/${target_name_lc}_export.h @ONLY )
        endif()

        install(FILES ${CMAKE_BINARY_DIR}/include/${target_name_lc}_export.h DESTINATION ${PUBLIC_HEADER_OUTPUT_PREFIX}/${projectName})

    endif()
    # UGLY: TODO: remove : we should not export the header file for plugins !
    if(${TARGET_TYPE} STREQUAL "MODULE_LIBRARY")
        configure_file(${cmakeProjectUtilitiesPath}/Export.h.in ${CMAKE_BINARY_DIR}/include/${target_name_lc}_export.h @ONLY )
    endif()


    ## handle install version for all target type          
    set_target_properties(${target} PROPERTIES
        VERSION "${VERSION}"
        SOVERSION "${SOVERSION}"    # set by project_init MACRO
    )
    

    ## handle build/install postfix extension according to what configuration is being built.
    set(CMAKE_DEBUG_POSTFIX "d")            # for CMAKE_BUILD_TYPE=Debug
    set(CMAKE_RELEASE_POSTFIX "")           # for CMAKE_BUILD_TYPE=Release
    set(CMAKE_RELWITHDEBINFO_POSTFIX "")    # for CMAKE_BUILD_TYPE=RelWithDebInfo
    set(CMAKE_MINSIZEREL_POSTFIX "")        # for CMAKE_BUILD_TYPE=MinSizeRel
    if(CMAKE_BUILD_TYPE)
        string(TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_UC )
    else()
        set(${CMAKE_BUILD_TYPE} "")
    endif()
    if(CMAKE_BUILD_TYPE MATCHES "Debug")
        add_definitions(-DDEBUG)
    endif()
    # CMAKE_<CONFIG>_POSTFIX is not used for the executable output name, we take into account here
    set_target_properties(${target} PROPERTIES
        OUTPUT_NAME_${CMAKE_BUILD_TYPE_UC} "${target}${CMAKE_${CMAKE_BUILD_TYPE_UC}_POSTFIX}"
    )

    ## VERBOSITY install prop
    if(${projectName}_INSTALL_VERBOSE)
        get_target_property(TARGET_NAME ${target} OUTPUT_NAME_${CMAKE_BUILD_TYPE_UC})
        message(STATUS "   output name : ${TARGET_NAME}")
        message(STATUS "   version : ${VERSION}.${SOVERSION}")
    endif()
    

    ## handle HEADER destination
    set_target_properties(${target} PROPERTIES
        PUBLIC_HEADER "${${projectName}_HEADERS}" # set by project_add macro 
    )
    

    ## handle installation destination
    if(EXPORT_PROJECT_NAME)
        set(EXPORT_PROJECT_NAME_COMMAND EXPORT ${EXPORT_PROJECT_NAME}) # set by project_init MACRO
        if(${projectName}_INSTALL_VERBOSE)
            message(STATUS "   will be export for ${EXPORT_PROJECT_NAME}")
        endif()
    else()
        set(EXPORT_PROJECT_NAME_COMMAND "")
    endif()
    # install relative to the value of CMAKE_INSTALL_PREFIX
    # following variables are used from the macro projet_init
    install(TARGETS ${target}
            ${EXPORT_PROJECT_NAME_COMMAND}
            RUNTIME DESTINATION ${RUNTIME_OUTPUT_DIRECTORY}
            LIBRARY DESTINATION ${LIBRARY_OUTPUT_DIRECTORY}
            ARCHIVE DESTINATION ${ARCHIVE_OUTPUT_DIRECTORY}
            PUBLIC_HEADER DESTINATION ${PUBLIC_HEADER_OUTPUT_PREFIX}/${projectName}
    )


    ## VERBOSITY install dest
    if(${projectName}_INSTALL_VERBOSE)
        if(${TARGET_TYPE} STREQUAL "STATIC_LIBRARY")   
                message(STATUS "   will be install in ${CMAKE_INSTALL_PREFIX}/${ARCHIVE_OUTPUT_DIRECTORY}")        
        elseif(${TARGET_TYPE} STREQUAL "SHARED_LIBRARY" OR ${TARGET_TYPE} STREQUAL "MODULE_LIBRARY")
                message(STATUS "   will be install in ${CMAKE_INSTALL_PREFIX}/${LIBRARY_OUTPUT_DIRECTORY}")
        elseif(${TARGET_TYPE} STREQUAL "EXECUTABLE")
                message(STATUS "   will be install in ${CMAKE_INSTALL_PREFIX}/${RUNTIME_OUTPUT_DIRECTORY}")
        endif()
        message(STATUS "   will generate headers in ${CMAKE_INSTALL_PREFIX}/${PUBLIC_HEADER_OUTPUT_PREFIX}/${projectName}")
    endif()

ENDMACRO()


###############################################################################


## CMAKE_DOCUMENTATION_START project_export 
##  Usage: \\b FOURTH. Export stuff for the project \\n
##  Depend of variables set into project_init macro but can still be used independently if you use options.
##  \\code
##  project_export(<masterProjectName> <packageName> <exportFileName> \n
##  EXPORT_PROJECT_NAME <flagName> \n
##  VERSION_MAJOR       <numberMajor> \n
##  VERSION_MINOR       <numberMinor> \n
##  VERSION_BUILD       <numberBuild> \n
##  VERBOSE
##  )
##  \\endcode
##  Use this macro at the end of your main project CMakeLists.txt file. \\n
##  \\n
##  File \\ref PackageConfig    use variables set by this file. \\n 
##  File \\ref UsePackage       use variables set by this file. \\n 
##  \\n
##  All output cmake files are stored in <project_install_dir>/cmake. \\n
##  Another project will do a find_package(<packageName>) and if it found
##  a <packageName>Config.cmake, the other project just have to 
##  include(\${USE_<packageName>}) to use <packageName>.
##\\n
##  \\li    masterProjectName is only used as internal varibale (use \${CMAKE_PROJECT_NAME} ).
##  \\li    packageName is the final name of your project 
##          (other project should find it by using this name)
##  \\li    exportFileName is the generated cmake file contained the targets
##          which could be find by another project.
##          Generaly it's <lowercase_packageName>-config.cmake.
##\\n
##  It use the EXPORT_PROJECT_FILENAME varible set by \\ref project_init. \\n 
##\\n
##  If you won't use the project_init, project_add, project_install macros but 
##  you want to use this project_export interesting feature, 
##  you have to set the following options variables before call this macro or use directly theses additionals options : \\n
##  * EXPORT_PROJECT_NAME <flagName>      is the name you have to use with install(EXPORT <flageName>) command for your project(s) \\n
##  * VERSION_MAJOR       <numberMajor>     \\n
##  * VERSION_MINOR       <numberMinor>     \\n
##  * VERSION_BUILD       <numberBuild>     
##
## CMAKE_DOCUMENTATION_END
MACRO(PROJECT_EXPORT masterProjectName packageName exportFileName)

    ##params: "PREFIX" "optionsArgs" "oneValueArgs" "multiValueArgs"
    cmake_parse_arguments(${projectName}_EXPORT "VERBOSE" "EXPORT_PROJECT_NAME;VERSION_MAJOR;VERSION_MINOR;VERSION_BUILD" "" ${ARGN} )

    # check the variables needed but not necessary for this macro (Used into UsePackage.cmake.in)
    if(NOT DEFINED VERSION_MAJOR OR NOT DEFINED VERSION_MINOR OR NOT DEFINED VERSION_BUILD) # check first variables from project_init
        if(    NOT DEFINED ${projectName}_EXPORT_VERSION_MAJOR
            OR NOT DEFINED ${projectName}_EXPORT_VERSION_MINOR
            OR NOT DEFINED ${projectName}_EXPORT_VERSION_BUILD ) # check second variables from options
            message(WARNING "From PROJECT_EXPORT( ${masterProjectName} ${packageName} ${exportFileName} : ")
            message("You have not set all VERSION_* variables.")
            message("PROJECT_EXPORT macro will be incompleted and the result Use${packageName}.cmake will not contain VERSION informations")
        endif()
    endif()

    # check the necessary variables for this macro (Used into UsePackage.cmake.in)
    if(NOT EXPORT_PROJECT_NAME)

        message(WARNING "From PROJECT_EXPORT( ${masterProjectName} ${packageName} ${exportFileName} : ")
        message("You have not set the EXPORT_PROJECT_NAME variable (EXPORT option from PROJECT_INIT macro or from this macro).")
        message("PROJECT_EXPORT macro will be ignored.")

    else()
        
        set(PACKAGE_NAME ${packageName})                ## Used into UsePackage.cmake.in
        set(EXPORT_PROJECT_FILENAME ${exportFileName})  ## Used into UsePackage.cmake.in
        install(EXPORT      ${EXPORT_PROJECT_NAME}    ## set from the project_init MACRO or this macro
                DESTINATION cmake
                FILE        ${EXPORT_PROJECT_FILENAME}
        )
        #get_directory_property(DEPS_INCLUDE_DIRS INCLUDE_DIRECTORIES) ## deprecated since we let the user create its own Use<packageName>Dependencies
        # on the other hand, the ${PUBLIC_HEADER_OUTPUT_PREFIX} variable set by project_init macro is used in UsePackage.cmake.in
        configure_file(${cmakeProjectUtilitiesPath}/PackageConfig.cmake.in  cmake/${PACKAGE_NAME}Config.cmake @ONLY)
        configure_file(${cmakeProjectUtilitiesPath}/UsePackage.cmake.in     cmake/Use${PACKAGE_NAME}.cmake @ONLY)
        configure_file(${cmakeProjectUtilitiesPath}/exportReadMe.txt.in     cmake/exportReadMe.txt @ONLY)
        install(FILES  
                    ## file found by find_package(PROJECT) from external project
                    ${CMAKE_BINARY_DIR}/cmake/${PACKAGE_NAME}Config.cmake 
                    ## included by <PROJECT>Config.cmake
                    ${CMAKE_BINARY_DIR}/cmake/Use${PACKAGE_NAME}.cmake
                    ## helper file to understand how to use this generated files
                    ${CMAKE_BINARY_DIR}/cmake/exportReadMe.txt
                DESTINATION cmake
        )

        if( ${projectName}_EXPORT_VERBOSE )
            message(STATUS "From PROJECT_EXPORT macro : ")
            message(STATUS "  - Generate cmake/${PACKAGE_NAME}Config.cmake")
            message(STATUS "  - cmake/Use${PACKAGE_NAME}.cmake")
        endif()

        ## Optional : additional file the user can set to allow find its dependencies into
        if(EXISTS "${CMAKE_SOURCE_DIR}/cmake/Use${PACKAGE_NAME}_Dependencies.cmake.in")
            configure_file( cmake/Use${PACKAGE_NAME}_Dependencies.cmake.in
                            cmake/Use${PACKAGE_NAME}_Dependencies.cmake @ONLY )
            install(FILES 
                    ## deal with embeded 3rdParty in the export project
                    ${CMAKE_BINARY_DIR}/cmake/Use${PACKAGE_NAME}_Dependencies.cmake
                DESTINATION cmake 
            )

            if( ${projectName}_EXPORT_VERBOSE )
                message(STATUS "From PROJECT_EXPORT macro : ")
                message(STATUS "  - Found cmake/Use${PACKAGE_NAME}_Dependencies.cmake.in")
                message(STATUS "  - Generate cmake/Use${PACKAGE_NAME}_Dependencies.cmake")
            endif()

        endif()
                
    endif()

ENDMACRO()


###############################################################################


## CMAKE_DOCUMENTATION_START project_cpack 
##  Usage: \\b FIFTH. package project with CPACK.\\n
##  Depend of variables set into project_init macro.
##  \\code
##  project_cpack(${CMAKE_PROJECT_NAME}     \n
##    [VENDOR              vendorName]      \n
##    [DESCRIPTION         shortDescription]\n
##    [CONTACT             anMailAdress]    \n
##    [URL_INFO            anURL]           \n
##    [DEB_DEPENDS         debianSyntaxDepends] \n
##    [RPM_REQUIRES        rpmSyntaxDepends]    \n
##    [GENERATOR           cpackBuildGenerator] \n
##    [SOURCE_GENERATOR    cpackSourceGenerator]\n
##    [SOURCE_IGNORE_FILES ignoreListPattern]   \n
##)
##  \\endcode
##  Use variables set by \\ref project_init.        \\n
##  masterProjectName is use internaly (use \${CMAKE_PROJECT_NAME} ).\\n
##  Not yet stable... \\n
##  TODO : Have to deal with dependencies...        \\n
## CMAKE_DOCUMENTATION_END 
MACRO(PROJECT_CPACK masterProjectName)
## standard use of CPACK :      http://www.cmake.org/Wiki/CMake:Packaging_With_CPack
## CPACK variables :            http://www.cmake.org/Wiki/CMake:CPackConfiguration
## Specific CPACK variables :   http://www.cmake.org/Wiki/CMake:CPackPackageGenerators

    ##params: "PREFIX" "optionsArgs" "oneValueArgs" "multiValueArgs"
    cmake_parse_arguments(${masterProjectName}_CPACK 
        "VERBOSE"
        "VENDOR;DESCRIPTION;CONTACT;URL_INFO;DEB_DEPENDS;RPM_REQUIRES"
        "GENERATOR;SOURCE_GENERATOR;SOURCE_IGNORE_FILES"
        ${ARGN}
    )

    if(NOT DEFINED ${masterProjectName}_CPACK_VENDOR)
        set(${masterProjectName}_CPACK_VENDOR " ") # default empty
    endif()

    if(NOT DEFINED ${masterProjectName}_CPACK_DESCRIPTION)
        set(${masterProjectName}_CPACK_DESCRIPTION " ") # default empty
    endif()

    if(NOT DEFINED ${masterProjectName}_CPACK_CONTACT)
        set(${masterProjectName}_CPACK_CONTACT " ") # default empty
    endif()

    if(NOT DEFINED ${masterProjectName}_CPACK_URL_INFO)
        set(${masterProjectName}_CPACK_URL_INFO " ") # default empty
    endif()

    if(DEFINED ${masterProjectName}_CPACK_GENERATOR) # default is managed by cmake/cpack (see gui) 
        set(CPACK_GENERATOR ${${masterProjectName}_CPACK_GENERATOR})
    endif()

    if(DEFINED ${masterProjectName}_CPACK_SOURCE_GENERATOR) # default is managed by cmake/cpack (see gui)
        set(CPACK_SOURCE_GENERATOR ${${masterProjectName}_CPACK_SOURCE_GENERATOR}) 
    endif()

    if(NOT DEFINED ${masterProjectName}_CPACK_SOURCE_IGNORE_FILES)
        set(${masterProjectName}_CPACK_SOURCE_IGNORE_FILES ".svn/;.git/;*.gitignore;*.*~")
    endif()
 
    include(InstallRequiredSystemLibraries)

    # from first macro
    set(CPACK_PACKAGE_NAME          "${masterProjectName}")
    set(CPACK_PACKAGE_VERSION_MAJOR "${VERSION_MAJOR}")
    set(CPACK_PACKAGE_VERSION_MINOR "${VERSION_MINOR}")
    set(CPACK_PACKAGE_VERSION_PATCH "${VERSION_BUILD}")
    set(CPACK_PACKAGE_FILE_NAME "${masterProjectName}-${VERSION}.${VERSION_BUILD}")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "${masterProjectName}-${VERSION}")

    # from macro args
    set(CPACK_PACKAGE_VENDOR "${${masterProjectName}_CPACK_VENDOR}")
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY   "${${masterProjectName}_CPACK_DESCRIPTION}")
    #set(CPACK_PACKAGE_DESCRIPTION_FILE      "")
    set(CPACK_PACKAGE_CONTACT "${${masterProjectName}_CPACK_CONTACT}")
    set(CPACK_SOURCE_IGNORE_FILES "${${masterProjectName}_CPACK_SOURCE_IGNORE_FILES}")

    if(WIN32 AND NOT UNIX)
        ## There is a bug in NSIS that does not handle full unix paths properly
        ## Make sure there is at least one set of four (4) backlasshes
        #set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}/share/*.jpg")
        #set(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\ViewerApp.exe")

        #set(CPACK_NSIS_DISPLAY_NAME "${CPACK_PACKAGE_INSTALL_DIRECTORY} My Famous Project")
        #set(CPACK_NSIS_HELP_LINK "http:\\\\\\\\www...")
        #set(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\www...")
        #set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT})
        #set(CPACK_NSIS_MODIFY_PATH ON) # Choice to add prog dir to the system PATH 
        set(CPACK_PACKAGING_INSTALL_PREFIX  "${masterProjectName}" CACHE PATH "Where you want to install your package")
        file(TO_CMAKE_PATH ${CPACK_PACKAGING_INSTALL_PREFIX} CPACK_PACKAGING_INSTALL_PREFIX)
        mark_as_advanced(CPACK_PACKAGING_INSTALL_PREFIX)
    else()
        set(CPACK_PACKAGING_INSTALL_PREFIX  "usr/local" CACHE PATH "Where you want to install your package")
        file(TO_CMAKE_PATH ${CPACK_PACKAGING_INSTALL_PREFIX} CPACK_PACKAGING_INSTALL_PREFIX)
        mark_as_advanced(CPACK_PACKAGING_INSTALL_PREFIX)

        ## RPM variables - use rpm -i <soft>.rpm --nodeps if you want to skeep the dependences search
        ## .rpm using => yum local install <soft>.rpm will find all dependencies listed below
        set(CPACK_RPM_PACKAGE_RELEASE       1)          #default
        set(CPACK_RPM_PACKAGE_LICENSE       "unknow")   #default
        set(CPACK_RPM_PACKAGE_GROUP         "unknow")   #default

        ## deal with dependencies (RPM - DEB)
        if(DEFINED ${masterProjectName}_CPACK_RPM_REQUIRES) #"qt-devel >= 4.7.4, cmake >= 2.8"
            set(CPACK_RPM_PACKAGE_REQUIRES "${${masterProjectName}_CPACK_RPM_REQUIRES}")
        endif()
        if(DEFINED ${masterProjectName}_CPACK_DEB_DEPENDS) #"libc6 (>= 2.3.1-6), libgcc1 (>= 1:3.4.2-12)"
            set(CPACK_DEBIAN_PACKAGE_DEPENDS "${${masterProjectName}_CPACK_DEB_DEPENDS}")
        endif()

    endif()

    if(${masterProjectName}_CPACK_VERBOSE)
        set(CPACK_RPM_PACKAGE_DEBUG 1)
    endif()

    include(CPack)

    message(STATUS "***INFO***: You can try to use custom target: make package.")

ENDMACRO()

