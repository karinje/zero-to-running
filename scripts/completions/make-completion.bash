# Bash completion for Makefile commands
# Add to ~/.bashrc: source /path/to/zero-to-running/scripts/completions/make-completion.bash

_make_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Get available make targets
    if [ -f Makefile ]; then
        opts=$(grep -E '^[a-zA-Z_-]+:.*?##' Makefile | awk '{print $1}' | sed 's/://')
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    fi
}

complete -F _make_completion make

