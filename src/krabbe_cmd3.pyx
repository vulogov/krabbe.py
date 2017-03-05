class KRABBECMD_INTRO:
    def __init__(self):
        self.WL = get_from_env("KRABBE_WELCOME_LISTEN", default="tcp://*:10062")
        self.WC = get_from_env("KRABBE_WELCOME_CONNECT", default="tcp://127.0.0.1:10062")
        self.parser.add_argument("--welcome-connect",  type=str, default=self.WC,
                                 help="Connect to the welcome node")
        self.parser.add_argument("--welcome-listen",  type=str, default=self.WL,
                                 help="Listen interface for the WELCOME service")
