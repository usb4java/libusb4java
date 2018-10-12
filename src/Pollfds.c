/*
 * Copyright (C) 2018 Klaus Reimer (k@ailis.de)
 * See LICENSE.md file for copying conditions
 */

#include "Pollfds.h"
#include "Pollfd.h"

jobject wrapPollfds(JNIEnv* env, const struct libusb_pollfd** list, int size)
{
    jobject pollfds = wrapPointer(env, list, CLASS_PATH("Pollfds"), "pollfdsPointer");
    jclass cls = (*env)->GetObjectClass(env, pollfds);
    jfieldID field = (*env)->GetFieldID(env, cls, "size", "I");
    (*env)->SetIntField(env, pollfds, field, size);
    return pollfds;
}

const struct libusb_pollfd** unwrapPollfds(JNIEnv* env, jobject pollfds)
{
    return (const struct libusb_pollfd **) unwrapPointer(env, pollfds, "pollfdsPointer");
}

void resetPollfds(JNIEnv* env, jobject object)
{
    RESET_POINTER(env, object, "pollfdsPointer");
}

/**
 * Pollfd get(index)
 */
JNIEXPORT jobject JNICALL METHOD_NAME(Pollfds, get)
(
    JNIEnv *env, jobject this, jint index
)
{
    jclass cls;
    const struct libusb_pollfd** list;
    jfieldID field;
    int size;

    list = unwrapPollfds(env, this);
    if (!list) return NULL;

    cls = (*env)->GetObjectClass(env, this);
    field = (*env)->GetFieldID(env, cls, "size", "I");
    size = (*env)->GetIntField(env, this, field);
    if (index < 0 || index >= size) return NULL;

    return wrapPollfd(env, list[index]);
}
