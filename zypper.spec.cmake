#
# spec file for package @PACKAGE@ (Version @VERSION@)
#
# Copyright (c) 2007 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# norootforbuild

Name:           @PACKAGE@
BuildRequires:  libzypp-devel > 3.23.1 boost-devel >= 1.33.1 gettext-devel >= 0.15 readline-devel >= 5.1
BuildRequires:  gcc-c++ >= 4.1 cmake >= 2.4.6 pkg-config >= 0.20
Requires:	procps
License:        GPL v2 or later
Group:          System/Packages
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Autoreqprov:    on
PreReq:         permissions
Summary:        Command line package management tool using libzypp
Version:        @VERSION@
Release:        0
Source:         @PACKAGE@-@VERSION@.tar.bz2
Prefix:         /usr
URL:            http://en.opensuse.org/Zypper
Provides:       y2pmsh 
Obsoletes:      y2pmsh 

%description
Command line package management tool using libzypp.

Authors:
--------
    Jan Kupec <jkupec@suse.cz>
    Duncan Mac-Vicar <dmacvicar@suse.de>
    Martin Vidner <mvidner@suse.cz>

%prep
%setup -q

%build
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=%{prefix} \
      -DSYSCONFDIR=%{_sysconfdir} \
      -DMANDIR=%{_mandir} \
      -DCMAKE_VERBOSE_MAKEFILE=TRUE \
      -DCMAKE_C_FLAGS_RELEASE:STRING="%{optflags}" \
      -DCMAKE_CXX_FLAGS_RELEASE:STRING="%{optflags}" \
      -DCMAKE_BUILD_TYPE=Release \
      ..

#gettextize -f
make %{?jobs:-j %jobs}
make -C po %{?jobs:-j %jobs} translations

%install
cd build
make install DESTDIR=$RPM_BUILD_ROOT
make -C po install DESTDIR=$RPM_BUILD_ROOT

# Create filelist with translatins
cd ..
%{find_lang} zypper
#rm -f ${RPM_BUILD_ROOT}%{_sbindir}/zypp-checkpatches-wrapper
%{__install} -d -m755 %buildroot%_var/log
touch %buildroot%_var/log/zypper.log

%post
%run_ldconfig
%run_permissions

%verifyscript
%verify_permissions -e %{_sbindir}/zypp-checkpatches-wrapper

%postun
%run_ldconfig

%clean


%files -f zypper.lang
%defattr(-,root,root)
%{_sysconfdir}/logrotate.d/zypper.lr
%{_bindir}/zypper
%{_bindir}/installation_sources
%{_sbindir}/zypp-checkpatches
%verify(not mode) %attr (755,root,root) %{_sbindir}/zypp-checkpatches-wrapper
%doc %{_mandir}/*/*
%doc %dir %{_datadir}/doc/packages/zypper
%doc %{_datadir}/doc/packages/zypper/TODO
%doc %{_datadir}/doc/packages/zypper/zypper-rug
%doc %{_datadir}/doc/packages/zypper/COPYING
%doc %{_datadir}/doc/packages/zypper/HACKING
# declare ownership of the log file but prevent
# it from being erased by rpm -e
%ghost %config(noreplace) %{_var}/log/zypper.log
