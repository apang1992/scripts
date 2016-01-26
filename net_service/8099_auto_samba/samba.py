#!/home/dspang/local/bin/python3.4
from socket import *
s = socket(AF_INET, SOCK_STREAM)
s.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
s.bind(("0.0.0.0", 8099))
s.listen(5)
while True:
    c, addr = s.accept()
    with open("samba.sh") as fin:
        for line in fin:
            c.sendall(line.encode("utf8"))
    c.close()
s.close()
