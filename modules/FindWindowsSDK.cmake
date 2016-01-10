## CMAKE_DOCUMENTATION_START FindWindowsSDK.cmake
## Try to find Microsft SDKs on your system by checking register. \\n
## \\n
## If a specific version is given, it will look for it first,
## if no path are detected from register, we try to get the default CurrentInstallFolder from register. \\n
## \\n
## If only the first VERSION_MAJOR is given, we try to complete with all possible VERSION_MINOR,
## so we get a list of plausible SDK version which are filled with advanced vairables,
## and we get the last SDK version informations to fill the standard WindowsSDK_* cmake variables. \\n
## \\n
## Define following variables : \\n
##  WINDOWSSDK_FOUND        : ON if found, OFF otherwise (WindowsSDK_FOUND could be also tested) \\n
##  WindowsSDK_INCLUDE_DIRS : all include directories (ABSOLUTE paths) where cmake detect headers \\n
##  WindowsSDK_LIBRARY_DIRS : all libraries directories (ABSOLUTE paths) where cmake detect lib \\n
##  WindowsSDK_LIBRARIES    : all libraries files (ABSOLUTE paths) detected \\n
##  WindowsSDK_VERSION      : the last found version of the windows SDK \\n
## \\n
## Define following advanced variables : \\n
##  WINDOWSSDK_<sdkVersion>_FOUND        : ON if found, OFF otherwise (WindowsSDK_<sdkVersion>_FOUND could be also tested) \\n
##  WindowsSDK_<sdkVersion>_INCLUDE_DIRS : all include directories (ABSOLUTE paths) where cmake detect headers \\n
##  WindowsSDK_<sdkVersion>_LIBRARY_DIRS : all libraries directories (ABSOLUTE paths) where cmake detect lib \\n
##  WindowsSDK_<sdkVersion>_LIBRARIES    : all libraries files (ABSOLUTE paths) detected \\n
## \\n
## You can set WindowsSDK_VERBOSE to ON before calling find_package function in order to get more informations.  \\n
## \\n
## Usage: \\n 
## find_package(WindowsSDK) \\n
##  OR \\n
## find_package(WindowsSDK 6) \\n
##  OR \\n
## find_package(WindowsSDK 7.1 REQUIRED) \\n
##  OR \\n
## find_package(WindowsSDK 8 QUIET) \\n
##  OR \\n
## find_package(WindowsSDK 8.1 EXACT) \\n
## \\n
## Created/updated by jesnault while last cmake version was 3.0.2
## CMAKE_DOCUMENTATION_END

if(NOT WIN32)
    return()
endif()

if(WindowsSDK_FIND_VERSION_MAJOR)
    if(WindowsSDK_FIND_VERSION_MINOR)
        foreach(majorPrefix "" "v")
            foreach(minorSuffix "" "A")
                list(APPEND win_sdk_ver_list "${majorPrefix}${WindowsSDK_FIND_VERSION_MAJOR}${WindowsSDK_FIND_VERSION_MINOR}${minorSuffix}")
            endforeach()
        endforeach()
    else()
        foreach(majorPrefix "" "v")
            foreach(minor ".0" ".0A" ".1" ".1A")
                list(APPEND win_sdk_ver_list "${majorPrefix}${WindowsSDK_FIND_VERSION_MAJOR}${minor}")
            endforeach()
        endforeach()
        if(WindowsSDK_FIND_REQUIRED)
            SET(WindowsSDK_FIND_REQUIRED OFF) ## we cannot required something by not providing full version number
        endif()
    endif()
endif()

## check it for the given sdk version to find on the machine register
foreach(win_sdk_ver ${win_sdk_ver_list})
    get_filename_component(win_sdk_dir
        "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\${win_sdk_ver};InstallationFolder]"
        ABSOLUTE
    )
    if(EXISTS "${win_sdk_dir}")
        list(APPEND win_sdk_dirs_list "${win_sdk_dir}")
    endif()
endforeach()

if(NOT win_sdk_dirs_list)
    
    ## check it for current USER register
    get_filename_component(win_sdk_dir
        "[HKEY_CURRENT_USER\\Software\\Microsoft\\Microsoft SDKs\\Windows;CurrentInstallFolder]"
        ABSOLUTE
    )
    if(EXISTS "${win_sdk_dir}")
        list(APPEND win_sdk_dirs_list "${win_sdk_dir}")
    endif()

    ## check it for the whole machine register
    get_filename_component(win_sdk_dir
        "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows;CurrentInstallFolder]"
        ABSOLUTE
    )
    if(EXISTS "${win_sdk_dir}")
        list(APPEND win_sdk_dirs_list "${win_sdk_dir}")
    endif()
    
    ## check Windows Kits (instead of SDKs) for the whole machine register
    get_filename_component(win_sdk_dir
        "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot]"
        ABSOLUTE
    )
    if(EXISTS "${win_sdk_dir}")
        list(APPEND win_sdk_dirs_list "${win_sdk_dir}")
    endif()
    
