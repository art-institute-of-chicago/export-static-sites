#!/bin/bash

# Script to export all of our Drupal 5 microsites to static sites. These were all created between
# 2008 and 2011 to promote museum exhibitions.
#
# Not that for `sed`s to work properly on OSX they're all preceded by `LC_ALL=C`. See:
# https://stackoverflow.com/questions/19242275/re-error-illegal-byte-sequence-on-mac-os-x

# Colors
R=`tput setaf 1`
G=`tput setaf 2`
Y=`tput setaf 3`
C=`tput setaf 6`
W=`tput sgr0`

# Folder to export to
OUTPUT='sites'
BACKUP_DIR=~/tmp
FROM_BACKUP=false
WGET_PARAMS="--page-requisites --convert-links --domains=artic.edu --no-host-directories --no-directories --timestamping " #  --adjust-extension --no-clobber --no-parent

function usage() {
    echo "${C}export.sh - export exhibition microsites as static sites${W}"
    echo " "
    echo "options:"
    echo "-h, --help                show brief help"
    echo "-c, --clean               clean existing folders before begining"
    echo "-b, --from-backup         pull the site from a backup instead of doing a wget"
    echo "-o, --output-dir DIR      specify a directory to store output in"
    echo ""
}

# Process command-line parameters
while [ ! $# -eq 0 ]
do
    case "$1" in
	--help | -h)
	    usage
            exit 0
	    ;;
	--output-dir | -o)
	    OUTPUT=$2
	    ;;
	--clean | -c)
	    rm -rf sites/*
	    ;;
	--from-backup | -b)
	    FROM_BACKUP=true
	    ;;
    esac
    shift
done

# Test for trailing slash - should not be present
dpath=$(echo $OUTPUT | awk '{print substr($0,length,1)}')
if [ $dpath = '/' ]; then
    echo "${R}Error: Please don't include a slash '/' at the end of the path.${W}"
    echo
    usage
    exit
fi


function move_js ()
{
    echo "Moving js files..."
    mkdir js
    mv */*.js js/
    mv *.js js/
}

function clean_js ()
{
    echo "Cleaning js files..."
    LC_ALL=C find . -name '*' \( -path ./js -o -path ./css -o -path ./images \) -prune -o -type f -depth 2 -exec sed -i "" -e 's?"\([^"]*\)\.js?"../js\/\1\.js?g' {} \;
    LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e 's?"\([^"]*\)\.js?"js\/\1\.js?g' {} \;
}

function move_css ()
{
    echo "Moving css files..."
    mkdir css
    mv */*.css css/
    mv *.css css/
}

function clean_css ()
{
    echo "Cleaning css files..."
    LC_ALL=C find . -name '*' \( -path ./js -o -path ./css -o -path ./images \) -prune -o -type f -depth 2 -exec sed -i "" -e 's?"\([^"]*\)\.css?"../css\/\1\.css?g' {} \;
    LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e 's?"\([^"]*\)\.css?"css\/\1\.css?g' {} \;
}

function move_image ()
{
    echo "Moving image files..."
    mkdir images
    mv */*.png images/
    mv */*.jpg images/
    mv */*.gif images/
    mv *.png images/
    mv *.jpg images/
    mv *.gif images/
}

function clean_image ()
{
    echo "Cleaning image files..."
    LC_ALL=C find . -name '*' \( -path ./js -o -path ./css -o -path ./images \) -prune -o -type f -depth 2 -exec sed -i "" -e 's?"\([^"]*\)\.png?"../images\/\1\.png?g' {} \;
    LC_ALL=C find . -name '*' \( -path ./js -o -path ./css -o -path ./images \) -prune -o -type f -depth 2 -exec sed -i "" -e 's?"\([^"]*\)\.jpg?"../images\/\1\.jpg?g' {} \;
    LC_ALL=C find . -name '*' \( -path ./js -o -path ./css -o -path ./images \) -prune -o -type f -depth 2 -exec sed -i "" -e 's?"\([^"]*\)\.gif?"../images\/\1\.gif?g' {} \;
    LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e 's?"\([^"]*\)\.png?"images\/\1\.png?g' {} \;
    LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e 's?"\([^"]*\)\.jpg?"images\/\1\.jpg?g' {} \;
    LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e 's?"\([^"]*\)\.gif?"images\/\1\.gif?g' {} \;
}

