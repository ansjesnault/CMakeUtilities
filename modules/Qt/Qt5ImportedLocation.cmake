if(NOT WIN32 OR __Qt5ImportedLocation_cmake_INCLUDED__)
	return()
else()
	set(__Qt5ImportedLocation_cmake_INCLUDED__ ON)
endif()

cmake_minimum_required(VERSION 3.0)

## CMAKE_DOCUMENTATION_START fillQt5ImportedLocationList
## Use Internaly for Qt5ImportedLocation function \\n
##
## look for all required filePath modules (components and plugins Qt5 targets)\\n
##
## CMAKE_DOCUMENTATION_END
##	Written by Jerome Esnault
function(fillQt5ImportedLocationList configUC returnedList)
	include(CMakeParseArguments)
	cmake_parse_arguments(qfill "" "" "QT5_MODULES" ${ARGN} )
	foreach(qtComp ${qfill_QT5_MODULES})
		get_target_property(${qtComp}_targ_imp_loc ${qtComp} IMPORTED_LOCATION_${configUC})
		if(${qtComp}_targ_imp_loc)
			if(EXISTS ${${qtComp}_targ_imp_loc})
				list(APPEND moduleList ${${qtComp}_targ_imp_loc})
			else()
				message(WARNING "IMPORTED_LOCATION_${configUC} of ${qtComp} doesn't exist.")
			endif()
		else()
			message(WARNING "IMPORTED_LOCATION_${configUC} of ${qtComp} is empty...")
		endif()
	endforeach()
	if(NOT moduleList)
		set(moduleList )
	endif()
	set(${returnedList} ${moduleList} PARENT_SCOPE)
endfunction()


