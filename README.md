sweeper
====

sweeper invests your spare cash in a stock of your choice. The sweeper converts your deposit currency and submits a LOC (limit on close) buy order just before the NYSE closing auction each weekday. The sweeper only acts when you have enough spare cash.



    git submodule update --init # if building from git to get oniguruma
    autoreconf -fi              # if building from git
    ./configure --with-oniguruma=builtin
    make -j8
    make check


Modified from https://github.com/UnusualAlpha/ib-gateway-docker

<img src="https://github.com/UnusualAlpha/ib-gateway-docker/blob/master/logo.png" height="300" />
