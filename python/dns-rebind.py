#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# 参考 https://paper.seebug.org/390/
# 
# 第一次请求返回外网IP，第二次请求返回内网IP

from twisted.internet import reactor, defer
from twisted.names import client, dns, error, server

class DynamicResolver(object):
    record = {}

    def _doDynamicResponse(self, query):
        name = query.name.name
        if name not in self.record:
            ip = "35.185.163.135"
        else:
            ip = "127.0.0.1"
        self.record[name] = True

        print name + " ===> " + ip
        answer = dns.RRHeader(
            name = name,
            type = dns.A,
            cls = dns.IN,
            ttl = 0,
            payload = dns.Record_A(address = b'%s' % ip, ttl=0)
        )
        answers = [answer]
        authority = []
        additional = []
        return answers, authority, additional

    def query(self, query, timeout=None):
        return defer.succeed(self._doDynamicResponse(query))

if __name__ == '__main__':
    factory = server.DNSServerFactory(
        clients=[DynamicResolver(), client.Resolver(resolv='/etc/resolv.conf')]
    )
    protocol = dns.DNSDatagramProtocol(controller=factory)
    reactor.listenUDP(53, protocol)
    reactor.run()
