import beanstalkc
import UserDict
import time
import uuid

class BEANPKT(UserDict.UserDict):
    def __init__(self, **kw):
        UserDict.UserDict.__init__(self)
        self.bpacket = None
        self.data = kw
        self["STAMP"] = time.time()
        self["ID"] = str(uuid.uuid4())
    def stats(self):
        if self.bpacket:
            return self.bpacket.stats()
    def dumps(self):
        import simplejson
        return simplejson.dumps(self.data)
    def loads(self, data):
        import simplejson
        self.data = simplejson.loads(data)
    def done(self):
        if self.bpacket != None:
            self.bpacket.delete()
            self.bpacket = None
    def __del__(self):
        self.done()


class BEANSTALK:
    def __init__(self, env):
        self.env = env
        self.b = beanstalkc.Connection(self.env.cfg["BEANSTALK_ADDRESS"],
                                       self.env.cfg["BEANSTALK_PORT"], True,
                                       self.env.cfg["TIMEOUT"])
    def channel(self, _channel):
        self.b.watch(_channel)
    def push(self, channel, delay, pkt):
        self.b.use(channel)
        self.b.put(pkt.dumps(), delay=delay)
    def pull(self, channel):
        self.b.use(channel)
        data = self.b.reserve(0)
        if data == None:
            return None
        e = BEANPKT()
        e.loads(data.body)
        e.bpacket = data
        return e