# Push a notification to the phone via ntfy.sh.
# Topic is secret (it's the only auth) — set NTFY_TOPIC in ~/.secrets/ntfy.sh.
ntfy() {
    if [[ -z "$NTFY_TOPIC" ]]; then
        echo "ntfy: NTFY_TOPIC not set (expected in ~/.secrets/ntfy.sh)" >&2
        return 1
    fi
    curl -s -H "Title: $(hostname -s)" -d "${*:-ping}" "https://ntfy.sh/$NTFY_TOPIC" > /dev/null
}
