# shellcheck shell=bash
# Shared workspace and project helpers for ndm.

path_in_list() {
	local needle=$1 p
	shift
	for p in "$@"; do
		[[ "$p" == "$needle" ]] && return 0
	done
	return 1
}

resolve_workspace_file() {
	local default="${PWD##*/}.code-workspace"
	local files=()

	if [[ -f "$default" ]]; then
		workspace_file=$default
		return 0
	fi

	shopt -s nullglob
	files=(*.code-workspace)
	shopt -u nullglob

	if [[ "${#files[@]}" -eq 1 ]]; then
		workspace_file=${files[0]}
		return 0
	fi

	if [[ "${#files[@]}" -gt 1 ]]; then
		die "Multiple .code-workspace files found: ${files[*]}"$'\n'"Keep a single workspace file in this directory."
	fi

	workspace_file=$default
	return 1
}

repo_in_workspace() {
	grep -Fq "\"path\": \"${1}\"" "$workspace_file"
}

read_workspace_paths() {
	workspace_paths=()
	local path_line path
	while IFS= read -r path_line; do
		path=${path_line#\"path\": \"}
		path=${path%\"}
		workspace_paths+=("$path")
	done < <(grep -oE '"path": "[^"]+"' "$workspace_file")
}

ensure_workspace_root() {
	local paths=() p
	for p in "$@"; do
		[[ "$p" == "./" ]] && continue
		paths+=("$p")
	done
	# shellcheck disable=SC2034
	workspace_folders=("./" ${paths[@]+"${paths[@]}"})
}

write_workspace_file() {
	local paths=("$@")
	local folders_json="" i settings_block

	for i in "${!paths[@]}"; do
		[[ "$i" -gt 0 ]] && folders_json+=","
		if [[ "${paths[$i]}" == "./" ]]; then
			folders_json+=$'\n    { "path": "./", "name": "workspace" }'
		else
			folders_json+=$'\n    { "path": "'"${paths[$i]}"'" }'
		fi
	done

	if [[ -f "$workspace_file" ]] && grep -q '"settings":' "$workspace_file"; then
		settings_block=$(sed -n '/"settings":/,/^  }/p' "$workspace_file")
	else
		settings_block='  "settings": {
    "editor.defaultFormatter": "oxc.oxc-vscode",
    "editor.formatOnSave": true,
    "editor.formatOnSaveMode": "file",
    "editor.codeActionsOnSave": {
      "source.fixAll.oxc": "explicit"
    },
    "search.exclude": {
      "**/node_modules": true,
      "**/dist": true
    }
  }'
	fi

	cat <<EOF >"$workspace_file"
{
  "folders": [${folders_json}
  ],
${settings_block}
}
EOF
}
