############################
## set cmake BUILD options
############################
include(CMakeDependentOption)
option(INSTALL_STANDALONE "Install IBR_project including external dependencies libs / ressources" ON) ## recommanded
cmake_dependent_option(BUILD_MY_X64_PROJECT "Build only under windows x64 at this moment" ON "CMAKE_CL_64;WIN32" OFF)

## create a combo list options with choice of one of those options
set(USE_RENDERER_API "GLUT" CACHE STRING "Choose preferred renderer" )
set_property(CACHE USE_RENDERER_API PROPERTY STRINGS "GLUT;QT" )

if( ${USE_RENDERER_API} MATCHES "QT" )
	add_definitions(-DHAS_QT=true)
elseif (${USE_RENDERER_API} MATCHES "GLUT")
	add_definitions(-DHAS_GLUT=true)
endif()


## Handle the LINUX R_PATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
IF("${isSystemDir}" STREQUAL "-1")
   SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
ENDIF()


##############################
## Find necessary dependencies
##############################
include(dependencies)		## Map/bind 3rdParty/external dependencies packages to cmake

## For GENERATE_EXPORT_HEADER cmake macro of common/core lib used by sub-projects (used when target SHARED under windows)
include_directories(${CMAKE_BINARY_DIR}/include)

###############################################
## Include projects
## (Project name = Directry name = Target name)
###############################################
add_subdirectory(lib01)
add_subdirectory(app01)
#add_subdirectory(submodules)## For optional source code (in case some targets here depend another project)
