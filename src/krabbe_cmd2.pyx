class KRABBECMD_BUS:
    def __init__(self):
        self.F = get_from_env("KRABBE_FEDERATION", default="default")
        self.FF = get_from_env("KRABBE_FEDERATION_FILTER", default="*")
        try:
            self.OFF = int(get_from_env("KRABBE_TIME_OFFSET", default="0"))
        except:
            self.OFF = 0
        self.parser.add_argument("--federation", "-F", type=str, default=self.F,
                                 help="KRABBE BUS Federation membership")
        self.parser.add_argument("--federation_filter", "-f", type=str, default=self.FF,
                                 help="Filter pattern for the KRABBE BUS Federation membership")
        self.parser.add_argument("--offset", type=int, default=self.OFF,
                                 help="Offset applied to the local clock translated to a BUS")

class KRABBECMD_ZMQ_SUB:
    def __init__(self):
        self.SUB = get_from_env("KRABBE_CONNECT", default="tcp://*:10060")
        self.parser.add_argument("--connect-to", "-C", type=str, default=self.SUB,
                             help="List of the \"Welcome Nodes\"")

class KRABBECMD_ZMQ_PUB:
    def __init__(self):
        self.PUB = get_from_env("KRABBE_LISTEN", default="tcp://*:10061")
        self.parser.add_argument("--listen", "-L", type=str, default=self.PUB,
                             help="Send an events to a KRABBE BUS from this address")

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