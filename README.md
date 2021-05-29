# scoop-tray

Systray companion for [scoop](https://scoop.sh). Polls for updates every 30min and alerts if there are any. 

## Installation

Download release zip and unpack to a folder. Run `scoop-tray.bat`.

Alternatively install through scoop, either manually: 

```
scoop install https://github.com/foosel/scoop-bucket/raw/main/bucket/scoop-tray.json
```

or by adding my bucket and installing from that (incl. updates):

```
scoop bucket add foosel https://github.com/foosel/scoop-bucket
scoop install scoop-tray
```

## Autostart

Create a shortcut in `shell:startup` targeting `scoop-tray.bat`.

## Screenshots

![Systray Icon](https://github.com/foosel/scoop-tray/raw/main/assets/systrayicon.png)

![Available updates](https://github.com/foosel/scoop-tray/raw/main/assets/updates.png)

![Context menu with options to run status, update and exit](https://github.com/foosel/scoop-tray/raw/main/assets/contextmenu.png)

![Notification](https://github.com/foosel/scoop-tray/raw/main/assets/notification.png)