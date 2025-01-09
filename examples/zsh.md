# Example ZSH setup

This is an example setup for ZSH that offers the following:

1. automatic activation of sandbox upon entering a directory with a
   `.python-sandbox` file
2. providing convenience commands for enabling a sandbox (`sbox <name>`)
3. Retaining new-tab/new-window while preserving the CWD in VTE software
   such as gnome-terminal

The code belongs into your `~/.zshrc`.

```bash
# Activate python environment on sandbox start to ease
# the life of the developer
if [ -n "$JAILED_ENV" ] && [ "$JAILED_ENV" != "1" ]; then

    # this is a workaround for firejail changing the CWD to the configured
    # CWD in every case. But when opening a new window or tab in a VTE we
    # don't want that, we want the directory we were in before.
    #
    # The hook (further below) for changing directories will make sure
    # that the directory is saved and we're navigating to it on initialization
    # here.
    if [ -n "$PWD_BEFORE_JAIL" ]; then
        cd "$PWD_BEFORE_JAIL"
    fi

    # Make sure that the precmd for VTE is working in jails so that it
    # saves the correct CWD to make new-tab / new-window preserving work.
    source /etc/profile.d/vte-2.91.sh

    sa "$JAILED_ENV"
fi

function sa() {
	local env
	local script
	env=~"/envs/$1/"
	script="$env/bin/activate"
	if ! [ -e "$script" ]; then
		echo "Env '$1' does not seem to exist :("
		echo "($script)"
		return 1
	fi
	source "$script"
}

alias sad='deactivate'

function sbox() {
    firejail --profile=python-env-$1 zsh
}

autoload -U add-zsh-hook

# Little helper to go upward the directory tree in search for a file.
# Makes sure to use the least amount of external tools for performance.
_upfind() {
    if [[ "$2" -eq 0 ]]; then
        return 1
    fi
    [[ -e "$1" ]] && echo "$1" || _upfind "../$1" "$(($2 - 1))"
}

enable_sbox_if_needed() {
    if [ -n "$JAILED_ENV" ]; then
        return
    fi

    # Look into current and upward directories for sandbox file to
    # enable sandbox upon finding it.
    sandbox_file=$(_upfind ".python-sandbox" 5)

	if [[ "$?" -eq 0 ]]; then
        export PWD_BEFORE_JAIL="$PWD"
        sbox "$(head -n1 "$sandbox_file")"
    fi
}

add-zsh-hook chpwd enable_sbox_if_needed
enable_sbox_if_needed
```
