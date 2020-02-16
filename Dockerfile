FROM tarantool/tarantool:2.2.1 

RUN set -x \
    && apk add --no-cache --virtual .build-deps \
        git \
        cmake \
        make \
        gcc \
        g++ \
    && cd /opt/tarantool/ \
    && tarantoolctl rocks install http 2.0.1\
    && : "---------- remove build deps ----------" \
    && apk del .build-deps

COPY . /opt/tarantool