endif()

## CHECKS
if(win_sdk_dirs_list)
    list(REMOVE_DUPLICATES win_sdk_dirs_list)
elseif(WindowsSDK_FIND_REQUIRED)
    message(SEND_ERROR "FindWindowsSDK cannot find any Microsoft SDKs paths from register... \
    Try to specify a version (v8.0 or v8 for example) or FIX the register by installing the SDK.")
    return()
elseif(WindowsSDK_FIND_QUIETLY)
    message(STATUS "FindWindowsSDK cannot find any Microsoft SDKs paths from register...")
else()
    message(WARNING "FindWindowsSDK cannot find any Microsoft SDKs paths from register...")
endif()
set(win_sdk_ver_exist OFF)
foreach(win_sdk_dir ${win_sdk_dirs_list})
    foreach(win_sdk_ver ${win_sdk_ver_list})
        get_filename_component(win_sdk_dir_ver ${win_sdk_dir} NAME)
        if("${win_sdk_dir_ver}" MATCHES "${win_sdk_ver}")
            set(win_sdk_ver_exist ON)
        endif()
    endforeach()
endforeach()
if(NOT win_sdk_ver_exist AND WindowsSDK_FIND_VERSION_EXACT)
    message("NO specified version founded among : ")
    foreach(win_sdk_ver ${win_sdk_ver_list})
        message("${win_sdk_ver}")
    endforeach()
    if(WindowsSDK_FIND_VERSION_EXACT)
        message(SEND_ERROR "NO specified version founded")
        unset(win_sdk_dirs_list)
    endif()
endif()


