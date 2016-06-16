export CLOUD_SDK_DIR="$HOME/src/google-cloud-sdk"
if [ -d "${CLOUD_SDK_DIR}" ]; then
  # The next line updates PATH for the Google Cloud SDK.
  export PATH=${CLOUD_SDK_DIR}/bin:${PATH}

  alias gce="gcloud compute"
fi
if [ -r "${CLOUD_SDK_DIR}/completion.bash.inc" ]; then
  source "${CLOUD_SDK_DIR}/completion.bash.inc"
fi

function gcloud-docker-logs {
  local dayago
  if [ $(uname -s) = "Darwin" ]; then
    dayago=$(date -v-1d -u '+%Y-%m-%dT%H:%M:%SZ')
  else
    dayago=$(date  --date="-1 day" -Isec -u)
  fi

  gcloud beta logging read \
    --order ASC \
    --format='value(timestamp, jsonPayload.data)' \
    "jsonPayload.container.name=\"/$1\" AND timestamp > \"${dayago}\""
}
