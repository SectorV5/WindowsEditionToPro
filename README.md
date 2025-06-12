# WindowsEditionToPro

`WindowsEditionToPro.ps1` is a PowerShell script for performing an **in-place upgrade** of almost any Windows edition to Windows 11 Pro.  It works even on “nonstandard” builds (Enterprise, Education, LTSC/LTSB, IoT, etc.), keeping your files and apps intact. The script uses **official Windows installation media** (no cracks or hacks) and requires a valid Windows 11 Pro license key.

## 🔧 Features

* 🛠 **In-place upgrade** to Windows 11 Pro from a wide range of editions (Home, Pro, Enterprise, Education, IoT, LTSC, etc.).
* ☑️ **Keeps files and apps** – performs a repair-install style upgrade without wiping your data.
* 📥 **Official ISO download** – auto-fetches the Windows 11 ISO using the [Fido](https://github.com/pbatard/Fido) script (which automates access to Microsoft’s retail ISO links) or via manual download.
* 🔄 **Fallback options** – if automated download fails, it can fall back to the [MAS (Massgrave) download page](https://massgrave.dev/genuine-installation-media) for genuine ISOs or use a manually downloaded ISO (from Microsoft or other trusted sources).
* 🔑 **Handles licensing prompts** – automatically accepts the EULA and prompts for the Windows 11 Pro product key. Requires a valid key (it does *not* bypass activation).
* ⚙️ **Multi-edition ISO support** – works with Microsoft’s multi-edition ISO (which selects the edition via product key).
* 💯 **Genuine media only** – uses only official Microsoft or MAS-sourced ISOs (all download links are verified as genuine files).

## 💻 Compatibility

| Windows Edition                              | Status           |
| -------------------------------------------- | ---------------- |
| Windows 10 Home / Pro / Education            | ✅ Tested         |
| Windows 10 Enterprise (incl. N/KN)           | ✅ Tested         |
| Windows 10 Enterprise LTSC/LTSB              | ✅ Tested         |
| Windows 10 IoT Enterprise                    | ⚠️ Known to work |
| Windows 11 Home / Pro / Education            | ✅ Tested         |
| Windows 11 Enterprise (incl. LTSC 2021/24H2) | ✅ Tested         |
| Other (N/KN editions, Insider builds)        | ⚠️ May vary      |

*Legend: ✅ = confirmed working; ⚠️ = may work or experimental.*

> **Note:** The MAS download page explicitly lists “Windows 10/11 Enterprise LTSC” among its offerings, indicating support for those editions.

## 🚀 Usage

1. **Prerequisites:**  Ensure you have a **valid Windows 11 Pro product key** and are running Windows 8 or later.
2. **Obtain Windows 11 ISO:** The script will attempt to download the official ISO via the Fido tool.  If that fails or offline, manually download the Windows 11 multi-edition ISO from Microsoft or get it from MAS.
3. **Run the script:** Copy `WindowsEditionToPro.ps1` to the machine you want to upgrade.  Open an elevated PowerShell (Run as Administrator).
4. **Execute:** At the PowerShell prompt, run:

   ```powershell
   .\WindowsEditionToPro.ps1
   ```
5. **Follow prompts:** The script will prompt you to select or confirm the ISO source, accept the Windows EULA, and enter your Windows 11 Pro product key.
6. **Complete upgrade:** The system will reboot into setup and proceed with the upgrade.  After completion, Windows will be at the Pro edition with your files and apps retained.

**Fallback:** If the automated download via Fido/MAS is not possible (e.g. no internet), simply place the ISO file in the same folder as the script and rerun. The script will detect and use it.

## ⚠️ Warnings / License

* ⚠️ **License Required:** You **must** have a valid license key for Windows 11 Pro.  The official process requires entering a new edition’s product key before or during the upgrade. This script does not provide a license or bypass activation.
* ⚠️ **Legitimate Media:** Only use official or MAS-provided ISOs. The MAS site notes: *“All download links available on our website lead to genuine files only.”* Always verify you’re using an unmodified, official ISO (for example, by checking the Microsoft SHA-256 hashes).
* ⚠️ **Unsupported Paths:** Microsoft documentation shows some edition changes are unsupported (for example, Enterprise→Pro is marked ❌). This script still attempts such upgrades, but it may behave like a clean install in those cases (keep an extra backup just in case).
* ⚠️ **Backup First:** As with any OS upgrade, back up important data before proceeding.
