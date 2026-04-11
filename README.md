# PowerShell Automation Toolkit

## Overview

This repository contains a collection of PowerShell scripts designed to automate common IT and cloud administration tasks across identity management, user lifecycle operations, and infrastructure.

The focus is on reducing manual effort, improving consistency, and enabling repeatable workflows in both on-premises and cloud environments.

---

## Core Focus Areas

* User lifecycle automation (onboarding & offboarding)
* Identity and access management
* System and device administration
* Azure infrastructure automation

---

## Script Breakdown

### User Lifecycle Automation

* **New-Onboarding.ps1**
  Automates new user onboarding workflows, such as account setup, group assignment, and initial configuration.

* **New-Offboarding.ps1**
  Handles user offboarding processes, including access removal, cleanup, and deprovisioning tasks.

* **Send-NewHireEmail.ps1**
  Sends onboarding-related communications for new users.

---

### Identity & User Management

* **Add-MsolGroups.ps1**
  Automates adding users to Microsoft Online (MSOL) groups.

* **Get-Employees.ps1**
  Retrieves user/employee data for reporting or automation workflows.

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

These scripts represent practical automation solutions for real-world administrative workflows, demonstrating:

* End-to-end user lifecycle automation
* Identity and access management in hybrid environments
* Infrastructure automation using scripting
* Operational efficiency through repeatable tooling

---

## Notes

* Scripts are environment-specific and may require modification before use
* Credentials and sensitive data are not included
* Intended for demonstration and portfolio purposes

---

## Future Improvements

* Standardize logging and error handling
* Add parameter validation and input schemas
* Convert commonly used scripts into reusable modules
* Integrate into CI/CD or automation pipelines

---

## Author Notes

This repository is part of a cloud engineering portfolio focused on automation, infrastructure, and operational tooling.
