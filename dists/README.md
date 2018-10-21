This directory contains the build scripts used by the usb4java CI server to
automatically build the native libraries shipped with usb4java.

If you want to build your own native library for a platform which is not
supported by usb4java out-of-the-box then this might be the wrong place for
you.  Follow the instructions in the README.md file in the root directory of
the project instead.

The bundle script can be used to create a distribution bundle ready to be
uploaded to Sonatype Nexus. It requires already build and deployed SNAPSHOT
versions of all the native JARs.
