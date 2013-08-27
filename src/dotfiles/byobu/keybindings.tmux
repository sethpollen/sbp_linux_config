# Change escape key to Alt+T.
set-option -g prefix M-t
unbind-key C-b
bind-key M-t send-prefix

# I have attempted to make the bindings in this file mirror their equivalents
# in my i3 config. Instead of holding Alt (as in i3), a command is sent by
# pressing Alt+T, releasing Alt, and typing the key combination.
bind-key ? list-keys

# I have left out a lot of the commands for managing sessions, since I only
# intend to use one session.

# Detach from tmux, but keep the session running in the background. You can also
# get this effect by closing the XTerm window.
bind-key Q detach-client

bind-key v select-layout even-vertical
bind-key h select-layout even-horizontal

# This was Shift+Escape in i3.
bind-key S-Escape break-pane

# Get an interactive list of windows.
bind-key "`" choose-window

bind-key 0 select-window -t 0
bind-key 1 select-window -t 1
bind-key 2 select-window -t 2
bind-key 3 select-window -t 3
bind-key 4 select-window -t 4
bind-key 5 select-window -t 5
bind-key 6 select-window -t 6
bind-key 7 select-window -t 7
bind-key 8 select-window -t 8
bind-key 9 select-window -t 9

bind-key q kill-pane
bind-key Escape new-window
bind-key Tab next-window
bind-key S-Tab prev-window
bind-key Enter split-window

bind-key Up select-pane -U
bind-key Down select-pane -D
bind-key Left select-pane -L
bind-key Right select-pane -R

# My best approximation for moving panes.
bind-key S-Up swap-pane -U
bind-key S-Down swap-pane -D

# Gives you a numeric menu for jumping to a particular pane. No real equivalent
# in i3.
bind-key S-Tab display-panes
