# Operator

Single-click mobile operator deployment (1 eNB and core network).

## How to run
```bash
./operator.sh config.json
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


## Prgramming SIM cards

85875:
```bash
./pySim-prog.py -p0 -s 8988211000000858756 --mcc=310 --mnc=451 -a 55932037 --imsi=310451000000001 -k 05EA501E9AF94BBA1AE5DD426EFA0DAA --opc=DCB307105505164936A46C831AA9A98A
```

85876:
```bash
./pySim-prog.py -p0 -s 8988211000000858764 --mcc=310 --mnc=451 -a 25244338 --imsi=310451000000002 -k 3E26DAE6189CA50B529DD0879724CB40 --opc=62C9D3F11B6BA25C648B32FF1A2DD479
```

85866 (iPhone):
```bash
./pySim-prog.py -p0 -s 8988211000000858665 --mcc=310 --mnc=451 -a 88953847 --imsi=310451000000003 -k 3E14763419F4BF79EC1CCAEDDF6B57AF --opc=27DF2870CC361FDC568DE86C8B56F610
```
```bash
./pySim-prog.py -p0 -s 8988211000000858665 --mcc=999 --mnc=99 -a 88953847 --imsi=999990000000003 -k 3E14763419F4BF79EC1CCAEDDF6B57AF --opc=27DF2870CC361FDC568DE86C8B56F610
```

85861:
```bash
./pySim-prog.py -p0 -s 8988211000000858616 --mcc=310 --mnc=451 -a 73718177 --imsi=310451000000004 -k 0584FFFDFE867AE2C6CB469FB598BD5A --opc=44902D4577095F0BBFC8D1416D7548D6
```