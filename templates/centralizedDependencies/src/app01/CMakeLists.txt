## Sub-project name (use for also for output targetName)
PROJECT(myX64project)

#include_directories(${CMAKE_HOME_DIRECTORY}/src/...)

## specify the source/header and resources files
set(SOURCES main.cpp)
set(RESOURCES "")

## Specify target rules
add_executable(${PROJECT_NAME} ${SOURCES})
target_link_libraries(${PROJECT_NAME}
	myX64projectLib
	${SuiteSparse_LIBRARIES}
)

if(${USE_RENDERER_API} MATCHES "QT")
	qt5_use_modules(${PROJECT_NAME} Widgets OpenGL)
elseif(${USE_RENDERER_API} MATCHES "GLUT")
	target_link_libraries(${PROJECT_NAME} ${GLEW_LIBRARIES} ${GLUT_LIBRARIES})
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES RESOURCE "${RESOURCES}")
set_target_properties(${PROJECT_NAME} PROPERTIES 
	DEBUG_POSTFIX "_d"
	RELWITHDEBINFO_POSTFIX "_rwdi"
	MINSIZEREL_POSTFIX "_msr"
)

## Building this app mean you want to test it with a default dataset
#if(NOT EXISTS ${DATASET_SAMPLE_PATH})
#	add_dependencies(${PROJECT_NAME} ${DATASET_DL_SAMPLE_TARGET})
#endif()

## Hight level macro to install in an homogen way all our targets
#include(install_runtime)
#install_target(${PROJECT_NAME} 
#    INSTALL_PDB                                     ## mean install also MSVC IDE *.pdb file (DEST according to target type)
#    STANDALONE ${INSTALL_STANDALONE}                ## mean call install_runtime with bundle dependencies resolution
#    COMPONENT   install_myproject		             ## will create custom target to install only this project
#    MSVC_ARGS "-path \"${DATASET_SAMPLE_PATH}\""    ## mean configure MSVC IDE to be ready to launch debugger with target path app and args
#    #RSC_FILE_ADD "${PROJECT_NAME}_rsc"             ## see install_target cmake doc
#    #QT5_PLUGINS <qt5Plugins>                       ## see Qt5ImportedLocation cmake doc at QT5_PLUGINS flag
#    #DIRS                                           ## see install_runtime cmake doc
#    PLUGINS                                         ## see install_runtime cmake doc
#        PLUGIN_PATH_NAME ${ASSIMP_DYNAMIC_LIB}          PLUGIN_PATH_DEST bin ## default relative to CMAKE_INSTALL_PREFIX
#        PLUGIN_PATH_NAME ${SuiteSparse_LAPACK_BLAS_DLL} PLUGIN_PATH_DEST bin ## default relative to CMAKE_INSTALL_PREFIX
#)
