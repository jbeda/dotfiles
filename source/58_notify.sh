# Phone notification helpers. Credentials live in ~/.secrets/ (ntfy.sh,
# pushover.sh) since the ntfy topic and Pushover keys are the only auth.

# Preferred: Pushover — reliable APNs delivery on iOS.
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

# Fallback: ntfy.sh — iOS push delivery is flaky, kept for non-Apple targets.
ntfy() {
    if [[ -z "$NTFY_TOPIC" ]]; then
        echo "ntfy: NTFY_TOPIC not set (expected in ~/.secrets/ntfy.sh)" >&2
        return 1
    fi
    curl -s -H "Title: $(hostname -s)" -d "${*:-ping}" "https://ntfy.sh/$NTFY_TOPIC" > /dev/null
}
