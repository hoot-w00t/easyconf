cmake_minimum_required(VERSION 3.13.0)
project(easyconf
    VERSION 1.0.0
    DESCRIPTION "Lightweight C library to manage simple configuration files"
    HOMEPAGE_URL "https://github.com/hoot-w00t/easyconf"
    LANGUAGES "C")

include(CheckCCompilerFlag)
include(GNUInstallDirs)
include(CTest)

enable_testing()

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

# Compiler flags
option(EASYCONF_COMPILE_PIC "Compile library with position independent code" OFF)
set(EASYCONF_INCLUDE_DIRS "")
set(EASYCONF_C_FLAGS_OPT "")
set(EASYCONF_C_FLAGS "")
set(EASYCONF_LINKER_FLAGS "")

list(APPEND EASYCONF_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/include")

check_c_compiler_flag("-pipe" cc_pipe)
check_c_compiler_flag("-Wcast-qual" cc_wcast_qual)
check_c_compiler_flag("-Wpointer-arith" cc_wpointer_arith)
check_c_compiler_flag("-Wwrite-strings" cc_wwrite_strings)
check_c_compiler_flag("-fstack-protector" cc_stack_protector)

if (cc_pipe)
    list(APPEND EASYCONF_C_FLAGS "-pipe")
endif()

list(APPEND EASYCONF_C_FLAGS "-pedantic" "-Wall" "-Wextra" "-Wshadow" "-Wformat-security")
if (cc_wcast_qual)
    list(APPEND EASYCONF_C_FLAGS "-Wcast-qual")
endif()
if (cc_wpointer_arith)
    list(APPEND EASYCONF_C_FLAGS "-Wpointer-arith")
endif()
if (cc_wwrite_strings)
    list(APPEND EASYCONF_C_FLAGS "-Wwrite-strings")
endif()
if (cc_stack_protector)
    list(APPEND EASYCONF_C_FLAGS "-fstack-protector-strong" "-Wstack-protector")
endif()

list(APPEND EASYCONF_C_FLAGS_OPT "-D_FORTIFY_SOURCE=2")

# If no build type was specified we will use the default
set(default_build_type "Debug")
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "No build type was specified, defaulting to '${default_build_type}'")
    set(CMAKE_BUILD_TYPE "${default_build_type}")
endif()

# Build type flags
set(CMAKE_C_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_C_FLAGS_MINSIZEREL "-Os ${EASYCONF_C_FLAGS_OPT}")
set(CMAKE_C_FLAGS_RELEASE "-O2 ${EASYCONF_C_FLAGS_OPT}")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELEASE} -g")

# easyconf.pc
set(EASYCONF_SOURCE_PKGCONF "${CMAKE_CURRENT_SOURCE_DIR}/pkgconf/easyconf.pc.in")
set(EASYCONF_PKGCONF "${CMAKE_CURRENT_BINARY_DIR}/pkgconf/easyconf.pc")
configure_file(${EASYCONF_SOURCE_PKGCONF} ${EASYCONF_PKGCONF} @ONLY)

# Library
add_library(easyconf ${EASYCONF_SOURCES})
target_include_directories(easyconf PRIVATE ${EASYCONF_INCLUDE_DIRS})
target_compile_options(easyconf PRIVATE ${EASYCONF_C_FLAGS})
target_link_options(easyconf PRIVATE ${EASYCONF_LINKER_FLAGS})
set_target_properties(easyconf PROPERTIES PUBLIC_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/include/easyconf.h")
if (EASYCONF_COMPILE_PIC)
    set_target_properties(easyconf PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
endif()

# Unit tests
option(ENABLE_UNIT_TESTS "Enable unit testing with Criterion" OFF)
if (ENABLE_UNIT_TESTS)
    find_library(CRITERION_FOUND criterion REQUIRED)
    add_executable(easyconf_tests ${EASYCONF_TESTS_SOURCES})
    target_include_directories(easyconf_tests PRIVATE ${EASYCONF_INCLUDE_DIRS})
    target_compile_options(easyconf_tests PRIVATE ${EASYCONF_C_FLAGS})
    target_link_options(easyconf_tests PRIVATE ${EASYCONF_LINKER_FLAGS})
    target_link_libraries(easyconf_tests easyconf criterion)
    if (EASYCONF_COMPILE_PIC)
        set_target_properties(easyconf_tests PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
    endif()

    add_test(NAME easyconf_unit_tests
             COMMAND easyconf_tests
             WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

# Install rules
install(TARGETS easyconf
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/easyconf)
install(FILES ${EASYCONF_PKGCONF}
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)

# Format and display the compiler and linker flags
string(TOUPPER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_UPPER)
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Compile PIC: ${EASYCONF_COMPILE_PIC}")
message(STATUS "C flags: ${CMAKE_C_FLAGS}")
message(STATUS "C flags (build type): ${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}")
message(STATUS "C flags (easyconf): ${EASYCONF_C_FLAGS}")
message(STATUS "Linker flags: ${CMAKE_EXE_LINKER_FLAGS}")
message(STATUS "Linker flags (build type): ${CMAKE_EXE_LINKER_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}")
message(STATUS "Linker flags (easyconf): ${EASYCONF_LINKER_FLAGS}")

# CPack variables must be set before including it
include(CPack)
