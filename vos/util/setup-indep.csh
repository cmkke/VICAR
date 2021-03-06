#!/bin/csh
#
# This script performs the following platform independent processes:
#
#  - Makes certain util/scripts executable.   
#  - Builds the packer/unpacker programs for the platform
#    on which the script is run. 
#  - Unpacks the include files for specific subsytems  
# 
cd $V2UTIL
chmod +x makeapp.sys
chmod +x ar.mac-aux
chmod +x create_Imake.perl
chmod +x unpack_inc.csh
chmod +x make_compile_pdf.csh
chmod +x remove_element.csh
chmod +x make_pdf_cache.perl
chmod +x bldcomfiles.csh
chmod +x pdf2html.perl
chmod +x make_html.csh
chmod +x workshop-D.sh
#
#
# Build the packer/unpacker programs.
#
mkdir $VICCPU
make -f vpack.make
#
#
# Unpack or setup rtl, mdms, gui, p2, tlm, vids, mars, ssv, and div subsystems
# include files.   
#
if (-d $V2TOP/rtl) $V2UTIL/setup-rtlinc.csh
if (-d $V2TOP/mdms) $V2UTIL/unpk-mdmsinc.csh
if (-d $V2TOP/gui) $V2UTIL/unpk-guiinc.csh
if (-d $V2TOP/p2) $V2UTIL/unpk-p2inc.csh
if (-d $V2TOP/tlm) $V2UTIL/unpk-tlminc.csh
if (-d $V2TOP/vids) $V2UTIL/setup-vidsinc.csh
if (-d $V2TOP/mars) $V2UTIL/unpk-marsinc.csh
if (-d $V2TOP/ssv) $V2UTIL/unpk-ssvinc.csh
if (-d $V2TOP/div) $V2UTIL/unpk-divinc.csh
if (-d $V2TOP/fei5) $V2UTIL/unpk-fei5inc.csh