## CMAKE_DOCUMENTATION_START Qt5ImportedLocation
##	Find where dynamique libraries are stored (return the absolute QT5 BINARY DIR) \\n
##  \\n
##	Find list of dynamique libraries absolute filePathName (*.dll on windows or *.so on UNIX)  \\n
##  	\\tAvailable qt5 components are easy to find as they are named like libraries name (without Qt5 prefix and confiMode suffix)  \\n
##  \\n
##	Find list of plugins absolute filePathName (*.dll on windows or *.so on UNIX)  \\n
##      \\tAvailable qt5 plugins are (Search "_populate_[1-2]*[a-z]*[A-z]*_plugin_properties" in cmake dir of Qt5) :  \\n
##      \\tAxBase plugins :            \\n
##      \\tAxContainer plugins :       \\n
##      \\tAxServer plugins :          \\n
##      \\tBluetooth plugins :         \\n
##      \\tConcurrent plugins :        \\n
##      \\tCore plugins :              \\n
##      \\tDeclarative plugins :       QTcpServerConnection QtQuick1Plugin  						\\n
##      \\tDesigner plugins :          QAxWidgetPlugin QDeclarativeViewPlugin QQuickWidgetPlugin  	\\n
##      \\tGui plugins :               QDDSPlugin  QGifPlugin                  QICNSPlugin QICOPlugin                  QJp2Plugin   	\\n
##                                  QJpegPlugin QMinimalIntegrationPlugin   QMngPlugin  QOffscreenIntegrationPlugin QTgaPlugin  	\\n
##                                  QTiffPlugin QWbmpPlugin                 QWebpPlugin QWindowsIntegrationPlugin					\\n
##      \\tHelp plugins :              \\n
##      \\tLocation plugins :          QGeoServiceProviderFactoryNokia QGeoServiceProviderFactoryOsm  \\n
##      \\tMultiMedia plugins:         AudioCaptureServicePlugin DSServicePlugin QM3uPlaylistPlugin QWindowsAudioPlugin WMFServicePlugin  \\n
##      \\tMultiMediaWidgets plugins:  \\n
##      \\tNetwork plugins :           QGenericEnginePlugin QNativeWifiEnginePlugin\\n
##      \\tNfc plugins :               \\n
##      \\tOpenGL plugins :            \\n
##      \\tOpenGLExtensions plugins :  \\n
##      \\tPositioning plugins :       QGeoPositionInfoSourceFactoryPoll \\n
##      \\tPrintSupport plugins :      QWindowsPrinterSupportPlugin \\n
##      \\tQml plugins :               QTcpServerConnection QtQuick2Plugin \\n
##      \\tQuick plugins :             \\n
##      \\tQuickTest plugins :         \\n
##      \\tQuickWidgets plugins :      \\n
##      \\tScript plugins :            \\n
##      \\tScriptTools plugins :       \\n
##      \\tSensors plugins :           dummySensorPlugin genericSensorPlugin QShakeSensorGesturePlugin QtSensorGesturePlugin \\n
##      \\tSerialPort plugins :        \\n
##      \\tSQL plugins :               QSQLiteDriverPlugin \\n
##      \\tSVG plugins :               QSvgIconPlugin QSvgPlugin \\n
##      \\tTest plugins :              \\n
##      \\tUiTools plugins :           \\n
##      \\tWebChannel plugins :        \\n
##      \\tWebSockets plugins :        \\n
##      \\tWidgets plugins :           \\n
##      \\tWinExtras plugins :         \\n
##      \\tXML plugins :               \\n
##      \\tXMLPatterns plugins :       \\n
## \\n
##Usage examples:
## 	\\code
##	Qt5ImportedLocation( QT5_DYN_LIB_DIR QT5_DYN_LIBS QT5_PLUGINS) 	## default Release with Qt5 Core and associated dependencies \n
##	#<OR>	\n
##	Qt5ImportedLocation( QT5_DYN_LIB_DIR QT5_DYN_LIBS QT5_PLUGINS										\n
##		CONFIG_MODE 	Release Debug																	\n
##		QT5_COMPONENTS	Qt5::Core Qt5::Gui Qt5::Widgets Qt5::OpenGL										\n
##      QT5_PLUGINS     Qt5::QWindowsIntegrationPlugin ## or ${Qt5Gui_PLUGINS} , Qt5<Module>_PLUGINS	\n
##	)	\n
##	message(QT5_DYN_LIB_DIR = ${QT_BINARY_DIR}) \n
##	foreach(lib ${QT5_DYN_LIBS} ${QT5_PLUGINS}) \n
##		message(${lib})							\n
##	endforeach()								\n
##	\\endcode
##  CMAKE_DOCUMENTATION_END
##	Written by Jerome Esnault	
function(Qt5ImportedLocation returnQt5DynDir returnedDynLibsList returnedPluginsList) ## configMode support only Debug or Release
    include(CMakeParseArguments)
	cmake_parse_arguments(qtil "" "" "CONFIG_MODE;QT5_COMPONENTS;QT5_PLUGINS" ${ARGN} )
	if(NOT qtil_CONFIG_MODE)
		if(DEFINED CMAKE_BUILD_TYPE)
			set(qtil_CONFIG_MODE ${CMAKE_BUILD_TYPE})
		else()
			set(qtil_CONFIG_MODE Release Debug)
		endif()
	endif()
	set(Qt5_DYNLIB_DIR 	"")
	set(Qt5_dynLibs		"")
    set(Qt5_plugins		"")
    
    ## default results (in any case there is the Qt5_DYNLIB_DIR and maybe some extras needed dynLibs/plugins)
    foreach(config ${qtil_CONFIG_MODE})
		string(TOUPPER ${config} config_UC)
        get_target_property(Qt5Core_targ_imp_loc Qt5::Core IMPORTED_LOCATION_${config_UC})
        if(Qt5Core_targ_imp_loc)
            get_filename_component(Qt5_DYNLIB_PATH ${Qt5Core_targ_imp_loc} PATH)
            file(GLOB 	Qt5_UCU_DYNLIB_FILES "${Qt5_DYNLIB_PATH}/icu*${CMAKE_SHARED_LIBRARY_SUFFIX}") ## for Qt <= 5.3
            list(APPEND Qt5_dynLibs ${Qt5_UCU_DYNLIB_FILES} ${Qt5Core_targ_imp_loc})
            set(Qt5_DYNLIB_DIR ${Qt5_DYNLIB_PATH}) ## we know debug and release targets are in the same place (this value will not change)
        elseif()
            message(WARNING "Cannot find Qt5::Core IMPORTED_LOCATION_${config_UC}. Qt5_DYNLIB_DIR=${Qt5_DYNLIB_DIR}")
        endif()
	endforeach()
	if(WIN32)
		foreach(config RELEASE DEBUG)
			get_target_property(Qt5WindowsPlugin_targ_imp_loc Qt5::QWindowsIntegrationPlugin IMPORTED_LOCATION_${config})
			if(Qt5WindowsPlugin_targ_imp_loc)
				list(APPEND Qt5_plugins ${Qt5WindowsPlugin_targ_imp_loc})
			else()
				message(WARNING "Cannot find Qt5::QWindowsIntegrationPlugin IMPORTED_LOCATION_${config}.")
			endif()
		endforeach()
	endif()
    
	foreach(config ${qtil_CONFIG_MODE})
		string(TOUPPER ${config} config_UC)
        if(qtil_QT5_COMPONENTS)
            fillQt5ImportedLocationList(${config_UC} Qt5_Comps_dynLibs QT5_MODULES ${qtil_QT5_COMPONENTS} )
            list(APPEND Qt5_dynLibs ${Qt5_Comps_dynLibs})
        endif()
        if(qtil_QT5_PLUGINS)
            fillQt5ImportedLocationList(${config_UC} Qt5_plugins_dynLibs QT5_MODULES ${qtil_QT5_PLUGINS} )
            list(APPEND Qt5_plugins ${Qt5_plugins_dynLibs})
        endif()
	endforeach()

	list(REMOVE_DUPLICATES Qt5_dynLibs)
    list(REMOVE_DUPLICATES Qt5_plugins)
	set(${returnedDynLibsList} 	${Qt5_dynLibs} 		PARENT_SCOPE)
	set(${returnQt5DynDir} 		${Qt5_DYNLIB_DIR} 	PARENT_SCOPE)
    set(${returnedPluginsList} 	${Qt5_plugins} 	    PARENT_SCOPE)
endfunction()