function aws-load-env {
    local profile="${1:-default}"

    if [[ ${profile} == clear ]]; then
        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
        unset AWS_SESSION_TOKEN
        unset AWS_SECRET_KEY
        echo "Cleared AWS env variables"
    else
        local AWS_ACCESS_KEY_ID="$(aws configure get aws_access_key_id --profile ${profile})"
        local AWS_SECRET_ACCESS_KEY="$(aws configure get aws_secret_access_key --profile ${profile})"
        local AWS_SESSION_TOKEN="$(aws configure get aws_session_token --profile ${profile})" 
        local AWS_SECRET_KEY=${AWS_SECRET_ACCESS_KEY}
        export AWS_ACCESS_KEY_ID
        export AWS_SECRET_ACCESS_KEY
        export AWS_SESSION_TOKEN
        export AWS_SECRET_KEY
        echo "Set AWS env variables for profile '${profile}'"
    fi
}