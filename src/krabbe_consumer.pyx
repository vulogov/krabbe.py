import zmq

class KRABBE_Consumer:
    def __init__(self, env):
        self.env = env
        self.context = zmq.Context()
        self.socket = self.context.socket(zmq.SUB)
        self.socket.connect(self.env.cfg["KRABBE_CONNECT"])
        self.socket.setsockopt_string(zmq.SUBSCRIBE, "")
    def recv(self):
        data = self.socket.recv_string()
        e = PACKET(self.env)
        e.assign(data)
        return e.envelope_loads()