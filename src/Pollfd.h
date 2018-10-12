/*
 * Copyright (C) 2018 Klaus Reimer (k@ailis.de)
 * See LICENSE.md file for copying conditions
 */

#ifndef USB4JAVA_POLLFD_H
#define USB4JAVA_POLLFD_H

#include "usb4java.h"

jobject wrapPollfd(JNIEnv*, const struct libusb_pollfd*);
const struct libusb_pollfd* unwrapPollfd(JNIEnv*, jobject);
void resetPollfd(JNIEnv*, jobject);

#endif
