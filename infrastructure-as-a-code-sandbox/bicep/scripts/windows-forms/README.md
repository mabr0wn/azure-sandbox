# Packaging Windows Forms PowerShell Script into Executable with Invoke-PS2EXE

This guide explains how to package your PowerShell script that creates an Azure VM using a Windows Forms GUI (`CreateAzureVMGUI.ps1`) into a standalone executable (`CreateAzureVM.exe`) using the `Invoke-PS2EXE` PowerShell module. This allows you to distribute your script as an executable file without requiring the user to have PowerShell installed.

## Prerequisites

- PowerShell (any version 5.x or later)
- The `Invoke-PS2EXE` module
- PowerShell script (`CreateAzureVMGUI.ps1`)
- Azure icon (`azure.ico`, optional)

## Steps to Package the Script

### Step 1: Install `Invoke-PS2EXE` Module


First, install the `Invoke-PS2EXE` module from the PowerShell Gallery if you don't have it already:


```powershell
Install-Module -Name Invoke-PS2EXE -Force -Scope CurrentUser
```

### Step 2: Prepare Your PowerShell Script

Make sure your PowerShell script (`CreateAzureVMGUI.ps1`) is complete and functions as expected. This script should contain the logic for creating an Azure VM through a GUI, such as a Windows Forms application.

### Step 3: Package the Script as an Executable

To convert your PowerShell script into an executable file, use the following command:

```powershell
Invoke-PS2EXE .\CreateAzureVMGUI.ps1 -OutputFile .\CreateAzureVM.exe -noConsole -icon azure.ico
```

- `. \CreateAzureVMGUI.ps1`: Path to your PowerShell script.
- `-OutputFile .\CreateAzureVM.exe`: Path and name of the output executable.
- `-noConsole`: Ensures the application runs without showing the PowerShell console window.
- `-icon azure.ico`: (Optional) Specifies the icon for the executable. You can replace `azure.ico` with your own custom icon.

### Step 4: Run the Executable

After packaging, you can run the executable `CreateAzureVM.exe` like any other program on a Windows machine. The executable will launch the GUI, and users can interact with it without needing PowerShell.

### Troubleshooting

- If the executable doesn't work as expected, ensure that all external dependencies (such as the Azure PowerShell module) are included and accessible.
- Check the script for any hard-coded paths that may not work when packaged into an executable.
- If you face issues with the GUI elements not displaying properly, ensure all forms and controls are initialized correctly in the script.

## Example Use Case

This method is ideal for creating a user-friendly tool that allows users to create Azure VMs without requiring them to have PowerShell or complex command-line knowledge. The GUI provides an easy way to input necessary details (e.g., VM name, size, region) and execute the creation process.

## Additional Resources

- [Invoke-PS2EXE GitHub Repository](https://github.com/ironmansoftware/ps2exe)
- [Azure PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/azure/?view=az-ps)

## License

This project is licensed under the MIT License.

### Key Points to Note:
- **Invoke-PS2EXE** allows converting PowerShell scripts into executables, making them portable and easier to distribute.
- The `-noConsole` option hides the PowerShell console, offering a cleaner user experience, especially for GUI-based scripts.
- The optional `-icon` flag adds a custom icon to the executable, helping personalize the application.