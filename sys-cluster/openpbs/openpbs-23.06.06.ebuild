# Copyright 2023 Amasaki Shinobu

EAPI=8

PYTHON_COMPAT=(python3_{10,11,12})

inherit flag-o-matic python-r1

DESCRIPTION="An HPC workload manager and job scheduler for desktops, clusters, and clouds."
HOMEPAGE="https://www.openpbs.org/"
SRC_URI="https://github.com/openpbs/openpbs/archive/refs/tags/v{$PV}.tar.gz -> ${P}.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="crypt syslog ptl cray static-libs"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND="
	!sys-cluster/torque
	!sys-cluster/slurm
	sys-devel/gcc
	sys-devel/make
	sys-devel/libtool
	sys-devel/autoconf
	sys-devel/automake
	sys-apps/hwloc
	sys-libs/ncurses
	dev-lang/perl
	dev-lang/python
	dev-lang/tk:0=
	dev-lang/tcl:0=
	crypt? ( virtual/libcrypt:= )
	dev-libs/openssl
	dev-libs/libedit
	dev-db/postgresql
	dev-lang/swig
	x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXext
	x11-libs/libXft
	media-libs/fontconfig
	syslog? ( virtual/logger:= )
	!!games-util/qstat"

DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND} ${PYTHON_DEPS}
	dev-libs/libical
	x11-libs/libXrender
	mail-mta/sendmail"

BDEPEND="${COMMON_DEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-${PV}-1.patch
)

src_configure() {
	${S}/autogen.sh
	append-libs "-ltinfo"
	econf \
		$(usex syslog "" "--disable-syslog") \
		$(usex ptl "--enable-ptl" "") \
		$(usex cray "--enable-alps" "") \
		$(use_enable static-libs static) \
		--enable-shared
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
	rm -rf ${ED}/usr/unsupported || die
	rm -rf ${ED}/usr/bin/mpiexec || die
}
