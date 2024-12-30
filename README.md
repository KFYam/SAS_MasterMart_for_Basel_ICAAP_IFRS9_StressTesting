# SAS_MasterMart_for_Basel_ICAAP_IFRS9_StressTesting
## Description
This repository contains SAS scripts developed for preparing a centralized master fact table to support key regulatory risk management projects, including IFRS9, stress testing, and advanced risk modeling (PD, EAD, LGD). The scripts integrate financial data, segment data by regulatory requirements, and validate compliance with Basel III and ICAAP standards.

## Key Features
1. **Regulatory Scope**: Supports IFRS9 compliance, Basel III validation, and ICAAP reporting.
2. **Advanced Modeling**: Prepares data for PD, EAD, LGD modeling and stress testing.
3. **Comprehensive Integration**: Creates a unified data mart by integrating diverse datasets.

## File Structure
| Script Name             | Purpose                                                  |
|-------------------------|----------------------------------------------------------|
| `00. STARTSCRIPT.sas`   | Initializes directories, libraries, and global variables. |
| `01. CAR_BASE.sas`      | Extracts base financial data and global parameters.       |
| `02. RU_NONBANK_EXP.sas`| Processes non-banking exposure datasets.                 |
| `04. ST_SEGMENT.sas`    | Segments data for modeling and regulatory analysis.       |
| `05. ST_COUNTRY_FI.sas` | Aggregates data by country for financial institution analysis. |
| `06. BIS_BASEL_III_CHECK.sas` | Conducts Basel III compliance checks and validations. |
| `07. PLOAN_A-CARD.sas`  | Processes credit card and personal loan data.            |
| `91. ICAAP_STARTSCRIPT.sas` | Prepares ICAAP-specific datasets.                     |
| `92. RST_STARTSCRIPT.sas` | Configures Reverse Stress Testing-specific data marts.   |
| `93. RP_STARTSCRIPT.sas` | Finalizes master fact data for reporting.                |

## Setup Instructions
1. Clone the repository:  
   ```
   git clone https://github.com/YourOrgName/IFRS9_StressTest_FactMart.git
   ```
2. Configure `00. STARTSCRIPT.sas`:
   - Update `&dir_root`, `&st_RptMth`, and other paths specific to your environment.
   - Assign libraries for staging and mart directories.

3. Run scripts in sequential order (00 → 93).

## Purpose
The output of this repository is a master fact/data mart that centralizes data preparation for IFRS9, stress testing, and risk analytics. It ensures compliance with regulatory standards and supports advanced risk modeling.
