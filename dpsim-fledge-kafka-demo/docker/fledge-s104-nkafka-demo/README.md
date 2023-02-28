
# Configuration

These are instructions for the configuration options of the [`Dockerfile`](Dockerfile) for Fledge.

### `jq` command line tool

The jq command line tool can be very helpful for making the data used by fledge readable.
Some configuration and data fields of fledge are JSON strings which themselves contain serialized json.
To expand such a JSON object into a more readable form `jq` comes in handy.

This walks through every element in a JSON structure and tries to parse it as JSON.
Pipe a JSON stream into it or pass an input file as an additional parameter.

```shell
FLEDGE_API="http://localhost:8081/fledge"

curl -sX GET "$FLEDGE_API/category/sIEC104/exchanged_data" |\
    jq --raw-input 'def expand: walk((fromjson? | expand) // .); expand'
```

You should also consider using `--compact-output` and `--unbuffered` where sensible.

## Kafka

The kafka configuration is very basic. Fledge only supports plaintext transmission.

### [`broker`](fledge-config/kafka/broker)

The Kafka bootstrap server to connect to. This is a comma separated list of `IP:PORT`.

### [`topic`](fledge-config/kafka/topic)

The Kafka topic to send data on.

## IEC104

The IEC104 south plugin has 3 configuration options.
These are strings containing serialized json.
All of these can be set directly with `IEC104_[OPTION]`.
For readablity plain, unescaped json is far more readable.
This can be specified with `IEC104_[OPTION]_JSON`.
If you prefer, a configuration file can be mounted into the container for each of these settings.
The root of the configuration directory is at `$FLEDGE_CONFIG`.
You can specify a path to the configuration file with `IEC104_[OPTION]_JSON_FILE`.
The path can be absolute or realtive to `$FLEDGE_CONFIG`.

### [`exchanged_data`](fledge-config/iec104/exchanged_data.json)

This option lists all types of known/accepted ASDUs and the mapping to their reading's label.

`jq` is also an especially helpful tool to generate the mapping array, e.g.:

```shell
jq -n '
[
    range(15)
    | [2 * ., tostring + "-real"], [2 * . + 1, tostring + "-imag"]
    | {
        "ca": 41025,
        "type_id": "M_ME_TF_1",
        "label": (if .[0] < 20 then "0" + .[1] else .[1] end),
        "ioa": (4202832 + .[0])
    }
]'
```

### [`protocol_stack`](fledge-config/iec104/protocol_stack.json)

The protocol stack configuration configures the `lib60870` library.
It contains timeouts, timestamp behaviour and the list of known endpoints.

### [`protocol_translation`](fledge-config/iec104/protocol_translation.json)

The protocol translation defines which protocol metadata (timestamps, IOAs, CAs, etc.) is translated to a Fledge Datapoint.

### [`tls`](fledge-config/iec104/tls.json)

The tls configuration is used when tls has been enabled in the `protocol_stack`.
