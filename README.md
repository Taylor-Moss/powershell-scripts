# PowerShell Automation Toolkit

## Overview

This repository contains a collection of PowerShell scripts used to automate common IT and cloud administration tasks across identity management, infrastructure, and system operations.

The scripts focus on reducing manual effort, improving consistency, and enabling repeatable workflows in both on-premises and cloud environments.

---

## Use Cases Covered

* Identity and user lifecycle automation
* Active Directory / computer management
* Email and onboarding workflows
* Azure infrastructure configuration
* Storage and networking automation

---

## Script Breakdown

### Identity & User Management

* **Add-MsolGroups.ps1**
  Automates adding users to Microsoft Online (MSOL) groups.

* **Get-Employees.ps1**
  Retrieves employee/user data for reporting or automation workflows.

* **Send-NewHireEmail.ps1**
  Sends onboarding emails as part of new hire provisioning.

---

### System / Device Management

* **Get-Computers.ps1**
  Retrieves computer objects from Active Directory.

* **Move-Computer.ps1**
  Automates moving computer objects between organizational units.

---

### Cloud Infrastructure Automation

* **New-VNetPeering.ps1**
  Automates Azure Virtual Network peering configuration.

* **New-BlobReplication.ps1**
  Configures Azure Storage replication between regions.

---

### Modules

* **ExchangeFunctions.psm1**
  Reusable PowerShell module for Exchange-related automation tasks.

---

## Technologies Used

* PowerShell
* Azure (Networking, Storage)
* Microsoft 365 / MSOL
* Active Directory

---

## Purpose

These scripts represent practical automation solutions for real-world administrative tasks, demonstrating:

* Scripting for operational efficiency
* Cloud and hybrid environment management
* Identity and access workflow automation
* Reusable tooling via PowerShell modules

---

## Notes

* Scripts are designed for specific environments and may require modification before use
* Credentials and sensitive data are not included
* Intended for demonstration and portfolio purposes

---

## Future Improvements

* Parameterization and input validation
* Logging and error handling standardization
* Conversion into reusable modules or CLI tools
* Integration into CI/CD or automation pipelines

---

## Author Notes

This repository is part of a broader cloud engineering portfolio focused on automation, infrastructure, and operational tooling.
