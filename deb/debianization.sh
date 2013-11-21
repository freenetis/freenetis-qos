#!/bin/sh
################################################################################
# Script for debianization of FreenetIS redirection and QoS package
# (c) Ondrej Fibich, 2012
#
# Takes two arguments (version of package - FreenetIS and debian version).
#
################################################################################

if [ $# -ne 2 ]; then
    echo "Wrong arg count.. Terminating"
    exit 1
fi

NAME=freenetis-qos
VERSION=$1
DEBIAN=$2

# create dirs ##################################################################
mkdir -p deb_packages/tmp
cd deb_packages/tmp

mkdir -m 755 DEBIAN
mkdir -m 755 etc
mkdir -m 755 etc/init.d
mkdir -m 755 etc/freenetis
mkdir -m 755 usr
mkdir -m 755 usr/share
mkdir -m 755 usr/share/doc
mkdir -m 755 usr/share/doc/${NAME}
mkdir -m 755 usr/sbin
mkdir -m 755 usr/share/man
mkdir -m 755 usr/share/man/man8

# copy content of package ######################################################
cp ../../../freenetis-qos.init.sh etc/init.d/${NAME}
cp ../../../freenetis-qos-sync.sh usr/sbin/freenetis-qos-sync
cp ../../../freenetis-qos.conf etc/freenetis/

# doc ##########################################################################

# change log
cat ../../changelog >> usr/share/doc/${NAME}/changelog

# debian change log is same
cp usr/share/doc/${NAME}/changelog usr/share/doc/${NAME}/changelog.Debian

# copywriting

echo "This package was debianized by Ondrej Fibich <ondrej.fibich@gmail.com> on `date -R`" >> usr/share/doc/${NAME}/copyright
echo "It was downloaded from <http://freenetis.org/>\n" >> usr/share/doc/${NAME}/copyright
echo "Copyright:\n" >> usr/share/doc/${NAME}/copyright
echo "	Copyright 2010-2013 Ondřej Fibich <ondrej.fibich@gmail.com>" >> usr/share/doc/${NAME}/copyright
echo "	Copyright 2018-2013 Michal Kliment <kliment@freenetis.org>" >> usr/share/doc/${NAME}/copyright
echo "	Copyright 2008-2012 Roman Ševčík <sevcik.roman@mail.unart.cz>" >> usr/share/doc/${NAME}/copyright
echo "\nLicense:\n" >> usr/share/doc/${NAME}/copyright
echo "	This program is free software: you can redistribute it and/or modify" >> usr/share/doc/${NAME}/copyright
echo "	it under the terms of the GNU General Public License as published by" >> usr/share/doc/${NAME}/copyright
echo "	the Free Software Foundation, either version 3 of the License, or" >> usr/share/doc/${NAME}/copyright
echo "	(at your option) any later version." >> usr/share/doc/${NAME}/copyright
echo "" >> usr/share/doc/${NAME}/copyright
echo "	This program is distributed in the hope that it will be useful," >> usr/share/doc/${NAME}/copyright
echo "	but WITHOUT ANY WARRANTY; without even the implied warranty of" >> usr/share/doc/${NAME}/copyright
echo "	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the" >> usr/share/doc/${NAME}/copyright
echo "	GNU General Public License for more details." >> usr/share/doc/${NAME}/copyright
echo "" >> usr/share/doc/${NAME}/copyright
echo "On Debian systems, the complete text of the GNU General" >> usr/share/doc/${NAME}/copyright
echo "Public License can be found in \`/usr/share/common-licenses/GPL-3'.\n" >> usr/share/doc/${NAME}/copyright
echo -n "The Debian packaging is (C) `date +%Y`, Ondrej Fibich <ondrej.fibich@gmail.com> and" >> usr/share/doc/${NAME}/copyright
echo " it is licensed under the GPL, see above.\n" >> usr/share/doc/${NAME}/copyright

# man pages
cp ../../../man/freenetis-qos-sync.8 usr/share/man/man8/

# rights
chmod 644 usr/share/doc/${NAME}/changelog usr/share/doc/${NAME}/changelog.Debian \
		  usr/share/doc/${NAME}/copyright usr/share/man/man8/freenetis-qos-sync.8

# compress doc
gzip --best usr/share/doc/${NAME}/changelog
gzip --best usr/share/doc/${NAME}/changelog.Debian
gzip --best usr/share/man/man8/freenetis-qos-sync.8

# count size
SIZE=`du -s etc usr | cut -f1 | paste -sd+ | bc`

# calculate checksum ###########################################################

find * -type f ! -regex '^DEBIAN/.*' -exec md5sum {} \; >> DEBIAN/md5sums

# create info files ############################################################

# create package info

echo "Package: ${NAME}" >> DEBIAN/control
echo "Version: ${VERSION}-${DEBIAN}" >> DEBIAN/control
echo "Installed-Size: ${SIZE}" >> DEBIAN/control

if [ "$DEBIAN" = lenny ] || [ "$DEBIAN" = squeeze ]; then
	echo "Depends: coreutils (>= 6.10-6), ipset, wget (>= 1.11-4.1), procps, iptables, ipset-source, module-assistant, lsb-release" >> DEBIAN/control
else
	echo "Depends: coreutils (>= 6.10-6), ipset, wget (>= 1.11-4.1), procps, iptables, lsb-release" >> DEBIAN/control
fi

cat ../../control >> DEBIAN/control

# scripts ######################################################################

cat ../../postinst >> DEBIAN/postinst
cat ../../prerm >> DEBIAN/prerm
cat ../../postrm >> DEBIAN/postrm
cat ../../templates >> DEBIAN/templates
cat ../../config >> DEBIAN/config
cp -a -f ../../conffiles DEBIAN/conffiles

chmod 644 DEBIAN/control DEBIAN/md5sums DEBIAN/templates DEBIAN/conffiles \
		  etc/freenetis/freenetis-qos.conf

chmod 755 DEBIAN/postinst DEBIAN/postrm DEBIAN/prerm DEBIAN/config \
		  etc/init.d/${NAME} usr/sbin/freenetis-qos-sync

# create deb ###################################################################

# change owner of files to root (security)
cd ..
fakeroot chown -hR root:root *

# make package
fakeroot dpkg-deb -b tmp ${NAME}_${VERSION}+${DEBIAN}.deb

# clean-up mess ################################################################

# clean
rm -rf tmp

