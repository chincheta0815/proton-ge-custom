#ifndef __PWASIO_PWASIO_H__
#define __PWASIO_PWASIO_H__

#ifndef __clang__
#define nullptr ((void*)0)
#endif

#ifdef __GNUC__
#  define UNUSED(x) x ## _UNUSED __attribute__((__unused__))
#else
#  define UNUSED(x) x
#endif

#ifdef __GNUC__
#  define UNUSED_FUNCTION(x) __attribute__((__unused__)) x ## _UNUSED
#else
#  define UNUSED_FUNCTION(x) x
#endif

#include <unknwn.h>
#include <stdbool.h>

static GUID const class_id = {
    0x9d9612bc,
    0xcadd,
    0x43a2,
    {0xaa, 0x6f, 0x59, 0xf6, 0xac, 0xa4, 0xfe, 0x74},
};

struct factory {
  struct IClassFactoryVtbl *vtbl;
  LONG ref;
  HINSTANCE hinst;
};

HRESULT WINAPI CreateInstance(LPCLASSFACTORY, LPUNKNOWN, REFIID, LPVOID *);

#ifdef DEBUG
#include <wine/debug.h>
#else
#define WINE_DEFAULT_DEBUG_CHANNEL(...)
#define WINE_TRACE(...)
#define WINE_WARN(...)
#define WINE_ERR(...)
#endif

#endif // !__PWASIO_PWASIO_H__
