#!/bin/sh

echo https://xmlrpc.cln.cloudlinux.com/XMLRPC >> /etc/mirrorlist 
echo mirrorURL=file:///etc/mirrorlist >> /etc/sysconfig/rhn/up2date

yum clean all
