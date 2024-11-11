set -U fish_greeting
if status is-interactive
    # Commands to run in interactive sessions can go here
end

set ORPHEUS_ANNOUNCE_URL "https://home.opsfet.ch/$ORPHEUS_KEY/announce"

direnv hook fish | source

#set FZF_DEFAULT_COMMAND "fdfind . $HOME"
#set FZF_LEGACY_KEYBINDS 0
#set FZF_COMPLETE 1
#source "$HOME/.config/fish/fzf.fish"
