# ~/.bashrc

export EDITOR=vscodium
export PATH="$HOME/.config/bin:$PATH"

alias rm="rm -i"
alias ls="exa"
alias update="sudo pacman -Syu && clear"
alias download_music="torsocks yt-dlp --format 'bestaudio[ext=webm][acodec=opus]/bestaudio' --extract-audio --audio-format flac --audio-quality 0 --embed-thumbnail --embed-metadata --embed-info-json --write-subs --sub-langs 'en.*,ru.*' --add-metadata --parse-metadata 'title:%(title)s' --output '%(title)s [%(uploader)s].%(ext)s'"

PS1='[\w] => '
