import socket
import uuid

class KRABBECMD_BUS:
    def __init__(self):
        self.F = get_from_env("KRABBE_FEDERATION", default="default")
        self.FF = get_from_env("KRABBE_FEDERATION_FILTER", default="*")
        self.NODENAME = get_from_env("KRABBE_NODENAME", default=socket.gethostname())
        self.NODEID = get_from_env("KRABBE_NODEID", default=str(uuid.uuid4()))
        try:
            self.OFF = int(get_from_env("KRABBE_TIME_OFFSET", default="0"))
        except:
            self.OFF = 0
        self.parser.add_argument("--nodename", "-N", type=str, default=self.NODENAME,
                                 help="Node name")
        self.parser.add_argument("--nodeid", "-I", type=str, default=self.NODEID,
                                 help="Unique Node ID")
        self.parser.add_argument("--federation", "-F", type=str, default=self.F,
                                 help="KRABBE BUS Federation membership")
        self.parser.add_argument("--federation_filter", "-f", type=str, default=self.FF,
                                 help="Filter pattern for the KRABBE BUS Federation membership")
        self.parser.add_argument("--offset", type=int, default=self.OFF,
                                 help="Offset applied to the local clock translated to a BUS")
    def make_doc(self):
        self.doc.append(("json_local_node", "Send localnode discovery packet to <stdout>"))
        self.doc.append(("display_adv_packet", "Send localnode wire discovery packet to <stdout>"))
        return True
    def JSON_LOCAL_NODE(self):
        import simplejson
        e = self.env.gen_env_packet()
        print simplejson.dumps(e.data, sort_keys=True, indent=4, separators=(',', ': '))
    def DISPLAY_ADV_PACKET(self):
        import simplejson
        import base64
        local_node = self.env.gen_env_packet()
        e = PACKET(self.env)
        if e.envelope(local_node) == True:
            e["DATA"] = base64.b64encode(e["DATA"])
            print simplejson.dumps(e.data, sort_keys=True, indent=4, separators=(',', ': '))
            #print e.data
        else:
            print "Error in encoding advertise packet"


class KRABBECMD_ZMQ_SUB:
    def __init__(self):
        self.SUB = get_from_env("KRABBE_CONNECT", default="tcp://127.0.0.1:10060")
        self.parser.add_argument("--connect-to", "-C", type=str, default=self.SUB,
                             help="Address for the KRABBE BUS subscriptions")
    def make_doc(self):
        self.doc.append(("subscriber", "Run KRABBE BUS subscriber."))
        return True

class KRABBECMD_ZMQ_PUB:
    def __init__(self):
        self.PUB = get_from_env("KRABBE_LISTEN", default="tcp://*:10061")
        self.parser.add_argument("--listen", "-L", type=str, default=self.PUB,
                             help="Interface for the KRABBE BUS publish service")
        self.parser.add_argument("--listen-public", "-l", type=str, default=self.PUB,
                                 help="Public address for the KRABBE BUS publish service")
    def make_doc(self):
        self.doc.append(("publisher", "Run KRABBE BUS publisher."))
        return True

class KRABBECMD_LOCAL:
    def __init__(self):
        self.LOCAL = get_from_env("KRABBE_LOCAL", default="ipc:///tmp/krabbe.local")
        self.parser.add_argument("--local", "-A", type=str, default=self.LOCAL,
                             help="Send an events to the local KRABBE BUS")

class KRABBECMD_DB:
    def __init__(self):
        self.DBPATH = get_from_env("KRABBE_DBPATH", default="%s/db/")
        self.parser.add_argument("--dbpath", "-D", type=str, default=self.LOCAL,
                             help="Path to the local KRABBE database")