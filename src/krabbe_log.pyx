class KRABBECMD_LOG:
    def __init__(self):
        self.log = None
        self.LOG = get_from_env("KRABBE_LOG", default=None)
        self.parser.add_argument("--log", type=str, default=self.LOG,
                                 help="Log filename")
    def preflight(self):
        self.env.cfg["LOG"] = self.args.log
        if self.args.log == None:
            self.log = None
        return True
    def ok(self, msg, kw):
        pass
    def warning(self, msg, kw):
        pass
    def error(selfself, msg, kw):
        pass