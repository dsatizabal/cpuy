# CPUy Bring Up (WIP)

To do the bring up of the cpuy, you need to first flash the caravel SoC to select project 3 (cpuy) and configure
all GPIOs. To do so, you need only to run a script that I will write in the future

* enter caravel
cd caravel

* create a python venv
python3 -m venv --prompt caravel_board .venv
echo '*' >> .venv/.gitignore
source .venv/bin/activate
python3 --version # Python 3.10.12

* do
pip3 install pyftdi

* Create a "mapping" for lower-level usermode control of the FTDI USB-serial device, i.e. run lsusb to get the VID:PID (probably 0403:6014) and (as root) put into a new file called /etc/udev/rules.d/99-ftdi-everyone.rules: 

# Per https://groups.google.com/g/weewx-user/c/kol0udZNuyc/m/1WhtZF0kBAAJ
# ...and https://github.com/algofoogle/journal/blob/master/0206-2024-06-26.md
# ...this ensures all users get full access to the FTDI USB interface on
# the caravel_board hardware, without having to be root:

SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6014", MODE="666"

*  ...then: sudo service udev restart and unplug and replug the board, and pass back thru to Linux VM (if necessary).

* Try HKDebug: 

cd firmware/gf180/util
python3 caravel_hkdebug.py

*  ...and expect to see: 
Success: Found one matching FTDI device at ftdi://ftdi:232h:1:4/1
Caravel data:
   mfg        = 0456
   product    = 20
   project ID = 1801dc4f
   project ID = f23b8018

## Related repos:

* caravel board: https://github.com/efabless/caravel_board  
* other projects in the chip: https://github.com/algofoogle/algofoogle-multi-caravel

![GPIO](docs/gpio.jpeg)