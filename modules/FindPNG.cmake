## CMAKE_DOCUMENTATION_START FindPNG.cmake
## Important Note: \\n
## This is not an official Find*cmake. It has been written for searching through
## a custom path (PNG_DIR) before checking elsewhere. \\n
## This module defines : \\n
## 	\\t[in] 	\\tPNG_DIR, The base directory to search for PNG (as cmake var or env var) \\n
## 	\\t[out] 	\\tPNG_INCLUDE_DIR where to find PNG.h \\n
## 	\\t[out] 	\\tPNG_LIBRARIES, PNG_LIBRARY, libraries to link against to use PNG \\n
## 	\\t[out] 	\\tPNG_FOUND, If false, do not try to use PNG. \\n
## CMAKE_DOCUMENTATION_END

SET(_PNG_VERSION_SUFFIX 17)

if(NOT PNG_DIR)
    set(PNG_DIR "$ENV{PNG_DIR}" CACHE PATH "PNG root directory")
endif()
if(PNG_DIR)
	file(TO_CMAKE_PATH ${PNG_DIR} PNG_DIR)
endif()


## set the LIB POSTFIX to find in a right directory according to what kind of compiler we use (32/64bits)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
	set(PNG_SEARCH_LIB "lib64")
	set(PNG_SEARCH_BIN "bin64")
	set(PNG_SEARCH_LIB_PATHSUFFIXE "x64")
else()
	set(PNG_SEARCH_LIB "lib32")
	set(PNG_SEARCH_BIN "bin32")
	set(PNG_SEARCH_LIB_PATHSUFFIXE "x86")
endif()

set(PROGRAMFILESx86 "PROGRAMFILES(x86)")

FIND_PATH(PNG_INCLUDE_DIR
	NAMES pnglibconf.h
	PATHS
		${PNG_DIR}
		## linux
		/usr
		/usr/local
		/opt/local
		## windows
		"$ENV{PROGRAMFILES}/PNG"
		"$ENV{${PROGRAMFILESx86}}/PNG"
		"$ENV{ProgramW6432}/PNG"
	PATH_SUFFIXES include
  NO_DEFAULT_PATH
)

FIND_LIBRARY(PNG_LIBRARY
	NAMES libpng${_PNG_VERSION_SUFFIX}_static
	PATHS
		${PNG_DIR}/${PNG_SEARCH_LIB}
		${PNG_DIR}/lib
		## linux
		/usr/${PNG_SEARCH_LIB}
		/usr/local/${PNG_SEARCH_LIB}
		/opt/local/${PNG_SEARCH_LIB}
		/usr/lib
		/usr/local/lib
		/opt/local/lib
		## windows
		"$ENV{PROGRAMFILES}/PNG/${PNG_SEARCH_LIB}"
		"$ENV{${PROGRAMFILESx86}}/PNG/${PNG_SEARCH_LIB}"
		"$ENV{ProgramW6432}/PNG/${PNG_SEARCH_LIB}"
		"$ENV{PROGRAMFILES}/PNG/lib"
		"$ENV{${PROGRAMFILESx86}}/PNG/lib"
		"$ENV{ProgramW6432}/PNG/lib"
	PATH_SUFFIXES ${PNG_SEARCH_LIB_PATHSUFFIXE}
  NO_DEFAULT_PATH
)
set(PNG_LIBRARIES ${PNG_LIBRARY})

MARK_AS_ADVANCED(PNG_INCLUDE_DIR PNG_LIBRARIES)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(PNG
	REQUIRED_VARS PNG_INCLUDE_DIR PNG_LIBRARIES
	FAIL_MESSAGE "PNG wasn't found correctly. Set PNG_DIR to the root SDK installation directory."
)

if(NOT PNG_FOUND)
	set(PNG_DIR "" CACHE STRING "Path to PNG install directory")
endif()





# #.rst:
# # FindPNG
# # -------
# #
# # Find the native PNG includes and library
# #
# #
# #
# # This module searches libpng, the library for working with PNG images.
# #
# # It defines the following variables
# #
# # ::
# #
# #   PNG_INCLUDE_DIRS, where to find png.h, etc.
# #   PNG_LIBRARIES, the libraries to link against to use PNG.
# #   PNG_DEFINITIONS - You should add_definitons(${PNG_DEFINITIONS}) before compiling code that includes png library files.
# #   PNG_FOUND, If false, do not try to use PNG.
# #   PNG_VERSION_STRING - the version of the PNG library found (since CMake 2.8.8)
# #
# # Also defined, but not for general use are
# #
# # ::
# #
# #   PNG_LIBRARY, where to find the PNG library.
# #
# # For backward compatiblity the variable PNG_INCLUDE_DIR is also set.
# # It has the same value as PNG_INCLUDE_DIRS.
# #
# # Since PNG depends on the ZLib compression library, none of the above
# # will be defined unless ZLib can be found.

