NDK=${HOME}/Library/Android/sdk/ndk-bundle
ANDROID_VER=23
COMP_VER=4.9
HOST=darwin-x86_64
TARGET=arm-linux-androideabi
COMP_PATH=${NDK}/toolchains/${TARGET}-${COMP_VER}/prebuilt/${HOST}/bin/

export PATH := ${COMP_PATH}:$(PATH)

RACKETDIR=dist/racket-master/racket
LIBRACKET=${RACKETDIR}/lib/libracket3m.a
RACKETINCLUDE=${RACKETDIR}/include
JNI=project/app/src/main/jni
RACKETDEST=${JNI}/racket

.PHONY: build_all
build_all: ${RACKETDEST}/racket_app.c ${RACKETDEST}/libracket3m.a ${RACKETDEST}/include

clean:
	rm -f ${RACKETDEST}/racket_app.c

${RACKETDEST}/racket_app.c: rkt/app.rkt ${RACKETDEST}
	raco ctool --c-mods $@ $<

${RACKETDEST}/libracket3m.a: ${LIBRACKET}
	cp $< $@

${RACKETDEST}/include: ${RACKETINCLUDE}
	cp -r $< $@

${RACKETDEST}:
	mkdir -p $@
	touch $@

${RACKETINCLUDE} ${LIBRACKET}: dist/racket-master
	mkdir -p ${RACKETDIR}/src/build && cd ${RACKETDIR}/src//build && ../configure --host=${TARGET} --enable-sysroot="${NDK}/platforms/android-${ANDROID_VER}/arch-arm" --enable-racket=auto && make && make plain-install # --enable-shared --disable-lt

dist/racket-master: dist/racket-master.zip
	unzip $^ -d dist
	touch $@

dist/racket-master.zip:
	wget https://github.com/racket/racket/archive/master.zip -O $@ || rm -f $@
