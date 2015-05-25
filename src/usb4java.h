/*
 * Copyright (C) 2013 Klaus Reimer (k@ailis.de)
 * Copyright (C) 2013 Luca Longinotti (l@longi.li)
 * See LICENSE.md file for copying conditions
 */

#ifndef USB4JAVA_H
#define USB4JAVA_H

#include <jni.h>
#include <libusb.h>

#define PACKAGE_DIR "org/usb4java"
#define CLASS_PATH(CLASS_NAME) PACKAGE_DIR"/"CLASS_NAME
#define METHOD_NAME(CLASS_NAME, METHOD_NAME) Java_org_usb4java_##CLASS_NAME##_##METHOD_NAME

#define jptr uintptr_t

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

/**
 * Validates that the specified variable is not null.
 *
 * @param ENV
 *            The Java environment.
 * @param VAR
 *            The variable to validate.
 * @param ACTION
 *            The action to perform after throwing an exception.
 */
#define VALIDATE_NOT_NULL(ENV, VAR, ACTION) \
    if (!VAR) \
    { \
        illegalArgument(ENV, #VAR" must not be null"); \
        ACTION; \
    }

/**
 * Validates that the specified field is not already set.
 *
 * @param ENV
 *            The Java environment.
 * @param OBJECT
 *            The object.
 * @param FIELD
 *            The field name.
 * @param ACTION
 *            The action to perform after throwing an exception.
 */
#define VALIDATE_POINTER_NOT_SET(ENV, OBJECT, FIELD, ACTION) \
    if ((*ENV)->GetLongField(ENV, OBJECT, (*ENV)->GetFieldID(ENV, \
        (*ENV)->GetObjectClass(ENV, OBJECT), FIELD, "J"))) \
    { \
        illegalState(ENV, FIELD" is already initialized"); \
        ACTION; \
    }

/**
 * Connects the current thread to the Java environment.
 *
 * @param ENV
 *            A variable of type JNIEnv* to connect with the Java environment.
 * @param RESULT
 *            A variable of type jint to write the result of the GetEnv
 *            call to. This value must be passed to the THREAD_END macro at
 *            the end of the thread.
 */
#define THREAD_BEGIN(ENV, RESULT) \
    RESULT = (*jvm)->GetEnv(jvm, (void **) &ENV, JNI_VERSION_1_6); \
    if (RESULT == JNI_EDETACHED) \
        (*jvm)->AttachCurrentThread(jvm, (void**) &ENV, NULL);

/**
 * Detaches the Java environment from the current thread.
 *
 * @param RESULT
 *            The result from the GetEnv call made in the THREAD_BEGIN macro.
 */
#define THREAD_END(RESULT) \
    if (RESULT == JNI_EDETACHED) (*jvm)->DetachCurrentThread(jvm);

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
