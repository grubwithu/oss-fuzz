targets=(bloaty curl freetype2 harfbuzz jsoncpp lcms libjpeg-turbo libpcap libpng libxml2 libxslt mbedtls openssl openthread proj4 re2 sqlite3 systemd vorbis woff2 zlib)

sudo rm -rf build/

docker build --no-cache -t gcr.io/oss-fuzz-base/base-clang infra/base-images/base-clang
docker build --no-cache -t gcr.io/oss-fuzz-base/base-builder infra/base-images/base-builder

for target in "${targets[@]}"
do
	echo $target is building...
	infra/helper.py build_fuzzers $target 1>/dev/null 2>&1
	echo $target built with exited code $?
done

