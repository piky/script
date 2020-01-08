#!/usr/bin/python

import os

# List only files in current directory.
files = [f for f in os.listdir('.') if os.path.isfile(f)]

# List files in specific directory. Replace /somedir with your choice.
#files = [f for f in os.listdir("/somedir") if os.path.isfile(os.path.join("/somedir", f))]

for f in files:
	print (f)
