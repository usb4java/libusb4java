file(GLOB_RECURSE USB4JAVA_SOURCES *.c)
add_library(usb4java SHARED ${USB4JAVA_SOURCES})
target_link_libraries(usb4java ${LibUsb_LIBRARIES})
install(TARGETS usb4java DESTINATION lib)
