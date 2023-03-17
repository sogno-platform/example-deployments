FLEDGE_API="http://localhost:8081/fledge"

main () {
    configure-environment
    configure-kafka
    configure-iec104
}

configure-environment () {
    pushd "$FLEDGE_CONFIG" > /dev/null

    KAFKA_BROKER="${KAFKA_BROKER:-$(
        cat "${KAFKA_BROKER_FILE:-/dev/null}" 2> /dev/null
    )}"
    KAFKA_TOPIC="${KAFKA_TOPIC:-$(
        cat "${KAFKA_TOPIC_FILE:-/dev/null}" 2> /dev/null
    )}"
    IEC104_PROTOCOL_STACK_JSON="${IEC104_PROTOCOL_STACK_JSON:-$(
        cat "${IEC104_PROTOCOL_STACK_JSON_FILE:-/dev/null}" 2> /dev/null
    )}"
    IEC104_PROTOCOL_STACK="${IEC104_PROTOCOL_STACK:-$(
        printf "%s" "$IEC104_PROTOCOL_STACK_JSON" | jq tojson | sed -e 's|^.||' -e 's|.$||'
    )}"
    IEC104_EXCHANGED_DATA_JSON="${IEC104_EXCHANGED_DATA_JSON:-$(
        cat "${IEC104_EXCHANGED_DATA_JSON_FILE:-/dev/null}" 2> /dev/null
    )}"
    IEC104_EXCHANGED_DATA="${IEC104_EXCHANGED_DATA:-$(
        printf "%s" "$IEC104_EXCHANGED_DATA_JSON" | jq tojson | sed -e 's|^.||' -e 's|.$||'
    )}"
    IEC104_PROTOCOL_TRANSLATION_JSON="${IEC104_PROTOCOL_TRANSLATION_JSON:-$(
        cat "${IEC104_PROTOCOL_TRANSLATION_JSON_FILE:-/dev/null}" 2> /dev/null
    )}"
    IEC104_PROTOCOL_TRANSLATION="${IEC104_PROTOCOL_TRANSLATION:-$(
        printf "%s" "$IEC104_PROTOCOL_TRANSLATION_JSON" | jq tojson | sed -e 's|^.||' -e 's|.$||'
    )}"
    IEC104_TLS_JSON="${IEC104_TLS_JSON:-$(
        cat "${IEC104_TLS_JSON_FILE:-/dev/null}" 2> /dev/null
    )}"
    IEC104_TLS="${IEC104_TLS:-$(
        printf "%s" "$IEC104_TLS_JSON" | jq tojson | sed -e 's|^.||' -e 's|.$||'
    )}"

    popd > /dev/null
}

configure-kafka () {
    check-environment KAFKA_BROKER KAFKA_TOPIC
    fledge-create-service       nKafka  "north"     "Kafka"
    fledge-configure-service    nKafka  "brokers"   "$KAFKA_BROKER"
    fledge-configure-service    nKafka  "topic"     "$KAFKA_TOPIC"
    fledge-configure-service    nKafka  "json"      "Objects"
    fledge-enable-service       nKafka
}

configure-iec104 () {
    check-environment IEC104_PROTOCOL_STACK IEC104_EXCHANGED_DATA IEC104_PROTOCOL_TRANSLATION IEC104_TLS
    fledge-create-service       sIEC104 "south"                 "iec104"
    fledge-configure-service    sIEC104 "protocol_stack"        "$IEC104_PROTOCOL_STACK"
    fledge-configure-service    sIEC104 "exchanged_data"        "$IEC104_EXCHANGED_DATA"
    fledge-configure-service    sIEC104 "protocol_translation"  "$IEC104_PROTOCOL_TRANSLATION"
    fledge-configure-service    sIEC104 "tls"                   "$IEC104_TLS"
    fledge-enable-service       sIEC104
}

# ---- HELPER FUNCTIONS ----

# check if environment variables are empty
check-environment () {
    for VARIABLE in "$@" ; do
        if [ -z "$(eval echo \$$VARIABLE)" ]; then
            printf "environment variable '%s' not configured\n" "$VARIABLE"
        fi
    done
}

# wait for the API to be available
fledge-wait-for-api () {
    printf "%s" "Waiting for Fledge ."
    while ! curl -sX GET "$FLEDGE_API/service" > /dev/null ; do
        sleep 1
        printf "."
    done
    printf "\n"
}

# create a service
# $1 - new name
# $2 - type (north,south,filter,...)
# $3 - plugin (iec104,Kafka,...)
fledge-create-service () {
    if curl -sX GET "$FLEDGE_API/service" |\
       jq -e ".services | any(.name = \"$1\") | not" > /dev/null ; then
        printf "service %s already exists\n" "$1"
        return
    fi

    curl -sX POST "$FLEDGE_API/service" -d '{
        "name":"'"$1"'",
        "type":"'"$2"'",
        "plugin":"'"$3"'",
        "enabled":"false"
    }' && echo

    if [ $? -ne 0 ]; then
        printf "could not create service %s\n" "$1"
        exit 1
    fi
}

# configure a service
# $1 - name of the service
# $2 - configuration key
# $3 - new value
fledge-configure-service () {
    if [ -z "${3:+x}" ]; then
        return
    fi

    curl -sX PUT "$FLEDGE_API/category/$1/$2" -d '{
        "value":"'"$3"'"
    }' && echo

    if [ $? -ne 0 ]; then
        printf "could not configure option '%s' of service '%s'\n" "$2" "$1"
        exit 1
    fi
}

# configure a service
# $1 - name of the service
fledge-enable-service () {
    curl -sX PUT "$FLEDGE_API/schedule/enable" -d '{
        "schedule_name":"'"$1"'"
    }' && echo

    if [ $? -ne 0 ]; then
        printf "could not enable service '%s'\n" "$1"
        exit 1
    fi
}

# call 'configure-fledge' when API is up
fledge-wait-for-api && main "$@"
