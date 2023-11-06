# Copyright 1999-2023 Gentoo Authors
# Modified by Amasaki Shinobu in 2023
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FORTRAN_NEEDED=fortran
inherit cuda fortran-2 multilib-minimal

IUSE_OPENMPI_RM="
   openmpi_rm_pbs
   openmpi_rm_slurm"

DESCRIPTION="A high-performance message passing library (MPI)"
HOMEPAGE="https://www.open-mpi.org"
SRC_URI="https://download.open-mpi.org/release/open-mpi/v$(ver_cut 1-2)/openmpi-${PV}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cma cuda cxx +fortran ipv6 libompitrace peruse romio valgrind prrte doc
	${IUSE_OPENMPI_FABRICS} ${IUSE_OPENMPI_RM} ${IUSE_OPENMPI_OFED_FEATURES}"

REQUIRED_USE="
   openmpi_rm_slurm? ( !openmpi_rm_pbs )
   openmpi_rm_pbs? ( !openmpi_rm_slurm )"

RDEPEND="
   !sys-cluster/mpich
   !sys-cluster/mpich2
   !sys-cluster/nullmpi
   >=dev-libs/libevent-2.0.22:=[${MULTILIB_USEDEP},threads(+)]
   dev-libs/libltdl:0[${MULTILIB_USEDEP}]
   >=sys-apps/hwloc-2.0.2:=[${MULTILIB_USEDEP}]
   >=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}]
   >=sys-cluster/pmix-4.2.7
   cuda? ( >=dev-util/nvidia-cuda-toolkit-6.5.19-r1:= )
   openmpi_rm_pbs? ( sys-cluster/openpbs )
   openmpi_rm_slurm? ( sys-cluster/slurm )
	doc? (
		dev-python/sphinx
		dev-python/sphinx-rtd-theme
		dev-python/recommonmark )"

DEPEND="${RDEPEND}
   valgrind? ( dev-util/valgrind )"

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/mpi.h
	/usr/include/openmpi/mpiext/mpiext_cuda_c.h
)

pkg_setup() {
   fortran-2_pkg_setup

	elog
	elog "OpenMPI has an overwhelming count of configuration options."
	elog "Don't forget the EXTRA_ECONF environment variable can let you"
	elog "specify configure options if you find them necessary."
	elog
}

src_prepare() {
   default

   # Avoid test which ends up looking at system mounts
	echo "int main() { return 0; }" > test/util/opal_path_nfs.c || die

	# Necessary for scalibility, see
	# http://www.open-mpi.org/community/lists/users/2008/09/6514.php
	echo 'oob_tcp_listen_mode = listen_thread' \
		>> opal/etc/openmpi-mca-params.conf || die
}

multilib_src_configure() {
   local myconf=(
      --disable-mpi-java
		# configure takes a looooong time, but upstream currently force
		# constriants on caching:
		# https://github.com/open-mpi/ompi/blob/9eec56222a5c98d13790c9ee74877f1562ac27e8/config/opal_config_subdir.m4#L118
		# so no --cache-dir for now.
		--enable-mpi-fortran=$(usex fortran all no)

		--enable-pretty-print-stacktrace
 		--enable-prte-prefix-by-default
    
		--sysconfdir="${EPREFIX}/etc/${PN}"

		--with-hwloc="${EPREFIX}/usr"
		--with-hwloc-libdir="${EPREFIX}/usr/$(get_libdir)"
		--with-libltdl="${EPREFIX}/usr"
      --with-libltdl-libdir="${EPREFIX}/usr/$(get_libdir)"
		--with-libevent="${EPREFIX}/usr"
		--with-libevent-libdir="${EPREFIX}/usr/$(get_libdir)"

		# Re-enable for 5.0!
		# See https://github.com/open-mpi/ompi/issues/9697#issuecomment-1003746357
		# and https://bugs.gentoo.org/828123#c14
	   --enable-heterogeneous

      --with-prrte="${EPREFIX}/usr"
		--enable-binaries

		$(use_enable ipv6)
		$(use_enable peruse)
		$(use_enable romio io-romio)

      $(multilib_native_use_with cuda cuda "${EPREFIX}"/opt/cuda)
		$(multilib_native_use_with valgrind)

		$(multilib_native_use_with openmpi_rm_pbs tm)
      $(multilib_native_use_with openmpi_rm_pbs pbs)
		$(multilib_native_use_with openmpi_rm_slurm slurm) 
   )
   	CONFIG_SHELL="${BROOT}"/bin/bash ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

multilib_src_compile() {
	emake V=1
}

multilib_src_install() {
	default

	# fortran header cannot be wrapped (bug #540508), workaround part 1
	if multilib_is_native_abi && use fortran; then
		mkdir "${T}"/fortran || die
		mv "${ED}"/usr/include/mpif* "${T}"/fortran || die
	else
		# some fortran files get installed unconditionally
		rm \
			"${ED}"/usr/include/mpif* \
			"${ED}"/usr/bin/mpif* \
			|| die
	fi

}

multilib_src_install_all() {
	# fortran header cannot be wrapped (bug #540508), workaround part 2
	if use fortran; then
		mv "${T}"/fortran/mpif* "${ED}"/usr/include || die
	fi

	# Remove la files, no static libs are installed and we have pkg-config
	find "${ED}" -name '*.la' -delete || die

}