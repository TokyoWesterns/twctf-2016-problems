PHP_ARG_ENABLE(hastur, whether to enable Hastur support,
[ --enable-hastur   Enable Hastur support])

if test "$PHP_HASTUR" = "yes"; then
  AC_DEFINE(HAVE_HASTUR, 1, [Whether you have Hastur])
  PHP_NEW_EXTENSION(hastur, hastur.c, $ext_shared)
fi

export CPPFLAGS="$CPPFLAGS -U_FORTIFY_SOURCE"

