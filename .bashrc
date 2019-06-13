#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias song_rip='youtube-dl -x --audio-format flac'
PS1='\[\e[1;30m\][\W] \[\e[m\e[1;34m\][\A]> \[\e[m\]'

