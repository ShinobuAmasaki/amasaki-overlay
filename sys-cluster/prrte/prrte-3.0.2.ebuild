# Copyright 2023 Amasaki Shinobu

EAPI=8

DESCRIPTION="PMIx Reference RunTime Environment (PRRTE)"
HOMEPAGE="https://github.com/openpmix/prrte"
SRC_URI="https://github.com/openpmix/prrte/releases/download/v${PV}/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="ipv6 doc"

RDEPEND="
   >=sys-devel/flex-2.5.35
	>=dev-libs/libevent-2.0.22:=[threads(+)]
	>=sys-apps/hwloc-2.0.2:=
   doc? (
		dev-python/sphinx
      dev-python/sphinx-rtd-theme
   )
   >=sys-cluster/pmix-4.2.7
   "

DEPEND="${RDEPEND}"


src_configure() {
   local myconf=(
		--with-hwloc="${EPREFIX}/usr"
		--with-hwloc-libdir="${EPREFIX}/usr/$(get_libdir)"
		--with-libevent="${EPREFIX}/usr"
		--with-libevent-libdir="${EPREFIX}/usr/$(get_libdir)"
      --with-pmix="${EPREFIX}/usr"
   )
   CONFIG_SHELL="${BROOT}"/bin/bash ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

src_install() {
   default
   find "${ED}" -name '*.la' -delete || die
}