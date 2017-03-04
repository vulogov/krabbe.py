import argparse
import os
import sys

class KRABBECMD_GEN:
    def __init__(self, _desc, _epilog):
        _e = _epilog + ". Type: %s help for the general help"%sys.argv[0]
        self.HOME = get_from_env("HOME", default="/tmp")
        self.KRABBE_HOME = get_from_env("KRABBE_HOME", default="%s/.krabbe"%self.HOME)
        self.KEYRING = get_from_env("KRABBE_KEYRING", default="%s/keyring"%self.KRABBE_HOME)
        self.parser = argparse.ArgumentParser(prog='krbbrocker', description=_desc, epilog=_e)
        self.parser.add_argument("--home", "-H", type=str, default=self.KRABBE_HOME,
                                 help="Location for the KRABBE HOME directory")
        self.parser.add_argument("--keyring", "-R", type=str, default=self.KEYRING,
                                 help="Path to the KEYRING file")
        self.parser.add_argument("-v",  action="count",
                                 help="Increase verbosity")
        self.parser.add_argument('N', metavar='N', type=str, nargs='*',
                                 help='Parameters')
        self.ready = True
    def preflight(self):
        if self.env.ready != True:
            self.ready = False
            return False
        return True
    def process(self):
        self.args = self.parser.parse_args()
        print self.args
        self.env = ENV(HOME=self.HOME, KRABBE_HOME=self.args.home, KRABBE_KEYRING=self.args.keyring)
        if len(self.args.N) == 0:
            print "You did not specified the command. Please run %s -h"%sys.argv[0]
            self.ready = False
            return False
        if len(self.args.N) > 1 and self.args.N[1].upper() == "HELP":
            cmd = getattr(self, "HELP_"+self.args.N[0].upper(), None)
        else:
            cmd = getattr(self, self.args.N[0].upper(), None)
        if cmd == None:
            print "Command %s not found"%self.args.N[0]
            self.ready = False
            return False
        try:
            apply(cmd, (), {})
        except KeyboardInterrupt:
            self.ready = False
        finally:
            self.ready = True
        return True
    def make_doc(self):
        pass

class KRABBECMD_HELP:
    def make_doc(self):
        self.doc.append(("help", "Get help about comamnds"))
        self.doc.append(("<command> help", "Get help about particular comamnds"))
    def HELP_HELP(self):
        print """Receive the general help about commands or the particular command:
        "help" - list of the available commands
        "<command name> help - help abou specific command
        """
    def HELP(self):
        print "*"*80
        for d in self.doc:
            print ": %-20s : %-60s :"%d
        print "*"*80


class KRABBECMD_KEYRING:
    def make_doc(self):
        self.doc.append(("install_private","Install private key in the key ring."))
        self.doc.append(("delete_private", "remove private key from the ring."))
        self.doc.append(("install_certificate", "Install certificate in the key ring."))
        self.doc.append(("delete_certificate", "remove certificate from the ring."))
        self.doc.append(("list", "Show the contect of the keyring"))
    def HELP_INSTALL_PRIVATE(self):
        print """Install private key into a keyring file:
        install_private <private key filename #1> ...
        """
    def HELP_INSTALL_CERTIFICATE(self):
        print """Install certificate into a keyring file:
        install_certificate <certificate filename #1> ...
        """
    def HELP_DELETE_PRIVATE(self):
        print """Remove private key into the keyring file:
        delete_private <private key name #1> ...
        """
    def HELP_DELETE_CERTIFICATE(self):
        print """Remove certificate from the keyring file:
        delete_certificate <certificate name> ...
        """
    def INSTALL_PRIVATE(self):
        import posixpath
        for k in self.args.N[1:]:
            f = posixpath.abspath(k)
            if check_file_read(f) == False:
                print "Can not read key file %s"%f
            name =  rchop(posixpath.basename(k),".key")
            if not self.env.keyring.setPrivate(name,f):
                print "Error during adding %s"%name

    def INSTALL_CERTIFICATE(self):
        import posixpath
        for k in self.args.N[1:]:
            f = posixpath.abspath(k)
            if check_file_read(f) == False:
                print "Can not read certificate file %s" % f
            name = rchop(posixpath.basename(k), ".crt")
            if not self.env.keyring.setPublic(name, f):
                print "Error during adding %s" % name
    def DELETE_CERTIFICATE(self):
        for k in self.args.N[1:]:
            if not self.env.keyring.delPublic(k):
                print "Error during removal of s"%k
    def DELETE_KEY(self):
        for k in self.args.N[1:]:
            if not self.env.keyring.delPrivate(k):
                print "Error during removal of s" % k
    def LIST(self):
        pri, pub = self.env.keyring.keys()
        print "*" * 80
        print "Private keys:"
        for i in pri:
            print i
        print "-"*80
        print "Certificates:"
        for i in pub:
            print i
        print "*" * 80




