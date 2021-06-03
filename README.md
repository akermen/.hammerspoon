# Personal Configuration for Hammerspoon

My personal [Hammerspoon](http://www.hammerspoon.org) configuration which supports both regular and the [tmux](https://github.com/tmux/tmux) style key bindings.

Addition to the key bindings, the script automatically moves application windows to specified screen, adjust their dimensions, placements and keyboard locale based on the configuration. Screen connect or disconnect and new application launch events trigger and focus change events trigger related update tasks.

## Configuration
The `config.json` file includes almost all configurations parameters. The exception is the list of key bindings.

**`screens`:** The list of of available screens with unique keys. The keys will be referenced at the `layout` options.
```json
    "screens": [
        {"key": "A", "name": "Color LCD"},
        {"key": "B", "name": "DELL UP3216Q"}
    ]
```

**`layouts`:** The list of application layouts for different screen configurations. Each group defines same size and placement option for all applications listed on same screen.
```json
    {
        "names": ["com.googlecode.iterm2", "Terminal", "Termius"],
        "modes": {
            "A" : ["", "Turkish Q", 2, 2, 0, 1],
            "B" : ["", "U.S.", 2, 3, 1, 2],
            "AB": ["A", "U.S.", 1, 10, 0, 1, 1, 8]
        }
    }
```
By following above example, `names` lists application names or bundle identifiers that group will apply, `modes` are list of screen configurations, the mode `A` will be used when only the screen `A` (`Color LCD`) is available, `B` will be used when only the screen `B` (`DELL ABC`) is available and `AB` will be used when both `A` and `B` screens are available at the same time.

The first element of the mode array is preferred screen which is used only for multi screen configurations, the second is keyboard locale, and starting from third the rest of the list defines the window grid parameters as:

- number of grid rows for selected screen
- number of grid columns for selected screen
- row index where application window's left-top corner located
- column index where application window's left-top corner located
- row width, how wide is application window
- column width, how tall is application window

**`applications`:** The list of different workspace applications to be launched using single macro (key binding).

**`myip`:** Hostname to get current public IP address.

**`tunnelblick`:** [Tunnelblick](https://tunnelblick.net) connection options.


## Key bindings
Regular key bindings require each key is pressed at the same time such as <kbd>⌘</kbd> <kbd>⌥</kbd> <kbd>↵</kbd> for fullscreen. The [tmux](https://github.com/tmux/tmux) style is a little bit different where the first key combination <kbd>⌥</kbd> <kbd>space</kbd> enables a modal mode where second key press triggers the action. For same fullscreen action first <kbd>⌥</kbd> <kbd>space</kbd> is pessed and then <kbd>↵</kbd>.

Although this two step may seem inefficient compared to the regular method, by freeing almost all the keys on the keyboard after modal mode is activated it brings usability and compatibility advantages for certain use cases especially when many different actions triggered without overriding or conflicting existing key combinations on the operating system or installed applications.


| Modifier     | Key              | Action                   |
| -------------|:----------------:|:------------------------:|
|              | <kbd>↵</kbd>     | Fullscreen               |
|              | <kbd>⌫</kbd>     | Center big, full height  |
|              | <kbd>e</kbd>     | Top right small          |
|              | <kbd>c</kbd>     | Bottom right small       |
|              | <kbd>q</kbd>     | Top left small           |
|              | <kbd>z</kbd>     | Bottom left small        |
|              | <kbd>a</kbd>     | Left small               |
|              | <kbd>s</kbd>     | Middle small             |
|              | <kbd>d</kbd>     | Right small              |
|              | <kbd>,</kbd>     | Left half                |
|              | <kbd>.</kbd>     | Right half               |
|              | <kbd>[</kbd>     | Top left                 |
|              | <kbd>]</kbd>     | Top right                |
|              | <kbd>;</kbd>     | Bottom left              |
|              | <kbd>\\</kbd>    | Bottom right             |
|              | <kbd>o</kbd>     | Center on screen         |
|              | <kbd>n</kbd>     | Send to next screen      |
|              | <kbd>h</kbd>     | Hide all except focused  |
|              | <kbd>l</kbd>     | Apply active layout      |
|              | <kbd>y</kbd>     | Center medium            |
|              | <kbd>↑</kbd>     | Shrink vertically        |
|              | <kbd>↓</kbd>     | Grow vertically          |
|              | <kbd>←</kbd>     | Shrink horizontally      |
|              | <kbd>→</kbd>     | Grow horizontally        |
| <kbd>⇧</kbd> | <kbd>e</kbd>     | Top right big            |
| <kbd>⇧</kbd> | <kbd>c</kbd>     | Bottom right big         |
| <kbd>⇧</kbd> | <kbd>q</kbd>     | Top left big             |
| <kbd>⇧</kbd> | <kbd>z</kbd>     | Bottom left big          |
| <kbd>⇧</kbd> | <kbd>a</kbd>     | Left large               |
| <kbd>⇧</kbd> | <kbd>s</kbd>     | Middle large             |
| <kbd>⇧</kbd> | <kbd>d</kbd>     | Right large              |
| <kbd>⇧</kbd> | <kbd>w</kbd>     | Top center big           |
| <kbd>⇧</kbd> | <kbd>x</kbd>     | Bottom center big        |
| <kbd>⇧</kbd> | <kbd>1</kbd>     | Open `web` apps          |
| <kbd>⇧</kbd> | <kbd>2</kbd>     | Open `c++` apps          |
| <kbd>⇧</kbd> | <kbd>r</kbd>     | Close all workspace apps |
| <kbd>⇧</kbd> | <kbd>m</kbd>     | Highlight mouse cursor   |
| <kbd>⇧</kbd> | <kbd>h</kbd>     | Hide all windows         |
| <kbd>⇧</kbd> | <kbd>t</kbd>     | Toggle `Tunnelblick`     |
| <kbd>⇧</kbd> | <kbd>i</kbd>     | Show public IP address   |
| <kbd>⇧</kbd> | <kbd>o</kbd>     | Show clock               |
| <kbd>⇧</kbd> | <kbd>↑</kbd>     | Move up                  |
| <kbd>⇧</kbd> | <kbd>↓</kbd>     | Move down                |
| <kbd>⇧</kbd> | <kbd>←</kbd>     | Move left                |
| <kbd>⇧</kbd> | <kbd>→</kbd>     | Move right               |

Addition to the listed bindings, <kbd>⎇</kbd> <kbd>tab</kbd> can be used to switch between focused application windows.

## Credits
- The modal mode feature (`prefix.lua`) is from [raulchen/dotfiles](https://github.com/raulchen/dotfiles/tree/master/hammerspoon).
- Inspired by many of the sample configurations listed on [Sample Configurations](https://github.com/Hammerspoon/hammerspoon/wiki/Sample-Configurations).

## Dependencies
- [ReloadConfiguration](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/)
- [AClock](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/)
- [WinWin](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/)

## Notes

Feel free to extend, modify and contribute.
