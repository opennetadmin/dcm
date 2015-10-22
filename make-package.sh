#!/bin/bash
# This script will build a package for dcm. It uses fpm. Simple install of
# fpm is:
#   sudo apt-get install ruby-dev gcc
#   sudo gem install fpm
#   sh ./make-package.sh


# -------- Variables that change --------
PREFIX='/opt/ona'
VERSION=$(bin/dcm.pl --version)
# default is deb.. change to rpm if you want (not currently tested)
TYPE=deb


# -------- Initial setup --------

# ----- Build the package ------
fpm -s dir -t ${TYPE} -n dcm -v ${VERSION} \
--force \
-x "**/.git/**" -x "**/.git" \
-a all \
--prefix ${PREFIX} \
--config-files ${PREFIX}/etc \
--template-scripts \
--deb-use-file-permissions \
--deb-no-default-config-files \
--url https://github.com/opennetadmin/dcm \
--vendor OpenNetAdmin \
--license "GPL v2" \
-m "Matt Pascoe (matt@opennetadmin.com)" \
--description "Command line interface for OpenNetAdmin" \
etc bin
