#!/bin/bash
# Purpose   : A FPM Wrapper which internally invokes equives to generate debian package.
# Author    : Joses Paul <josespaul@zilogic.com>
# License   : GPL 2.0
# Dependency: equivs

# Generate Equivs control file (/tmp/equivs-control.*)
ctlfile=$(mktemp /tmp/equivs-control.XXXXXX)
echo "Maintainer: Zilogic Systems <code@zilogic.com>" >> $ctlfile
arch="-a $(dpkg --print-architecture)" # Default architecture
prefix=/ # Default prefix
current_dir=$(pwd) # Current Dir (before change dir)
output_dir=$current_dir # Default

cleanup()
{
    rm -f $ctlfile
}

error()
{
    echo -e "\nUsage Error"
    echo "USAGE: fpm [OPTIONS] [--prefix=foo/bar] file1 file2 file3 .."
    echo "HELP : fpm --help"
}

help()
{
    echo -e "NAME \n\tfpm-equivs"
    echo -e "\nSYNOPSIS\n\tfpm [OPTIONS] [--prefix=foo/bar] file1 file2 file3"
    echo -e "\nDESCRIPTION\n\tfpm-equivs is a program that understands the fpm style arguments and invokes equivs to create debian package."
    echo -e "\nOPTIONS"
    echo -e "-h, --help\t\t Help"
    echo -e "-C\t\t\t Change directory before searching file(s) (ex: -C /foo/bar)"
    echo -e "-n\t\t\t Package name (Default: equivs-dummy)"
    echo -e "-v\t\t\t Version"
    echo -e "-s\t\t\t Package source type (-s dir) ~for fpm compatablity"
    echo -e "-t\t\t\t Package output type (-t deb) ~for fpm compatablity"
    echo -e "-p, --package\t\t Package output path (ex: -p /foo)"
    echo -e "-d, --depends\t\t Dependency (ex: -d gcc) ~can be used multiple times"
    echo -e "-x, --exclude\t\t Exclude files (ex: -x \"*.pdf\") ~can be used multiple times"
    echo -e "-a, --architecture\t Architecture (ex: -a all)"
    echo -e "--before-install\t Preinst (ex: --before-install foo)"
    echo -e "--after-install\t\t Postinst (ex: --after-install bar)"
    echo -e "--before-remove\t\t Prerm (ex: --before-remove foo)"
    echo -e "--after-remove\t\t Postrm (ex: --before-remove bar)"
    echo -e "--description\t\t Description for the package (ex: --description \"short description\")"
    echo -e "--replaces\t\t Replaces package (ex: --replaces debian-package)"
    echo -e "--conflicts\t\t Conflict package (ex: --conflicts debian-package)"
    echo -e "--url\t\t\t URI (ex: --url http://www.zilogic.com)"
    echo -e "--maintainer\t\t Details of the maintainer (ex: --maintainer code@zilogic.com)"
    echo -e "\nPREFIX"
    echo -e "\t--prefix  - Prefix for package installation directory (ex: --prefix=/foo/bar)"
    echo -e "\nAUTHOR\n\tZilogic System <code@zilogic.com>"
}

# clean before exit
trap cleanup EXIT

opts=`getopt -o hC:v:s:t:n:d:a:x:p: -l depends:,before-install:,after-install:,before-remove:,after-remove:,prefix:,architecture:,description:,replaces:,conflicts:,url:,maintainer:,exclude:,package:,help -n 'fpm' -- "$@"`
eval set -- "$opts"

if [ $? -ne 0 ]; then
    echo "fpm-equivs: usage error " >&2
    error
    exit 2
fi

