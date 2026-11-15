# usage: workspace:sync
# summary: Pull latest changes and install dependencies for all repositories in the workspace.
# shellcheck shell=bash

cli_name=${cli_name:?}
workspace_file=""
workspace_paths=()

usage() {
	cat <<EOF
Usage: $cli_name workspace:sync

Pull latest changes and install dependencies for every repository listed in the
workspace file in the current directory.
EOF
	exit "${1:-1}"
}

validate_flags --help -- "$@"
if has_flag --help "$@"; then
	usage 0
fi

mapfile -t args < <(strip_flags "$@")
if [[ "${#args[@]}" -gt 0 ]]; then
	die 2 "Unexpected argument(s): ${args[*]}"
fi

if ! resolve_workspace_file; then
	die "No .code-workspace file found in the current directory."
fi

read_workspace_paths

info "🔄 Syncing workspace (${workspace_file})..."

for path in "${workspace_paths[@]}"; do
	[[ "$path" == "./" ]] && continue

	if [[ ! -d "$path" ]]; then
		warn "⚠️  ${path} does not exist, skipping."
		continue
	fi

	info "📦 Syncing ${path}..."
	(
		cd "$path" || exit
		git pull
		vp install
	)
done

info "🎉 All done!"
