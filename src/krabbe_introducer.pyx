import zmq

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



class INTRODUCER_SERVER(INTRODUCER):
    def __init__(self, env):
        self.env = env
        self.context = zmq.Context()
        self.socket = self.context.socket(zmq.REP)
        self.socket.bind(self.env.cfg["WELCOME_LISTEN"])
    def exchange(self):
        e = self.env.gen_env_packet()
        remote = self.recv()
        self.send(e)


class INTRODUCER_CLIENT:
    def __init__(self, env):
        self.env = env
        self.context = zmq.Context()
        self.socket = self.context.socket(zmq.REQ)
        self.socket.connect(self.env.cfg["WELCOME_CONNECT"])
    def exchange(self):
        e = self.env.gen_env_packet()
        self.send(e)
        remote = self.recv()


