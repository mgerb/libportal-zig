#pragma once

// Zig's translate-c has trouble with some C macros. We disable some things
// here as a result.

#define GLIB_VERSION_MIN_REQUIRED 144896
#define GLIB_VERSION_MAX_ALLOWED 144896

#define __GLIB_H_INSIDE__
#include <glib/gmacros.h>
#undef __GLIB_H_INSIDE__

#undef G_GNUC_BEGIN_IGNORE_DEPRECATIONS
#undef G_GNUC_END_IGNORE_DEPRECATIONS
#define G_GNUC_BEGIN_IGNORE_DEPRECATIONS
#define G_GNUC_END_IGNORE_DEPRECATIONS

#undef _GLIB_DEFINE_AUTOPTR_CLEANUP_FUNCS
#undef _GLIB_DEFINE_AUTOPTR_CHAINUP
#undef G_DEFINE_AUTOPTR_CLEANUP_FUNC
#undef G_DEFINE_AUTO_CLEANUP_CLEAR_FUNC
#undef G_DEFINE_AUTO_CLEANUP_FREE_FUNC
#define _GLIB_DEFINE_AUTOPTR_CLEANUP_FUNCS(TypeName, ParentName, cleanup)
#define _GLIB_DEFINE_AUTOPTR_CHAINUP(ModuleObjName, ParentName)
#define G_DEFINE_AUTOPTR_CLEANUP_FUNC(TypeName, func)
#define G_DEFINE_AUTO_CLEANUP_CLEAR_FUNC(TypeName, func)
#define G_DEFINE_AUTO_CLEANUP_FREE_FUNC(TypeName, func, none)

#undef glib_typeof

#define __GI_SCANNER__
#include <libportal/portal.h>
#undef __GI_SCANNER__
