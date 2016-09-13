dnl AC_CHECK_STATICLIB(LIBRARY, FUNCTION [, ACTION-IF-FOUND
dnl		 [, ACTION-IF-NOT-FOUND  [, OTHER-LIBRARIES]]])
dnl Like AC_CHECK_LIB but looking for static libraries.
dnl LIBRARY must be of the form libxxx.a.
dnl The current language must be C (AC_LANG_C).
AC_DEFUN([AC_CHECK_STATICLIB],
[AC_MSG_CHECKING([for $2 in $1])
dnl Use a cache variable name containing both the library and function name,
dnl because the test really is for library $1 defining function $2, not
dnl just for library $1.  Separate tests with the same $1 and different $2s
dnl may have different results.
ac_lib_var=`echo $1['_']$2 | sed 'y%./+-%__p_%'`
AC_CACHE_VAL(ac_cv_lib_static_$ac_lib_var,
if test -r /etc/ld.so.conf ; then
  ld_so_paths="/lib /usr/lib `cat /etc/ld.so.conf`"
else
  ld_so_paths="/lib /usr/lib"
fi
for path in $ld_so_paths; do
  [ac_save_LIBS="$LIBS"
  LIBS="$path/$1 $5 $LIBS"
  AC_TRY_LINK(dnl
  ifelse([$2], [main], , dnl Avoid conflicting decl of main.
  [/* Override any gcc2 internal prototype to avoid an error.  */
  ]dnl
  [/* We use char because int might match the return type of a gcc2
      builtin and then its argument prototype would still apply.  */
  char $2();
  ]),
	      [$2()],
	      eval "ac_cv_lib_static_$ac_lib_var=$path/$1",
	      eval "ac_cv_lib_static_$ac_lib_var=no")
  LIBS="$ac_save_LIBS"
  if eval "test \"`echo '$ac_cv_lib_static_'$ac_lib_var`\" != no"; then
    break
  fi
done
])dnl
eval result=\"`echo '$ac_cv_lib_static_'$ac_lib_var`\"
if test "$result" != no; then
  AC_MSG_RESULT($result)
  ifelse([$3], ,
[changequote(, )dnl
  ac_tr_lib=HAVE_`echo $1 | sed -e 's/[^a-zA-Z0-9_]/_/g' \
    -e 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/'`
changequote([, ])dnl
  AC_DEFINE_UNQUOTED($ac_tr_lib, 1, Define if static library is available.)
  LIBS="$result $LIBS"
], [$3])
else
  AC_MSG_RESULT(no)
ifelse([$4], , , [$4
])dnl
fi
])

AC_DEFUN([BASH_CHECK_GETPW_FUNCS],
[AC_MSG_CHECKING(whether programs are able to redeclare getpw functions)
AC_CACHE_VAL(bash_cv_can_redecl_getpw,
[AC_TRY_COMPILE([#include <sys/types.h>
#include <pwd.h>
extern struct passwd *getpwent();
extern struct passwd *getpwuid();
extern struct passwd *getpwnam();],
[struct passwd *z; z = getpwent(); z = getpwuid(0); z = getpwnam("root");],
  bash_cv_can_redecl_getpw=yes,bash_cv_can_redecl_getpw=no)])
AC_MSG_RESULT($bash_cv_can_redecl_getpw)
if test $bash_cv_can_redecl_getpw = no; then
AC_DEFINE([HAVE_GETPW_DECLS], 1, [Define this when you are able to redeclare getpw functions.])
fi
])
