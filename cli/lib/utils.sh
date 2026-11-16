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

write_agents_file() {
	local workspace_name=${workspace_file%.code-workspace}

	cat <<EOF >AGENTS.md
# ${workspace_name} Guide for Developers & AI Agents

This is a multi-repository development environment. Each project lives in its own folder (a separate git repository) and is listed in the VS Code multi-root workspace file [${workspace_file}](./${workspace_file}).

Rather than relying on pre-built published npm packages, projects in this workspace resolve each other's packages to their local source code. This enables a seamless development flow with hot-reloading (HMR) across all repositories.

---

## 📂 Workspace Folder Organization

\`\`\`
${workspace_name}/
├── ${workspace_file}  # VS Code multi-root workspace config
├── AGENTS.md          # This guide
├── TODOs.md           # Symlink to the main project's TODO list (Nextcloud notes)
├── Plans/             # Symlink to the main project's plans folder (Nextcloud notes)
└── <project>/         # One folder per repository listed in the workspace file
\`\`\`

\`TODOs.md\` and \`Plans/\` are not part of any repository; they link to notes synced outside the workspace. Read them for context on pending work, and write implementation plans for larger tasks in \`Plans/\`.

Check the \`folders\` in [${workspace_file}](./${workspace_file}) to see which projects are part of the workspace. Libraries are usually monorepos with their packages under \`packages/\`, and each project has its own \`package.json\`, \`pnpm\` setup and \`node_modules\`.

---

## 🔗 How Local Resolution & Aliasing Works

To avoid manual \`npm link\` or local file dependency resolution (\`file:...\` paths), applications use the \`vite-plugin-multi-root-workspace\` resolver plugin in their \`vite.config.ts\`:

\`\`\`ts
import Workspace from 'vite-plugin-multi-root-workspace';

export default defineConfig({
    plugins: [
        // ...
        Workspace(),
    ],
});
\`\`\`

This plugin dynamically configures Vite's alias mapping:

1. It reads the nearest \`.code-workspace\` file to discover the folder structure.
2. For each project, if a \`packages/\` directory exists, it scans all subdirectories containing a \`package.json\`.
3. If a package has a \`src/\` folder, it maps the package name directly to the **absolute path** of its local \`src/\` folder.
4. During dev (\`vp dev\`) or build (\`vp build\`), imports of these libraries are resolved directly to their local source code.
5. This facilitates instant hot-reloading (HMR) in the browser when making changes to library code.

---

## 🛠 Development Workflow & Commands Reference

Since projects are independent in terms of node modules and pnpm configuration, run commands inside their respective directories.

### Toolchain (Vite+)
All projects use Vite+ (\`vp\`) as their script runner and package manager interface:

\`\`\`bash
vp install      # Install dependencies
vp dev          # Start the development server (applications)
vp build        # Build for production
vp check        # Format, lint, and type-check
vp test         # Run tests with Vitest
vp run <script> # Run a package.json script (add -r to run it recursively in monorepos)
\`\`\`

Check each project's \`package.json\` for additional scripts (e.g. \`type-check\` for \`.vue\` files, which isn't covered by \`vp check\`).

### Node Version Management (\`mise\`)
Node.js versions are managed with \`mise\`. Each project pins its own version in \`.node-version\`, so they may differ. Make sure commands run through \`mise exec\` or with \`mise\` activated; \`vp\` commands also pick up the project's \`.node-version\` automatically.

---

## 🧠 Guidelines for AI Agents

When working on this workspace, please adhere to the following best practices:

1. **Direct Package Imports & Changes**:
   * Since Vite aliases libraries to local source paths, you can modify code directly in \`<library>/packages/*/src\`, and the changes will be picked up by application dev servers immediately.
   * If you add new exports or files to libraries, make sure they are properly exported from the package entry points.
   * Changes may span multiple repositories; remember that each folder is a separate git repository.
2. **Toolchain & Package Managers**:
   * Use Vite+ (\`vp\`) for script execution and package installation.
   * Each project pins its own \`pnpm\` version via the \`packageManager\` field in \`package.json\`. Make sure to use the correct toolchain in each subfolder.
3. **Dependency Catalogs**:
   * Projects use pnpm catalogs (\`catalog:\` protocol) in their \`pnpm-workspace.yaml\` files. Avoid modifying dependency versions in individual \`package.json\` files; update the catalog definition in \`pnpm-workspace.yaml\` instead, or verify alignment with existing overrides.
4. **Code Quality and Formatter**:
   * Projects use \`oxc\` (\`oxfmt\` and \`oxlint\`, configured in their \`vite.config.ts\`) with formatting on save.
   * Ensure imports are sorted and TypeScript is strictly type-checked (\`vp check\`, plus \`vp run type-check\` where available for Vue components).
EOF
}

link_notes() {
	local main_project=$1
	local todos_file="${HOME}/Nextcloud/Notes/TODOs/${main_project}.md"
	local plans_dir="${HOME}/Nextcloud/Notes/Plans/${main_project}"

	if [[ -e TODOs.md || -L TODOs.md ]]; then
		info "✅ TODOs.md already exists, skipping."
	elif [[ ! -f "$todos_file" ]]; then
		info "⏭️  ${todos_file} not found, skipping TODOs.md link."
	else
		info "🔗 Linking TODOs.md -> ${todos_file}..."
		ln -s "$todos_file" TODOs.md
	fi

	if [[ -e Plans || -L Plans ]]; then
		info "✅ Plans already exists, skipping."
	elif [[ ! -d "$plans_dir" ]]; then
		info "⏭️  ${plans_dir} not found, skipping Plans link."
	else
		info "🔗 Linking Plans -> ${plans_dir}..."
		ln -s "$plans_dir" Plans
	fi
}
