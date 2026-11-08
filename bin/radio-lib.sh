# radio-lib.sh — shared helpers, sourced by the radio scripts.
# All audio goes through one permanent mpv (radio-mpv.service), controlled over its IPC socket.
. /etc/alarm-radio.conf
RUN=/run/alarm-radio
SOCK=$RUN/mpv.sock
TONE=/usr/local/share/alarm-radio/keepalive.wav

# mpv_cmd '<json array>' — send one command to mpv, print the JSON reply
mpv_cmd() { echo "{\"command\":$1}" | socat -t 2 - "UNIX-CONNECT:$SOCK" 2>/dev/null; }

# mpv_get <property> — print the value (raw JSON), nothing if unavailable
mpv_get() { mpv_cmd "[\"get_property\",\"$1\"]" | sed -n 's/^{"data":\(.*\),"request_id".*/\1/p'; }

# mpv_load <url> <volume> [fade-sec] [extra "key":"value" options]
# Per-file options (volume, fade filter, loop) are reset by mpv when the next file loads.
mpv_load() {
    local opts="\"volume\":\"$2\""
    [ "${3:-0}" -gt 0 ] && opts="$opts,\"af\":\"lavfi=[afade=t=in:d=$3:curve=qua]\""
    [ -n "${4:-}" ] && opts="$opts,$4"
    mpv_cmd "[\"loadfile\",\"$1\",\"replace\",-1,{$opts}]" | grep -q '"success"'
}

mpv_playing() { [ "$(mpv_get idle-active)" = false ]; }
mpv_path() { mpv_get path | tr -d '"'; }

# A radio/alarm player (radio-player) is running — the keep-alive stays out of the way.
player_active() { [ -f "$RUN/player.pid" ] && kill -0 "$(cat "$RUN/player.pid")" 2>/dev/null; }

speaker_connected() { bluetoothctl info "$SPEAKER_MAC" 2>/dev/null | grep -q "Connected: yes"; }
pcm_ready() { bluealsa-cli list-pcms 2>/dev/null | grep -q "dev_${SPEAKER_MAC//:/_}/a2dpsrc/sink"; }
