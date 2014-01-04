export CLOUD_SDK_DIR="$HOME/src/google-cloud-sdk"
if [ -d "${CLOUD_SDK_DIR}" ]; then
    # The next line updates PATH for the Google Cloud SDK.
    export PATH=${CLOUD_SDK_DIR}/bin:${PATH}
fi
