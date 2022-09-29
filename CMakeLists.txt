cmake_minimum_required(VERSION 3.0.0)
project(easyconf
    VERSION 1.0.0
    DESCRIPTION "Lightweight C library to manage simple configuration files"
    HOMEPAGE_URL "https://github.com/hoot-w00t/easyconf"
    LANGUAGES "C")

include(CheckCCompilerFlag)
include(GNUInstallDirs)
include(CTest)

enable_testing()

include_directories("${CMAKE_CURRENT_SOURCE_DIR}/include")

# Library sources
set(EASYCONF_SOURCES
    src/easyconf.c
    src/getline.c
    src/parameter.c)

# Unit tests sources
set(EASYCONF_TESTS_SOURCES
    tests/easyconf_tests.c
    tests/getline_tests.c
    tests/parameter_tests.c)

# easyconf library
add_library(easyconf ${EASYCONF_SOURCES})
set_target_properties(easyconf PROPERTIES PUBLIC_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/include/easyconf.h")

# easyconf.pc
set(EASYCONF_SOURCE_PKGCONF "${CMAKE_CURRENT_SOURCE_DIR}/pkgconf/easyconf.pc.in")
set(EASYCONF_PKGCONF "${CMAKE_CURRENT_BINARY_DIR}/pkgconf/easyconf.pc")
configure_file(${EASYCONF_SOURCE_PKGCONF} ${EASYCONF_PKGCONF} @ONLY)

# Criterion unit tests
option(ENABLE_UNIT_TESTS "Enable unit testing with Criterion" OFF)
if (ENABLE_UNIT_TESTS)
    find_library(CRITERION_FOUND criterion REQUIRED)
    add_executable(easyconf_tests ${EASYCONF_TESTS_SOURCES})
    target_link_libraries(easyconf_tests easyconf criterion)

    add_test(NAME easyconf_unit_tests
             COMMAND ${CMAKE_CURRENT_BINARY_DIR}/easyconf_tests
             WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

# Install rules
install(TARGETS easyconf
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/easyconf)
install(FILES ${EASYCONF_PKGCONF}
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)

# Compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wshadow -Wformat-security")

check_c_compiler_flag("-pipe" cc_pipe)
if (cc_pipe)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pipe")
endif()

# If no build type was specified we will use the default
set(default_build_type "Debug")
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "No build type was specified, defaulting to '${default_build_type}'")
    set(CMAKE_BUILD_TYPE "${default_build_type}")
endif()

# Build type flags
set(CMAKE_C_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_C_FLAGS_MINSIZEREL "-Os")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g")
set(CMAKE_C_FLAGS_RELEASE "-O2")
set(CMAKE_C_FLAGS_NATIVERELEASE "-O2 -march=native")
set(CMAKE_C_FLAGS_HARDENED "-O2 -g -fstack-protector-strong -D_FORTIFY_SOURCE=2")

# Format and display the compiler and linker flags
string(TOUPPER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_UPPER)
string(STRIP "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}" EASYCONF_COMPILER_FLAGS)
string(STRIP "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}" EASYCONF_LINKER_FLAGS)
message(STATUS "Compiler flags: ${EASYCONF_COMPILER_FLAGS}")
message(STATUS "Linker flags: ${EASYCONF_LINKER_FLAGS}")

# CPack variables must be set before including it
include(CPack)