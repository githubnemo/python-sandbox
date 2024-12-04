# Python Sandboxing

Do you trust whatever comes out of `pip install`?
Do you [trust nightly builds](https://pytorch.org/blog/compromised-nightly-dependency/)?

No? Good! Maybe this is a solution for you, then.

This project aims to provide firejail profiles for python development
environments. This means that you will have an isolated shell with only
selected parts, some read-only, some not at all visible, of your host
filesystem.

This is by no means perfect but at least it is better than being at
the mercy of pypi.

## Requirements

- firejail
- python-virtualenv
- bash or zsh

## Workflow

New python project? New sandbox.

```
$ mkdir ~/code/mynewproject
$ create-python-sandbox mynewproject ~/code/mynewproject

# After profile creation we can jump into the sandbox
$ firejail --profile=python-env-mynewproject --tab bash

# We can now create a virtualenv there (or use poetry, conda, ...)
$ python -m venv ~/envs/mynewproject
$ . ~/envs/mynewproject/bin/activate
$ pip install [...]
```

It is best to make access to the sandbox as easy as possible.
At best, never leave it (launch a tmux session inside the sandbox,
work in there). Second best: create an alias to quickly jump into
the sandbox. See [this section][Common entrypoint]:

```
$ sbox mynewproject
```

## Neat things

### Common entrypoint
I have a function definition for invoking sandboxed shells

```bash
sbox() {
    # replace "bash" with any shell you like
    firejail --profile=python-env-$1 --tab bash
}
```

so I can quickly jump into the sandbox using `sbox myenv`.

### Visual hint of being inside a sandbox
To gauge if I'm in a sandbox or not the sandbox environment
provides an environment variable (`JAILED_ENV=1`) so it is
easy to react on that in the shell prompt.

Example from my `.bashrc`:
```bash
jail=""
if [ -n "$JAILED_ENV" ]; then
    jail="(J)"
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}${jail}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}${jail}\u@\h:\w\$ '
fi
```
