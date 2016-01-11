#!/bin/sh
basedir=`dirname "$0"`

case `uname` in
    *CYGWIN*) basedir=`cygpath -w "$basedir"`;;
esac

if [ -x "$basedir/node" ]; then
  "$basedir/node"  "$basedir/node_modules/http-server/bin/http-server" "$@"
  ret=$?
else 
  node  "$basedir/node_modules/http-server/bin/http-server" "$@"
  ret=$?
fi
exit $ret
