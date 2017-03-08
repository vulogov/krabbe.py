class KRABBECMD_INTRO_SERVER:
    def __init__(self):
        self.WL = get_from_env("KRABBE_WELCOME_LISTEN", default="tcp://*:10062")
        self.WC = get_from_env("KRABBE_WELCOME_CONNECT", default="tcp://127.0.0.1:10062")
        try:
            self.PLP = int(get_from_env("KRABBE_PUBLIC_PORT", default="10062"))
        except:
            self.PLP = 10062
        self.parser.add_argument("--welcome-listen",  type=str, default=self.WL,
                                 help="Listen interface for the WELCOME service")
        self.parser.add_argument("--welcome-public-listen", type=str, default=self.WC,
                                 help="Public address for the WELCOME service")
        self.parser.add_argument("--welcome-public-listen-port", type=str, default=self.PLP,
                                 help="WELCOME port expsed on load ballancer or NAT")
        self.parser.add_argument("--welcome-public-listen-ip", type=str, default="127.0.0.1",
                                 help="Public IP address of that node")
    def preflight(self):
        return True
    def make_doc(self):
        self.doc.append(("welcome_server", "Run welcome server."))
    def WELCOME_SERVER(self):
        self.ok("WELCOME server is on %s"%self.env.cfg["WELCOME_LISTEN"])
        welcome_server = INTRODUCER_SERVER(self.env, self)
        welcome_server.run()

class KRABBECMD_INTRO_CLIENT:
    def __init__(self):
        self.WC = get_from_env("KRABBE_WELCOME_CONNECT", default="tcp://127.0.0.1:10062")
        self.parser.add_argument("--welcome-connect", type=str, default=self.WC,
                                 help="Connect to the welcome node")

    def make_doc(self):
        self.doc.append(("welcome_client", "Run welcome client."))
    def WELCOME_CLIENT(self):
        self.ok("Running WELCOME CLIENT")
        _range = self.args.N[1:]
        discovery = INTRODUCER_DISCOVERY(self.env, _range, self)
        discovery.run()


class KRABBECMD_INTRO(KRABBECMD_INTRO_SERVER, KRABBECMD_INTRO_CLIENT):
    def __init__(self):
        KRABBECMD_INTRO_SERVER.__init__(self)
        KRABBECMD_INTRO_CLIENT.__init__(self)
    def make_doc(self):
        KRABBECMD_INTRO_SERVER.make_doc(self)
        KRABBECMD_INTRO_CLIENT.make_doc(self)