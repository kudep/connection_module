#!/bin/bash

iverilog -o main connection_module.v reception_module.v transmission_module.v top_connection_module_tb.v

vvp main

#gtkwave test.vcd &