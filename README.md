# Operator

Single-click LTE cell deployment (with Open5GS, srsRAN, and USRP devices). 

This branch runs a simple LTE cell with no fancy features.

## How to run
```bash
sudo ./operator.sh
```

> Logfiles are placed in `/lte`.

## Config file parameters
- **MCC**: Home network mobile country code
- **MNC**: Home network mobile network code
- **TYPE**: IP forwarding type (1=IPv4 only, 2=IPv6 only, 3=IPv4v6)
- **USRP**: Serial number of the USRP that is going to be used as base station radio frontend
- **NUM_UES**: Number of UEs to be registered in Core DB (The UEs will look like: MCC-MNC-000000001, MCC-MNC-000000002, etc)
- **KEY**: Sim key registered in Core DB
- **OPC**: Sim operator key registered in Core DB
