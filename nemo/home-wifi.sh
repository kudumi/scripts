#!/bin/bash

sudo dhcpcd -S ip_address=${1:-192.168.0.111} -S routers=192.168.0.1 -S domain_name_servers=8.8.8.8
