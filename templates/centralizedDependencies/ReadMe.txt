All 3rdParty for the whole project are centralized :
* All find CMake modules in one place (generaly top root project level /cmake)
* All cached otions set at the same place (higher level of CMakeLists.txt to be inherited for all sub CMakeLists.txt) and to define which sub project to load for build or not (with default values)
* Only one CMake file which do all find modules according to cached options set (resulting of a list of cmake includes / defines / libraries variables to use for sub cmakelists.txt projects)

=> Advantages : 
 * CMakeLists.txt lower level are very small and similar each other (where only project specific variable are set)
 * CMake modules are all in same place and ease the uniformization and maintenability of 3rdParty
 * windows / linux and mac specification as well as install and package steps could be handle in advance at higher cmake level to ease the creation of low level sub project

=> Drawbacks :
 * User who will write a sub CMakeLists.txt project have to know which cmake variables are inherited to be used at this level (it may confuse and/or force to read/edit the cmake 3rdParty part => may introduce conflicts if many developpers want to add many sub-projects)
 * As more there will be optional specific sub-projects as more we will have cached options to managed and so as difficult it will be to maintain the overall project (at this point we could think about the use of submodules) 