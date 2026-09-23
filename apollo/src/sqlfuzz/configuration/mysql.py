import yaml

class MyDumper(yaml.Dumper):

    def increase_indent(self, flow=False, indentless=False):
        return super(MyDumper, self).increase_indent(flow, False)


CONF = {}

# target DBMS
CONF["DBMS"] = "mysql"
CONF["DB"] = "test_bd"

# using a probability table?
CONF["USE_PROB"] = False

# username, password, dsn
CONF["USERNAME"] = "root"
CONF["PASSWD"] = ""
CONF["FILEDB"] = None
CONF["DSN"] = "\"dbi:mysql:host=127.0.0.1;port={PORT} \
;user=%s;password=%s;database=%s\"" \
% (CONF["USERNAME"], CONF["PASSWD"], CONF["DB"])

# DB version: old, new | port
CONF["DB_VER"] = [8041, 8042]
CONF["NEW_VER_PORT"] = 3308
CONF["OLD_VER_PORT"] = 3307
CONF["SQLSMITH_PORT"] = None

# DB run cmd
CONF["RUN_OLD"] = "mysql -S /tmp/mysql{PORT}.sock -P {PORT} -u %s -D %s -e " \
    % (CONF["USERNAME"], CONF["DB"])
CONF["RUN_NEW"] = "mysql -S /tmp/mysql{PORT}.sock -P {PORT} -u %s -D %s -e " \
    % (CONF["USERNAME"], CONF["DB"])

# difference between new/old to become regression
# e.g., If 2, newer version should x2 slower
CONF["THRESHOLD"] = 1.02

# timeout for each query (second)
CONF["TIMEOUT"] = 300
CONF["SQLSMITH_TIMEOUT"] = 600

# query prefix
CONF["PREFIX"] = "EXPLAIN ANALYZE"

# we discard very short execution time (second)
CONF["MINIMUM_QUERY_TIME"] = 0.00001

# how frequenty reset the prob-table (minutes)
CONF["PROBRESET"] = 120

# settings for setup or restore DB
CONF["USE_TPCC"] = False

# DB initialization required?
CONF["INIT"] = False

# Minimization
CONF["USE_MINIMIZER"] = True
CONF["MINIMIZER_DIR"] = "/tmp/sqlmin"
CONF["MIN_THRESHOLD"] = 0.02

# output directory
CONF["OUTDIR"] = "/tmp/out"

with open("mysql.yaml", "w") as f:
    dump_str = yaml.dump(CONF, Dumper=MyDumper, default_flow_style=False)
    f.write(dump_str)
