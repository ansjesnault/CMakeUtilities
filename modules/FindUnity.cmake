## CMAKE_DOCUMENTATION_START FindUnity.cmake
## Try to find the UNITY 3D applications. \\n
## Once done this will define : \\n
## \\n
##  UNITY_FOUND - System has UNITY \\n
##  UNITY_CMD - The Unity executable \\n
##  UNITY_MONODEV_CMD - The MonoDevelop IDE executable \\n
##  UNITY_DIR - if not yet set by the user \\n
## \\n
## TODO: add MAC OS search paths \\n
## Created / updated by jesnault (2014)
## CMAKE_DOCUMENTATION_END

set(PROGRAMFILES64 		"PROGRAMFILES")
set(PROGRAMFILES32 		"PROGRAMFILES(x86)")
set(PROGRAMFILES6432 	"ProgramW6432")

find_program(UNITY_CMD 
	NAMES 			Unity
	PATHS 			"${UNITY_DIR}"
					"$ENV{UNITY_DIR}"
					"$ENV{${PROGRAMFILES64}}/Unity"
					"$ENV{${PROGRAMFILES32}}/Unity"
					"$ENV{${PROGRAMFILES6432}}/Unity"
					"C:/Program Files/Unity"
					"C:/Program Files (x86)/Unity"
	PATH_SUFFIXES	Editor
	DOC "Unity 3D application file path"
)

if(NOT UNITY_DIR AND UNITY_CMD)
	get_filename_component(UNITY_DIR ${UNITY_CMD} PATH CACHE)
elseif(NOT UNITY_DIR AND NOT UNITY_CMD)
	set(UNITY_DIR "$ENV{UNITY_DIR}" CACHE PATH "Where we can find the Unity 3D application")
endif()

find_program(UNITY_MONODEV_CMD 
	NAMES 			MonoDevelop
	PATHS 			"${UNITY_DIR}"
					"$ENV{UNITY_DIR}"
					"${UNITY_MONODEV_DIR}"
					"$ENV{UNITY_MONODEV_DIR}"
					"$ENV{${PROGRAMFILES64}}/Unity"
					"$ENV{${PROGRAMFILES32}}/Unity"
					"$ENV{${PROGRAMFILES6432}}/Unity"
					"C:/Program Files"
					"C:/Program Files (x86)"
					"C:/Program Files/Unity"
					"C:/Program Files (x86)/Unity"
	PATH_SUFFIXES	MonoDevelop
					MonoDevelop/bin
	DOC "MonoDevelop associated IDE application file path"
)

if(NOT UNITY_MONODEV_DIR AND UNITY_MONODEV_CMD)
	get_filename_component(UNITY_MONODEV_DIR ${UNITY_MONODEV_CMD} PATH CACHE)
elseif(NOT UNITY_MONODEV_DIR AND NOT UNITY_MONODEV_CMD)	
	set(UNITY_MONODEV_DIR "$ENV{UNITY_MONODEV_DIR}" CACHE PATH "Where we can find the MonoDevelop application")
endif()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(UNITY DEFAULT_MSG UNITY_CMD)

if(UNITY_FOUND)
	mark_as_advanced(UNITY_DIR UNITY_CMD UNITY_MONODEV_DIR UNITY_MONODEV_CMD UNITY_RENDERING_MODE UNITY_PROJECT_NAME)
endif()