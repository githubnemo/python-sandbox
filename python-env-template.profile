include /etc/firejail/globals.local

# do not assume a shell (and therefore mock a rc file)
# since we want to allow our own shell config (but read-only)
shell none
#keep-shell-rc  # enable this for firejail >0.9.66

### Permission overrides
#
# firejail provides ready-made profiles that are very restrictive (good).
# Here we define what not to disallow.

# we want our vim config to be available but readonly
# the read-only attribute is already imposed by the includes
noblacklist ${HOME}/.vim
noblacklist ${HOME}/.vimrc
whitelist ${HOME}/.vimrc
whitelist ${HOME}/.vim

noblacklist ${HOME}/.tmux.conf
whitelist ${HOME}/.tmux.conf

noblacklist ${HOME}/.zshrc
whitelist ${HOME}/.zshrc

noblacklist ${HOME}/.gitconfig
whitelist ${HOME}/.gitconfig
read-only ${HOME}/.gitconfig
whitelist ${HOME}/.gitignore
read-only ${HOME}/.gitignore
noblacklist ${HOME}/.bashrc
whitelist ${HOME}/.bashrc

# make sure that there's a viminfo file (RW);
# it is temporary and discarded after sandbox shutdown!
mkfile ${HOME}/.viminfo

# Exceptions for tools that we need when developing, such as ssh.
noblacklist ${PATH}/ssh

include /etc/firejail/disable-common.inc
include /etc/firejail/disable-programs.inc

### Resource limitations
#
# no access to /mnt or /media needed I think
disable-mnt


### Visual hint of jailing
#
# We cannot influence the shell directly since we do not know which
# variables are overriden by config but we can provide a hint that
# we are running inside a jailed environment.
#
# This can, of course, be used against us but I don't see a better way yet.
env JAILED_ENV=€{sandbox_name}


### GPU access
#
noblacklist /sys/module
whitelist /sys/module/nvidia*
read-only /sys/module/nvidia*
noblacklist /dev/nvidia-uvm


### Read-only file system
#
# Files and directories that are allowed to be seen and read but not
# written to.
#
read-only ~/.zshrc
read-only ~/.bashrc

whitelist ${HOME}/Code/pyenv/
read-only ${HOME}/Code/pyenv/

whitelist ${HOME}/Code/fzf
read-only ${HOME}/Code/fzf
whitelist ${HOME}/Code/goto-tool
read-only ${HOME}/Code/goto-tool
whitelist ${HOME}/.config/goto_favourites.list
whitelist ${HOME}/.config/goto.lock


### Caching directories
#
# persistent directory between invocations
#
mkdir ~/.cache/pysandbox-€{sandbox_name}/
whitelist ~/.cache/pysandbox-€{sandbox_name}/

env HF_HOME=~/.cache/pysandbox-€{sandbox_name}/huggingface
env PIP_CACHE_DIR=~/.cache/pysandbox-€{sandbox_name}/pip


### Work directory
#
# You need to specify the directories that are read+write. Note that malicious
# software will try to do cross-contamination so it is best to have few
# specific writable directory per sandbox only. In this case only the
# working directory + python environment directory - both specific to the
# sandbox environment.
#
mkdir ~/envs/€{sandbox_name}
whitelist ~/envs/€{sandbox_name}
whitelist €{working_dir}
private-cwd €{working_dir}


