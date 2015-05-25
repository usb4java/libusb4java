/*
 * Copyright (C) 2013 Luca Longinotti (l@longi.li)
 * See LICENSE.md file for copying conditions
 */

#include "HotplugCallbackHandle.h"

void setHotplugCallbackHandle(JNIEnv* env, const libusb_hotplug_callback_handle hotplugHandle,
    jobject object)
{
    SET_POINTER(env, hotplugHandle, object, "hotplugCallbackHandleValue");
}

libusb_hotplug_callback_handle unwrapHotplugCallbackHandle(JNIEnv* env, jobject hotplugHandle)
{
    jclass cls;
    jfieldID field;
    jlong val;

    // Hotplug callback handles are integers, starting at 1. As such, we can use the same logic
    // as for pointers, and consider 0 to be uninitialized/invalid.
    if (!hotplugHandle) return 0;
    cls = (*env)->GetObjectClass(env, hotplugHandle);
    field = (*env)->GetFieldID(env, cls, "hotplugCallbackHandleValue", "J");
    val = (*env)->GetLongField(env, hotplugHandle, field);
    if (!val) illegalState(env, "hotplugCallbackHandleValue is not initialized");
    return (libusb_hotplug_callback_handle) val;
}

void resetHotplugCallbackHandle(JNIEnv* env, jobject hotplugHandle)
{
    RESET_POINTER(env, hotplugHandle, "hotplugCallbackHandleValue");
}
