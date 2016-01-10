## Included once for all sub projects.
## It contain the whole cmake instructions to find necessary common dependencies.
## 3rdParty (provided by win3rdParty or from external packages) are then available in cmake sub projects.
##
## Do not include this file more than once but you can modify it to fit to your own project.
## So please, read it carefully because you can use on of these dependencies for your project or appen new one.
##
## As it is included after cmake options, you can use conditional if(<CMAKE_PROJ_OPT>)/endif() to encapsulate your 3rdParty.
##
## Created/updated by jesnault while last cmake version was 3.0.2
if(__dependencies_cmake_INCLUDED__)
	return()
else()
	set(__dependencies_cmake_INCLUDED__ ON)
endif()

## win3rdParty function allowing to auto check/download/update binaries dependencies for current windows compiler
## Please open this file in order to get more documentation and usage examples.
#include(Win3rdParty)


message("")
message(STATUS "[dependencies] Looking for necessary dependencies:")
#Win3rdPartyGlobalCacheAction()



##
## All cmake instructions not inside if BUILD_* condition are common to all projects
##

find_package(OpenGL REQUIRED) ## Not really requiered here since we use the OpenGL from Qt5 (see libls-mini)

if(${USE_RENDERER_API} MATCHES "GLUT")

    ############
    ## Find GLUT
    ############
#    win3rdParty(GLUT #VERBOSE ON
#        MSVC11 "win3rdParty/MSVC11/GLUT" "https://gforge.inria.fr/frs/download.php/file/34358/freeglut-2.8.1.7z"
#        MSVC12 "win3rdParty/MSVC11/GLUT" "https://gforge.inria.fr/frs/download.php/file/34358/freeglut-2.8.1.7z"
#        MULTI_SET
#            CHECK_CACHED_VAR GLUT_ROOT_PATH     PATH    "freeglut-2.8.1"
#            CHECK_CACHED_VAR OPENGL_LIBRARY_DIR PATH    "freeglut-2.8.1/${LIB_BUILT_DIR}/Release"
#            CHECK_CACHED_VAR GLUT_INCLUDE_DIR	PATH    "freeglut-2.8.1/include"
#            CHECK_CACHED_VAR GLUT_glut_LIBRARY	STRING  "freeglut-2.8.1/${LIB_BUILT_DIR}/Release/freeglut.lib"
#    )
    FIND_PACKAGE(GLUT REQUIRED)
    IF(GLUT_FOUND)
        INCLUDE_DIRECTORIES(${GLUT_INCLUDE_DIR})
    ELSE(GLUT_FOUND)
        MESSAGE("GLUT not found. Set GLUT_ROOT_PATH to base directory of GLUT.")
    ENDIF(GLUT_FOUND)


    ############
    ## Find GLEW
    ############
#    win3rdParty(GLEW #VERBOSE ON
#        MSVC11 "win3rdParty/MSVC11/GLEW" "https://gforge.inria.fr/frs/download.php/file/34357/glew-1.10.0.7z"
#        MSVC12 "win3rdParty/MSVC11/GLEW" "https://gforge.inria.fr/frs/download.php/file/34357/glew-1.10.0.7z"
#        MULTI_SET
#            CHECK_CACHED_VAR GLEW_INCLUDE_DIR	    PATH "glew-1.10.0/include" DOC "default empty doc"
#            CHECK_CACHED_VAR GLEW_LIBRARIES         STRING LIST "debug;glew-1.10.0/${LIB_BUILT_DIR}/glew32d.lib;optimized;glew-1.10.0/${LIB_BUILT_DIR}/glew32.lib" DOC "default empty doc"
#    )
    FIND_PACKAGE(GLEW REQUIRED)
    IF(GLEW_FOUND)
        INCLUDE_DIRECTORIES(${GLEW_INCLUDE_DIR})
    ELSE(GLEW_FOUND)
        MESSAGE("GLEW not found. Set GLEW_DIR to base directory of GLEW.")
    ENDIF(GLEW_FOUND)

elseif(${USE_RENDERER_API} MATCHES "QT")

    ############
    ## Find Qt5
    ############
    if(ARCHI_BUILT_DIR MATCHES "x64") ## ARCHI_BUILT_DIR is set in top root CMakeLists.txt
