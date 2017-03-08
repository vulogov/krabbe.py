import zmq.green as zmq
import gevent
import time
import ipaddr


class INTRODUCER:
    def recv(self):
        data = self.socket.recv_string()
        e = PACKET(self.env)
        e.assign(data)
        return e.envelope_loads()
    def send(self, pkt):
        e = PACKET(self.env)
        e.envelope(pkt)
        data = e.envelope_dumps()
        self.socket.send_string(data)



class INTRODUCER_SERVER(INTRODUCER, TASKS):
    def __init__(self, env, _shell=None):
        TASKS.__init__(self)
        self.env = env
        self.shell = _shell
        self.context = zmq.Context()
        self.socket = self.context.socket(zmq.REP)
        self.socket.bind(self.env.cfg["WELCOME_LISTEN"])
        self.spawn("server", self.loop)
    def exchange(self):
        e = self.env.gen_env_packet()
        remote = self.recv()
        self.send(e)
        print remote
    def loop(self):
        while True:
            self.exchange()





class INTRODUCER_CLIENT(INTRODUCER, TASKS):
    def __init__(self, env, ip=None):
        TASKS.__init__(self)
        self.env = env
        self.context = zmq.Context()
        self.socket = self.context.socket(zmq.REQ)
        if ip == None:
            self.addr = "tcp://%s:%d"%(self.env.cfg["WELCOME_PUBLIC_LISTEN_IP"], self.env.cfg["WELCOME_PUBLIC_LISTEN_PORT"])
        else:
            self.addr = "tcp://%s:%d"%(ip, self.env.cfg["WELCOME_PUBLIC_LISTEN_PORT"])
        self.socket.connect(self.addr)
    def exchange(self):
        e = self.env.gen_env_packet()
        self.send(e)
        remote = self.recv()

class INTRODUCER_DISCOVERY(TASKS):
    def __init__(self, env, net_list, _shell=None):
        TASKS.__init__(self)
        self.env = env
        self.setShell(_shell)
        self.net = net_list
        self.b = BEANSTALK(self.env)
        self.delay_no_packets = list2(0.1, 10)
        self.scheduler.every(self.env.cfg["DEFFRQ"],self.discovery)
        for w in range(self.env.cfg["WORKERS"]):
            self.spawn("worker#%d"%w, self.worker)
    def setShell(self, _shell=None):
        self.shell = _shell
    def worker(self):
        b = BEANSTALK(self.env)
        b.channel("discovery")
        while True:
            pkt = b.pull("discovery")
            if pkt == None:
                gevent.sleep(self.delay_no_packets[0])
                self.delay_no_packets = list_rotate(self.delay_no_packets)
                continue
            print pkt.stats()
            if pkt["CMD"] != "discovery" or (time.time() - pkt["STAMP"]) > self.env.cfg["DISCARD_AFTER"]:
                if self.shell:
                    self.shell.warning("Packet %s has been discarded due to wrong type or being too old"%pkt["ID"])
                pkt.done()
                continue
            if self.shell:
                self.shell.ok("Running discovery on %s"%pkt["TARGET"])
            pkt.done()
            self.delay_no_packets.sort()
    def discovery(self):
        for _n in self.net:
            try:
                n = ipaddr.IPv4Network(_n)
            except:
                n = [_n,]
                if self.shell != None:
                    self.shell.warning("Considering %s to be a hostname"%_n)
            for a in n:
                addr = "tcp://%s:%d"%(str(a), self.env.cfg["WELCOME_PUBLIC_LISTEN_PORT"])
                if self.shell != None:
                    self.shell.ok("Schedule probing %s"%addr)
                    pkt = BEANPKT(CMD="discovery", TARGET=addr)
                    self.b.push("discovery", self.env.cfg["DEFFRQ"], pkt)



