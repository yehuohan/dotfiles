#!/usr/bin/env python

import os

def check_touchpad_state(dev_num):
    dev_state = os.popen('xinput list-props  %s' % str(dev_num))
    for lines in dev_state.readlines():
        if 'Device Enabled' in lines:
            sig = lines[-3:-1].strip()
            signal = int(sig)
            print ('signal now :%d' % signal)
            return signal


def get_dev_num(dev_name = 'SynPS/2 Synaptics TouchPad'):
    dev_state = os.popen('xinput list')
    for lines in dev_state.readlines():
        if dev_name in lines:
            print (lines)
            station = lines.find('id=')
            dev_num = lines[station + 3: station+5]
            dev_num = int(dev_num)
            print ('dev_num: %d' % dev_num)
            return dev_num
    dev_state.close()

def change_state(state_value, dev_num):
    print ('state_value = ', state_value)
    state = not state_value
    if state == True:
        state = 1
    #else:
        #state = 0
    #print ('state = ', state, str(state))
    tem = os.popen("xinput set-prop %s 'Device Enabled' %s" % (str(dev_num), str(state)))
    tem.close()

def main():
    dev_num = get_dev_num()
    state = check_touchpad_state(dev_num)
    change_state(state, dev_num)


if __name__ == '__main__':
    main()


