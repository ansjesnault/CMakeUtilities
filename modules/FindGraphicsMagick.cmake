## CMAKE_DOCUMENTATION_START FindGraphicsMagick.cmake
## - Find the GraphicsMagick binary suite. \\n
##  	\\tGraphicsMagick_FOUND				\\t\\t\\t- ON if found.\\n
##  	\\tGraphicsMagick_EXECUTABLE_DIR	\\t- Full path to executables directory.\\n
##  	\\tGraphicsMagick_EXECUTABLE		\\t\\t- Full path to executables app.\\n
##  \\n
##	If 'devel' COMPONENTS is given, it provide additional cmake variables : \\n
##  	\\tGraphicsMagick_INCLUDE_DIR  	\\t- Include directory for GraphicsMagick \\n
##  	\\tGraphicsMagick_LIBRARY_DIR  	\\t- Library directory for GraphicsMagick \\n
##  	\\tGraphicsMagick_LIBRARIES		\\t- Libraries you need to link to \\n
## \\n
## Example Usages:
## \\code
##  find_package(GraphicsMagick)\n
##  find_package(GraphicsMagick COMPONENTS devel)
## \\endcode
## CMAKE_DOCUMENTATION_END

SET(GraphicsMagick_FOUND OFF)

set(PROGRAMFILES64 		"PROGRAMFILES")
set(PROGRAMFILES32 		"PROGRAMFILES(x86)")
set(PROGRAMFILES6432 	"ProgramW6432")

if(WIN32)
	file(GLOB GRAPHICSMAGICK_CMD "$ENV{${PROGRAMFILES64}}/GraphicsMagick*/gm.exe")
	IF(NOT GRAPHICSMAGICK_CMD)
		file(GLOB GRAPHICSMAGICK_CMD "$ENV{${PROGRAMFILES32}}/GraphicsMagick*/gm.exe")
		IF(NOT GRAPHICSMAGICK_CMD)
			file(GLOB GRAPHICSMAGICK_CMD "$ENV{${PROGRAMFILES6432}}/GraphicsMagick*/gm.exe")
		ENDIF()
	ENDIF()
	if(GRAPHICSMAGICK_CMD)
		if(EXISTS ${GRAPHICSMAGICK_CMD} AND NOT GraphicsMagick_DIR)
				get_filename_component(GraphicsMagick_DIR ${GRAPHICSMAGICK_CMD} PATH)
		endif()
	endif()
endif()

find_program(GraphicsMagick_EXECUTABLE NAMES gm
	PATHS
		${GraphicsMagick_DIR}
		${GraphicsMagick_DIR}/bin
		"$ENV{GraphicsMagick_DIR}"
		"$ENV{GraphicsMagick_DIR}/bin"
		"[HKEY_LOCAL_MACHINE\\SOFTWARE\\WoW6432Node\\GraphicsMagick\\Current;BinPath]"
		"[HKEY_LOCAL_MACHINE\\SOFTWARE\\WoW6432Node\\GraphicsMagick\\Current;ConfigurePath]/bin"
		/usr/bin/magick
		/usr/bin/
		/usr/local/bin
		/usr/local/bin/GraphicsMagick/magick
		/usr/local/bin/GraphicsMagick/
		/opt/local/bin/GraphicsMagick/magick
		/opt/local/bin/GraphicsMagick
)

set(GraphicsMagick_devel "-1")
if(ImageMagick_FIND_COMPONENTS)
	list(FIND ${ImageMagick_FIND_COMPONENTS} devel GraphicsMagick_devel )
endif()
if(${GraphicsMagick_devel} MATCHES "-1")

	if(EXISTS ${GraphicsMagick_EXECUTABLE})
		SET(GraphicsMagick_FOUND ON)
		GET_FILENAME_COMPONENT(GraphicsMagick_EXECUTABLE_DIR ${GraphicsMagick_EXECUTABLE} PATH)
	endif()
	
else()

	FIND_PATH( GraphicsMagick_INCLUDE_DIR NAMES magick.h
		PATHS
			${GraphicsMagick_DIR}
			${GraphicsMagick_DIR}/include
			"$ENV{GraphicsMagick_DIR}"
			"$ENV{GraphicsMagick_DIR}/include"
			"[HKEY_LOCAL_MACHINE\\SOFTWARE\\WoW6432Node\\GraphicsMagick\\Current;ConfigurePath]"
			"[HKEY_LOCAL_MACHINE\\SOFTWARE\\WoW6432Node\\GraphicsMagick\\Current;ConfigurePath]/include"
			/usr/include/magick
			/usr/include/
			/usr/local/include
			/usr/local/include/GraphicsMagick/magick
			/usr/local/include/GraphicsMagick/
			/opt/local/include/GraphicsMagick/magick
			/opt/local/include/GraphicsMagick
	)

	FIND_LIBRARY( GraphicsMagick_LIBRARY NAMES GraphicsMagick
		PATHS
			${GraphicsMagick_DIR}
			${GraphicsMagick_DIR}/lib64
			"$ENV{GraphicsMagick_DIR}"
			"$ENV{GraphicsMagick_DIR}/lib64"
			"[HKEY_LOCAL_MACHINE\\SOFTWARE\\WoW6432Node\\GraphicsMagick\\Current;LibPath]"
			"[HKEY_LOCAL_MACHINE\\SOFTWARE\\WoW6432Node\\GraphicsMagick\\Current;LibPath]/lib64"
			${GraphicsMagick_DIR}/lib
			"$ENV{GraphicsMagick_DIR}/lib"
			"[HKEY_LOCAL_MACHINE\\SOFTWARE\\WoW6432Node\\GraphicsMagick\\Current;LibPath]/lib"
			/usr/lib64
			/usr/local/lib64
			/opt/local/lib64
			/usr/lib
			/usr/local/lib
			/opt/local/lib
	)

	SET(GraphicsMagick_LIBRARIES ${GraphicsMagick_LIBRARY} )

	IF (GraphicsMagick_INCLUDE_DIR)
	  IF(GraphicsMagick_LIBRARIES)
		SET(GraphicsMagick_FOUND ON)
		GET_FILENAME_COMPONENT(GraphicsMagick_LIBRARY_DIR ${GraphicsMagick_LIBRARY} PATH)
	  ENDIF()
	ENDIF()
	
endif()

IF(NOT GraphicsMagick_FOUND)
	IF(NOT GraphicsMagick_FIND_QUIETLY)
		IF(GraphicsMagick_FIND_REQUIRED)
			MESSAGE(FATAL_ERROR "GraphicsMagick required, please specify it's location with GraphicsMagick_DIR")
		ELSE()
			MESSAGE(STATUS "GraphicsMagick was not found.")
		ENDIF()
	ENDIF()
ENDIF()