while true; do
    case "$1" in

	-h | --help)
	    help
	    exit
	    ;;

	-v) # -v Version - appends in the package filename.
	    echo "Version: $2" >> $ctlfile
	    shift; shift;
	    ;;

	-s) # -s Dir - Default input dir/files.
	    if [ $2 != "dir" ]; then
		echo "fpm-equivs: Input type must be dir/files (-s dir)" >&2
		exit 2
	    fi
	    shift; shift;
	    ;;

	-t) # -t deb - Default output Deb.
	    if [ $2 != "deb" ]; then
		echo "fpm-equivs: Output type must be deb (-t deb)" >&2
		exit 2
	    fi
	    shift; shift;
	    ;;

	-a | --architecture) # Architecture
	    if [[ $2 != "noarch" && $2 != "all" ]]; then
		echo "Architecture: $2" >> $ctlfile
		arch="-a $2"
	    else
		unset arch
	    fi
	    shift; shift;
	    ;;

	-x | --exclude) # Exclude Files
	    exclude="$exclude -not -name $2"
	    shift; shift;
	    ;;

	--before-install)
	    if [ -f $(realpath $2) ] # Validate Preinstallation file.
	    then
		echo "Preinst: $(realpath $2)" >> $ctlfile
		shift; shift;
	    else
		echo "fpm-equivs: pre-installation file not found" >&2
		exit 2
	    fi
	    ;;

	--after-install)
	    if [ -f $(realpath $2) ] # Validate Postinstallation file.
	    then
		echo "Postinst: $(realpath $2)" >> $ctlfile
		shift; shift;
	    else
		echo "fpm-equivs: post-installation file not found" >&2
		exit 2
	    fi
	    ;;

	--before-remove)
	    if [ -f $(realpath $2) ] # Validate Prerm file.
	    then
		echo "Prerm: $(realpath $2)" >> $ctlfile
		shift; shift;
	    else
		echo "fpm-equivs: pre-removal file not found" >&2
		exit 2
	    fi
	    ;;

	--after-remove)
	    if [ -f $(realpath $2) ] # Validate Postrm file.
	    then
		echo "Postrm: $(realpath $2)" >> $ctlfile
		shift; shift;
	    else
		echo "fpm-equivs: Post-removal file not found" >&2
		exit 2
	    fi
	    ;;

	-n) # Set Package Name.
	    echo "Package: $2" >> $ctlfile
	    shift; shift;
	    ;;

	-p | --package) # package output location
	    output_dir=$(realpath $2)
	    shift; shift;
	    ;;

	--description)
	    echo "Description: $2" >> $ctlfile
	    shift; shift;
	    ;;

	--url)
	    echo "Homepage: $2" >> $ctlfile
	    shift; shift;
	    ;;

	--prefix)
	    prefix="$2/"
	    echo "setting prefix: $prefix"
	    shift; shift;
	    ;;

	--replaces)
	    echo "Replaces: $2" >> $ctlfile
	    shift; shift;
	    ;;

	--conflicts)
	    echo "Conflicts: $2" >> $ctlfile
	    shift; shift;
	    ;;

	--maintainer) # Overwrite default maintainer.
	    sed -i "1s/.*/Maintainer: $2 <$2>/" $ctlfile
	    shift; shift;
	    ;;

	-d | --depends) # Dependency
	    depends="$depends $2,"
	    shift; shift;
	    ;;

	-C) # Change directry
	    change_dir="$(realpath $2)/"
	    current_dir=$change_dir
	    shift; shift;
	    ;;

	--) # Break after --
	    shift;
	    break
	    ;;
    esac
done

echo "Depends: $depends" >> $ctlfile

if [[ -n $change_dir ]]; then
    pushd $change_dir > /dev/null
fi
# Input files
if [[ -z $@ ]]; then
    echo "fpm-equivs: expected filenames as arguments." >&2
    error
    exit 2
fi
echo -n "Files:" >> $ctlfile

for file in $@
do
    if [[ -f $file ]]; then # If file
	echo " $file $prefix" >> $ctlfile
    elif [[ -d $file ]]; then # If dir
	set -f
	file_list=$(find $file -type f $exclude) # Find all files
	set +f
	for i in $file_list
	do
	    echo " $i $prefix" >> $ctlfile
	done
    else
	echo "fpm-equivs: $file : no such file or directory" >&2
	exit 2
    fi
done

# Build-package
if [ -f $ctlfile ]; then
    equivs-build $arch $ctlfile
fi

if [[ $current_dir != $output_dir ]]; then
    mv -f *.deb $output_dir
fi
