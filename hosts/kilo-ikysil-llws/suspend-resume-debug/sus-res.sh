#! /bin/bash

sync && echo 1 > /sys/power/pm_trace && pm-suspend
