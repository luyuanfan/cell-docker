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
<<<<<<< HEAD
- **OPC**: Sim operator key registered in Core DB
=======
- **OPC**: Sim operator key registered in Core DB

```
./pySim-prog.py -p0 -s 8949440000001703501 --mcc=999 --mnc=70 -a 59987167 --imsi=999700000170350  -k 63515E7822AD7EAB68F4930923553215 --opc=880D5FC7E4C4369D953FA649DC325577
./pySim-prog.py -p0 -s 8949440000001703519 --mcc=999 --mnc=70 -a 95536624 --imsi=999700000170351  -k A3DA21BF54192E4AEC81575C8B47F7F5 --opc=9F76D6E4B52079F4201C3178BBF503F5
./pySim-prog.py -p0 -s 8949440000001703527 --mcc=999 --mnc=70 -a 1394297 --imsi=999700000170352  -k 1C1C03E40A578C1C6ED49FBF45194177 --opc=0B4984A94FEC14503A7F4F332E5C826A
./pySim-prog.py -p0 -s 8949440000001703535 --mcc=999 --mnc=70 -a 75511758 --imsi=999700000170353  -k 973F40CB68B4F0F52670FA5A8730E68D --opc=3DF537607B20B3701D0A88F6E76D5CB5
./pySim-prog.py -p0 -s 8949440000001703543 --mcc=999 --mnc=70 -a 43229364 --imsi=999700000170354  -k 88C208464AA2D0903CB836102CA1FA6D --opc=E16B3BA0BEA58CDCA2032970C07E3C1A
./pySim-prog.py -p0 -s 8949440000001703550 --mcc=999 --mnc=70 -a 172651 --imsi=999700000170355  -k 179DF48FC0086C73E2C231F6569BCDBD --opc=CF38F250CB4098DFDB65EF6BC456AF1D
./pySim-prog.py -p0 -s 8949440000001703568 --mcc=999 --mnc=70 -a 50700174 --imsi=999700000170356  -k 38093B53D3BB97BFFF572867066377A0 --opc=51CA4C7D002228530AC69AF7CD5CA6DD
./pySim-prog.py -p0 -s 8949440000001703576 --mcc=999 --mnc=70 -a 20500848 --imsi=999700000170357  -k E605DF2391EB2920721560390A6CC16A --opc=BAF511651885BD3253FBA394C63A27A2
./pySim-prog.py -p0 -s 8949440000001703584 --mcc=999 --mnc=70 -a 33131109 --imsi=999700000170358  -k 2F2F8B695A87C9612BE38CD88CA30FBF --opc=8E7FAC84F8A37755D7F8520FC4431B82
```
>>>>>>> d9bd1443736ea9541a78dab35d41dc82acbd460c
