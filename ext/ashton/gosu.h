/*
 * module Gosu being extended.
 *
 */


#ifndef GOSU_H
#define GOSU_H

#include "common.h"

static VALUE rb_mGosu;

#include "color.h"
#include "font.h"
#include "image.h"
#include "window.h"

void Init_Gosu();

#endif // GOSU_H