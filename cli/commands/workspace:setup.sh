# usage: workspace:setup <repo> [repo...]
# summary: Set up a new multi-root workspace, or add projects to an existing one.
# shellcheck shell=bash

cli_name=${cli_name:?}
workspace_file=""
workspace_paths=()
workspace_folders=()

usage() {
	cat <<EOF
Usage: $cli_name workspace:setup <repo> [repo...]

Set up a new multi-root workspace, or add projects to an existing one.

New workspace
  Run from an empty directory. Clones each repository and creates
  <dirname>.code-workspace in the current directory.

Adding a project to a workspace
  Run from a directory that already contains a .code-workspace file.
  Clones any new repositories and appends them to the workspace file.
  Repositories already listed in the workspace are ignored.
EOF
	exit "${1:-1}"
}

validate_flags --help -- "$@"
if has_flag --help "$@"; then
	usage 0
fi

mapfile -t repos < <(strip_flags "$@")
if [[ "${#repos[@]}" -eq 0 ]]; then
	usage 1
fi

adding_to_workspace=false
if resolve_workspace_file; then
	adding_to_workspace=true
elif [[ -n "$(ls -A 2>/dev/null)" ]]; then
	die "Current directory is not empty and has no workspace file."$'\n'"Use an empty folder to create a new workspace, or run this from an existing workspace root that already contains a .code-workspace file."
fi

if [[ "$adding_to_workspace" == true ]]; then
	info "📂 Adding projects to workspace (${workspace_file})..."
else
	info "📂 Setting up workspace in the current directory..."
fi
info "   Repositories: ${repos[*]}"

for repo in "${repos[@]}"; do
	if [[ "$adding_to_workspace" == true ]] && repo_in_workspace "$repo"; then
		info "✅ ${repo} is already in the workspace, skipping."
		continue
	fi

	if [[ -d "$repo" ]]; then
		info "✅ ${repo} already exists, skipping clone."
	else
		info "⬇️  Cloning ${repo}..."
		git clone "git@github.com:NoelDeMartin/${repo}.git"
	fi
done

if [[ "$adding_to_workspace" == true ]]; then
	info "📝 Updating ${workspace_file}..."
	read_workspace_paths
	merged_paths=(${workspace_paths[@]+"${workspace_paths[@]}"})
	for repo in "${repos[@]}"; do
		if ! path_in_list "$repo" ${merged_paths[@]+"${merged_paths[@]}"}; then
			merged_paths+=("$repo")
		fi
	done
	ensure_workspace_root ${merged_paths[@]+"${merged_paths[@]}"}
	write_workspace_file "${workspace_folders[@]}"
else
	info "📝 Creating ${workspace_file}..."
	ensure_workspace_root "${repos[@]}"
	write_workspace_file "${workspace_folders[@]}"
fi

info "🎉 All done!"
