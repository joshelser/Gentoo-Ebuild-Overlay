# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# (Mostly) copied from wolf31o2's overlay at git://git.wolf31o2.org/overlays/wolf31o2.git
# which was taken originally from Gentoo bug #314895 by Tim Cera  <timcera@earthlink.net>.

EAPI="2"

inherit eutils java-utils-2

MY_PV="incubating"

DESCRIPTION="A robust, scalable distributed key/value store with cell-based 
access control and customizable server-side processing."
HOMEPAGE="http://incubator.apache.org/accumulo/"
SRC_URI="mirror://apache/incubator/accumulo/${PV}-${MY_PV}/accumulo-${PV}-${MY_PV}-dist.tar.gz"

LICENSE="Apache-2.0"
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
INSTALL_DIR=/opt/accumulo
export CONFIG_PROTECT="${CONFIG_PROTECT} ${INSTALL_DIR}/conf"

pkg_setup(){
	enewgroup hadoop
	enewuser hadoop -1 /bin/sh /var/lib/hadoop hadoop
}

src_install() {
	# The hadoop-env.sh file needs JAVA_HOME set explicitly
	#sed -i -e "2iexport JAVA_HOME=${JAVA_HOME}" conf/accumulo-env.sh || die "sed failed"

	dodir "${INSTALL_DIR}"
	mv "${S}-${MY_PV}"/* "${D}${INSTALL_DIR}" || die "install failed"
	chown -Rf hadoop:hadoop "${D}${INSTALL_DIR}"

	# env file
	cat > 99accumulo <<-EOF
		ACCUMULO_HOME=${INSTALL_DIR}
		PATH=${INSTALL_DIR}/bin
		CONFIG_PROTECT=${INSTALL_DIR}/conf
	EOF
	doenvd 99accumulo || die "doenvd failed"
}

pkg_postinst() {
	elog "Copy each .example file in ${INSTALL_DIR}/conf to a file with
	the same base name. For additional information on configuration, see
	http://incubator.apache.org/accumulo/user_manual_1.3-incubating/"
}
