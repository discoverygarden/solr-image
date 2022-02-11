# README
Difference in v1 and v2 is a performance/security trade-off

## v1
- better performance as services are mapped ports on VM, which is exposed
- more ports are exposed = less secure

## v2
- utilizes Docker network
- performance is lower as there is increased latency from the extra hops
- increased security as ports for supporting services are only exposed within the network

## ATTENTION!!! :
- `generate_configs.sh` was written for/tested on Ubuntu, so some commands used to acquire private IP (for example) may not work properly if run from a Mac or other Linux distros

## TODO
- disable ClamAV via config_override
