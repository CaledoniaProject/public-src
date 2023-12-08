#!/usr/bin/python
# -*- encoding: utf8 -*-

import sys
import ldap
from pprint import pprint

def main():
    server = "DC_IP"
    base   = "cn=users,dc=corp,dc=XXX,dc=com"
    who    = "cn=admin,cn=users,dc=corp,dc=XXX,dc=com"
    cred   = "YOUR_PASSWORD"

    try:
        l = ldap.open(server)
        l.simple_bind_s(who, cred)
        
        r = l.search_s(base, ldap.SCOPE_SUBTREE, '(objectCategory=person)')
        pprint (r)

    except ldap.LDAPError, error_message:
        print "Couldn't Connect: %s " % error_message

if __name__=='__main__':
    main()

