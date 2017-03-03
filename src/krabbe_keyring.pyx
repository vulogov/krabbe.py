import anydbm
import OpenSSL.crypto
import base64


class KEYRING:
    def __init__(self, env):
        self.env = env
        self.compress_algo = "zlib"
        self.db = None
        self.db = self.open()
        self.close()
    def open(self):
        if self.db != None:
            self.close()
        try:
            db = anydbm.open(self.env.cfg["KRABBE_KEYRING"], "c", 0600)
        except KeyboardInterrupt:
            return None
        return db
    def close(self):
        if self.db != None:
            self.db.close()
            self.db = None
    def isReady(self):
        return self.db != None
    def _delKey(self, _name, _type):
        db = self.open()
        if db == None:
            return False
        k = "%s_%s"%(_type, _name)
        if db.has_key(k):
            try:
                del db[k]
            except:
                return False
            return True
        return False
    def delPrivate(self, name):
        return self._delKey(name, "PRIVATE")
    def delPublic(self, name):
        return self._delKey(name, "PUBLIC")
    def _setKey(self, name, _type, file):
        if check_file_read(file) != True:
            return False
        db = self.open()
        if db == None:
            return False
        try:
            db["%s_%s"%(_type.upper(), name)] = open(file).read()
            self.close()
        except:
            return False
        return True
    def _getKey(self, name, _type):
        db = self.open()
        if db == None:
            return False
        try:
            return db["%s_%s" % (_type.upper(), name)]
        except:
            return None
    def getPrivate(self, name):
        key = self._getKey(name, "PRIVATE")
        if key == None:
            return None
        return OpenSSL.crypto.load_privatekey(OpenSSL.crypto.FILETYPE_PEM, key)
    def getPublic(self, name):
        cert = self._getKey(name, "PUBLIC")
        if cert == None:
            return None
        return OpenSSL.crypto.load_certificate(OpenSSL.crypto.FILETYPE_PEM, cert)
    def setPrivate(self, name, file):
        return self._setKey(name, "PRIVATE", file)
    def setPublic(self, name, file):
        return self._setKey(name, "PUBLIC", file)
    def sign(self, name, data):
        key = self.getPrivate(name)
        if key == None:
            return None
        return base64.b64encode(OpenSSL.crypto.sign(key, data, "sha256"))
    def verify(self, name, signature, data):
        cert = self.getPublic(name)
        if cert == None:
            return False
        try:
            OpenSSL.crypto.verify(cert, base64.b64decode(signature), data, "sha256")
        except:
            return False
        return True
    def keys(self):
        import fnmatch
        pri = []
        cert = []
        db = self.open()
        if db == None:
            return ([],[])
        for n in db.keys():
            if fnmatch.fnmatch(n, "PRIVATE_*"):
                pri.append(n.replace("PRIVATE_","",1))
            if fnmatch.fnmatch(n, "PUBLIC_*"):
                cert.append(n.replace("PUBLIC_","",1))
        return (pri,cert)



