/*
 * Copyright (C) 2013 Klaus Reimer (k@ailis.de)
 * See LICENSE.md file for copying conditions
 */

#include "DeviceList.h"
#include "Device.h"

void setDeviceList(JNIEnv* env, libusb_device* const *list, jint size, jobject object)
{
    jclass cls;
    jfieldID field;

    SET_POINTER(env, list, object, "deviceListPointer");

    cls = (*env)->GetObjectClass(env, object);
    field = (*env)->GetFieldID(env, cls, "size", "I");
    (*env)->SetIntField(env, object, field, size);
}

libusb_device** unwrapDeviceList(JNIEnv* env, jobject list)
{
    return (libusb_device **) unwrapPointer(env, list, "deviceListPointer");
}

void resetDeviceList(JNIEnv* env, jobject object)
{
    jclass cls;
    jfieldID field;

    RESET_POINTER(env, object, "deviceListPointer");

    cls = (*env)->GetObjectClass(env, object);
    field = (*env)->GetFieldID(env, cls, "size", "I");
    (*env)->SetIntField(env, object, field, 0);
}

/**
 * Device get(index)
 */
JNIEXPORT jobject JNICALL METHOD_NAME(DeviceList, get)
(
    JNIEnv *env, jobject this, jint index
)
{
    jclass cls;
    libusb_device* const *list;
    jfieldID field;
    int size;

    list = unwrapDeviceList(env, this);
    if (!list) return NULL;

    cls = (*env)->GetObjectClass(env, this);
    field = (*env)->GetFieldID(env, cls, "size", "I");
    size = (*env)->GetIntField(env, this, field);
    if (index < 0 || index >= size) return NULL;

    return wrapDevice(env, list[index]);
}
