#!/bin/bash
function check_fmt() {
    # No extension
    if ! [[ $1 =~ \..*$ ]]; then
        return
    fi

    tmpdir=$(mktemp -d)
    git checkout-index --prefix "$tmpdir/" "$1"
    nf="$tmpdir/$1"
    echo "$nf"

    if [[ $1 =~ \.yaml$ ]]; then
        prettier --check --parser yaml "$nf"
    elif [[ $1 =~ \.json$ ]]; then
        prettier --check --parser json "$nf"
    elif [[ $1 =~ \.pyi?$ ]]; then
        isort --check-only --multi-line=3 --trailing-comma --force-grid-wrap=0 \
            --use-parentheses --line-width=88 -q -df "$nf" && black --check --py36 "$nf"
    elif [[ $1 =~ \.sh$ ]]; then
        shfmt -d -s -i 4 "$nf"
    fi
    exit_code=$?

    rm -rf "$tmpdir"

    return "$exit_code"
}

function doc_only() {
    git diff --cached --name-only | while read file; do
        if [[ ! $file =~ \.tex$ ]] && [[ ! $file =~ \.md$ ]] && [[ ! $file =~ \.bib$ ]]; then
            false
            return
        fi
    done
}

doc_only
is_doc_only=$?

if [[ ! $VIRTUAL_ENV ]] && [[ $is_doc_only -ne 0 ]]; then
    echo 'No virtual env detected'
    source .venv/bin/activate || exit $?
fi

# lowercase 'd' filter means exclude deleted
git diff --cached --name-only --diff-filter=d | while read FILE; do
    echo "$FILE"
    check_fmt "$FILE" || exit $?
done

[[ $is_doc_only -eq 0 ]] && exit 0

tmpdir="$(mktemp -d)/"
git checkout-index --prefix="$tmpdir" $(git ls-files 'test*.py' | grep -v 'test_full.py')

chronic python -m pytest -vv -s "$tmpdir"
exit_code=$?

rm -rf "$tmpdir"
exit "$exit_code"

# vim:ts=4:sw=4:expandtab:fo-=t:tw=88
