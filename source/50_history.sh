[[ -o interactive ]] || return

# Save timestamp and duration with each history entry
setopt EXTENDED_HISTORY

# Share history across all sessions in real time
setopt SHARE_HISTORY

# Don't save duplicate lines or lines starting with space
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Skip duplicates when searching; strip extra blanks; confirm history expansion before running
setopt HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS HIST_VERIFY

HISTSIZE=50000
SAVEHIST=10000
