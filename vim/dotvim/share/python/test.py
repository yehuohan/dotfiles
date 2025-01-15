#!/usr/bin/env python3

from catch import catch
from singleton import singleton

# Note: double underline `__TAG` will become `_<ClassName>__TAG` when used at class scope
_TAG = "py"


def tst_catch():
    @catch(_TAG)
    def sub():
        raise Exception("tst_catch")

    sub()
    print(">>> Tested singleton")


def tst_singleton():
    @singleton
    class Sub:
        def __init__(self, x=0):
            self.x = x

    s1 = Sub(1)
    assert s1.x == 1
    s2 = Sub(2)
    assert s1.x == 1
    s2.x = 3
    assert s1.x == 3
    assert s1 == s2
    print(">>> Tested singleton")


if __name__ == "__main__":
    tst_catch()
    tst_singleton()
