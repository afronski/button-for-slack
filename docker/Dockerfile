FROM lambci/lambda-base:build

RUN set -e \
   && yum -y install \
      ncurses-devel

ARG OTP_VERSION="21.1.1"

RUN set -e \
        && OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" \
        && OTP_DOWNLOAD_SHA256="a6588243e9659960e184083f49b15ea37890e4cd9bb8aef84ba4180db68befc3" \
        && curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
        && echo "$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - \
        && export ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" \
        && mkdir -vp $ERL_TOP \
        && tar -xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 \
        && rm otp-src.tar.gz \
        && ( cd $ERL_TOP \
             && ./otp_build autoconf \
             && ./configure --without-termcap --without-javac --without-wx --without-odbc --without-observer --without-debugger --without-et \
             && make -j$(nproc) \
             && make install ) \
        && find /usr/local -name examples | xargs rm -rf

CMD ["erl"]

ENV REBAR_VERSION="2.6.4"

RUN set -xe \
        && REBAR_DOWNLOAD_URL="https://github.com/rebar/rebar/archive/${REBAR_VERSION}.tar.gz" \
        && REBAR_DOWNLOAD_SHA256="577246bafa2eb2b2c3f1d0c157408650446884555bf87901508ce71d5cc0bd07" \
        && mkdir -p /usr/src/rebar-src \
        && curl -fSL -o rebar-src.tar.gz "$REBAR_DOWNLOAD_URL" \
        && echo "$REBAR_DOWNLOAD_SHA256 rebar-src.tar.gz" | sha256sum -c - \
        && tar -xzf rebar-src.tar.gz -C /usr/src/rebar-src --strip-components=1 \
        && rm rebar-src.tar.gz \
        && cd /usr/src/rebar-src \
        && ./bootstrap \
        && install -v ./rebar /usr/local/bin/ \
        && rm -rf /usr/src/rebar-src

ARG REBAR3_VERSION="3.6.2"

RUN set -xe \
        && REBAR3_DOWNLOAD_URL="https://github.com/erlang/rebar3/archive/${REBAR3_VERSION}.tar.gz" \
        && REBAR3_DOWNLOAD_SHA256="7f358170025b54301bce9a10ec7ad07d4e88a80eaa7b977b73b32b45ea0b626e" \
        && mkdir -p /usr/src/rebar3-src \
        && curl -fSL -o rebar3-src.tar.gz "$REBAR3_DOWNLOAD_URL" \
        && echo "$REBAR3_DOWNLOAD_SHA256 rebar3-src.tar.gz" | sha256sum -c - \
        && tar -xzf rebar3-src.tar.gz -C /usr/src/rebar3-src --strip-components=1 \
        && rm rebar3-src.tar.gz \
        && cd /usr/src/rebar3-src \
        && HOME=$PWD ./bootstrap \
        && install -v ./rebar3 /usr/local/bin/ \
        && rm -rf /usr/src/rebar3-src

ARG ELIXIR_VERSION=1.8.0
ENV LANG=en_US.UTF-8 \
        LANGUAGE=en_US.UTF-8 \
        LC_ALL=en_US.UTF-8

ENV MIX_REBAR3=/usr/local/bin/rebar3
ENV MIX_REBAR=/usr/local/bin/rebar

RUN set -xe \
        && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/v${ELIXIR_VERSION}.tar.gz" \
        && ELIXIR_DOWNLOAD_SHA256="fe896d8b2914f982d2e6fceeb585f59a8f92ad872653fc46c13df9ff86d69234" \
        && curl -fsSL $ELIXIR_DOWNLOAD_URL -o elixir-src.tar.gz \
        && echo "$ELIXIR_DOWNLOAD_SHA256 elixir-src.tar.gz" | sha256sum -c - \
        && mkdir -p /usr/src/elixir-src \
        && tar -xzf elixir-src.tar.gz -C /usr/src/elixir-src --strip-components=1 \
        && rm elixir-src.tar.gz \
        && cd /usr/src/elixir-src \
        && make -j$(nproc) \
        && make install \
        && rm -rf /usr/src/elixir-src \
        && cd $HOME \
        && mix local.hex --force \
        && mix hex.info