#        win3rdParty(Qt5 TIMEOUT 800 DEFAULT_USE OFF #VERBOSE ON
#                MSVC11 "win3rdParty/MSVC11/Qt5" "https://gforge.inria.fr/frs/download.php/file/34393/Qt5.4-msvc11-x64.7z"
#                MSVC12 "win3rdParty/MSVC11/Qt5" "https://gforge.inria.fr/frs/download.php/file/34393/Qt5.4-msvc11-x64.7z"
#                SET CHECK_CACHED_VAR Qt5_DIR PATH "Qt5.4-msvc11-x64/lib/cmake/Qt5"
#        )
    elseif(ARCHI_BUILT_DIR MATCHES "x86")
#        win3rdParty(Qt5 TIMEOUT 800 DEFAULT_USE OFF #VERBOSE ON
#                MSVC11 "win3rdParty/MSVC11/Qt5" "https://gforge.inria.fr/frs/download.php/file/34394/Qt5.4-mscv11-x86.7z"
#                MSVC12 "win3rdParty/MSVC11/Qt5" "https://gforge.inria.fr/frs/download.php/file/34393/Qt5.4-msvc11-x64.7z"
#                SET CHECK_CACHED_VAR Qt5_DIR PATH "Qt5.4-mscv11-x86/lib/cmake/Qt5"
#        )
    endif()

    ## WORK AROUND with windows : try to auto find and set Qt5_DIR
    if(WIN32)
        file(GLOB qt5versionPathList "C:/Qt/Qt5.*")
        if(NOT Qt5_DIR AND qt5versionPathList)
            list(LENGTH qt5versionPathList qt5versionPathListCount)
            if(${qt5versionPathListCount} GREATER "1")
                message("Many Qt5 version auto detected (check manually the right one with Qt5_DIR cmake variable).")
            endif()
            foreach(qt5versionPath ${qt5versionPathList})
                ## go deep to look for any qt5 install dir (sdk include/lib dirs)
                file(GLOB qt5versionSubPathList "${qt5versionPath}/5.*")
                file(GLOB qt5versionSubPathList "${qt5versionSubPathList}/*")
                if(qt5versionSubPathList)
                    foreach(qt5versionSubPath ${qt5versionSubPathList})
                        get_filename_component(redistArch ${qt5versionSubPath} NAME)
                        string(REGEX MATCH 	"[A-Za-z_0-9-]+64[A-Za-z_0-9-]+" 64archMatched ${redistArch})
                        if(64archMatched)
                            set(qtArch x64)
                        else()
                            set(qtArch x86)
                        endif()
                        message("Plausible Qt5 instllation dir [${qtArch}] : ${qt5versionSubPath}")
                        if(CMAKE_SIZEOF_VOID_P MATCHES "8")
                            if("${qtArch}" MATCHES "x64")
                                set(Qt5_DIR "${qt5versionSubPath}/lib/cmake/Qt5") ## choose last one
                            endif()
                        else()
                            if("${qtArch}" MATCHES "x86")
                                set(Qt5_DIR "${qt5versionSubPath}/lib/cmake/Qt5") ## choose last one
                            endif()
                        endif()
                    endforeach()
                endif()
            endforeach()
        endif()
    endif()
    set(Qt5_DIR ${Qt5_DIR} CACHE PATH "Path to <Qt5 installation>/lib/cmake/Qt5")

    set(QtComponents OpenGL Widgets)
    if(BUILD_IS) ## for is submodule Qt5 dependencies
        list(APPEND QtComponents Network Qml Quick)
    endif()

    ## WORK AROUND: QT5 5.2.1 win32 OpenGL problem to find glu32... we need WINSDK to let qt find it
    list(FIND QtComponents OpenGL haveOpenGLComponent)
    if(NOT "${haveOpenGLComponent}" MATCHES "-1" AND WIN32)
        find_package(WindowsSDK QUIET)
        if(WindowsSDK_FOUND)
            message(STATUS "WindowsSDK ${WindowsSDK_VERSION} found for QOpenGL component using Qt5 < 5.3")
            list(APPEND CMAKE_LIBRARY_PATH ${WindowsSDK_LIBRARY_DIRS})
        else()
            message(WARNING "You need Windows SDK to let Qt5 find OpenGL glu32.")
        endif()
    endif()

    set(CMAKE_AUTOMOC ON) # Instruct CMake to run moc automatically when needed.
    find_package(Qt5 COMPONENTS ${QtComponents} REQUIRED) ## then you can use : qt5_use_modules(<target> <component> <...>)
    include(Qt5ImportedLocation) ## function mainly used to get binaries location for installation under windows (*.dll)

    if(NOT Qt5_FOUND)
        message(SEND_ERROR "Qt5 not found, please set Qt5_DIR to <Qt5 installation>/lib/cmake/Qt5")
    elseif(WIN32 AND "${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}" MATCHES "5.2.1")
        message(WARNING "Be careful, there were bugs on 5.2.1 win32 version : http://stackoverflow.com/questions/14008737/qt5-qconfig-h-weird")
    endif()

