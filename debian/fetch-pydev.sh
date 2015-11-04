#!/bin/sh

set -e

NAME=eclipse-pydev
VERSION=87087f1f782778f3894eae914d760667ba38d016
DEB_VERSION=3.9.2

GIT_WEB=https://github.com/fabioz/Pydev

OUT_DIR=${NAME}-${VERSION}

downloadSnapshot() {
	VERSION_UNDERSCORE=$(echo $VERSION | sed "s/\./_/g")
	SRC_DIR=Pydev-$VERSION_UNDERSCORE
	TARBALL=$VERSION_UNDERSCORE.tar.gz

	rm -rf $OUT_DIR
	wget "$GIT_WEB/archive/$TARBALL"
	tar xf $TARBALL
	rm -f $TARBALL
	mv $SRC_DIR $OUT_DIR
}

downloadSnapshot

cd $OUT_DIR

find -type f \( -name .gitignore -o -name .cvsignore \) -delete

# We don't need these
rm -rf builders make_release.py fix_new_lines.py
rm -rf plugins/org.python.pydev.core/lib

# No binary junk, please
find -type f -iregex '.*/.*\.\(jar\|so\|exe\|dll\)' -delete
rm -f plugins/org.python.pydev/tests/pysrc/configobj-*.egg

# Bye bye, bundled Jython
rm -rf plugins/org.python.pydev.jython/src_jython \
       plugins/org.python.pydev.jython/Lib \
       plugins/org.python.pydev.jython/LICENSE_JYTHON.txt \
       plugins/org.python.pydev.jython/LICENSE_PYHON.txt # Not a typo!

rm -rf plugins/com.python.pydev.docs \
       plugins/org.python.pydev/pysrc/third_party/pep8/lib2to3 \
       plugins/org.python.pydev/pysrc/third_party/wrapped_for_pydev/ctypes \
       plugins/org.python.pydev/pysrc/third_party/wrapped_for_pydev/not_in_default_pythonpath.txt

# Some useless Windows-specific process attach code
rm -rf plugins/org.python.pydev/pysrc/pydevd_attach_to_process/dll \
       plugins/org.python.pydev/pysrc/pydevd_attach_to_process/winappdbg

# Delete empty directories
find -depth -type d -empty -delete

cd ..

ORIG_TARBALL=${NAME}_${DEB_VERSION}.orig.tar.xz

echo "Creating tarball '$ORIG_TARBALL'..."
tar -cJf ../$ORIG_TARBALL $OUT_DIR

rm -rf $OUT_DIR
