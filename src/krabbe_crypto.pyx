import uuid
import UserDict
import time
import msgpack

class PACKET(UserDict.UserDict):
    def __init__(self, env=None):
        UserDict.UserDict.__init__(self)
        self.env = env
        self["ID"] = str(uuid.uuid4())
        self["STAMP"] = time.time()
        self["DATA"] = None
        self["COMPRESS"] = "zlib"
    def envelope(self, pkt, **kw):
        dump_status, zalgo, data = pkt.envelope_dumps()
        if dump_status != True:
            return False
        self["DATA"] = data
        self["SIGNATURE"] = self.env.keyring.sign(self.env.cfg["KEYNAME"], self["DATA"])
        self["KEYNAME"] = self.env.cfg["KEYNAME"]
        return True
    def envelope_dumps(self):
        return compress(msgpack.dumps(self.data), ["zlib"])
    def envelope_loads(self):
        p = PACKET(self.env)
        if not self["DATA"]:
            return {}
        d = msgpack.loads(decompress(self["DATA"], self["COMPRESS"]))
        p.assign(d)
        return p
    def assign(self, d):
        if type(d) == type({}):
            self.data = d
        elif type(d) == type(""):
            self.data = msgpack.loads(decompress(d, self["COMPRESS"]))
        else:
            return