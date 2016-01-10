## Sub-project name (use for also for output targetName)
PROJECT(myX64projectLib)

## specify the source/header and resources files
set(SOURCES
	foo.h
	foo.cpp
)

source_group("Source Files" FILES ${SOURCES})
set(RESOURCES myResources
#    shaders/anaglyph.vp
#    shaders/anaglyph.fp
#    shaders/depth.vp
#    shaders/depth.fp
#    shaders/texture.vp
#    shaders/texture.fp
#    shaders/topview.vp
#    shaders/topview.fp
)

## Specify target rules
add_library(${PROJECT_NAME} SHARED ${SOURCES})
set_target_properties(	${PROJECT_NAME} PROPERTIES RESOURCE "${RESOURCES}")
target_link_libraries(	${PROJECT_NAME} ${ASSIMP_LIBRARIES})

if(${USE_RENDERER_API} MATCHES "QT")
	qt5_use_modules(${PROJECT_NAME} Widgets OpenGL)
elseif(${USE_RENDERER_API} MATCHES "GLUT")
	target_link_libraries(${PROJECT_NAME} ${GLEW_LIBRARIES} ${GLUT_LIBRARIES})
endif()

## EXPORT/EXPOSE C++ macro to win32 dllimport(use)/dllexport(build) rules
include(GenerateExportHeader)
GENERATE_EXPORT_HEADER(${PROJECT_NAME}) ## will generate filename in lower case
string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LC)
configure_file(	${PROJECT_BINARY_DIR}/${PROJECT_NAME_LC}_export.h
				${CMAKE_BINARY_DIR}/include/${PROJECT_NAME_LC}_export.h
				COPYONLY )
include_directories(${CMAKE_BINARY_DIR}/include)

## Hight level macro to install in an homogen way all our targets
#include(install_runtime)
#install_target(${PROJECT_NAME} RSC_FILE_ADD "${PROJECT_NAME}_rsc" INSTALL_PDB)