else()
    message(WARNING "USE_RENDERER_API is not Qt nor GLUT : USE_RENDERER_API=${USE_RENDERER_API} you need to choose a correct one.")
endif()

###################
## Find OpenImageIO
###################
if(BUILD_MY_X64_PROJECT) ## will need boost (thread system chrono) also (see above)
#    win3rdParty(OPENIMAGEIO #VERBOSE ON
#            MSVC11 "win3rdParty/MSVC11/OpenImageIO" "https://gforge.inria.fr/frs/download.php/file/34749/OpenImageIO-1.6.7z"
#            #MSVC12 "win3rdParty/MSVC12/OpenImageIO" "TODO"
#            MULTI_SET
#                CHECK_CACHED_VAR OPENIMAGEIO_DIR    PATH "OpenImageIO-1.6"
#                CHECK_CACHED_VAR ILMBASE_HOME       PATH "OpenImageIO-1.6/external/ilmbase-2.2.0"
#                CHECK_CACHED_VAR OPENEXR_HOME       PATH "OpenImageIO-1.6/external/openexr-2.2.0"
#    )
    find_package(OpenImageIO)
    if(NOT OpenImageIO_FOUND)
        message(WARNING "OpenImageIO NOT FOUND!!")
    else()
        include_directories(${OPENIMAGEIO_INCLUDE_DIR})
    endif()

    ## IlmBase (needed by oiio)
    find_package(IlmBase)
    if(ILMBASE_FOUND)
        include_directories ("${ILMBASE_INCLUDE_DIR}")
        include_directories ("${ILMBASE_INCLUDE_DIR}/OpenEXR")
        list(APPEND OPENIMAGEIO_LIBRARIES ${ILMBASE_LIBRARIES})
    else()
        message(WARNING "IlmBase NOT FOUND, needed with OpenImageIO!!")
    endif()

    ## OpenEXR (needed by oiio)
    find_package(OpenEXR)
    if(OPENEXR_FOUND)
        if (EXISTS "${OPENEXR_INCLUDE_DIR}/OpenEXR/ImfMultiPartInputFile.h")
            add_definitions (-DUSE_OPENEXR_VERSION2=1)
        endif()
        include_directories ("${OPENEXR_INCLUDE_DIR}")
        include_directories ("${OPENEXR_INCLUDE_DIR}/OpenEXR")
        list(APPEND OPENIMAGEIO_LIBRARIES ${OPENEXR_LIBRARIES})
    else()
        message(WARNING "OpenEXR NOT FOUND, needed with OpenImageIO!!")
    endif()

    if(OpenImageIO_FOUND)
        list(REMOVE_DUPLICATES OPENIMAGEIO_LIBRARIES)
        message(STATUS "OPENIMAGEIO_LIBRARIES=${OPENIMAGEIO_LIBRARIES}")
    endif()
endif()


