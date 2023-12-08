# Add a native method "ShowWindow" from user32.dll
Add-Type -name win -member '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -namespace native;

# Hide this process window
#[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0);

# Start the application to be hidden
Start-Process -WindowStyle hidden -FilePath "C:\Users\User\AppData\Roaming\TP\p\Proxifier.exe";

# Wait a few seconds
Start-Sleep -m 500;

# Hide the started application
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetProcessesByName("proxifier")| Get-Process).MainWindowHandle, 0);
