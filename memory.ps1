$memorytype = "Unknown", "Other", "DRAM", "Synchronous DRAM", "Cache DRAM",
"EDO", "EDRAM", "VRAM", "SRAM", "RAM", "ROM", "Flash", "EEPROM", "FEPROM",
"EPROM", "CDRAM", "3DRAM", "SDRAM", "SGRAM", "RDRAM", "DDR", "DDR-2", "DDR-3", "DDR-4"
$formfactor = "Unknown", "Other", "SIP", "DIP", "ZIP", "SOJ", "Proprietary",
"SIMM", "DIMM", "TSOP", "PGA", "RIMM", "SODIMM", "SRIMM", "SMD", "SSMP",
"QFP", "TQFP", "SOIC", "LCC", "PLCC", "BGA", "FPBGA", "LGA"
$col1 = @{Name='Size (GB)'; Expression={ $_.Capacity/1GB } }
$col2 = @{Name='Form Factor'; Expression={$formfactor[$_.FormFactor]} }
$col3 = @{Name='Memory Type'; Expression={ $memorytype[$_.MemoryType] } }


get-wmiobject Win32_PhysicalMemory  -computername localhost| Select-Object BankLabel, $col1, $col2, $col3
