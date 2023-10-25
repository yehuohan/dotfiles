#!/usr/bin/env python3

"""
Linked this file to /usr/local/bin with 'ln -s'
Usage:
    ./ToggleTouchPad.py         : toggle touchpad
    ./ToggleTouchPad.py on      : enable touchpad
    ./ToggleTouchPad.py off     : disable touchpad
"""

import os
import sys


def get_touchpad_state(dev_num):
    """Get touchpad state
    :Returns:
        0 or 1
    """
    dev_state = os.popen("xinput list-props  %s" % str(dev_num))
    for lines in dev_state.readlines():
        if "Device Enabled" in lines:
            sig = lines[-3:-1].strip()
            signal = int(sig)
            print("signal now :%d" % signal)
            return signal


def get_dev_num(dev_name="SynPS/2 Synaptics TouchPad"):
    """Get touchpad device number"""
    dev_state = os.popen("xinput list")
    for lines in dev_state.readlines():
        if dev_name in lines:
            print(lines)
            station = lines.find("id=")
            dev_num = lines[station + 3 : station + 5]
            dev_num = int(dev_num)
            print("dev_num: %d" % dev_num)
            return dev_num
    dev_state.close()


def set_state(state_value, dev_num):
    """Set touchpad state
    :Parameters:
        - state_value: 0 for disable touchpad and 1 for enable touchpad
        - dev_num: touchpad device number
    """
    print("state_value = ", state_value)
    tem = os.popen(
        "xinput set-prop %s 'Device Enabled' %s" % (str(dev_num), str(state_value))
    )
    tem.close()


def main(args):
    dev_num = get_dev_num()
    if len(args) >= 2:
        if args[1] == "on":
            state = 1
        elif args[1] == "off":
            state = 0
    else:
        state = get_touchpad_state(dev_num)
        state = not state
        state = 1 if state == True else 0
    set_state(state, dev_num)


if __name__ == "__main__":
    main(sys.argv)
