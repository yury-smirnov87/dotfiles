# Repository Guidelines & Operational Rules

## Git Workflow & Pull Requests
- **Branching**: When a new change is started, a new local branch must be created.
- **Committing**: When the work is wrapped up, all files should be added and committed with a meaningful commit message.
- **Pushing**: Push the local branch to the remote repository (`origin`).
- **Repository Owner**: The repository owner is `yury-smirnov87`.
- **Pull Request Owner**: Must be set to repo owner, i.e. `yury-smirnov87`. This can be done via mcp write_issue call.
- **Pull Request Reviewers**: When creating pull requests for this repository, never add `yury-smirnov87` as a reviewer.
- **Post-Merge Cleanup**: When a pull request is merged, checkout the local repository to the `main` branch, pull all changes from remote with rebasing (`git pull --rebase`), and delete the local feature branch.

## Chezmoi Dotfiles Management
- **Declarative Source of Truth**: User configuration files like `~/.bashrc` are managed via Chezmoi templates (e.g. `dot_bashrc.tmpl`).
- **Prevent External Drift**:
  - Avoid letting third-party installer scripts append configuration blocks or environment variables directly to target dotfiles on the filesystem.
  - Common paths (such as `$HOME/.local/bin`) are already exported in `dot_bashrc.tmpl`.

## Package Management & Documentation Sync
- **Package Categorization**: When adding Debian APT packages, place them in the relevant array within `run_onchange_30-install-common-packages.sh` (`DEV_TOOLS`, `THEMES`, `FONTS`, `MULTIMEDIA`, or `APPS`).
- **Documentation Sync**: When packages or software suites are added, removed, or changed, update `README.md` to keep the software lists, directory tree, and summary table accurate.
