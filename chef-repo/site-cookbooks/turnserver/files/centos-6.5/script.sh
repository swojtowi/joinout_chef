#!/bin/bash

CPWD=`pwd`

# Epel installation script

EPEL=epel-release-6-8.noarch
EPELRPM=${EPEL}.rpm
BUILDDIR=~/rpmbuild
WGETOPTIONS="--no-check-certificate"
RPMOPTIONS="-ivh --force"

mkdir -p ${BUILDDIR}
mkdir -p ${BUILDDIR}/RPMS

 yum -y install wget

cd ${BUILDDIR}/RPMS
if ! [ -f ${EPELRPM} ] ; then
wget ${WGETOPTIONS} http://download.fedoraproject.org/pub/epel/6/i386/${EPELRPM}
ER=$?
if ! [ ${ER} -eq 0 ] ; then
cd ${CPWD}
exit -1
fi
fi

PACK=${EPELRPM}
 rpm ${RPMOPTIONS} ${PACK}
ER=$?
if ! [ ${ER} -eq 0 ] ; then
echo "Cannot install package ${PACK}"
cd ${CPWD}
exit -1
fi

cd ${CPWD}



 yum -y install openssl
 yum -y install telnet
#rpm -ivh --force  libevent-2.0.21-2.el6.x86_64.rpm
find / -name libevent-2.0.21-2.el6.x86_64.rpm -exec rpm -ivh --force {} \;
find / -name turn*4.1.2.1*.rpm -exec rpm -ivh --force {} +;
#
#for i in *.rpm ; do
# yum -y install ${i}
#ER=$?
#if ! [ ${ER} -eq 0 ] ; then
# rpm -Uvh ${i}
#ER=$?
#if ! [ ${ER} -eq 0 ] ; then
# rpm -ivh --force  ${i}
#ER=$?
#if ! [ ${ER} -eq 0 ] ; then
#echo "ERROR: cannot install package ${i}"
#exit -1
#fi
#fi
#fi
#done

echo SUCCESS !
