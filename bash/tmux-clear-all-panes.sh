for pane in $(tmux list-panes -F '#{pane_id}')
do
    tmux clear-history -t "${pane}"
done