##############
## Find zlib
##############
#win3rdParty(ZLIB #VERBOSE ON
#        MSVC11 "win3rdParty/MSVC11/zlib" "https://gforge.inria.fr/frs/download.php/file/35189/zlib-1.2.8.7z"
#        MSVC12 "win3rdParty/MSVC12/zlib" "https://gforge.inria.fr/frs/download.php/file/35189/zlib-1.2.8.7z"
#        SET CHECK_CACHED_VAR ZLIB_ROOT PATH "zlib-1.2.8"
#)
find_package(ZLIB REQUIRED)
include_directories(${ZLIB_INCLUDE_DIR})


####################
## Find SuiteSparse
####################
if(BUILD_MY_X64_PROJECT)
#    win3rdParty(SuiteSparse #VERBOSE ON
#        MSVC11 "win3rdParty/MSVC11/SuiteSparse" "https://gforge.inria.fr/frs/download.php/file/34361/SuiteSparse-4.2.1.7z"
#        MSVC12 "win3rdParty/MSVC11/SuiteSparse" "https://gforge.inria.fr/frs/download.php/file/34361/SuiteSparse-4.2.1.7z"
#        MULTI_SET
#            CHECK_CACHED_VAR SuiteSparse_DIR             PATH "SuiteSparse-4.2.1"
#            CHECK_CACHED_VAR SuiteSparse_USE_LAPACK_BLAS BOOL ON
#    )
	find_package(SuiteSparse QUIET NO_MODULE)
	if(NOT SuiteSparse_FOUND)
		SET(SuiteSparse_VERBOSE ON)
		find_package(SuiteSparse REQUIRED COMPONENTS amd camd colamd ccolamd cholmod)
		if(SuiteSparse_FOUND)
			include_directories(${SuiteSparse_INCLUDE_DIRS})
		else()
			message(SEND_ERROR "SuiteSparse not found.")
		endif()
	else()
		message(STATUS "Find SuiteSparse: INCLUDE(${USE_SuiteSparse})")
		include(${USE_SuiteSparse})
	endif()
endif()

#############
## Find Boost
#############
if(BUILD_MY_X64_PROJECT)
    ## [UGLY CGAL] CGAL depend of Boost so if we use CGAL, we need to link against boost libs also (thread<-sytem<-chrono)
    ## if there is a library path where static boost libs are, then MSVC should auto find it
    set(Boost_NEEDED_COMPONENTS )
    if(CGAL_FOUND)
        list(APPEND Boost_NEEDED_COMPONENTS thread system chrono)
    endif()
    if(BUILD_MY_X64_PROJECT)
        list(APPEND Boost_NEEDED_COMPONENTS thread system chrono)
    endif()
    list(REMOVE_DUPLICATES Boost_NEEDED_COMPONENTS)

