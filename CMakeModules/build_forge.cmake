INCLUDE(ExternalProject)

SET(prefix ${CMAKE_BINARY_DIR}/third_party/forge)

IF(CMAKE_VERSION VERSION_LESS 3.2)
    IF(CMAKE_GENERATOR MATCHES "Ninja")
        MESSAGE(WARNING "Building forge with Ninja has known issues with CMake older than 3.2")
    endif()
    SET(byproducts)
ELSE()
    SET(byproducts BYPRODUCTS ${forge_location})
ENDIF()

# FIXME Tag forge correctly during release
ExternalProject_Add(
    forge-ext
    GIT_REPOSITORY https://github.com/arrayfire/forge.git
    GIT_TAG d58557f130548980af32fc562830c119f9bf71ef
    PREFIX "${prefix}"
    INSTALL_DIR "${prefix}"
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -Wno-dev "-G${CMAKE_GENERATOR}" <SOURCE_DIR>
    -DCMAKE_SOURCE_DIR:PATH=<SOURCE_DIR>
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DUSE_GLEWmx_STATIC:BOOL=${USE_GLEWmx_STATIC}
    -DGLEW_ROOT_DIR:STRING=${GLEW_ROOT_DIR}
    -DGLFW_ROOT_DIR:STRING=${GLFW_ROOT_DIR}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DBUILD_EXAMPLES:BOOL=OFF
    ${byproducts}
    )

ExternalProject_Get_Property(forge-ext binary_dir)
ExternalProject_Get_Property(forge-ext install_dir)
ADD_LIBRARY(forge SHARED IMPORTED)
SET_TARGET_PROPERTIES(forge PROPERTIES IMPORTED_LOCATION ${binary_dir}/src/libforge.so)
IF(WIN32)
    SET_TARGET_PROPERTIES(forge PROPERTIES IMPORTED_IMPLIB ${prefix}/lib/forge.lib)
ELSE(WIN32)
    IF(APPLE)
	SET_TARGET_PROPERTIES(forge PROPERTIES IMPORTED_LOCATION ${binary_dir}/src/libforge.dylib)
    ELSE(APPLE)
	SET_TARGET_PROPERTIES(forge PROPERTIES IMPORTED_LOCATION ${binary_dir}/src/libforge.so)
    ENDIF(APPLE)
ENDIF(WIN32)
ADD_DEPENDENCIES(forge forge-ext)
SET(FORGE_INCLUDE_DIRECTORIES ${install_dir}/include)
SET(FORGE_LIBRARIES forge)
SET(FORGE_FOUND ON)
