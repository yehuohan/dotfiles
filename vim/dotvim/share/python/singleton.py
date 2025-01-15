def singleton(cls):
    # cls_new = cls.__new__
    cls_init = cls.__init__

    def __cls__new__(cls, *args, **kwargs):
        if cls.__instance is None:
            cls.__instance = object.__new__(cls)
            cls.__instance.__has_inited = False
            # print(cls.__dict__)
            # print(cls.__instance.__dict__)
        return cls.__instance

    def __cls__init__(self, *args, **kwargs):
        if self.__has_inited:
            return
        cls_init(self, *args, **kwargs)
        self.__has_inited = True

    cls.__instance = None
    cls.__new__ = __cls__new__
    cls.__init__ = __cls__init__
    return cls
