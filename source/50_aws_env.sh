function aws-load-env {
    local profile="${1:-default}"

    export TEST_FOO=FOO

    if [[ ${profile} == clear ]]; then
        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
        unset AWS_SESSION_TOKEN
        unset AWS_SECRET_KEY
        echo "Cleared AWS env variables"
    else
        export AWS_ACCESS_KEY_ID="$(aws configure get aws_access_key_id --profile ${profile})"
        export AWS_SECRET_ACCESS_KEY="$(aws configure get aws_secret_access_key --profile ${profile})"
        export AWS_SESSION_TOKEN="$(aws configure get aws_session_token --profile ${profile})" 
        export AWS_SECRET_KEY=${AWS_SECRET_ACCESS_KEY}
        echo "Set AWS env variables for profile '${profile}'"
    fi
}