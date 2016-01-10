if(__set_policies_INCLUDED__)
	return()
else()
	set(__set_policies_INCLUDED__ ON)
endif()

## To keep project entierly compatible with differents version of CMAKE
macro(setPolicies )
	## since cmake 2.8.11
	## NEW = link executables to qtmain.lib automatically when they link to QtCore IMPORTED target
	if(POLICY CMP0020)
		cmake_policy(SET CMP0020 NEW)
	endif()

	## since cmake 3.0.0
	## NEW = Ignore COMPILE_DEFINITIONS_<Config> properties
	if(POLICY CMP0043) 
	  cmake_policy(SET CMP0043 NEW)
	endif()
endmacro()