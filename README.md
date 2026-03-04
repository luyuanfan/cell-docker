Single-click 5G standalone cell deployment (with Open5GS, srsRAN, and USRP devices). 

This branch runs a rouge base station roaming attack scneario. Both `open5gs` and `srsRAN_Project` are mounted from host machine. It runs a home network (HPLMN: 99970) and a visited network (VPLMN: 00101). The visited network broadcasts a fake identity (PLMN: 99980). Target UE is registered on home network and in the serving region of the visited network. The 

The home network's core is built in docker image. The visited network's core is mounted from host machine. 

## How to run

To start cell, run: 
```bash
sudo ./operator.sh
```

## Config file parameters
- **MCC**: Home network mobile country code
- **MNC**: Home network mobile network code
- **TYPE**: IP forwarding type (1=IPv4 only, 2=IPv6 only, 3=IPv4v6)
- **USRP**: Serial number of the USRP that is going to be used as base station radio frontend
- **NUM_UES**: Number of UEs to be registered in Core DB (The UEs will look like: MCC-MNC-000000001, MCC-MNC-000000002, etc)
- **KEY**: Sim key registered in Core DB
- **OPC**: Sim operator key registered in Core DB

## Programming SIM cards

1. 85875 is programmed to be registered in home network 99970:
```bash
./pySim-prog.py -p0 -s 8988211000000858756 --mcc=999 --mnc=70 -a 55932037 --imsi=999700000000001 -k 05EA501E9AF94BBA1AE5DD426EFA0DAA --opc=DCB307105505164936A46C831AA9A98A
```

2. 85876 (on white nothing phone, connected)
```bash
./pySim-prog.py -p0 -s 8988211000000858764 --mcc=999 --mnc=70 -a 25244338 --imsi=999700000000002 -k 3E26DAE6189CA50B529DD0879724CB40 --opc=62C9D3F11B6BA25C648B32FF1A2DD479
```

3. 85866 (modified for iPhone following [these step](https://github.com/herlesupreeth/docker_open5gs/discussions/248#discussioncomment-7392233)):
```bash
./pySim-prog.py -p0 -s 8988211000000858665 --mcc=999 --mnc=70 -a 88953847 --imsi=999700000000003 -k 3E14763419F4BF79EC1CCAEDDF6B57AF --opc=27DF2870CC361FDC568DE86C8B56F610
```

4. 85861:
```bash
./pySim-prog.py -p0 -s 8988211000000858616 --mcc=999 --mnc=70 -a 73718177 --imsi=999700000000004 -k 0584FFFDFE867AE2C6CB469FB598BD5A --opc=44902D4577095F0BBFC8D1416D7548D6
```

5. gialer 5

6. 85865 (on blue samsung, connected)
```bash
./pySim-prog.py -p0 -s 8988211000000858657 --mcc=999 --mnc=70 -a 51897857 --imsi=999700000000006 -k C7DE9F9BED42D654B562F62DF53628F7 --opc=5469AE5A50E405EE36A2F9CBD8FE5502
```

7. gialer 7
8. gialer 8 (on matte oneplus phone, connected)
9. gialer 9

## Acknowledgement

Code is based on [Operator](https://github.com/j0lama/Operator). 

##  TODO

Glossy oneplus also have a hard time connectintg.

Pixel 9's modem doesn't seem to think either sysmocom nor gialer SIM card is 5G enabled, it does think a regular T-Mobile SIM is 5G enabled. 

> TODO: Might want to see how to make the phone think that the card is 5G enabled.

> TODO: Check how eSIM works on pixel 10.

> TODO: really not sure what the metrics field means in all the config files. The way I'm trying to run AMF might be really wrong

> TODO: also might want to fix the log file problem. the open5gs files are not recorded anywhere on the host machine and we might want to pick some and maybe sort them or something into one big file question mark?

One thing to consider is to have srsran be ok with weird sbi block without needing this entry in the supported tracking areas in cu_up because i feel like this might be what srsran also sends to core. 
```bash
- plmn: "99980"
    tai_slice_support_list:
        - sst: 1
```

another possibility is that the message the phone sends back to srsran contains some information about the plmn it heard (the fake one) and that gets sent to the core as well. this part needs more reading. can read the pcap files and also read the shared tech notes. 

## Logs

the gnb logs and those pcaps are placed in `/gnb` and the logs from the cores are 