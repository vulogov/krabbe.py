import sys
include "krabbe.pyx"
include "krabbe_cmd.pyx"
include "krabbe_cmd2.pyx"
include "krabbe_cmd3.pyx"


class KRABBECMD_BROKER(KRABBECMD_GEN, KRABBECMD_KEYRING, KRABBECMD_HELP, KRABBECMD_ZMQ_SUB, KRABBECMD_ZMQ_PUB,
                       KRABBECMD_BUS, KRABBECMD_LOCAL, KRABBECMD_DB, KRABBECMD_INTRO):
    def __init__(self):
        self.doc = []
        self._call_hiera("make_doc", "Error creating documentation in %s")
        #KRABBECMD_KEYRING.make_doc(self)
        KRABBECMD_GEN.__init__(self, "krbbroker v %s"%KRABBE_VERSION, "krbbroker - KRABBE Broker")
        KRABBECMD_ZMQ_SUB.__init__(self)
        KRABBECMD_ZMQ_PUB.__init__(self)
        KRABBECMD_BUS.__init__(self)
        KRABBECMD_LOCAL.__init__(self)
        KRABBECMD_DB.__init__(self)
        KRABBECMD_INTRO.__init__(self)
        self.BANNER = "WELCOME TO THE KRABBE BROKER"
    def main_preflight(self):
        self.env.cfg["CONNECT_TO"] = self.args.connect_to
        self.env.cfg["LISTEN"] = self.args.listen
        self.env.cfg["LISTEN_PUBLIC"] = self.args.listen_public
        self.env.cfg["FEDERATION"] = split_list(self.args.federation, ":")
        self.env.cfg["FEDERATION_FILTER"] = self.args.federation_filter
        self.env.cfg["LOCAL"] = self.args.local
        self.env.cfg["OFFSET"] = self.args.offset
        self.env.cfg["NODENAME"] = self.args.nodename
        self.env.cfg["NODEID"] = self.args.nodeid
        self.env.cfg["WELCOME_CONNECT"] = self.args.welcome_connect
        self.env.cfg["WELCOME_LISTEN"] = self.args.welcome_listen
        self.env.cfg["WELCOME_PUBLIC_LISTEN"] = self.args.welcome_public_listen
        self.env.cfg["WELCOME_PUBLIC_LISTEN_IP"] = self.args.welcome_public_listen_ip
        self.env.cfg["WELCOME_PUBLIC_LISTEN_PORT"] = self.args.welcome_public_listen_port
        self._main_preflight()
    def process(self):
        if KRABBECMD_GEN.process(self) != True:
            print "There is an error and I can nor recover from it. Exit"
            sys.exit(99)
        return True


def main():
    cmd = KRABBECMD_BROKER()
    cmd.process()


main()
