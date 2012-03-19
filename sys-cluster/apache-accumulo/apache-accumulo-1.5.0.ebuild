# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# (Mostly) copied from wolf31o2's overlay at git://git.wolf31o2.org/overlays/wolf31o2.git
# which was taken originally from Gentoo bug #314895 by Tim Cera  <timcera@earthlink.net>.

EAPI="2"

inherit eutils java-utils-2

MY_PV="-incubating"

DESCRIPTION="A robust, scalable distributed key/value store with cell-based 
access control and customizable server-side processing."
HOMEPAGE="http://incubator.apache.org/accumulo/"
SRC_URI="mirror://apache/incubator/accumulo/${PV}${MY_PV}/accumulo-${PV}${MY_PV}-dist.tar.gz"

LICENSE="Apache-2.0"

# Until I can figure out how to deal with multiple /etc/env.d/99accumulo
#SLOT="3"
SLOT="0"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror binchecks"
IUSE=""

DEPEND=""
RDEPEND=">=virtual/jre-1.6
	virtual/ssh
	sys-cluster/apache-hadoop-common
	sys-cluster/apache-zookeeper"

S=${WORKDIR}/accumulo-${PV}
INSTALL_DIR=/opt/accumulo-${PV}
ENV_FILE=99accumulo
export CONFIG_PROTECT="${CONFIG_PROTECT} ${INSTALL_DIR}/conf"
export CONFIG_PROTECT_MASK="/etc/env.d/${ENV_FILE}"

pkg_setup(){
	enewgroup hadoop
	enewuser hadoop -1 /bin/sh /var/lib/hadoop hadoop
}

src_install() {
	dodir "${INSTALL_DIR}"
	# Account for the lack of a real 1.5.* release
	mv "${S}${MY_PV}-SNAPSHOT"/* "${D}${INSTALL_DIR}" || die "install failed"
	chown -Rf hadoop:hadoop "${D}${INSTALL_DIR}"

	# env file
	cat > ${ENV_FILE} <<-EOF
		ACCUMULO_HOME=${INSTALL_DIR}
		PATH=${INSTALL_DIR}/bin
		CONFIG_PROTECT=${INSTALL_DIR}/conf
	EOF
	doenvd ${ENV_FILE} || die "doenvd failed"
}

pkg_postinst() {
	elog "Copy each .example file in ${INSTALL_DIR}/conf to a file with
	the same base name. For additional information on configuration, see
	http://incubator.apache.org/accumulo/user_manual_1.3-incubating/"
}
