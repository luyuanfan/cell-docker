Single-click 5G standalone cell deployment (with [Open5GS](https://github.com/open5gs/open5gs), [srsRAN_Project](https://github.com/srsran/srsRAN_Project/tree/main), and USRP B210/B200). 

This branch runs a rouge base station roaming attack scneario. It runs a legitimate trusted home network with PLMN `99970`. It also runs a rogue visited network with the registered PLMN `00101` (known by home network). The visited network also runs a secret base station under the PLMN `99980`. The phone should connect to `99980`. 

The home network is simulated in docker service `hplmn`, in which the core code is built in the docker container from unmodified `open5gs` code. The visited network is simulated in docker service `vplmn` where the core source code is mounted from the `/open5gs:vplmn` directory on the host machine. 

Behavior: HPLMN should only see `00101` and not know about the existence of `99980`. UE should see only `99980` but not `00101`. 

## How to run

To start cell, run: 
```bash
sudo ./operator.sh
```

## Config file parameters
- **MCC**: Home network mobile country code
- **MNC**: Home network mobile network code
- **APN**: Access point name (with which the phone's PLMN must match)
- **USRP**: Serial number of the USRP device (as the radio frontend)
- **NUM_UES**: Number of UEs to be registered in core DB
- **SIM INFO**
  - **IMSIx**: SIM card's international mobile subscriber identity (IMSI)
  - **KEYx**: SIM card's authentication key (K or Ki)
  - **OPCx**: SIM card's operator code (OPc)

## Logs

gNB RF and core logs are placed in `/gnb` with timestamps.

## Building Open5gs and srsRAN source files

After editing source code in either repository, run
```bash
./recompile.sh
```

## Acknowledgement

Code is based on [Operator](https://github.com/j0lama/Operator). 