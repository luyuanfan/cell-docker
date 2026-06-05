Single-click 5G standalone cell deployment (with [Open5GS](https://github.com/open5gs/open5gs), [srsRAN_Project](https://github.com/srsran/srsRAN_Project/tree/main), and USRP B210/B200). 

This branch simulates a roaming attack scenario that involves a state-sponsored rogue base station. The scenario has three parts:

1. An User Equipment (UE). It has a SIM card that is registered in the home network database. It is physically in the service region of the visited network, and out of that of the home network. 
  - It has roaming turned on.
  - It has the PLMN of its Access Point Name (APN) set to `99970`, which is the home network's PLMN.
  - It thinks that it is being served by `99980`. 

2. A home network. It is trusted by the UE, and has a roaming partnership agreement with the visited network.
  - It has its own PLMN set to `99970`.
  - It has a list of its roaming partners (in the form of the visited network's SEPP function's URIs; IRL it may be handled differently).
  - *Its core services are simulated in docker container `hplmn`.*

3. A visited network. It serves the region where the UE is physically at.
  - It has its own PLMN set to `00101` (as a network operator). 
  - It is (and must be) configured to support both HPLMN and VPLMN access control.
  - It runs a secret rouge base station which broadcasts the PLMN `99980`; the phone should connect to the network with PLMN `99980`. 
  - *Its core services are simulated in docker container `vplmn`.*
  - *Its radio access network (RAN) services are simulated in container `gnb`.*

Behavior: HPLMN should only see `00101` and not know about the existence of `99980`. UE should think it is being served by `99980`. 

## How to run

To start cell, run: 
```bash 
sudo ./operator.sh
```

## Config file parameters
- **MCC**: Home network mobile country code
- **MNC**: Home network mobile network code
- **APN**: Access point name (with which the phone setting's APN must match)
- **USRP**: Serial number of the USRP device (as the radio frontend)
- **NUM_UES**: Number of UEs to be registered in core DB
- **SIM INFO**
  - **IMSIx**: SIM card's international mobile subscriber identity (IMSI)
  - **KEYx**: SIM card's authentication key (K or Ki)
  - **OPCx**: SIM card's operator code (OPc)

## Logs

All logs are placed in `/roaming` locally. 

## Building Open5gs and srsRAN source files

After editing source code in either repository, run
```bash
./recompile.sh
```

## Acknowledgement

Code is based on [Operator](https://github.com/j0lama/Operator). 