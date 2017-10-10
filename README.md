# fpm-equivs
A FPM Wrapper which internally invokes equivs(debian package creator) to generate debian package.


NAME 
	fpm-equivs

SYNOPSIS
	fpm [OPTIONS] [--prefix=foo/bar] file1 file2 file3

DESCRIPTION
	fpm-equivs is a program that understands the fpm style arguments and invokes equivs to create debian package.

OPTIONS
-h, --help		 Help
-C			 Change directory before searching file(s) (ex: -C /foo/bar)
-n			 Package name (Default: equivs-dummy)
-v			 Version
-s			 Package source type (-s dir) ~for fpm compatablity
-t			 Package output type (-t deb) ~for fpm compatablity
-p, --package		 Package output path (ex: -p /foo)
-d, --depends		 Dependency (ex: -d gcc) ~can be used multiple times
-x, --exclude		 Exclude files (ex: -x "*.pdf") ~can be used multiple times
-a, --architecture	 Architecture (ex: -a all)
--before-install	 Preinst (ex: --before-install foo)
--after-install		 Postinst (ex: --after-install bar)
--before-remove		 Prerm (ex: --before-remove foo)
--after-remove		 Postrm (ex: --before-remove bar)
--description		 Description for the package (ex: --description "short description")
--replaces		 Replaces package (ex: --replaces debian-package)
--conflicts		 Conflict package (ex: --conflicts debian-package)
--url			 URI (ex: --url http://www.zilogic.com)
--maintainer		 Details of the maintainer (ex: --maintainer code@zilogic.com)

PREFIX
	--prefix  - Prefix for package installation directory (ex: --prefix=/foo/bar)

AUTHOR
	Zilogic System <code@zilogic.com>
