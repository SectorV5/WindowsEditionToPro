# ConvertTo-WinPro 🚀

A robust PowerShell script to perform an **in-place upgrade** of any Windows 10 or Windows 11 edition to **Windows 11 Professional**.

This script automates the entire process, from downloading the official installation media to initiating the upgrade, all while preserving your personal files, installed applications, and settings. It is designed to be a "fire-and-forget" solution for system administrators and power users.

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://docs.microsoft.com/en-us/powershell/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## ✨ Key Features

*   ✅ **Universal Upgrade Path:** Upgrades a wide range of editions (Home, Enterprise, Education, IoT, LTSC, etc.) directly to Windows 11 Pro.
*   📂 **Keeps Everything:** Performs a repair-style in-place upgrade, so you don't lose your data, apps, or settings.
*   📥 **Automatic & Official ISO Download:** Intelligently downloads the latest official Windows 11 ISO directly from Microsoft servers using the well-regarded [Fido](https://github.com/pbatard/Fido) script.
*   🌐 **Multi-Language Support:** Automatically detects your system's language for the ISO download. You can also manually specify a language or list all available ones.
*   🧠 **Smart ISO Sourcing:** Before downloading, the script automatically checks for a pre-existing ISO in common locations (`C:\Win11_ISO\` and `$env:TEMP\Win11.iso`) to save time and bandwidth.
*   ⚙️ **Fully Automated Setup:** Injects the necessary configuration to pre-select the "Professional" edition and accept the EULA, making the setup process silent and non-interactive.
*   🛡️ **Robust & Safe:** Includes prerequisite checks (Admin rights, disk space), solid error handling, and reliable ISO mounting logic. It works on a *copy* of the installation files for maximum safety.
*   💯 **Genuine Media Only:** Uses only official Microsoft ISOs. If automatic downloads fail, it provides links to trusted sources for manual download.

## 💻 Compatibility

The underlying Windows Setup technology supports the following upgrade paths. This script simply automates the process.

| From Windows Edition                         | To Windows 11 Pro | Status              |
| -------------------------------------------- | ----------------- | ------------------- |
| Windows 10/11 Home                           | ✅ Supported      | ✅ Tested           |
| Windows 10/11 Pro                            | ✅ Supported      | ✅ Tested (Repair)  |
| Windows 10/11 Education                      | ✅ Supported      | ✅ Tested           |
| Windows 10/11 Enterprise                     | ⚠️ Unofficial     | ✅ Tested & Works   |
| Windows 10/11 Enterprise LTSC/LTSB           | ⚠️ Unofficial     | ✅ Tested & Works   |
| Windows 10 IoT Enterprise                    | ⚠️ Unofficial     | ⚠️ Known to work    |
| Other (N/KN editions, Insider builds)        | ⚠️ Unofficial     | ⚠️ May vary         |

> **Note:** Paths marked "Unofficial" are not documented by Microsoft as direct downgrade paths. However, this method forces a "repair install" using the Pro edition, which has been proven to work reliably while keeping all data and apps.

## 🚀 Quick Start Guide

1.  **Prerequisites:** Ensure you have a **valid Windows 11 Pro product key** for activation after the upgrade is complete.
2.  **Download:** Download the [`ConvertTo-WinPro.ps1`](<path/to/your/repo/ConvertTo-WinPro.ps1>) script to your computer (e.g., your Desktop).
3.  **Run as Administrator:** Right-click the Start Menu, select **PowerShell (Admin)** or **Windows Terminal (Admin)**.
4.  **Navigate to the script's location:**
    ```powershell
    cd $env:USERPROFILE\Desktop
    ```
5.  **Execute the script:**
    ```powershell
    .\ConvertTo-WinPro.ps1
    ```
6.  **Done!** The script will handle the rest. It will download the ISO (if not found locally), extract it, and launch the upgrade. Your computer will restart automatically to complete the process.

## ⚙️ Advanced Usage (Command-Line Options)

You can control the script's behavior with parameters.

### Specifying an ISO Language

By default, the script uses your current Windows language. You can override this with the `-Language` parameter.

```powershell
# Example: Download the German (Germany) ISO
.\ConvertTo-WinPro.ps1 -Language de-DE
```

### Listing Available Languages

To see a full list of language codes available for download from Microsoft, use `List`.

```powershell
# This will display all language options and then exit
.\ConvertTo-WinPro.ps1 -Language List
```

##  MANUAL ISO DOWNLOAD (Fallback Plan)

If the automated download fails (e.g., due to network restrictions), the script will guide you. You can perform the upgrade by manually downloading the ISO.

1.  **Download the ISO** from one of these official/trusted sources:
    *   **Microsoft:** [https://www.microsoft.com/software-download/windows11](https://www.microsoft.com/software-download/windows11) (Use the "Download Windows 11 Disk Image (ISO)" option).
    *   **Massgrave:** [https://massgrave.dev/genuine-installation-media](https://massgrave.dev/genuine-installation-media) for an alternative source of genuine ISOs.
2.  **Place the ISO** in one of the two locations the script checks automatically:
    *   `C:\Win11_ISO\Win11_24H2_English_x64.iso` (The folder `Win11_ISO` must be in the root of C:)
    *   **OR** `$env:TEMP\Win11.iso` (You can get to this folder by typing `%TEMP%` in the File Explorer address bar).
3.  **Re-run the script.** It will find the local ISO and proceed with the upgrade.

## ⚠️ Important Warnings

*   🔑 **License Required:** This script **does not** bypass Windows activation or provide a license. You **must** own a valid Windows 11 Pro license key to activate your system after the upgrade. The script uses a generic key only to facilitate the installation process.
*   🛡️ **Backup First:** While this process is extremely reliable and designed to preserve data, you should **always back up your important files** before performing any operating system upgrade.
*   🚫 **No Cancellations:** Once the in-place upgrade process begins (`setup.exe` is launched), it cannot be easily canceled. Ensure you are ready to proceed before running the script.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
