Similar to the [zsh example](./zsh.md) bash can do auto-activation of
sandboxes:

```bash
sbox() {
    firejail --profile=~/.config/firejail/python-env-$1.profile --tab bash
}

sa() {
	source ~/envs/$1/bin/activate
}

if [ -n "$JAILED_ENV" ]; then
   if [ -n "$PWD_BEFORE_JAIL" ]; then
       cd "$PWD_BEFORE_JAIL"
   fi
   sa "${JAILED_ENV}"
fi

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

_PYTHON_SANDBOX_PWD=""

setPythonSandboxPrompt() {
    # only enable sandbox if we changed the directory or doing this for the first time
    if [ -z "$_PYTHON_SANDBOX_PWD" ] || [ "$_PYTHON_SANDBOX_PWD" != "$PWD" ]; then
            enable_sbox_if_needed
            _PYTHON_SANDBOX_PWD="$PWD"
    fi
}

if [[ "${PROMPT_COMMAND[*]}" != *setPythonSandboxPrompt* ]]; then
    PROMPT_COMMAND+=(setPythonSandboxPrompt)
fi
```
