#!/bin/bash

OUTPUT='sites'
WGET_PARAMS="--page-requisites --recursive --convert-links --timestamping --adjust-extension --span-hosts --domains=files.wordpress.com,r-login.wordpres.com,museum3d.artic.edu,wp.com,fonts.googleapis.com,0.gravatar.com,platform.twitter.com,syndication.twitter.com,staticxx.facebook.com --no-clobber "
#--no-parent --no-directories --no-host-directories --exclude-domains=wordpress.com

rm -rf $OUTPUT/museum3d/*
wget $WGET_PARAMS --directory-prefix=$OUTPUT/museum3d http://museum3d.artic.edu

# Move museum3d.artic.edu to top level and relink all relative links
#cd sites/museum3d/museum3d.artic.edu
#LC_ALL=C find . -name '*' -type f -exec sed -i "" -e "s?\"\.\./?\"?g" {} \;
#LC_ALL=C find . -name '*' -type f -exec sed -i "" -e "s?'\.\./?'?g" {} \;
#cd ../
#mv museum3d.artic.edu/* .
#rmdir museum3d.artic.edu

# All done
#cd ../../
