import msgpack
import time
include "krabbe_db_localfiles.pyx"
include "krabbe_db_lmdb.pyx"

class KRABBE_DB:
    def __init__(self, env, _shell=None, **kw):
        self.env = env
        self.shell = _shell
        self.params = kw
        if self.env.cfg["KRABBE_DBTYPE"] == "lmdb":
            self.drv = KRABBE_LMDB_DRIVER(self.env, self.shell)
        else:
            self.drv = None
        if self.reload() == False:
            if self.shell != None:
                self.shell.error("Database initialization had failed")
            self.drv = None
    def isReady(self):
        if self.drv == None:
            return False
        return True
    def reload(self):
        if not self.isReady():
            return False
        if self.drv.reload() != True:
            if self.shell != None:
                self.shell.error("%s database driver initialization had failed"%self.env.cfg["KRABBE_DBTYPE"])
            self.drv = None
            return False
        return True
    def _set(self, name, key, val):
        data = msgpack.dumps([time.time(),val])
        return self.drv.set(name, key, data)
    def _get(self, name, key):
        data = self.drv.get(name, key)
        if data == None:
            return None
        _t, _val = msgpack.loads(data)
        return _val
    def setVar(self, key, value):
        path = "/%s/%s"%(self.env.cfg["NODENAME"], key)
        return self._set("VARSTOR",path, value)
    def getVar(self, key):
        path = "/%s/%s" % (self.env.cfg["NODENAME"], key)
        return self._get("VARSTOR",path)

