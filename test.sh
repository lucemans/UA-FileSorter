#!/bin/bash

rm -rf ./Inleiding\ Programmeren

# Download file and call it download.tgz
curl -o download.tgz http://msdl.cs.mcgill.ca/people/hv/teaching/ComputerSystemsArchitecture/materials/CS_Unix/materials/CS_Unix/assignment_UA_Inleiding%20Programmeren_Huistaak%201%20Hello%20World_2019-11-11.tgz 2> /dev/null

./sort.sh ./download.tgz ./template/python.sh

rm -rf ./download.tgz > /dev/null