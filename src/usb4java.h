/*
 * Copyright (C) 2013 Klaus Reimer (k@ailis.de)
 * Copyright (C) 2013 Luca Longinotti (l@longi.li)
 * See COPYING file for copying conditions
 */

#ifndef USB4JAVA_H
#define USB4JAVA_H

#include <jni.h>
#include <libusb.h>
#include "config.h"

#define PACKAGE_DIR "org/usb4java"
#define CLASS_PATH(CLASS_NAME) PACKAGE_DIR"/"CLASS_NAME
#define METHOD_NAME(CLASS_NAME, METHOD_NAME) Java_org_usb4java_##CLASS_NAME##_##METHOD_NAME

#if SIZEOF_VOID_P == 4
#  define jptr jint
#elif SIZEOF_VOID_P == 8
#  define jptr jlong
#endif

/**
 * Sets a pointer address in an object field.
 *
 * @param ENV
 *            The Java environment.
 * @param PTR
 *            The pointer address to set.
 * @param OBJECT
 *            The Java object.
 * @param FIELD
 *            The Java object field name.
 */
#define SET_POINTER(ENV, PTR, OBJECT, FIELD) \
    (*ENV)->SetLongField(ENV, OBJECT, (*ENV)->GetFieldID(ENV, \
        (*ENV)->GetObjectClass(ENV, OBJECT), FIELD, "J"), (jptr) PTR);

/**
 * Resets a pointer address in an object field to 0.
 *
 * @param ENV
 *            The Java environment.
 * @param OBJECT
 *            The Java object.
 * @param FIELD
 *            The Java object field name.
 */
#define RESET_POINTER(ENV, OBJECT, FIELD) SET_POINTER(ENV, 0, OBJECT, FIELD)

/**
 * Validates that the specified buffer (returned from GetDirectBufferAddress)
 * is a direct buffer (It will be null if it is not).
 *
 * @param ENV
 *            The Java environment.
 * @param BUFFER
 *            The buffer to check.
 * @param NAME
 *            The buffer name to use in the exception thrown when the buffer
 *            is invalid.
 * @param ACTION
 *            The action to perform after throwing an exception.
 */
#define VALIDATE_DIRECT_BUFFER(ENV, BUFFER, NAME, ACTION) \
    if (!BUFFER) \
    { \
        illegalArgument(ENV, NAME" must be a direct buffer"); \
        ACTION; \
    }

#define NOT_NULL(ENV, VAR, ACTION) \
    if (!VAR) \
    { \
        illegalArgument(ENV, #VAR" must not be null"); \
        ACTION; \
    }

#define NOT_SET(ENV, VAR, FIELD, ACTION) \
    jclass cls = (*ENV)->GetObjectClass(ENV, VAR); \
    jfieldID field = (*ENV)->GetFieldID(ENV, cls, FIELD, "J"); \
    jptr ptr = (jptr) (*ENV)->GetLongField(ENV, VAR, field); \
    if (ptr) \
    { \
        illegalState(ENV, FIELD" is already initialized"); \
        ACTION; \
    }

#define THREAD_BEGIN(ENV) \
    JNIEnv *ENV; \
    jint getEnvResult = (*jvm)->GetEnv(jvm, (void **) &ENV, JNI_VERSION_1_6); \
    if (getEnvResult == JNI_EDETACHED) \
        (*jvm)->AttachCurrentThread(jvm, (void**) &ENV, NULL);

#define THREAD_END \
    if (getEnvResult == JNI_EDETACHED) \
        (*jvm)->DetachCurrentThread(jvm);

// JVM access.
extern JavaVM *jvm;

// Callback caching.
extern jclass jClassLibUsb;
extern jmethodID jMethodTriggerPollfdAdded;
extern jmethodID jMethodTriggerPollfdRemoved;
extern jmethodID jMethodHotplugCallback;

jobject wrapPointer(JNIEnv *env, const void *ptr, const char *className,
    const char *fieldName);
void * unwrapPointer(JNIEnv *env, jobject object, const char *fieldName);
jint illegalArgument(JNIEnv *env, const char *message, ...);
jint illegalState(JNIEnv *env, const char *message, ...);
jobject NewDirectReadOnlyByteBuffer(JNIEnv *env, const void *mem,
    int mem_length);

#endif
