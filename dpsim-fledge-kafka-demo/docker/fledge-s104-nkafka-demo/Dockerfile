FROM ubuntu:20.04

# fledge installation
ARG FLEDGE_VERSION="1.9.2"
ARG FLEDGE_INSTALL_DIR="/usr/local/fledge"
ARG FLEDGE_DEFAULT_CONFIG="/fledge-default-config"

ENV DEBIAN_FRONTEND="noninteractive"

# install dependencies
RUN \
    apt-get update && apt-get install --no-install-recommends --yes \
    avahi-daemon \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    cmake \
    cpulimit \
    curl \
    git \
    jq \
    krb5-user \
    libboost-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libcurl4-openssl-dev \
    libpq-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libz-dev \
    pkg-config \
    python3-dev \
    python3-pip \
    python3-numpy \
    rsyslog \
    sqlite3 \
    uuid-dev

RUN pip3 install --upgrade pip

# fix the default `rsyslog` conf for use in containers.
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

WORKDIR /tmp/fledge

ARG MAKEFLAGS=""

# install Fledge
#
# Why does `make install` not install every component of fledge (e.g. headers)?
# Why does `make` call `cmake` to call `make`? The build process seems really convoluted.
# Why does the `requirements.sh` build a static sqlite3?
RUN \
    git clone "https://github.com/fledge-iot/fledge.git" "${FLEDGE_INSTALL_DIR}" && \
    cd "${FLEDGE_INSTALL_DIR}" && \
    git checkout "v${FLEDGE_VERSION}" && \
    make $MAKEFLAGS

ENV \
    FLEDGE_ROOT="${FLEDGE_INSTALL_DIR}" \
    PATH="${FLEDGE_ROOT}/bin:${PATH}"

# install librdkafka
RUN \
    git clone https://github.com/edenhill/librdkafka.git && \
    cd librdkafka && \
    git checkout "v1.8.2" && \
    ./configure && \
    make $MAKEFLAGS && make install

# install north plugin
RUN \
    git clone "https://github.com/fledge-iot/fledge-north-kafka.git" nkafka && \
    cd nkafka && \
    git checkout "v${FLEDGE_VERSION}" && \
    # The `CMakeLists.txt` has a hardcoded path to `/usr/local/include/librdkafka/`
    # which does not work with the headers from `librdkafka-dev` in `/usr/include/`
    sed -i "s|<rdkafka.h>|<librdkafka/rdkafka.h>|" include/kafka.h && \
    mkdir build && cd build && \
    cmake -DFLEDGE_INSTALL="${FLEDGE_ROOT}" .. && \
    make $MAKEFLAGS && make install

# install lib60870
RUN \
    git clone "https://github.com/mz-automation/lib60870.git" lib60870 && \
    cd lib60870 && \
    git checkout "63481bd35aff1db8b397d712401e9ef2f0d23a5c" && \
    mkdir build && cd build && \
    cmake ../lib60870-C && \
    make $MAKEFLAGS && make install

# install south plugin
#
# Why does `fledge-south-iec104` not have releases with corresponding tags?
#
# The sed script fixes a segfault and incorrect labels being assigned when an ASDU carries multiple IOAs
RUN \
    git clone "https://github.com/fledge-iot/fledge-south-iec104.git" siec104 && \
    cd siec104 && \
    git checkout "15841bde3d1a96633c4beefe0716b000e249edf3" && \
    sed -i \
        -e 's|auto\* header_dp = new Datapoint("data_object_header", header_dpv);|auto header_dp = Datapoint{"data_object_header", header_dpv};|' \
        -e 's|Datapoint\* item_dp|auto item_dp|' \
        -e 's|Reading reading(dataName, {header_dp, item_dp});|Reading reading(item_dp.first, {new Datapoint(header_dp), item_dp.second});|' \
        -e 's|vector<Datapoint *\*> datapoints|vector<pair<string, Datapoint*>> datapoints|' \
        -e 's|vector<Datapoint *\*>& datapoints|vector<pair<string, Datapoint*>>\& datapoints|' \
        -e 's|datapoints.push_back(new Datapoint("data_object_item", dpv));|datapoints.push_back(make_pair(dataname, new Datapoint("data_object_item", dpv)));|' \
        iec104.cpp && \
    sed -i \
        -e 's|std::vector<Datapoint *\*>|std::vector<std::pair<std::string, Datapoint*>>|' \
        include/iec104.h && \
    mkdir build && cd build && \
    cmake -DFLEDGE_INSTALL="${FLEDGE_ROOT}" .. && \
    make $MAKEFLAGS && make install

# cleanup the plugin builds
WORKDIR $FLEDGE_ROOT
RUN rm -rf /tmp/fledge

COPY configure-fledge.bash /
COPY fledge-config $FLEDGE_DEFAULT_CONFIG

# default configuration file paths (relative to $FLEDGE_CONFIG)
ENV \
    FLEDGE_CONFIG="$FLEDGE_DEFAULT_CONFIG" \
    KAFKA_BROKER_FILE="kafka/broker" \
    KAFKA_TOPIC_FILE="kafka/topic" \
    IEC104_PROTOCOL_STACK_JSON_FILE="iec104/protocol_stack.json" \
    IEC104_EXCHANGED_DATA_JSON_FILE="iec104/exchanged_data.json" \
    IEC104_PROTOCOL_TRANSLATION_JSON_FILE="iec104/protocol_translation.json" \
    IEC104_TLS_JSON_FILE="iec104/tls.json"

EXPOSE 161 162 1995 6683 8080 8081

CMD \
    # Start rsyslog for logging
    # `service rsyslogd start` and `rsyslogd` hang and hog a cpu core
    rsyslogd -n & \
    # Start the fledge service
    # Why does this fail/return non-zero?
    ./scripts/fledge start || true && \
    # Configure fledge using the REST API
    bash /configure-fledge.bash && \
    # This does not react to a failed fledge service thus
    # a cluster running this container will not be informed
    # should the fledge service fail.
    tail -f /var/log/syslog
