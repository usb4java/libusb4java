/*
 * Copyright (C) 2013 Klaus Reimer (k@ailis.de)
 * See LICENSE.md file for copying conditions
 */

#include "Context.h"

void setContext(JNIEnv* env, const libusb_context* context, jobject object)
{
    SET_POINTER(env, context, object, "contextPointer");
}

jobject wrapContext(JNIEnv* env, const libusb_context* context)
{
    return wrapPointer(env, context, CLASS_PATH("Context"), "contextPointer");
}

libusb_context* unwrapContext(JNIEnv* env, jobject context)
{
    return (libusb_context *) unwrapPointer(env, context, "contextPointer");
}

void resetContext(JNIEnv* env, jobject obj)
{
    RESET_POINTER(env, obj, "contextPointer");
}
