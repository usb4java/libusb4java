/*
 * Copyright (C) 2013 Klaus Reimer (k@ailis.de)
 * See LICENSE.md file for copying conditions
 */

#include "Device.h"

jobject wrapDevice(JNIEnv* env, const libusb_device* device)
{
    return wrapPointer(env, device, CLASS_PATH("Device"), "devicePointer");
}

libusb_device* unwrapDevice(JNIEnv* env, jobject device)
{
    return (libusb_device *) unwrapPointer(env, device, "devicePointer");
}

void resetDevice(JNIEnv* env, jobject object)
{
    RESET_POINTER(env, object, "devicePointer");
}
