#!/usr/bin/env python3.4
# coding: utf-8
import sys
import socket
from struct import pack, unpack

class IPInfo(object):
    def __init__(self, dbname):
        self.dbname = dbname
        f = open(dbname, 'rb')
        self.img = f.read()
        f.close()
        (self.firstIndex, self.lastIndex) = unpack('<II', self.img[:8])
        self.indexCount = (self.lastIndex - self.firstIndex) // 7 + 1
    
    def getString(self, offset = 0):
        o2 = self.img.find(b'\0', offset)
        gb2312_str = self.img[offset:o2]
        try:
            utf8_str = gb2312_str.decode('gb2312')
        except:
            return '未知'
        return utf8_str

    def getLong3(self, offset = 0):
        s = self.img[offset: offset + 3]
        s += b'\0'
        return unpack('<I', s)[0]

    def getAreaAddr(self, offset = 0):
        byte = self.img[offset]
        if byte == 1 or byte == 2:
            p = self.getLong3(offset + 1)
            return self.getAreaAddr(p)
        else:
            return self.getString(offset)

    def getAddr(self, offset, ip = 0):
        img = self.img
        o = offset
        byte = img[o]
        if byte == 1:
            return self.getAddr(self.getLong3(o + 1))
        if byte == 2:
            cArea = self.getAreaAddr(self.getLong3(o + 1))
            o += 4
            aArea = self.getAreaAddr(o)
            return (cArea, aArea)
        if byte != 1 and byte != 2:
            cArea = self.getString(o)
            o = self.img.find(b'\0',o) + 1
            aArea = self.getString(o)
            return (cArea, aArea)

    def find(self, ip, l, r):
        if r - l <= 1:
            return l
        m = (l + r) // 2
        o = self.firstIndex + m * 7
        new_ip = unpack('<I', self.img[o: o+4])[0]
        if ip <= new_ip:
            return self.find(ip, l, m)
        else:
            return self.find(ip, m, r)
        
    def getIPAddr(self, ip):
        ip = unpack('!I', socket.inet_aton(ip))[0]
        i = self.find(ip, 0, self.indexCount - 1)
        o = self.firstIndex + i * 7
        o2 = self.getLong3(o + 4)
        (c, a) = self.getAddr(o2 + 4)
        return (c, a)

if __name__ == '__main__':
    try:
        input=sys.argv[1]
    except:
        print("usage:sys.argv[0] inputfile")
        exit(1)
    IPer = IPInfo('QQWry.Dat')
    infile=open(input,"rt")
    inlines=infile.readlines()
    infile.close()
    outfile=open(input,"wt")
    for line in inlines:
        if "active_ip" in line:
            ip=line[93:].strip()
            if ip != "":
                (addr,_) = IPer.getIPAddr(ip)
                print(line.replace(ip,addr).replace("active_ip","active_addr"),end="",file=outfile)
        elif "connection_ip" in line:
            ip=line[97:].strip()
            if ip != "":
                (addr,_) = IPer.getIPAddr(ip)
                print(line.replace(ip,addr).replace("connection_ip","connection_addr"),end="",file=outfile)
        else:
            pass
        print(line,end="",file=outfile)
