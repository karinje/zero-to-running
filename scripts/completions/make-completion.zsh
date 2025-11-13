# Zsh completion for Makefile commands
# Add to ~/.zshrc: source /path/to/zero-to-running/scripts/completions/make-completion.zsh

_make_completion() {
    local -a commands
    if [ -f Makefile ]; then
        commands=($(grep -E '^[a-zA-Z_-]+:.*?##' Makefile | awk '{print $1}' | sed 's/://'))
    fi
    _describe 'make commands' commands
}

compdef _make_completion make

