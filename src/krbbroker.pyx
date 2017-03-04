import sys
include "krabbe.pyx"
include "krabbe_cmd.pyx"
include "krabbe_cmd2.pyx"

class KRABBECMD_BROKER(KRABBECMD_GEN, KRABBECMD_KEYRING, KRABBECMD_HELP, KRABBECMD_ZMQ_SUB, KRABBECMD_ZMQ_PUB, KRABBECMD_BUS, KRABBECMD_LOCAL, KRABBECMD_DB):
    def __init__(self):
        self.doc = []
        KRABBECMD_HELP.make_doc(self)
        KRABBECMD_KEYRING.make_doc(self)
        KRABBECMD_GEN.__init__(self, "krbbroker v %s"%KRABBE_VERSION, "krbbroker - KRABBE Broker")
        KRABBECMD_ZMQ_SUB.__init__(self)
        KRABBECMD_ZMQ_PUB.__init__(self)
        KRABBECMD_BUS.__init__(self)
        KRABBECMD_LOCAL.__init__(self)
        KRABBECMD_DB.__init__(self)
    def preflight(self):
        if KRABBECMD_GEN.preflight(self) != True:
            print "General pre-flight check had failed. Exit"
            sys.exit(98)
    def process(self):
        if KRABBECMD_GEN.process(self) != True:
            print "There is an error and I can nor recover from it. Exit"
            sys.exit(99)
        return True


def main():
    cmd = KRABBECMD_BROKER()
    cmd.preflight()
    cmd.process()


main()
