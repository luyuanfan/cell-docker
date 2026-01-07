Single-click cell deployment (with Open5GS, srsRAN, and USRP devices). 

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

85876 (authenticated and able to attach and go online):
```bash
./pySim-prog.py -p0 -s 8988211000000858764 --mcc=310 --mnc=451 -a 25244338 --imsi=310451000000002 -k 3E26DAE6189CA50B529DD0879724CB40 --opc=62C9D3F11B6BA25C648B32FF1A2DD479
```

85866 (modified for iPhone following [these step](https://github.com/herlesupreeth/docker_open5gs/discussions/248#discussioncomment-7392233); PLMN is 99999; does not see the cell but tries to connect in the background; getting some strange SUPI errors):
```bash
./pySim-prog.py -p0 -s 8988211000000858665 --mcc=999 --mnc=99 -a 88953847 --imsi=999990000000003 -k 3E14763419F4BF79EC1CCAEDDF6B57AF --opc=27DF2870CC361FDC568DE86C8B56F610
```

85861 (authenticated and able to attach and go online):
```bash
./pySim-prog.py -p0 -s 8988211000000858616 --mcc=310 --mnc=451 -a 73718177 --imsi=310451000000004 -k 0584FFFDFE867AE2C6CB469FB598BD5A --opc=44902D4577095F0BBFC8D1416D7548D6
```

85865 (unauthenticated but can see the cell; apn is configured; tries hard to attach)

85863 (another one for iphone, configured following the regular tutorial; does not see the cell):
```bash
./pySim-prog.py -p0 -s 8988211000000858632 --mcc=999 --mnc=99 -a 52071445 --imsi=999990000000003 -k 8B162AF6C8231ED9C4BB96F8054FBE36 --opc=49B6D989E4D9D3722128FF32C1E499CA
```

## Acknowledgement

Code is based on [Operator](https://github.com/j0lama/Operator). 
