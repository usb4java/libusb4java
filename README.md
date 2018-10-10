This is the source code of the JNI wrapper for libusb. usb4java
already includes prebuilt libraries for the following platforms:

* linux-x86
* linux-x86-64
* linux-arm
* linux-aarch64
* win32-x86
* win32-x86-64
* darwin-x86-64

If you need the library on an other platform then you can easily compile it
yourself.  On a Unix-compatible operating system you only need the Java JDK,
an up-to-date libusb library version, the GNU C compiler and cmake.  When
everything is correctly installed then you should be able to build the
library with the following commands:

    $ mkdir build
    $ cd build
    $ cmake ..
    $ make

When compilation was successful then you can find the library in the
`build/src` directory.

usb4java searches for the library in the CLASSPATH directory
`org/libusb4java/<OS>-<ARCH>/`. On a 32 bit x86 linux machine for
example the directory name is `org/libusb4java/linux-x86`. Usually
you can find the required name in the exception thrown by usb4java when it
does not find the required library.
