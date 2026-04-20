# The Fuck - https://github.com/nvbn/thefuck
# Symlinked to ~/.config/thefuck/settings.py

# Wait time before applying correction (seconds)
wait_command = 3

# Require confirmation before executing corrected command
require_confirmation = True

# Commands to never correct
excluded_search_path_prefixes = []

# Skip these commands entirely
exclude_rules = [
    "fix_file",          # too aggressive with file creation
    "apt_list_upgradable",  # noisy on Ubuntu
]

# Max number of corrected commands to display
max_history_length = 1000

# Enable experimental instant mode for faster corrections
instant_mode = False

# Log level
debug = False
