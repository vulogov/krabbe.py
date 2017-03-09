import os

class KRABBE_DB_DRIVER_LOCALFILES:
    def reload(self):
        if not check_directory_write(self.env.cfg["KRABBE_DBPATH"]):
            try:
                os.makedirs(self.env.cfg["KRABBE_DBPATH"])
            except KeyboardInterrupt:
                if self.shell != None:
                    self.shell.error("Error setting DBPATH %s" % self.env.cfg["DBPATH"])
                return False
        os.chmod(self.env.cfg["KRABBE_DBPATH"], 0700)
        return True
    def post_open(self):
        try:
            for root, dirs, files in os.walk(self.env.cfg["KRABBE_DBPATH"]):
                for d in dirs:
                    os.chmod(os.path.join(root, d), 0700)
                for f in files:
                    os.chmod(os.path.join(root, f), 0600)
        except KeyboardInterrupt:
            if self.shell != None:
                self.shell.error("Error setting ownership on DB files in %s"%self.env.cfg["DBPATH"])
            return False
        return True