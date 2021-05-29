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
