# This module defines:
#
#   LibUdev_LIBRARIES         : The libraries to link against
#   LibUdev_INCLUDE_DIRS      : The directories to include
#   LibUdev_LIBRARY_FOUND     : Library found or not
#   LibUdev_INCLUDE_DIR_FOUND : Include directory was found or not
#   LibUdev_FOUND             : All files found or not
#
# If libudev is not found automatically then the locations can be manually 
# specified by defining:
#
#   LibUdev_LIBRARY     : The libudev library to link against
#   LibUdev_INCLUDE_DIR : The include directory containing libudev.h
#
# ============================================================================
# Copyright (C) 2013 Klaus Reimer (k@ailis.de)
# See COPYING file for copying conditions.
# ============================================================================

find_path(LibUdev_INCLUDE_DIR 
    NAMES
        libudev.h
    HINTS
        /usr/local/include
)

find_library(LibUdev_LIBRARY
    NAMES
        udev
    HINTS
        /usr/local/lib
)

if(LibUdev_INCLUDE_DIR AND EXISTS "${LibUdev_INCLUDE_DIR}/libudev.h")
    message(STATUS "Found libudev.h in ${LibUdev_INCLUDE_DIR}")
    set(LibUdev_INCLUDE_DIR_FOUND TRUE)
else()
    message(STATUS "libudev.h not found")
    set(LibUdev_INCLUDE_DIR_FOUND FALSE)
endif()

if(LibUdev_LIBRARY AND EXISTS "${LibUdev_LIBRARY}")
    message(STATUS "Found libudev: ${LibUdev_LIBRARY}")
    set(LibUdev_LIBRARY_FOUND TRUE)
else()
    message(STATUS "libudev library not found")
    set(LibUdev_LIBRARY_FOUND FALSE)
endif()

if (LibUdev_INCLUDE_DIR_FOUND AND LibUdev_LIBRARY_FOUND)
    set(LibUdev_FOUND TRUE)
else()
    set(LibUdev_FOUND FALSE)
endif()

if(NOT LibUdev_FOUND AND LibUdev_FIND_REQUIRED)
    message(FATAL_ERROR "Could not find required libudev")
endif()

set(LibUdev_INCLUDE_DIRS
    ${LibUdev_INCLUDE_DIR}
)

set(LibUdev_LIBRARIES
    ${LibUdev_LIBRARY}
)
