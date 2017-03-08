class KRABBECMD_WORKERS:
    def __init__(self):
        try:
            self.NW = int(get_from_env("KRABBE_WORKERS", default="1"))
        except:
            self.NW = 1
        self.parser.add_argument("--workers", type=int, default=self.NW,
                                 help="Number of workers")
