condaOn() {
__conda_prefix="${HOME}/anaconda3"
__conda_setup="$('${__conda_prefix}/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${__conda_prefix}/etc/profile.d/conda.sh" ]; then
        . "${__conda_prefix}/etc/profile.d/conda.sh"
    else
        export PATH="${__conda_prefix}/bin:$PATH"
    fi
fi
unset __conda_setup
unset __conda_prefix
}