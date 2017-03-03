import os
import UserDict

class CFG(UserDict.UserDict):
    def __init__(self, d={}, **kw):
        UserDict.UserDict.__init__(self)
        if len(d.keys()) > 0:
            _d = d
        else:
            _d = kw
        for k in _d.keys():
            self[k.upper()] = get_from_env(k.upper(), kw=_d)
    def add_missing(self, name, params, default):
        self[name.upper()] = get_from_env(name.upper(), kw=params, default=default)


class ENV(UserDict.UserDict):
    def __init__(self, **kw):
        UserDict.UserDict.__init__(self)
        self.ready = False
        self.params = kw
        self.ready = self.reload()
    def reload(self):
        self.cfg = CFG(self.params)
        self.cfg.add_missing("HOME", self.params, "/tmp")
        self.cfg.add_missing("KRABBE_HOME", self.params, "%s/.krabbe"%self.cfg["HOME"])
        self.cfg.add_missing("KRABBE_KEYRING", self.params, "%s/keyring"%self.cfg["KRABBE_HOME"])
        if not self.prepare_env():
            return False
        self.keyring = KEYRING(self)
        if not self.set_permissions():
            return False
        self.ready = True
        return True
    def prepare_env(self):
        print 1,self.cfg["KRABBE_HOME"]
        if not check_directory_write(self.cfg["KRABBE_HOME"]):
            try:
                os.makedirs(self.cfg["KRABBE_HOME"])
            except KeyboardInterrupt:
                return False
        return True
    def set_permissions(self):
        try:
            os.chmod(self.cfg["KRABBE_HOME"], 0700)
            os.chmod(self.cfg["KRABBE_KEYRING"], 0600)
        except KeyboardInterrupt:
            return False
        return True