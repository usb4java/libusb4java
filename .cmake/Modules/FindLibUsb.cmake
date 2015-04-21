# This module defines:
#
#   LibUsb_LIBRARIES         : The libraries to link against
#   LibUsb_INCLUDE_DIRS      : The directories to include
#   LibUsb_LIBRARY_FOUND     : Library found or not
#   LibUsb_INCLUDE_DIR_FOUND : Include directory was found or not
#   LibUsb_FOUND             : All files found or not
#
# If libusb is not found automatically then the locations can be manually 
# specified by defining:
#
#   LibUsb_LIBRARY     : The libusb library to link against
#   LibUsb_INCLUDE_DIR : The include directory containing libusb-1.0/libusb.h
#
# ============================================================================
# Copyright (C) 2013 Klaus Reimer (k@ailis.de)
# See COPYING file for copying conditions.
# ============================================================================

find_path(LibUsb_INCLUDE_DIR 
    NAMES
        libusb-1.0/libusb.h
    HINTS
        /usr/local/include
)

find_library(LibUsb_LIBRARY
    NAMES
        usb-1.0 
        usb
    HINTS
        /usr/local/lib
)

if(LibUsb_INCLUDE_DIR AND EXISTS "${LibUsb_INCLUDE_DIR}/libusb-1.0/libusb.h")
    message(STATUS "Found libusb-1.0/libusb.h in ${LibUsb_INCLUDE_DIR}")
    set(LibUsb_INCLUDE_DIR_FOUND TRUE)
else()
    message(STATUS "libusb-1.0/libusb.h not found")
    set(LibUsb_INCLUDE_DIR_FOUND FALSE)
endif()

if(LibUsb_LIBRARY AND EXISTS "${LibUsb_LIBRARY}")
    message(STATUS "Found libusb: ${LibUsb_LIBRARY}")
    set(LibUsb_LIBRARY_FOUND TRUE)
else()
    message(STATUS "libusb library not found")
    set(LibUsb_LIBRARY_FOUND FALSE)
endif()

if (LibUsb_INCLUDE_DIR_FOUND AND LibUsb_LIBRARY_FOUND)
    set(LibUsb_FOUND TRUE)
else()
    set(LibUsb_FOUND FALSE)
endif()

if(NOT LibUsb_FOUND AND LibUsb_FIND_REQUIRED)
    message(FATAL_ERROR "Could not find required libusb")
endif()

set(LibUsb_INCLUDE_DIRS
    ${LibUsb_INCLUDE_DIR}
)

set(LibUsb_LIBRARIES
    ${LibUsb_LIBRARY}
)
