/*
 * Copyright (C) 2013 Klaus Reimer (k@ailis.de)
 * See LICENSE.md file for copying conditions
 */

#include "DeviceHandle.h"

void setDeviceHandle(JNIEnv* env, const libusb_device_handle* deviceHandle,
    jobject object)
{
    SET_POINTER(env, deviceHandle, object, "deviceHandlePointer");
}

jobject wrapDeviceHandle(JNIEnv* env, const libusb_device_handle* deviceHandle)
{
    return wrapPointer(env, deviceHandle, CLASS_PATH("DeviceHandle"),
        "deviceHandlePointer");
}

libusb_device_handle* unwrapDeviceHandle(JNIEnv* env, jobject deviceHandle)
{
    return (libusb_device_handle *) unwrapPointer(env, deviceHandle,
        "deviceHandlePointer");
}

void resetDeviceHandle(JNIEnv* env, jobject object)
{
    RESET_POINTER(env, object, "deviceHandlePointer");
}
