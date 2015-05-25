/*
 * Copyright (C) 2013 Klaus Reimer (k@ailis.de)
 * Copyright (C) 2013 Luca Longinotti (l@longi.li)
 * See LICENSE.md file for copying conditions
 */

#include "usb4java.h"
#include <stdarg.h>
#include <stdio.h>

JavaVM *jvm = NULL;

jclass jClassLibUsb = NULL;
jmethodID jMethodTriggerPollfdAdded = NULL;
jmethodID jMethodTriggerPollfdRemoved = NULL;
jmethodID jMethodHotplugCallback = NULL;

jint illegalArgument(JNIEnv *env, const char *message, ...)
{
    char tmp[256];
    va_list args;

    va_start(args, message);
    vsnprintf(tmp, 256, message, args);
    va_end(args);
    return (*env)->ThrowNew(env, (*env)->FindClass(env,
        "java/lang/IllegalArgumentException"), tmp);
}

jint illegalState(JNIEnv *env, const char *message, ...)
{
    char tmp[256];
    va_list args;

    va_start(args, message);
    vsnprintf(tmp, 256, message, args);
    va_end(args);
    return (*env)->ThrowNew(env, (*env)->FindClass(env,
        "java/lang/IllegalStateException"), tmp);
}

jobject NewDirectReadOnlyByteBuffer(JNIEnv *env, const void *mem,
    int mem_length)
{
    jobject buffer = (*env)->NewDirectByteBuffer(env, (void *) mem, mem_length);

    // Get a read-only buffer from this buffer.
    jclass cls = (*env)->GetObjectClass(env, buffer);
    jmethodID method = (*env)->GetMethodID(env, cls, "asReadOnlyBuffer",
        "()Ljava/nio/ByteBuffer;");
    return (*env)->CallObjectMethod(env, buffer, method);
}

jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved)
{
    JNIEnv *env;
    jint getEnvResult;

    // Set JVM to the current one.
    jvm = vm;

    // Get the current environment.
    getEnvResult = (*vm)->GetEnv(vm, (void **) &env, JNI_VERSION_1_6);
    if (getEnvResult != JNI_OK)
    {
        // Send unrecognized version to signal error and deny library load.
        return -1;
    }

    // Find classes and methods and cache them.
    // Persistence is guaranteed by global references.
    jClassLibUsb = (*env)->FindClass(env, CLASS_PATH("LibUsb"));
    jClassLibUsb = (*env)->NewGlobalRef(env, jClassLibUsb);

    jMethodTriggerPollfdAdded = (*env)->GetStaticMethodID(env, jClassLibUsb,
        "triggerPollfdAdded", "(Ljava/io/FileDescriptor;IJ)V");
    jMethodTriggerPollfdRemoved = (*env)->GetStaticMethodID(env, jClassLibUsb,
        "triggerPollfdRemoved", "(Ljava/io/FileDescriptor;J)V");
    jMethodHotplugCallback = (*env)->GetStaticMethodID(env, jClassLibUsb,
        "hotplugCallback", "(L"CLASS_PATH("Context;L")CLASS_PATH("Device;IJ)I"));

    return JNI_VERSION_1_6;
}

void JNICALL JNI_OnUnload(JavaVM *vm, void *reserved)
{
    // Get the current environment.
    JNIEnv *env;
    jint getEnvResult = (*vm)->GetEnv(vm, (void **) &env, JNI_VERSION_1_6);
    if (getEnvResult != JNI_OK)
    {
        return;
    }

    // Cleanup all global references.
    (*env)->DeleteGlobalRef(env, jClassLibUsb);
}

/**
 * Wrap a C pointer with a wrapper Java class and returns the instance of
 * this wrapper class. When the C pointer is null or the wrapper class could
 * not be created then NULL is returned.
 *
 * @param env
 *            The JNI environment.
 * @param ptr
 *            The C pointer to wrap.
 * @param className
 *            The class name of the wrapper class.
 * @param fieldName
 *            The field name for storing the pointer in the wrapper class.
 * @return The instance of the wrapper class or null if C pointer is null or
 *         the wrapper class could not be created.
 */
jobject wrapPointer(JNIEnv *env, const void *ptr, const char *className,
    const char *fieldName)
{
    jclass cls;
    jmethodID constructor;
    jobject object;
    jfieldID field;

    if (!ptr) return NULL;
    cls = (*env)->FindClass(env, className);
    if (cls == NULL) return NULL;
    constructor = (*env)->GetMethodID(env, cls, "<init>", "()V");
    if (!constructor) return NULL;
    object = (*env)->NewObject(env, cls, constructor);
    field = (*env)->GetFieldID(env, cls, fieldName, "J");
    (*env)->SetLongField(env, object, field, (jptr) ptr);
    return object;
}

/**
 * Unwraps a C pointer from a Java wrapper object.
 *
 * @param env
 *            The JNI environment.
 * @param object
 *            The Java wrapper object.
 * @param fieldName
 *            The field name where the C pointer is stored in the wrapper
 *            object.
 * @return The C pointer.
 */
void * unwrapPointer(JNIEnv *env, jobject object, const char *fieldName)
{
    jptr ptr;
    jclass cls;
    jfieldID field;
    if (!object) return NULL;
    cls = (*env)->GetObjectClass(env, object);
    field = (*env)->GetFieldID(env, cls, fieldName, "J");
    ptr = (jptr) (*env)->GetLongField(env, object, field);
    if (!ptr) illegalState(env, "%s is not initialized", fieldName);
    return (void *) ptr;
}
