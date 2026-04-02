# Operator

Single-click 5G standalone cell deployment (with Open5GS, srsRAN, and USRP devices). 

This branch runs a simple cell without any extra features (no roaming nor handover nor mounting). 

## How to run
```bash
sudo ./operator.sh
```

> Logfiles are placed in `/gnb`.

## NOTES:

Add
```bash
sudo sysctl -w net.core.wmem_max=25000000
sudo sysctl -w net.core.rmem_max=25000000
sudo sysctl -w net.core.wmem_default=25000000
sudo sysctl -w net.core.rmem_default=25000000
sudo ip link set dev enp7s0f0np0 mtu 9000
```

## Config file parameters
- **MCC**: Home network mobile country code
- **MNC**: Home network mobile network code
- **TYPE**: IP forwarding type (1=IPv4 only, 2=IPv6 only, 3=IPv4v6)
- **USRP**: Serial number of the USRP that is going to be used as base station radio frontend
- **NUM_UES**: Number of UEs to be registered in Core DB (The UEs will look like: MCC-MNC-000000001, MCC-MNC-000000002, etc)
- **KEY**: Sim key registered in Core DB
- **OPC**: Sim operator key registered in Core DB