# The Greater Wall
* Author: Kyle Desjardins
* Co-author: Justin Demoss
* Email: Thegreaterwall@gmail.com
* Creation Date: December 2019
* Release Date: 05 November 2021
* Last Updated: 06 September 2023
#### Important
* Make sure to always download the latest copy of The Greater Wall to ensure you have the most up to date features and bug fixes.
#### PowerShell - PowerShell Hunt and data collection framework
* Agentless
* Written entirely in PowerShell
* Customizable
***
***
### Setup
1. Download code as .zip
2. Extract the folder
3. Right-click setup.ps1 and choose "run with PowerShell"

At the end of the setup, an administrative PowerShell ISE window will open.
The Greater Wall must be run in an administrative PowerShell ISE window.
***
***
### 5/31/2024
* Temporarily removed the Active Directory Enumeration Module. Making improvements on how it collects and post processes the AD data. Will upload when complete.
  
### Coming Soon 
* Entirely powershell-native light weight machine learning.

### New Features 9-8-2023
* 2 New modules! WindowsDrivers and WindowsFirewall

### Update 9/8/2023
* Fixed minor issue with adding targets
* When running against localhost, the newly created results folder will now have the computername present in its name so that you can distinguish between different localhosts
  
### Update 9/6/2023
* The issue with the winlog beat forwarding has been resolved.

### New Features 10-20-2022
* New feature! Results can either be pulled back to your system  (Traditional) or left on the remote endpoint, allowing for an already existing log forwarder push them to your SIEM.
* New Feature! Load from a saved running configuration.
* New Module! EnumerateEventLogs - Gathers a list of every event log being logged on a system. Quickly determine whether the auditpolicy is set to log what you think it's logging.

### New Features 9-20-2022
* New Module! AppCompatCache
* Improved ServiceInfo Module - Now includes Service Recovery Options data property
* New feature! Ability to categorize results by operating system prior to analyzing outliers

https://www.paypal.com/donate/?business=9YT3GRLGZPHML&no_recurring=0&currency_code=USD

