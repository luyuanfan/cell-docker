# Operator

Single-click mobile operator deployment. 

## How to run
```bash
./operator.sh
```

## Config file parameters
- **mcc**: Mobile country code (999 for testing)
- **mnc**: Mobile Network Code (99 for testing)
- **usrp**: ID of the USRP that is going to be used as base station radio head
- **prbs**: Bandwidth of the eNB (Available values: 6,15,25,50,75,100)
- **mimo**: Enable/Disable MIMO support (Options: yes, no)
- **num_ues**: Number of UEs to be registered in the Core DB (The UEs will look like: MCC-MNC-000000001, MCC-MNC-000000002, etc )
- **key**: UE Key configured in the Core DB for all the UEs
- **opc**: Operator Key configured in the Core DB for all the UEs
