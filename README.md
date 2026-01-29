Single-click 5G standalone cell deployment (with Open5GS, srsRAN, and USRP devices). 

This branch runs a simple cell without handover nor roaming, with both `open5gs` and `srsRAN_Project` source code and executables mounted from the host machine. 

## How to run

To start cell simply, run: 
```bash
sudo ./operator.sh
```

## Mounting

Both `open5gs` and `srsRAN_Project` are directly mounted from host. Since there are absolute pathes baked into these files at the time of make, it's important that we place and build these two directories in a convenient place (since they are placed in `/` in the container, we just build them in `/` on the host as well):

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

To build `srsRAN_Project` for the first time, run:
```bash
cd ~
git clone git@github.com:luyuanfan/srsRAN_Project.git
sudo mv srsRAN_Project /
cd srsRAN_Project
mkdir build
cmake ../
make -j $(nproc)
```

> How srsRAN_Project is built depends on the version of one of its dependencies--libuhd. In the container, we do `apt install libuhd-dev uhd-host` and install libuhd.so.4.6.0, so any gNB binary we run in there must also be linked to 4.6.0. If there is other libuhd versions installed (such as 4.8.0, build from source) when you build srsRAN_Project on the host, CMake might build srsRAN_Project against that version. Then the resulting gNB binary will depend on 4.8.0, and it won’t run inside the container that only has 4.6.0. Therefore, make sure the host only has libuhd.so.4.6.0 when you build srsRAN_Project. 

## Config file parameters
- **MCC**: Home network mobile country code
- **MNC**: Home network mobile network code
- **TYPE**: IP forwarding type (1=IPv4 only, 2=IPv6 only, 3=IPv4v6)
- **USRP**: Serial number of the USRP that is going to be used as base station radio frontend
- **NUM_UES**: Number of UEs to be registered in Core DB (The UEs will look like: MCC-MNC-000000001, MCC-MNC-000000002, etc)
- **KEY**: Sim key registered in Core DB
- **OPC**: Sim operator key registered in Core DB

## Notes

- Home network PLMN: 99970
- Visitied network PLMN: 00101 and 315010
- gNB running on visited network 00101, phone registered on 99970

## Programming SIM cards

1. 85875:
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
9. gialer 9

Glossy oneplus also have a hard time connectintg.
Glossy oneplus also have a hard time connectintg.

Pixel 9's modem doesn't seem to think either sysmocom nor gialer SIM card is 5G enabled, it does think a regular T-Mobile SIM is 5G enabled. 
Pixel 9's modem doesn't seem to think either sysmocom nor gialer SIM card is 5G enabled, it does think a regular T-Mobile SIM is 5G enabled. 
> Note: gialer 5 and 7 are not doing great. fix it

I'm actually not so happy with the auto branch switch code because it seems like the built content would not change at branches switch. Don't want to look into it now yet.