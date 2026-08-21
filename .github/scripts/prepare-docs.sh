#!/usr/bin/env bash
#
# Prepare the docs/ tree for the Zensical site build.
#
# Documentation sources use repository-relative links so they remain useful
# when browsing the source on GitHub. Those paths do not exist in the
# published docs tree, so links that leave docs/ are rewritten to the source
# repository at the ref being published.

set -euo pipefail

REPO_SLUG="AMWA-TV/is-05"
REF="${BUILD_REF:-${GITHUB_REF_NAME:-main}}"
REPO_URL="https://github.com/${REPO_SLUG}/blob/${REF}"

if [[ ! -f README.md ]]; then
    echo "error: README.md not found (run from repo root)" >&2
    exit 1
fi

# Generate the documentation landing page from README.md. README.md contains
# the repository overview; the detailed pages are already under docs/.
sed -E \
    -e 's#\]\(docs/([^)]+)\)#](\1)#g' \
    -e "s#\]\(\./?LICENSE(\.txt|\.md)?\)#](${REPO_URL}/LICENSE\1)#g" \
    -e "s#\]\(CONTRIBUTING\.md\)#](${REPO_URL}/CONTRIBUTING.md)#g" \
    -e "s#\]\(SECURITY\.md\)#](${REPO_URL}/SECURITY.md)#g" \
    README.md > docs/index.md

echo "Generated docs/index.md from README.md"

# Rewrite links from docs/*.md to repository files. Also remove Jekyll-only
# table-of-contents directives left in older documentation.
shopt -s nullglob
for file in docs/*.md; do
    [[ "${file}" == "docs/index.md" ]] && continue
    sed -i -E \
        -e "s#\]\(\.\./APIs/([^)]*)\)#](${REPO_URL}/APIs/\1)#g" \
        -e "s#\]\(\.\./examples/([^)]*)\)#](${REPO_URL}/examples/\1)#g" \
        -e "/^\{:\.no_toc\}/,/^\{:toc\}/d" \
        "${file}"
done

echo "Rewrote repository-relative links to ${REPO_URL}"
