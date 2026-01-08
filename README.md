Single-click cell deployment (with Open5GS, srsRAN, and USRP devices). 

This branch runs a simple cell with roaming support and with `open5gs` mounted from the host machine (no handover support). The intention is the recreate the roaming attack described in ["Wherever I May Roam: Stealthy Interception and Injection Attacks through Roaming Agreements"](https://hpi.de/fileadmin/user_upload/90_Research_Groups/classen/Documents/Lange_2024_Wherever_I_May_Roam-Stealthy_Interception_and_Injection_Attacks_through_Roaming_Agreements_author_version.pdf) (page 12). 

## How to run

To start cell, run: 
```bash
sudo ./operator.sh
```

## Mounting

To build `open5gs` for the first time, run:
```bash
cd ~ 
git clone git@github.com:luyuanfan/open5gs.git
sudo mv open5gs /
cd /open5gs
meson build --prefix=`pwd`/install
ninja -C build
cd build
ninja install
```

To rebuild `open5gs` after editing source code, run:
```bash
./recompile.sh
```

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