# All variables in bash are global, so this method doesn't need to return anything.
# It just sets the value for `pages` that will be used in subsequent calls.
function set_pages_var()
{
    if [ "$site" = "Ryerson-2015" ] ; then
	pages=( "${Ryerson_2015_pages[@]}" )
    elif [ "$site" = "Ryerson-2014" ] ; then
	pages=( "${Ryerson_2014_pages[@]}" )
    elif [ "$site" = "Ryerson" ] ; then
	pages=( "${Ryerson_pages[@]}" )
    fi
}

function fix_links ()
{
    echo "Fixing links..."

    # Remove extra slash in URL
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -e "s?http://www.artic.edu/aic/collections//exhibitions?http://www.artic.edu/aic/collections/exhibitions?g" {} \;

    # Remove errant `.html` from links
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E 's/\.jpg\.html/\.jpg/g' {} \;
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E 's/\.jpg\.html/\.jpg/g' {} \;
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E 's/\.js\.html/\.js/g' {} \;
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E 's/\.css\.html/\.css/g' {} \;

    # Clean up spaces
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E 's/&#32;/ /g' {} \;

    # Fix galleryObjects JS object
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E 's/http:\\\/\\\/www.artic.edu\\\/aic\\\/collections\\\/citi\\\/resources\\\/thumbnails\\\///g' {} \;
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s?\"resource_link\":\"\\\/aic\\\/collections\\\/exhibitions\\\/$site\\\/resource?\"resource_link\":\"..?g" {} \;
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s?\"resource_url\":\"..\/images\/http:\\\/\\\/www.artic.edu\\\/aic\\\/collections\\\/citi\\\/resources?\"resource_url\":\"..\\\/images?g" {} \;
    
    # Make links local
    #LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e "s?http:\/\/www.artic.edu\/aic\/collections\/exhibitions\/$site\/$page\([^\"]*\)?$page\1?g" {} \;

    set_pages_var

    for page in "${pages[@]}"
    do
	:
	# Fix galleryObjects JS object on sub-sub pages
	LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e "s?http:\/\/www.artic.edu\/aic\/collections\/exhibitions\/$site\/$page\([^\"]*\)?$page\1?g" {} \;
	LC_ALL=C find . -name '*' -type f -exec sed -i "" -e "s?http:\/\/www.artic.edu\/aic\/collections\/exhibitions\/$site\/$page\([^\"]*\)?../$page\1?g" {} \;
	LC_ALL=C find . -name '*' -type f -exec sed -i "" -e "s?href=\"../$page/\\\&quot;\([^&]*\)\\\&quot;\"?href=\&quot;\1\&quot;?g" {} \;
	LC_ALL=C find . -name '*' -type f -exec sed -i "" -e "s?href=\"../$page/\\\&quot;\([^\"]*\)\\\"\"?href=\&quot;\1\&quot;?g" {} \;
	LC_ALL=C find . -name '*' -type f -exec sed -i "" -e "s?href=\&quot;\([^\"]*\)\"\"?href=\&quot;\1\&quot;?g" {} \;
    done
}

