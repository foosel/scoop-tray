[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")

$State = "unknown"

$MainForm = New-Object System.Windows.Forms.form
$NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$ContextMenu = New-Object System.Windows.Forms.ContextMenu
$MenuItemStatus = New-Object System.Windows.Forms.MenuItem
$MenuItemUpdate = New-Object System.Windows.Forms.MenuItem
$MenuItemExit = New-Object System.Windows.Forms.MenuItem
$TimerScoop = New-Object System.Windows.Forms.Timer
$IconUpToDate = New-Object System.Drawing.Icon("$PSScriptRoot\up-to-date.ico")
$IconUpdatesAvailable = New-Object System.Drawing.Icon("$PSScriptRoot\updates-available.ico")

$MainForm.ShowInTaskbar = $False
$MainForm.WindowState = "minimized"

$NotifyIcon.Icon = $IconUpToDate
$NotifyIcon.ContextMenu = $ContextMenu
$NotifyIcon.contextMenu.MenuItems.AddRange($MenuItemStatus)
$NotifyIcon.contextMenu.MenuItems.AddRange($MenuItemUpdate)
$NotifyIcon.contextMenu.MenuItems.AddRange($MenuItemExit)
$NotifyIcon.Visible = $True

$TimerScoop.Interval = 1800000  # (30 min)
$TimerScoop.add_Tick({EvalScoop})
$TimerScoop.start()

$MenuItemStatus.Text = "Status..."
$MenuItemStatus.add_Click({
    Start-Process "cmd" -ArgumentList "/c scoop status * && pause"
})

$MenuItemUpdate.Text = "Update..."
$MenuItemUpdate.Enabled = $False
$MenuItemUpdate.add_Click({
    switch ($State) {
        "scoop_and_app_updates" {
            Start-Process "cmd" -ArgumentList "/c scoop update && scoop update * && pause"
        }
        "scoop_update" {
            Start-Process "cmd" -ArgumentList "/c scoop update && pause"
        }
        "app_updates" {
            Start-Process "cmd" -ArgumentList "/c scoop update * && pause"
        }
        default {
            Start-Process "cmd" -ArgumentList "/c scoop status * && pause"
        }
    }
    
})

$MenuItemExit.Text = "Exit"
$MenuItemExit.add_Click({
    $TimerScoop.stop()
    $NotifyIcon.Visible = $False
    $MainForm.close()
})

function GetScoopStatus {
    $status = @{}
    $status_command ="scoop status"
    & { Invoke-Expression $status_command } *>&1 | Tee-Object -Variable status_output

    $status.scoop_update = $status_output -match "Scoop is out of date"
    $status.app_updates = $status_output -match "Updates are available for:"
    return $status
}

function EvalScoop {
    $old_state = $State
    $status = GetScoopStatus

    # eval state
    if ($status.scoop_update -or $status.app_updates) {
        $State = "scoop_and_app_updates"
        if ($status.scoop_update -and $status.app_updates) {
            $State = "scoop_and_app_updates"
        } elseif ($status.scoop_update) {
            $State = "scoop_update"
        } elseif ($status.app_updates) {
            $State = "app_update"
        }
    } else {
        $State = "up_to_date"
    }

    # adjust tray icon accordingly
    if ($old_state -ne $State) {
        switch ($State) {
            "up_to_date" {
                $MenuItemUpdate.Enabled = $False
                $NotifyIcon.Text = "Scoop: Everything ok!"
                $NotifyIcon.Icon = $IconUpToDate
            }
            default {
                switch ($State) {
                    "scoop_and_app_updates" {
                        $NotifyIcon.Text = "Scoop: There are updates for scoop and apps!"
                    }
                    "scoop_update" {
                        $NotifyIcon.Text = "Scoop: There is an update for scoop!"
                    }
                    "app_updates" {
                        $NotifyIcon.Text = "Scoop: There are updates for apps!"
                    }
        
                }
                $MenuItemUpdate.Enabled = $True
                $NotifyIcon.Icon = $IconUpdatesAvailable
                $NotifyIcon.ShowBalloonTip(30000,"Attention","There are updates available via scoop!",[system.windows.forms.ToolTipIcon]"Info")
            }
        }
    }
}

EvalScoop
[void][System.Windows.Forms.Application]::Run($MainForm)