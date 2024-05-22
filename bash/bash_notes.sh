

# https://stackoverflow.com/questions/6475524/how-do-i-prevent-commands-from-showing-up-in-bash-history
# ...
HISTFILE=~/.zshhistory
# ...

# remove dangerous entries from the shell history
temp_histfile="/tmp/$$.temp_histfile"
grep -v -P '^rm .*-rf' $HISTFILE > $temp_histfile
mv $temp_histfile $HISTFILE

# https://unix.stackexchange.com/questions/48713/how-can-i-remove-duplicates-in-my-bash-history-preserving-order
# combine the above with
history | nl | sort -k2 -k 1,1nr | uniq -f1 | sort -n | cut -f2

# https://unix.stackexchange.com/questions/48713/how-can-i-remove-duplicates-in-my-bash-history-preserving-order

# Found this solution in the wild and tested:

awk '!x[$0]++'
# The first time a specific value of a line ($0) is seen, the value of x[$0] is zero.
# The value of zero is inverted with ! and becomes one.
# An statement that evaluates to one causes the default action, which is print.

# Therefore, the first time an specific $0 is seen, it is printed.

# Every next time (the repeats) the value of x[$0] has been incrented,
# its negated value is zero, and a statement that evaluates to zero doesn't print.

# To keep the last repeated value, reverse the history and use the same awk:

awk '!x[$0]++' ~/.bash_history                 # keep the first value repeated.

tac ~/.bash_history | awk '!x[$0]++' | tac     # keep the last

#KY... IN BASHRC
function remove_duplicate_bash_history() {
# Remove all duplicates from .bash_history while keeping the history in order
    HISTFILE=~/.bash_history
    temp_histfile="/tmp/$$.temp_histfile"
    tac ~/.bash_history | awk '!x[$0]++' | tac > $temp_histfile
    mv $temp_histfile $HISTFILE
}
# https://antofthy.gitlab.io/software/history_merge.bash.txt