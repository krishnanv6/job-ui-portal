#!/usr/bin/env bash
# Cross-platform desktop notification for Claude Code hooks.
TITLE="Claude Code"
MESSAGE="Claude Code needs your attention"

case "$(uname -s)" in
  Darwin)
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
    ;;
  Linux)
    command -v notify-send >/dev/null 2>&1 && notify-send "$TITLE" "$MESSAGE"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    powershell.exe -NoProfile -Command "
      Add-Type -AssemblyName System.Windows.Forms
      \$notify = New-Object System.Windows.Forms.NotifyIcon
      \$notify.Icon = [System.Drawing.SystemIcons]::Information
      \$notify.Visible = \$true
      \$notify.ShowBalloonTip(5000, '$TITLE', '$MESSAGE', [System.Windows.Forms.ToolTipIcon]::Info)
      Start-Sleep -Seconds 1
      \$notify.Dispose()
    "
    ;;
esac
