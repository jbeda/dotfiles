# Remove duplicates in the path.  From http://unix.stackexchange.com/a/40779/55895.
PATH=$(echo -n $PATH | awk -v RS=: '{ if (!arr[$0]++) {printf("%s%s",!ln++?"":":",$0)}}')
