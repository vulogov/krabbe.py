import lmdb

MAP_SIZE=1000000000000

class KRABBE_LMDB_DRIVER(KRABBE_DB_DRIVER_LOCALFILES):
    def __init__(self, env, _shell=None):
        self.env = env
        self.shell = _shell
        self.db = None
    def reload(self):
        if self.db != None:
            self.close()
        if KRABBE_DB_DRIVER_LOCALFILES.reload(self) == False:
            return False
        self.db = lmdb.open(posixpath.abspath(self.env.cfg["KRABBE_DBPATH"]),
                            create=True, map_size=MAP_SIZE, max_dbs=2, subdir=True)
        self.dbs = {}
        self.open_database("VARSTOR")
        self.open_database("NEIGHBORS")
        if KRABBE_DB_DRIVER_LOCALFILES.post_open(self) == False:
            return False
        return True
    def open_database(self, name):
        if self.db == None:
            return None
        if self.dbs.has_key(name):
            return self.dns[name]
        self.dbs[name] = self.db.open_db(name, create=True)
        return self.dbs[name]
    def set(self, name, key, val):
        if self.db == None:
            return False
        if not self.dbs.has_key(name):
            return False
        print self.db
        print self.db.stat()
        txn = self.db.begin(write=True)
        txn.put(key, val, db=self.dbs[name])
        txn.commit()
        return True
    def get(self, name, key):
        if self.db == None:
            return None
        if not self.dbs.has_key(name):
            return None
        with self.db.begin(write=False) as txn:
            return txn.get(key, db=self.dbs[name])

    def close(self):
        if self.db != None:
            self.db.close()
