# F-Copilot

This is a PowerShell script that attempts to fully disable and remove Microsoft Copilot from Windows 11.

## How It Works

The script targets several areas where Copilot is integrated into the operating system. It's designed to be a more aggressive approach than just flipping a switch in the settings.

Here's what it does:
- Modifies registry keys to disable the Copilot feature for all users and hide the taskbar button.
- Sets policies to prevent Microsoft Edge from using its integrated Copilot features.
- Attempts to uninstall the main Copilot application package for all current users on the machine.
- Attempts to remove the provisioned package, which helps prevent Copilot from being reinstalled for new user accounts.
- Deletes specific registry keys that allow Copilot to act as a system protocol handler.

## How to Use

1.  Download the `Disable-Copilot.ps1` file.
2.  Right-click the file in your file explorer.
3.  Select **"Run with PowerShell"**. You will need to approve the administrator prompt that appears, as the script needs elevated permissions to modify system settings and remove packages.
4.  Let the script run. It will print messages showing its progress.
5.  Once it's finished, **restart your computer** to make sure all the changes take effect.

After restarting, you can also check the Startup Apps list in your Task Manager to manually disable any remaining Copilot-related entries if they are still present.
