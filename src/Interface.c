/*
 * Copyright (C) 2013 Klaus Reimer (k@ailis.de)
 * See LICENSE.md file for copying conditions
 */

#include "Interface.h"
#include "InterfaceDescriptor.h"

jobject wrapInterface(JNIEnv *env, const struct libusb_interface *iface)
{
    return wrapPointer(env, iface, CLASS_PATH("Interface"),
        "interfacePointer");
}

jobjectArray wrapInterfaces(JNIEnv *env, int count,
    const struct libusb_interface *interfaces)
{
    jobjectArray array = (jobjectArray) (*env)->NewObjectArray(env,
        count, (*env)->FindClass(env, CLASS_PATH("Interface")),
        NULL);
    for (int i = 0; i < count; i++)
        (*env)->SetObjectArrayElement(env, array, i,
            wrapInterface(env, &interfaces[i]));

    return array;
}

struct libusb_interface *unwrapInterface(JNIEnv *env, jobject iface)
{
    return (struct libusb_interface *) unwrapPointer(env, iface,
        "interfacePointer");
}

JNIEXPORT jint JNICALL METHOD_NAME(Interface, numAltsetting)
(
    JNIEnv *env, jobject this
)
{
    struct libusb_interface* interface = unwrapInterface(env, this);
    if (!interface) return 0;
    return interface->num_altsetting;
}

JNIEXPORT jobjectArray JNICALL METHOD_NAME(Interface, altsetting)
(
    JNIEnv *env, jobject this
)
{
    struct libusb_interface* interface = unwrapInterface(env, this);
    if (!interface) return NULL;
    return wrapInterfaceDescriptors(env, interface->num_altsetting,
        interface->altsetting);
}