# #=============================================================================
# # Copyright 2002-2009 Kitware, Inc.
# #
# # Distributed under the OSI-approved BSD License (the "License");
# # see accompanying file Copyright.txt for details.
# #
# # This software is distributed WITHOUT ANY WARRANTY; without even the
# # implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# # See the License for more information.
# #=============================================================================
# # (To distribute this file outside of CMake, substitute the full
# #  License text for the above reference.)

# if(PNG_FIND_QUIETLY)
  # set(_FIND_ZLIB_ARG QUIET)
# endif()
# find_package(ZLIB ${_FIND_ZLIB_ARG})

# if(ZLIB_FOUND)
  # find_path(PNG_PNG_INCLUDE_DIR png.h
  # /usr/local/include/libpng             # OpenBSD
  # )

  # list(APPEND PNG_NAMES png libpng)
  # unset(PNG_NAMES_DEBUG)
  # set(_PNG_VERSION_SUFFIXES 17 16 15 14 12)
  # if (PNG_FIND_VERSION MATCHES "^[0-9]+\\.[0-9]+(\\..*)?$")
    # string(REGEX REPLACE
        # "^([0-9]+)\\.([0-9]+).*" "\\1\\2"
        # _PNG_VERSION_SUFFIX_MIN "${PNG_FIND_VERSION}")
    # if (PNG_FIND_VERSION_EXACT)
      # set(_PNG_VERSION_SUFFIXES ${_PNG_VERSION_SUFFIX_MIN})
    # else ()
      # string(REGEX REPLACE
          # "${_PNG_VERSION_SUFFIX_MIN}.*" "${_PNG_VERSION_SUFFIX_MIN}"
          # _PNG_VERSION_SUFFIXES "${_PNG_VERSION_SUFFIXES}")
    # endif ()
    # unset(_PNG_VERSION_SUFFIX_MIN)
  # endif ()
  # foreach(v IN LISTS _PNG_VERSION_SUFFIXES)
    # list(APPEND PNG_NAMES png${v} libpng${v})
    # list(APPEND PNG_NAMES_DEBUG png${v}d libpng${v}d)
  # endforeach()
  # unset(_PNG_VERSION_SUFFIXES)
  # # For compatiblity with versions prior to this multi-config search, honor
  # # any PNG_LIBRARY that is already specified and skip the search.
  # if(NOT PNG_LIBRARY)
    # find_library(PNG_LIBRARY_RELEASE NAMES ${PNG_NAMES})
    # find_library(PNG_LIBRARY_DEBUG NAMES ${PNG_NAMES_DEBUG})
    # include(${CMAKE_CURRENT_LIST_DIR}/SelectLibraryConfigurations.cmake)
    # select_library_configurations(PNG)
    # mark_as_advanced(PNG_LIBRARY_RELEASE PNG_LIBRARY_DEBUG)
  # endif()
  # unset(PNG_NAMES)
  # unset(PNG_NAMES_DEBUG)

  # # Set by select_library_configurations(), but we want the one from
  # # find_package_handle_standard_args() below.
  # unset(PNG_FOUND)

  # if (PNG_LIBRARY AND PNG_PNG_INCLUDE_DIR)
      # # png.h includes zlib.h. Sigh.
      # set(PNG_INCLUDE_DIRS ${PNG_PNG_INCLUDE_DIR} ${ZLIB_INCLUDE_DIR} )
      # set(PNG_INCLUDE_DIR ${PNG_INCLUDE_DIRS} ) # for backward compatiblity
      # set(PNG_LIBRARIES ${PNG_LIBRARY} ${ZLIB_LIBRARY})

      # if (CYGWIN)
        # if(BUILD_SHARED_LIBS)
           # # No need to define PNG_USE_DLL here, because it's default for Cygwin.
        # else()
          # set (PNG_DEFINITIONS -DPNG_STATIC)
        # endif()
      # endif ()

  # endif ()

  # if (PNG_PNG_INCLUDE_DIR AND EXISTS "${PNG_PNG_INCLUDE_DIR}/png.h")
      # file(STRINGS "${PNG_PNG_INCLUDE_DIR}/png.h" png_version_str REGEX "^#define[ \t]+PNG_LIBPNG_VER_STRING[ \t]+\".+\"")

      # string(REGEX REPLACE "^#define[ \t]+PNG_LIBPNG_VER_STRING[ \t]+\"([^\"]+)\".*" "\\1" PNG_VERSION_STRING "${png_version_str}")
      # unset(png_version_str)
  # endif ()
# endif()

# # handle the QUIETLY and REQUIRED arguments and set PNG_FOUND to TRUE if
# # all listed variables are TRUE
# include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
# find_package_handle_standard_args(PNG
                                  # REQUIRED_VARS PNG_LIBRARY PNG_PNG_INCLUDE_DIR
                                  # VERSION_VAR PNG_VERSION_STRING)

# mark_as_advanced(PNG_PNG_INCLUDE_DIR PNG_LIBRARY )
