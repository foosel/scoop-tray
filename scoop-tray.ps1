[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")

$State = "unknown"

$MainForm = New-Object System.Windows.Forms.form
$NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$ContextMenu = New-Object System.Windows.Forms.ContextMenu
$MenuItemCheckNow = New-Object System.Windows.Forms.MenuItem
$MenuItemStatus = New-Object System.Windows.Forms.MenuItem
$MenuItemUpdate = New-Object System.Windows.Forms.MenuItem
$MenuItemCleanup = New-Object System.Windows.Forms.MenuItem
$MenuItemCache = New-Object System.Windows.Forms.MenuItem
$MenuItemExit = New-Object System.Windows.Forms.MenuItem
$TimerScoop = New-Object System.Windows.Forms.Timer
$IconUpToDate = New-Object System.Drawing.Icon("$PSScriptRoot\up-to-date.ico")
$IconUpdatesAvailable = New-Object System.Drawing.Icon("$PSScriptRoot\updates-available.ico")

function Initialize-Tray () {
    $MainForm.ShowInTaskbar = $False
    $MainForm.WindowState = "minimized"
    
    $NotifyIcon.Icon = $IconUpToDate
    $NotifyIcon.ContextMenu = $ContextMenu
    $NotifyIcon.contextMenu.MenuItems.AddRange($MenuItemCheckNow)
    $NotifyIcon.contextMenu.MenuItems.Add("-");
    $NotifyIcon.contextMenu.MenuItems.AddRange($MenuItemStatus)
    $NotifyIcon.contextMenu.MenuItems.AddRange($MenuItemUpdate)
    $NotifyIcon.contextMenu.MenuItems.AddRange($MenuItemCleanup)
    $NotifyIcon.contextMenu.MenuItems.Add("-");
    $NotifyIcon.contextMenu.MenuItems.AddRange($MenuItemExit)
    $NotifyIcon.Visible = $True
    
    $TimerScoop.Interval = 1800000  # (30 min)
    $TimerScoop.add_Tick({Eval-Scoop})
    $TimerScoop.start()

    $MenuItemCheckNow.Text = "Check now"
    $MenuItemCheckNow.add_Click({
        Update-Scoop-Status
    })
    
    $MenuItemStatus.Text = "Status..."
    $MenuItemStatus.add_Click({
        Start-Process "cmd" -ArgumentList "/c scoop status * && pause"
    })
    
    $MenuItemUpdate.Text = "Update..."
    $MenuItemUpdate.add_Click({
        Start-Process "cmd" -ArgumentList "/c scoop update && scoop update * && pause" -Wait
        Write-Host "Update done, refreshing status"
        Update-Scoop-Status
    })
    
    $MenuItemCleanup.Text = "Cleanup..."
    $MenuItemCleanup.add_Click({
        Start-Process "cmd" -ArgumentList "/c scoop cleanup * -k && pause"
    })

    $MenuItemCache.Text = "Remove cache..."
    $MenuItemCache.add_Click({
        Start-Process "cmd" -ArgumentList "/c scoop cache rm * -k && pause"
    })
    
    $MenuItemExit.Text = "Exit"
    $MenuItemExit.add_Click({
        $TimerScoop.stop()
        $NotifyIcon.Visible = $False
        $MainForm.close()
    })
}

function Get-Scoop-Status () {
    Write-Host "Running `scoop update`..."
    $update_command = "scoop update"
    Invoke-Expression $update_command

    $status = @{}

    Write-Host "Running `scoop status`..."
    $status_command ="scoop status"
    & { Invoke-Expression $status_command } *>&1 | Tee-Object -Variable status_output
    $status.scoop_update = $status_output -match "Scoop is out of date"
    $status.app_updates = $status_output -match "Updates are available for:"
    Write-Host $status_output

    return $status
}

function Update-Scoop-Status () {
    $old_state = $State

    $status = Get-Scoop-Status

    # eval state
    if ($status.scoop_update -or $status.app_updates) {
        $State = "scoop_and_app_updates"
        if ($status.scoop_update -and $status.app_updates) {
            $State = "scoop_and_app_updates"
        } elseif ($status.scoop_update) {
            $State = "scoop_update"
        } elseif ($status.app_updates) {
            $State = "app_updates"
        }
    } else {
        $State = "up_to_date"
    }

    # adjust tray icon accordingly
    if ($old_state -ne $State) {
        switch ($State) {
            "up_to_date" {
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
                $NotifyIcon.Icon = $IconUpdatesAvailable
                $NotifyIcon.ShowBalloonTip(30000,"Attention","There are updates available via scoop!",[system.windows.forms.ToolTipIcon]"Info")
            }
        }
    }
}

Initialize-Tray
Update-Scoop-Status
[void][System.Windows.Forms.Application]::Run($MainForm)
