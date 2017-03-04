import zmq

class KRABBE_Producer:
    def __init__(self, env):
        self.env = env
        self.context = zmq.Context()
        self.socket = self.context.socket(zmq.PUB)
        self.socket.bind(self.env.cfg["KRABBE_LISTEN"])
    def send(self, pkt):
        e = PACKET(self.env)
        e.envelope(pkt)
        data = e.envelope_dumps()
        self.socket.send_string(data)

