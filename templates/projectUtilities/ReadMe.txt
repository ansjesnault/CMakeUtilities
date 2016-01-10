A cmake abstraction of cmake to ease the creation of a c++ SDK :
* a few list of cmake functions / macros and template .in file to create c++ projects in very few lines of cmake code
* created initialy under linux (with RPATH management, SDK versionning and installation, and cluster deployement) but could be used under any supported cmake platform

Advantages : 
* Unified and easy to use/read with smmall piece of cmake
* Powerful to create openSource C++ SDK to be used by another cmake project (an external cmake project could easily integrate this project as 3rdParty)

DrawBacks :
* Many cmake specifications hided from platform. So not very flexible for projects requiering specific cmake settings (not designed for other purppose that c++ SDK).
* Not very easy to maintain in parallel of the new cmake versions/features evolutions (internaly needed of updates)