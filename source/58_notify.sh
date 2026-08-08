# Push a notification to the phone via Pushover.
# Keys live in ~/.secrets/pushover.sh (they're the only auth).
notify() {
    if [[ -z "$PUSHOVER_USER" || -z "$PUSHOVER_TOKEN" ]]; then
        echo "notify: PUSHOVER_USER/PUSHOVER_TOKEN not set (expected in ~/.secrets/pushover.sh)" >&2
        return 1
    fi
    curl -s \
        --form-string "token=$PUSHOVER_TOKEN" \
        --form-string "user=$PUSHOVER_USER" \
        --form-string "title=$(hostname -s)" \
        --form-string "message=${*:-ping}" \
        https://api.pushover.net/1/messages.json > /dev/null
}
