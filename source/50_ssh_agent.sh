# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Ensure that there is an ssh-agent running.  If it isn't already running start
# one.  If it is, hook up to it.
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     /usr/bin/ssh-add
}

# Source SSH settings, if applicable
if ! ssh-add -l &> /dev/null; then
    if [ -f "${SSH_ENV}" ]; then
         . "${SSH_ENV}" > /dev/null
         #ps ${SSH_AGENT_PID} doesn't work under cywgin
         ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
             start_agent
         }
    else
         start_agent
    fi
fi