function move_files_to_index()
{
    echo "Moving files to index.html..."

    mv index index.html

    set_pages_var

    for page in "${pages[@]}"
    do
	:
	# Get all the files withing a sub-page's directory
	filenames=()
	while IFS=  read -r -d $'\0'; do
	    filenames+=("$REPLY")
	done < <(find $page ! -name '*.*' -type f -maxdepth 1 -print0)

	# If the file has the same name as the folder, make it the index.html
	for j in "${filenames[@]}"
	do
	    :
	    name=${j:${#page}+1}

	    if [ -d "$name" ]; then
		mv $j $name/index.html
	    fi
	done

	# Then upate all references to it
	sed -i "" -e "s/href=\"$page\/\([^\"]\)/href=\"\1\.html/g" $page/index.html

    done
}

function remove_bad_files()
{
    echo "Removing bad files..."
    find . -name "' + gObj*" -type f -print0 | xargs -0 rm
    rm robots.txt*
    rm */robots.txt*
}

# Array of sites to export
sites=(
    #'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2008'
    #'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2015'
    #'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2009'
    #'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2010'
    #'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2011'
    #'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2012'
    #'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2013'
    'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2014'
    #'http://www.artic.edu/aic/collections/exhibitions/Ryerson'
    # 'http://www.artic.edu/aic/collections/exhibitions/Modern'
    # 'http://www.artic.edu/aic/collections/exhibitions/Lichtenstein'
    # 'http://www.artic.edu/aic/collections/exhibitions/AfricanAmerican'
    # 'http://www.artic.edu/aic/collections/exhibitions/IrvingPennArchives'
    # 'http://www.artic.edu/aic/collections/exhibitions/Fashioning-Object'
    # 'http://www.artic.edu/aic/collections/exhibitions/Parcours'
    # 'http://www.artic.edu/aic/collections/exhibitions/Rethink-Typologies'
    # 'http://www.artic.edu/aic/collections/exhibitions/ArtVisit'
    # 'http://www.artic.edu/aic/collections/exhibitions/Matisse'
    # 'http://www.artic.edu/aic/collections/exhibitions/Impressionism'
    # 'http://www.artic.edu/aic/collections/exhibitions/Indian'
    # 'http://www.artic.edu/aic/collections/exhibitions/African'
    # 'http://www.artic.edu/aic/collections/exhibitions/American'
    # 'http://www.artic.edu/aic/collections/exhibitions/Goldberg'
    # 'http://www.artic.edu/aic/collections/exhibitions/AncientIndian'
    # 'http://www.artic.edu/aic/collections/exhibitions/Chinese'
    # 'http://www.artic.edu/aic/collections/exhibitions/Renaissance'
    # 'http://www.artic.edu/aic/collections/exhibitions/Rococo'
    # 'http://www.artic.edu/aic/collections/exhibitions/TASS'
    # 'http://www.artic.edu/aic/collections/exhibitions/Three-Graces'
    # 'http://www.artic.edu/aic/collections/exhibitions/Ryerson'
    # 'http://www.artic.edu/aic/collections/exhibitions/B-Encounters'
    # 'http://www.artic.edu/aic/collections/exhibitions/Harlequin'
    # 'http://www.artic.edu/aic/collections/exhibitions/Hyperlinks'
    # 'http://www.artic.edu/aic/collections/exhibitions/Marin'
    # 'http://www.artic.edu/aic/collections/exhibitions/Arms-and-Armor'
    # 'http://www.artic.edu/aic/collections/exhibitions/Cartier-Bresson'
    # 'http://www.artic.edu/aic/collections/exhibitions/LouisSullivan'
    # 'http://www.artic.edu/aic/collections/exhibitions/VictPhotoColl'
    # 'http://www.artic.edu/aic/collections/exhibitions/500Ways'
    # 'http://www.artic.edu/aic/collections/exhibitions/CaseWine'
    # 'http://www.artic.edu/aic/collections/exhibitions/BeyondGoldenClouds'
    # 'http://www.artic.edu/aic/collections/exhibitions/CyTwombly'
    # 'http://www.artic.edu/aic/collections/exhibitions/Munch'
    # 'http://www.artic.edu/aic/collections/exhibitions/divineart'
    # 'http://www.artic.edu/aic/collections/exhibitions/silkroad'
    # 'http://www.artic.edu/aic/collections/exhibitions/360degrees'
    # 'http://www.artic.edu/aic/collections/exhibitions/benin'
    # 'http://www.artic.edu/aic/collections/exhibitions/hopper'
    # 'http://www.artic.edu/aic/collections/exhibitions/homer_exhb'
    # 'http://www.artic.edu/aic/collections/exhibitions/homer'
    # 'http://www.artic.edu/aic/collections/exhibitions/Kings-Queens'
    # 'http://www.artic.edu/aic/collections/exhibitions/Avant-Garde'
    # 'http://www.artic.edu/aic/collections/exhibitions/ApostlesBeauty'
    # 'http://www.artic.edu/aic/collections/exhibitions/Tagore'
    # 'http://www.artic.edu/aic/collections/exhibitions/modernwing'
    # 'http://www.artic.edu/aic/collections/exhibitions/LightYears'
    # 'http://www.artic.edu/aic/collections/exhibitions/ArtAccess'
)

Ryerson_2015_pages=(
    'frank-lloyd-wright-and-wendingen'
    'Picturesque-Ideal-Art-Landscape-Garden-Design'
    'books-for-working-artists'
    'Decidedly-Surreal-Bindings-Mary-Louise-Reynolds'
    'Tools-of-the-Trade-19th-20th-Century-Architectural-Trade-Catalogs'
)

Ryerson_2014_pages=(
    'Comic-Art-Architecture-Chris-Ware'
    'Around-World-Travel-Sketches'
    'Hired-Hand'
    'Rene-Magritte-Art-in-Belgium'
    'Czech-Avant-Garde-Book'
)

Ryerson_pages=(
    'CopyrightLaw'
    'Lost-Found'
    'ChicagoPlanning'
    'Goldberg'
    'Design-Inspiration'
    'Making-History'
    'Caricatures'
    'Paper-Architecture'
    'Burnham-Centennial'
    'Modern-Inkers'
    'In-Succession'
    'Beauty-Book'
    'Provoke'
    'Devouring-Books'
    'What-Vincent-Saw'
    'Fashion-Plates'
    'Armory'
    'Published-Picasso'
)

# Loop through sites and export
if [ -f _export.status ]; then
    read SITE < _export.status
fi
   
for i in "${sites[@]}"
do
   : 
   site=${i:49}

   if [ -z $SITE ] || [ $SITE = $site ]; then
       echo "Getting ${site}..."
       
       if [ "$FROM_BACKUP" = true ] ; then
	   cp -r $BACKUP_DIR/$site sites/
       else
	   # Get index page
	   wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site http://www.artic.edu/aic/collections/exhibitions/$site/index

	   # Get all subpages
	   set_pages_var

	   for page in "${pages[@]}"
	   do
	       :
  	       wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site/$page http://www.artic.edu/aic/collections/exhibitions/$site/$page

	       ind=1
	       until [[ $(curl -s http://www.artic.edu/aic/collections/exhibitions/$site/$page/$ind | pcregrep -M "<div id=\"content\">(\n| )+<div id=\"content-content\" class=\"clear-block\">( )+</div>(\n| )+<\!-- /content-content -->(\n| )+</div>") ]]; do
		   wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site/$page http://www.artic.edu/aic/collections/exhibitions/$site/$page/$ind
		   let "ind++"
	       done

	   done

	   # Wget links and images that are in Javascript objects
	   grep -roE "resource_link\":\"[\\\\\/a-zA-Z0-9-]+" * | cut -f3- -d\" | sed -E 's/\\\//\//g' | xargs -I % wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site http://www.artic.edu/%
	   grep -roE "resource_image_thumbnail\":\"[\\\\\/a-zA-Z0-9_\.:-]+" * | cut -f3- -d\" | sed -E 's/\\\//\//g' | xargs -I % wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site %

	   rm -rf $BACKUP_DIR/$site
	   cp -r sites/$site $BACKUP_DIR/
       fi

       cd $OUTPUT/$site/

       move_js
       move_css
       move_image
       clean_js
       clean_css
       clean_image
       fix_links
       remove_bad_files
       move_files_to_index

       echo "Done!"
       cd ../../

       echo $site > _export.status
       SITE=""
   else
       echo "Skipping ${site}"
   fi
done

rm _export.status

# After importing all the sites, fixs links across microsites
echo "Fixing links across microsites..."
cd $OUTPUT
LC_ALL=C find . -depth 2 -name "index.html" -exec sed -i "" -e "s?http://www.artic.edu/aic/collections/exhibitions/Ryerson/\([^\"]*\)\"?../Ryerson/\1\"?g" {} \;
cd ../