foreach(win_sdk_dir ${win_sdk_dirs_list})
    
    get_filename_component(win_sdk_ver "${win_sdk_dir}" NAME)
    set(WindowsSDK_${win_sdk_ver}_DIR ${win_sdk_dir})
    
    ## look for includes
    foreach(include_suffix "" "/shared" "/um" "/winrt" "/km" "/wdf")
        file(GLOB headers "${win_sdk_dir}/Include${include_suffix}/*.h")
        foreach(inc ${headers})
            get_filename_component(include_dir "${inc}" DIRECTORY)
            list(APPEND WindowsSDK_${win_sdk_ver}_INCLUDE_DIRS ${include_dir})
        endforeach()
    endforeach()
    if(WindowsSDK_${win_sdk_ver}_INCLUDE_DIRS)
        list(REMOVE_DUPLICATES WindowsSDK_${win_sdk_ver}_INCLUDE_DIRS)
    endif()
    
    if(CMAKE_SIZEOF_VOID_P MATCHES "8")
        set(win_sdk_old     "/x64")
        set(win_sdk_arch    "amd64")
        set(win_sdk_arch8   "x64")
    else()
        set(win_sdk_old     "")
        set(win_sdk_arch    "i386")
        set(win_sdk_arch8   "x86")
    endif()
    
    ## look for libs
    foreach(lib_suffix  "${win_sdk_old}"
                        "/w2k/${win_sdk_arch}"       "/wxp/${win_sdk_arch}"           "/wnet/${win_sdk_arch}" 
                        "/wlh/${win_sdk_arch}"       "/win7/${win_sdk_arch}"
                        "/wlh/um/${win_sdk_arch8}"   "/win7/um/${win_sdk_arch8}"      "/win8/um/${win_sdk_arch8}"
                        "/win8/km/${win_sdk_arch8}"  "/$winv6.3/km/${win_sdk_arch8}"  "/winv6.3/um/${win_sdk_arch8}"
    )
        file(GLOB libraries "${win_sdk_dir}/Lib${lib_suffix}/*.lib")
        if(libraries)
            foreach(lib ${libraries})
                get_filename_component(library_dir "${lib}" DIRECTORY)
                list(APPEND WindowsSDK_${win_sdk_ver}_LIBRARY_DIRS  ${library_dir})
            endforeach()
            list(APPEND WindowsSDK_${win_sdk_ver}_LIBRARIES ${libraries})
        endif()
    endforeach()
    if(WindowsSDK_${win_sdk_ver}_LIBRARY_DIRS)
        list(REMOVE_DUPLICATES WindowsSDK_${win_sdk_ver}_LIBRARY_DIRS)
    endif()
    if(WindowsSDK_${win_sdk_ver}_LIBRARIES)
        list(REMOVE_DUPLICATES WindowsSDK_${win_sdk_ver}_LIBRARIES)
    endif()
    
    ## check found or not
    string(TOUPPER ${win_sdk_ver} win_sdk_ver_UC)
    if(WindowsSDK_FIND_REQUIRED)
        include(FindPackageHandleStandardArgs)
        find_package_handle_standard_args(WindowsSDK_${win_sdk_ver} DEFAULT_MSG WindowsSDK_${win_sdk_ver}_LIBRARIES WindowsSDK_${win_sdk_ver}_INCLUDE_DIRS)
    else()
        if(WindowsSDK_${win_sdk_ver}_LIBRARIES AND WindowsSDK_${win_sdk_ver}_INCLUDE_DIRS)
            set(WINDOWSSDK_${win_sdk_ver_UC}_FOUND ON)
        else()
            set(WINDOWSSDK_${win_sdk_ver_UC}_FOUND OFF)
            if(NOT WindowsSDK_FIND_QUIETLY)
                message(WARNING "WINDOWSSDK_${win_sdk_ver_UC}_FOUND = ${WINDOWSSDK_${win_sdk_ver_UC}_FOUND}")
            endif()
        endif()
    endif()
    
    ## handle also lower case
    if(WINDOWSSDK_${win_sdk_ver_UC}_FOUND)
        set(WindowsSDK_${win_sdk_ver}_FOUND ON)
    else()
        set(WindowsSDK_${win_sdk_ver}_FOUND OFF)
    endif()
    
    ## verbose print
    if(WindowsSDK_VERBOSE)
        message(STATUS "WINDOWSSDK_${win_sdk_ver_UC}_FOUND  = ${WINDOWSSDK_${win_sdk_ver_UC}_FOUND}")
        message(STATUS "WindowsSDK_${win_sdk_ver}_FOUND     = ${WindowsSDK_${win_sdk_ver}_FOUND}")
        message(STATUS "WindowsSDK_${win_sdk_ver}_DIR       = ${WindowsSDK_${win_sdk_ver}_DIR}")
        message(STATUS "WindowsSDK_${win_sdk_ver}_INCLUDE_DIRS :")
        foreach(inc ${WindowsSDK_${win_sdk_ver}_INCLUDE_DIRS})
            message(STATUS ${inc})
        endforeach()
        message(STATUS "WindowsSDK_${win_sdk_ver}_LIBRARIES :")
        foreach(lib ${WindowsSDK_${win_sdk_ver}_LIBRARIES})
            message(STATUS ${lib})
        endforeach()
    endif()
    
    
    ## set default INCLUDES and LIBS to the last SDK found
    if(WINDOWSSDK_${win_sdk_ver_UC}_FOUND)
        set(WindowsSDK_VERSION      ${win_sdk_ver})
        set(WindowsSDK_INCLUDE_DIRS ${WindowsSDK_${win_sdk_ver}_INCLUDE_DIRS})
        set(WindowsSDK_LIBRARY_DIRS ${WindowsSDK_${win_sdk_ver}_LIBRARY_DIRS})
        set(WindowsSDK_LIBRARIES    ${WindowsSDK_${win_sdk_ver}_LIBRARIES})
    endif()
    
endforeach()

## final check
if(WindowsSDK_FIND_REQUIRED)
    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(WindowsSDK DEFAULT_MSG WindowsSDK_INCLUDE_DIRS WindowsSDK_LIBRARIES)
else()
    if(WindowsSDK_INCLUDE_DIRS AND WindowsSDK_LIBRARIES)
        set(WINDOWSSDK_FOUND ON)
    else()
        set(WINDOWSSDK_FOUND OFF)
        if(NOT WindowsSDK_FIND_QUIETLY)
            message(WARNING "WINDOWSSDK_FOUND = ${WINDOWSSDK_FOUND}")
        endif()
    endif()
endif()

## handle also lower case
if(WINDOWSSDK_FOUND)
    set(WindowsSDK_FOUND ON)
else()
    set(WindowsSDK_FOUND OFF)
endif()

if(WindowsSDK_VERBOSE)
    message(STATUS "WINDOWSSDK_FOUND = ${WINDOWSSDK_FOUND}")
    message(STATUS "WindowsSDK_INCLUDE_DIRS :")
    foreach(inc ${WindowsSDK_INCLUDE_DIRS})
        message(STATUS ${inc})
    endforeach()
    message(STATUS "WindowsSDK_LIBRARIES :")
    foreach(lib ${WindowsSDK_LIBRARIES})
        message(STATUS ${lib})
    endforeach()
endif()