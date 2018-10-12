/*
 * Copyright (C) 2018 Klaus Reimer (k@ailis.de)
 * See LICENSE.md file for copying conditions
 */

#ifndef USB4JAVA_POLLFDS_H
#define USB4JAVA_POLLFDS_H

#include "usb4java.h"

jobject wrapPollfds(JNIEnv*, const struct libusb_pollfd**, int size);
const struct libusb_pollfd** unwrapPollfds(JNIEnv*, jobject);
void resetPollfds(JNIEnv*, jobject);

#endif