#    win3rdParty(Boost VCID TIMEOUT 600 #VERBOSE ON
#        MSVC11 "win3rdParty/MSVC11/Boost" "https://gforge.inria.fr/frs/download.php/file/34425/boost_1_55_0.7z"
#        MSVC12 "win3rdParty/MSVC11/Boost" "https://gforge.inria.fr/frs/download.php/file/34425/boost_1_55_0.7z"
#    )
#    if(WIN32 AND NOT Boost_WIN3RDPARTY_VCID AND Boost_WIN3RDPARTY_USE)
#        message(WARNING "Boost_COMPILER is not set and it's needed. Try to disable Boost_WIN3RDPARTY_USE and set it manually.")
#    endif()
#    win3rdParty(Boost MULTI_SET
#            CHECK_CACHED_VAR BOOST_ROOT                 PATH "boost_1_55_0"
#            CHECK_CACHED_VAR BOOST_INCLUDEDIR 		    PATH "boost_1_55_0"
#            CHECK_CACHED_VAR BOOST_LIBRARYDIR 		    PATH "boost_1_55_0/${LIB_BUILT_DIR}"
#            CHECK_CACHED_VAR Boost_NO_SYSTEM_PATHS      BOOL ON DOC "Set to ON to disable searching in locations not specified by these boost cached hint variables"
#            CHECK_CACHED_VAR Boost_NO_BOOST_CMAKE       BOOL ON DOC "Set to ON to disable the search for boost-cmake (package cmake config file if boost was built with cmake)"
#            #CHECK_CACHED_VAR Boost_COMPILER             STRING "-${Boost_WIN3RDPARTY_VCID}" DOC "vcid (eg: -vc110 for MSVC11)"
#			CHECK_CACHED_VAR Boost_COMPILER             STRING "-vc110" DOC "vcid (eg: -vc110 for MSVC11)"
#            CHECK_CACHED_VAR Boost_REQUIRED_COMPONENTS  STRING LIST "${Boost_NEEDED_COMPONENTS}"
#    )
#    if(NOT Boost_COMPILER AND Boost_WIN3RDPARTY_USE)
#        message(WARNING "Boost_COMPILER is not set and it's needed.")
#    endif()

    if(Boost_NEEDED_COMPONENTS)
        find_package(Boost REQUIRED COMPONENTS ${Boost_REQUIRED_COMPONENTS})
    else()
        find_package(Boost)
    endif()

	if(Boost_LIB_DIAGNOSTIC_DEFINITIONS)
        add_definitions(${Boost_LIB_DIAGNOSTIC_DEFINITIONS})
    endif()

    if(WIN32)
        add_definitions(-DBOOST_ALL_DYN_LINK -DBOOST_ALL_NO_LIB)
    endif()

	if(Boost_FOUND OR BOOST_FOUND)
		include_directories(${BOOST_INCLUDEDIR} ${Boost_INCLUDE_DIRS})
		link_directories(${BOOST_LIBRARYDIR} ${Boost_LIBRARY_DIRS})
        if(CGAL_FOUND)
            list(APPEND CGAL_LIBRARIES ${Boost_LIBRARIES})
        endif()
	else()
		message(SEND_ERROR "Boost not found. Set BOOST_ROOT or BOOST_DIR and Boost_LIBRARYDIR.")
		message("CGAL use boost and if it is not build with embedded static boost lib, you will need it at runtime.")
	endif()

endif()


##############
## Find OpenMP
##############
find_package(OpenMP)
## then into your sub-CMakeLists.txt you can use :
## SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES COMPILE_OPTIONS ${OpenMP_CXX_FLAGS} LINK_FLAGS ${OpenMP_CXX_FLAGS})
## OR
## #target_compile_options(${PROJECT_NAME} PUBLIC ${OpenMP_C_FLAGS} PUBLIC ${OpenMP_CXX_FLAGS}) # but on some plateform there is a risk to skip LINK_FLAGS...


##############
## Find OpenCV
##############
if(BUILD_MY_X64_PROJECT)
#    win3rdParty(OpenCV #VERBOSE ON
#            ## the same package handle multiple config modes (x86 AND x64) and multiple compilers (vc10 AND vc11 AND vc12)
#            MSVC11 "win3rdParty/MSVC11/OpenCV" "http://sourceforge.net/projects/opencvlibrary/files/opencv-win/2.4.10/opencv-2.4.10.exe/download"
#            MSVC12 "win3rdParty/MSVC11/OpenCV" "http://sourceforge.net/projects/opencvlibrary/files/opencv-win/2.4.10/opencv-2.4.10.exe/download"
#            SET CHECK_CACHED_VAR OpenCV_DIR PATH "opencv/build" ## see OpenCVConfig.cmake
#        )
    find_package(OpenCV) ## Use directly the OpenCVConfig.cmake provided
    if(OpenCV_INCLUDE_DIRS)
        foreach(inc ${OpenCV_INCLUDE_DIRS})
            if(NOT EXISTS ${inc})
                set(OpenCV_INCLUDE_DIR "" CACHE PATH "additional custom include DIR (in case of trouble to find it (fedora 17 opencv package))")
            endif()
        endforeach()
        if(OpenCV_INCLUDE_DIR)
            list(APPEND OpenCV_INCLUDE_DIRS ${OpenCV_INCLUDE_DIR})
            include_directories(${OpenCV_INCLUDE_DIRS})
        endif()
    endif()
    if(NOT OPENCV_FOUND)
        message(WARNING "OpenCV is not Found.")
    endif()
endif()

#Win3rdPartyGlobalCacheAction()
message(STATUS "[dependencies] Finish to look for necessary dependencies.")
message("")
