# autosave.nvim

**autosave.nvim** is a Neovim plugin that automatically saves your files wwhen you leave insert mode or change text in normal mode. It offers customizable options to include or exclude specific directories, configure delay, and enable/disable saving notifications.

## Features
- Automatically saves files in specified directories.
- Exclude directories from being auto-saved.
- Configurable delay before saving.
- Optional success/error notifications.
- Supports events: `InsertLeave` and `TextChanged`.

## Installation

Below is an example of configuring this plugin using **lazy.nvim**:

```lua
{
    "brunofpessoa/autosave.nvim",
    opts = {
        included_dirs = {"~/.config/nvim"}, -- Allow auto-save only for files under the nvim config directory.
        excluded_dirs = {}, -- Exclude no directories by default.
        delay = 500, -- Delay in milliseconds before autosaving.
        show_notifications = false,
        messages = {
            success = "File successfully saved: %s",
            failure = "Failed to save file: %s\nError: %s",
        },
    },
}
```

## Default Options

| Option             | Default Value                              | Description                                                  |
|---------------------|--------------------------------------------|--------------------------------------------------------------|
| `included_dirs`     | `{}`                                       | List of directories to include in auto-save.                |
| `excluded_dirs`     | `{}`                                       | List of directories to exclude from auto-save.              |
| `delay`             | `500`                                      | Delay in milliseconds before auto-saving files.             |
| `show_notifications`| `false`                                    | If `true`, show success or failure messages on save.         |
| `messages`          | See below                                  | Customize the success/failure messages.                     |

## Default messages:
- success: "File successfully saved: %s"
- failure: "Failed to save file: %s\nError: %s"

## Events
The plugin listens to the following events:
- **`InsertLeave`**: Triggered when exiting insert mode.
- **`TextChanged`**: Triggered when text changes in normal mode.

## Including All Directories
To enable auto-save for all files in directories under your home directory, set `included_dirs` to `{"~/"}`:

```lua
opts = {
    included_dirs = {"~/"},
    -- Other configurations
}
```

This ensures all files in `~` and its subdirectories are eligible for auto-save unless excluded via `excluded_dirs`.

## How It Works
1. Files in specified `included_dirs` are monitored for changes.
2. After events (`InsertLeave` or `TextChanged`), the plugin waits for the specified `delay` before saving.
3. If `show_notifications` is enabled, it displays a success or error message upon saving.
