param($processName="firefox", $topmost=$true)
Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class SFW {
	[DllImport("user32.dll")]
	[return: MarshalAs(UnmanagedType.Bool)]
	public static extern bool SetForegroundWindow(IntPtr hWnd);

	[DllImport("user32.dll")]
	[return: MarshalAs(UnmanagedType.Bool)]
	static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

	static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
	static readonly IntPtr HWND_NOTTOPMOST = new IntPtr(-2);

	const UInt32 SWP_NOSIZE = 0x0001;
	const UInt32 SWP_NOMOVE = 0x0002;
	const UInt32 TOPMOST_FLAGS = SWP_NOMOVE | SWP_NOSIZE;

	public static void MakeTopMost (IntPtr hWnd)
	{
	    SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, TOPMOST_FLAGS);
	}
	public static void MakeNotTopMost (IntPtr hWnd)
	{
	    SetWindowPos(hWnd, HWND_NOTTOPMOST, 0, 0, 0, 0, TOPMOST_FLAGS);
	}
  }
"@

$h = ((Get-Process $processName).MainWindowhandle.Where({$_ -ne [IntPtr]0}))[0]


if($topmost)
{
	[SFW]::MakeTopMost([IntPtr]$h)
	[SFW]::SetForegroundWindow([IntPtr]$h)
}
else
{
	[SFW]::MakeNotTopMost([IntPtr]$h)
}
