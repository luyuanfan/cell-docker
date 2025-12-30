Single-click cell deployment (with Open5GS, srsRAN, and USRP devices). 

## How to run

To start cell simply, run: 
```bash
sudo ./operator.sh
```

## Roaming

To start cell with roaming, run:
```bash
sudo ./start.sh -r
```

## Intra-gNB handover

To start cell with CU-DU split and trigger handover, run: 
```bash
sudo ./operator.sh -h
./handover.sh
```

The left-most window runs `cu`, then `du_1`, then `du_2`.

In `du_1` and `du_2`, type `t` to view trace; in `cu`, type `ho <serving pci> <rnti> <target pci>` to force handover.

## Config file parameters
- **MCC**: Home network mobile country code
- **MNC**: Home network mobile network code
- **TYPE**: IP forwarding type (1=IPv4 only, 2=IPv6 only, 3=IPv4v6)
- **USRP**: Serial number of the USRP that is going to be used as base station radio frontend
- **NUM_UES**: Number of UEs to be registered in Core DB (The UEs will look like: MCC-MNC-000000001, MCC-MNC-000000002, etc)
- **KEY**: Sim key registered in Core DB
- **OPC**: Sim operator key registered in Core D B

## Notes

- Home network PLMN: 99970
- Visitied network PLMN: 00101 and 315010
- gNB running on visited network 00101, phone registered on 99970

## Programming SIM cards

85875 is programmed to be registered in home network 99970:
```bash
./pySim-prog.py -p0 -s 8988211000000858756 --mcc=999 --mnc=70 -a 55932037 --imsi=999700000000001 -k 05EA501E9AF94BBA1AE5DD426EFA0DAA --opc=DCB307105505164936A46C831AA9A98A
```

## Acknowledgement

Code is based on [Operator](https://github.com/j0lama/Operator). 
