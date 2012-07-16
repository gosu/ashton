#ifndef COMMON_H
#define COMMON_H

#include <ruby.h>

#if defined(WIN32) || defined(__linux) || defined(__FreeBSD__)
#  include <GL/gl.h>
#else
#  include <OpenGL/gl.h>
#endif

typedef unsigned int uint;
typedef unsigned long ulong;

#endif // COMMON_H