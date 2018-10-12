/*
 * Copyright (C) 2018 Klaus Reimer (k@ailis.de)
 * See LICENSE.md file for copying conditions
 */

#include "Pollfd.h"

jobject wrapPollfd(JNIEnv* env, const struct libusb_pollfd* pollfd)
{
    return wrapPointer(env, pollfd, CLASS_PATH("Pollfd"), "pollfdPointer");
}

const struct libusb_pollfd* unwrapPollfd(JNIEnv* env, jobject pollfd)
{
    return (struct libusb_pollfd *) unwrapPointer(env, pollfd, "pollfdPointer");
}

void resetPollfd(JNIEnv* env, jobject object)
{
    RESET_POINTER(env, object, "pollfdPointer");
}

/**
 * int fd()
 */
JNIEXPORT jint JNICALL METHOD_NAME(Pollfd, fd)
(
    JNIEnv *env, jobject this
)
{
    const struct libusb_pollfd* descriptor = unwrapPollfd(env, this);
    if (!descriptor) return 0;
    return (jint) descriptor->fd;
}

/**
 * int events()
 */
JNIEXPORT jshort JNICALL METHOD_NAME(Pollfd, events)
(
    JNIEnv *env, jobject this
)
{
    const struct libusb_pollfd* descriptor = unwrapPollfd(env, this);
    if (!descriptor) return 0;
    return (jshort) descriptor->events;
}
