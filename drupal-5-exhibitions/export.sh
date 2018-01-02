#!/bin/bash

# Drupal 5 Exhibitions Export
#
# Script to export all of our Drupal 5 microsites to static sites. These were all created between
# 2008 and 2011 to promote museum exhibitions.
#
# This script runs a series of `wget` commands to retrieve each site, move files around into a
# normalized directory structure, then does a series of `sed` find and replaces to correct
# references to requisite assets.
#
# The `wget`s are run once for each page in each microsite. This script was written this way
# rather than using `wget`'s `--recursive` flag so that each microsite can be isolated and
# treated individually. The recursive flag inevitably jumped around to other microsites making them
# hard to keep separate from each other. Likewise the `--no-directories` flag is used to squash
# all requisite assets like JavaScript, CSS and images into a single directory, then moved around
# after the fact. Each of these pages contained assets in all sorts of directory structures that
# didn't need to be maintained in a static distribution. So `--no-directories` allows this script
# to start from scratch and move files into a structure that makes sense outside of the Drupal
# framework.
#
# Note that for `sed`s to work properly on OSX they're all preceded by `LC_ALL=C`. See:
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
    LC_ALL=C find . -name '*' \( -path ./js -o -path ./css -o -path ./images \) -prune -o -type f -depth 2 -exec sed -i "" -e 's?"\([a-zA-Z0-9_\.\/\-]*\)\.js?"../js\/\1\.js?g' {} \;
    LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e 's?"\([a-zA-Z0-9_\.\-]*\)\.js?"js\/\1\.js?g' {} \;
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
    LC_ALL=C find . -name '*' \( -path ./js -o -path ./css -o -path ./images \) -prune -o -type f -depth 2 -exec sed -i "" -e 's?"\([a-zA-Z0-9_\.\/\-]*\)\.css?"../css\/\1\.css?g' {} \;
    LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e 's?"\([a-zA-Z0-9_\.\-]*\)\.css?"css\/\1\.css?g' {} \;
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
    LC_ALL=C find . -name '*' \( -path ./js -o -path ./css -o -path ./images \) -prune -o -type f -depth 2 -exec sed -i "" -e 's?"\([a-zA-Z0-9_./-]*\)\.png?"../images\/\1\.png?g' {} \;
    LC_ALL=C find . -name '*' \( -path ./js -o -path ./css -o -path ./images \) -prune -o -type f -depth 2 -exec sed -i "" -e 's?"\([a-zA-Z0-9_./-]*\)\.jpg?"../images\/\1\.jpg?g' {} \;
    LC_ALL=C find . -name '*' \( -path ./js -o -path ./css -o -path ./images \) -prune -o -type f -depth 2 -exec sed -i "" -e 's?"\([a-zA-Z0-9_./-]*\)\.gif?"../images\/\1\.gif?g' {} \;
    LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e 's?"\([a-zA-Z0-9_\.\-]*\)\.png?"images\/\1\.png?g' {} \;
    LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e 's?"\([a-zA-Z0-9_\.\-]*\)\.jpg?"images\/\1\.jpg?g' {} \;
    LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e 's?"\([a-zA-Z0-9_\.\-]*\)\.gif?"images\/\1\.gif?g' {} \;
}

function fix_links ()
{
    echo "Fixing links..."

    # Remove extra slash in URL
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -e "s?http://www.artic.edu/aic/collections/exhibitions?http://www.artic.edu/aic/collections/exhibitions?g" {} \;

    # Remove errant `.html` from links
    LC_ALL=C find . -name '*' -type f -exec sed -i ""images/ -E 's/\.jpg\.html/\.jpg/g' {} \;
    LC_ALL=C find . -name '*' -type f -exec sed -i ""images/ -E 's/\.jpg\.html/\.jpg/g' {} \;
    LC_ALL=C find . -name '*' -type f -exec sed -i ""js/ -E 's/\.js\.html/\.js/g' {} \;
    LC_ALL=C find . -name '*' -type f -exec sed -i ""css/ -E 's/\.css\.html/\.css/g' {} \;

    # Clean up spaces
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E 's/&#32;/ /g' {} \;

    # Fix galleryObjects JS object
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E 's/http:\\\/\\\/www.artic.edu\\\/aic\\\/collections\\\/citi\\\/resources\\\/thumbnails\\\//..\\\/images\\\//g' {} \;
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E 's/http:\\\/\\\/www.artic.edu\\\/aic\\\/collections\\\/citi\\\/images\\\/standard\\\/[a-zA-Z]*\\\/[a-zA-Z0-9_]*\\\//..\\\/images\\\//g' {} \;
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s?\"resource_link\":\"\\\/aic\\\/collections\\\/exhibitions\\\/$site\\\/resource?\"resource_link\":\"..?g" {} \;
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s?\"resource_url\":\"..\/images\/http:\\\/\\\/www.artic.edu\\\/aic\\\/collections\\\/citi\\\/resources?\"resource_url\":\"..\\\/images\\\/?g" {} \;
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s?\"artwork_link\":\"\\\/aic\\\/collections\\\/exhibitions\\\/$site\\\/artwork?\"artwork_link\":\"..?g" {} \;
    
    # Make links local
    #LC_ALL=C find . -name '*' -type f -depth 1 -exec sed -i "" -e "s?http:\/\/www.artic.edu\/aic\/collections\/exhibitions\/$site\/$page\([^\"]*\)?$page\1?g" {} \;

    # Fix links of images to main site
    LC_ALL=C find . -name '*' -type f -exec sed -i "" -E 's/http:\/\/www.artic.edu\/aic\/collections\/citi\/images\/standard\/[a-zA-Z]*\/[a-zA-Z0-9_]*\//..\\\/images\\\//g' {} \;

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
    'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2008'
    'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2009'
    'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2010'
    'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2011'
    'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2012'
    'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2013'
    'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2014'
    'http://www.artic.edu/aic/collections/exhibitions/Ryerson-2015'
    'http://www.artic.edu/aic/collections/exhibitions/Ryerson'
    'http://www.artic.edu/aic/collections/exhibitions/Modern'
    'http://www.artic.edu/aic/collections/exhibitions/Lichtenstein'
    'http://www.artic.edu/aic/collections/exhibitions/AfricanAmerican'
    'http://www.artic.edu/aic/collections/exhibitions/IrvingPennArchives'
    'http://www.artic.edu/aic/collections/exhibitions/Fashioning-Object'
    'http://www.artic.edu/aic/collections/exhibitions/Parcours'
    'http://www.artic.edu/aic/collections/exhibitions/Rethink-Typologies'
    'http://www.artic.edu/aic/collections/exhibitions/ArtVisit'
    'http://www.artic.edu/aic/collections/exhibitions/Matisse'
    'http://www.artic.edu/aic/collections/exhibitions/Impressionism'
    'http://www.artic.edu/aic/collections/exhibitions/Indian'
    'http://www.artic.edu/aic/collections/exhibitions/African'
    'http://www.artic.edu/aic/collections/exhibitions/American'
    'http://www.artic.edu/aic/collections/exhibitions/Goldberg'
    'http://www.artic.edu/aic/collections/exhibitions/AncientIndian'
    'http://www.artic.edu/aic/collections/exhibitions/Chinese'
    'http://www.artic.edu/aic/collections/exhibitions/Renaissance'
    'http://www.artic.edu/aic/collections/exhibitions/Rococo'
    'http://www.artic.edu/aic/collections/exhibitions/TASS'
    'http://www.artic.edu/aic/collections/exhibitions/Three-Graces'
    'http://www.artic.edu/aic/collections/exhibitions/B-Encounters'
    'http://www.artic.edu/aic/collections/exhibitions/Harlequin'
    'http://www.artic.edu/aic/collections/exhibitions/Hyperlinks'
    'http://www.artic.edu/aic/collections/exhibitions/Marin'
    'http://www.artic.edu/aic/collections/exhibitions/Arms-and-Armor'
    'http://www.artic.edu/aic/collections/exhibitions/Cartier-Bresson'
    'http://www.artic.edu/aic/collections/exhibitions/LouisSullivan'
    'http://www.artic.edu/aic/collections/exhibitions/VictPhotoColl'
    'http://www.artic.edu/aic/collections/exhibitions/500Ways'
    'http://www.artic.edu/aic/collections/exhibitions/CaseWine'
    'http://www.artic.edu/aic/collections/exhibitions/BeyondGoldenClouds'
    'http://www.artic.edu/aic/collections/exhibitions/CyTwombly'
    'http://www.artic.edu/aic/collections/exhibitions/Munch'
    'http://www.artic.edu/aic/collections/exhibitions/divineart'
    'http://www.artic.edu/aic/collections/exhibitions/silkroad'
    'http://www.artic.edu/aic/collections/exhibitions/360degrees'
    'http://www.artic.edu/aic/collections/exhibitions/benin'
    'http://www.artic.edu/aic/collections/exhibitions/hopper'
    'http://www.artic.edu/aic/collections/exhibitions/homer_exhb'
    'http://www.artic.edu/aic/collections/exhibitions/homer'
    'http://www.artic.edu/aic/collections/exhibitions/Kings-Queens'
    'http://www.artic.edu/aic/collections/exhibitions/Avant-Garde'
    'http://www.artic.edu/aic/collections/exhibitions/ApostlesBeauty'
    'http://www.artic.edu/aic/collections/exhibitions/Tagore'
    'http://www.artic.edu/aic/collections/exhibitions/modernwing'
    'http://www.artic.edu/aic/collections/exhibitions/LightYears'
    'http://www.artic.edu/aic/collections/exhibitions/ArtAccess'
)

# Arrays of sub-pages for each microsite
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

Modern_pages=(
    'Guitarist'
    'Improvisation'
    'Bathers'
    'Black-Cross'
    'American-Gothic'
    'Time'
    'Nighthawks'
    'Greyed-Rainbow'
    'Mao'
    'Zapata'
    'Clown'
    'Monk'
    'lesson'
    'resource/1024'
    'resource/1254'
    'resource/1022'
    'resource/1023'
    'family'
    'resource/1049'
    'resource/1048'
    'resource/1050'
    'books-media'
    'glossary'
    'selectedworks'
    'resource/1862'
)

Lichtenstein_pages=(
    'themes'
    'themes/Look-Mickey'
    'themes/Early-Abstractions'
    'themes/Early-Pop'
    'themes/Black-White'
    'themes/War-Romance'
    'themes/Brushstrokes'
    'themes/Landscapes'
    'themes/Art-History'
    'themes/Modern'
    'themes/Mirrors'
    'themes/Entablatures'
    'themes/Artists-Studios'
    'themes/Perfect-Imperfect'
    'themes/Nudes'
    'themes/Landscapes-Chinese'
    'themes/Works-Paper'
    'videos'
    'selectedworks'
    'search-artworks'
)

AfricanAmerican_pages=(
    'Douglass'
    'Two-Disciples'
    'Study'
    'Train-Station'
    'Wedding'
    'Hero'
    'Nightlife'
    'Sharecropper'
    'Starry-Night'
    'Return'
    'Many-Mansions'
    'Stranger'
    'lesson'
    'resource/985'
    'resource/986'
    'resource/987'
    'resource/1008'
    'resource/1007'
    'family'
    'resource/1035'
    'resource/1034'
    'books-media'
    'resource/1346'
    'glossary'
    'selectedworks'
)

IrvingPennArchives_pages=(
    'overview'
    'themes'
    'advertising'
    'ethnographic'
    'fashion'
    'nudes'
    'portraits'
    'still-lifes'
    'street-travel'
    'book'
    'permanent'
    'archive'
    'paper-archives'
    'resource/2006'
    'resource/1952'
    'resource/2377'
    'resource/2376'
    'resource/2121'
    'resource/2120'
    'resource/2122'
    'resource/1992'
    'resource/2375'
    'resource/2378'
    'resource/1081'
    'resource/1080'
    'resource/1985'
    'resource/2373'
    'resource/2119'
    'resource/1986'
    'resource/2118'
    'resource/1951'
    'resource/1991'
    'resource/2381'
    'resource/1792'
    'resource/2005'
    'timelines'
    'resource/1971'
    'resource/1976'
    'resource/1975'
    'resource/2382'
    'CollectionAccess'
    'copyright'
    'cameras-techniques'
    'rolleiflex'
    '35mm'
    'view'
    'pointillism'
    'moving-light'
    'dye-imbibition'
    'gelatin'
    'platinum'
    'silver'
    'additionalresources'
    'resource/1951'
    'resource/1973'
    'resource/1972'
    'resource/1968'
    'resource/1969'
    'resource/2379'
    'resource/2380'
    'resource/1968'
    'resource/1969'
    'resource/1951'
    'resource/2380'
    'resource/2379'
    'resource/1972'
    'resource/1973'
    'search'
    'thanks'
)

Fashioning_Object_pages=(
    'Bless'
    'Bless/selectedworks'
    'Boudicca'
    'Boudicca/selectedworks'
    'Backlund'
    'Backlund/selectedworks'
    'resource/2403'
    'events'
)

Parcours_pages=(
    'overview'
)

Rethink_Typologies_pages=(
    'artworks'
)

ArtVisit_pages=(
    'SummerVisits'
    'PlanVisit'
)

Matisse_pages=(
    'overview'
    'exhibitionthemes'
    'member'
    'Opportunity'
    'Painful'
    'Construction'
    'NewAmbitions'
    'Printmaking'
    'Interruptions'
    'Challenge'
    'Charting'
    'Experiment'
    'artwork'
)

Impressionism_pages=(
    'Manet'
    'Monet'
    'Renoir'
    'Caillebotte'
    'Degas'
    'Cassatt'
    'Seurat'
    'vanGogh'
    'Gauguin'
    'Cezanne'
    'Toulouse-Lautrec'
    'Vuillard'
    'lesson'
    'resource/503'
    'resource/504'
    'resource/1345'
    'resource/505'
    'family'
    'resource/1361'
    'resource/1362'
    'resource/1363'
    'books-media'
    'resource/1074'
    'Glossary'
    'selectedworks'
)

Indian_pages=(
    'Yakshi'
    'Vishnu'
    'Dance'
    'Female'
    'Uma'
    'Demon'
    'Ganesha'
    'Bodhisattva'
    'Buddha'
    'Banner'
    'Tara'
    'Manuscript'
    'lesson'
    'resource/1015'
    'resource/1017'
    'resource/1016'
    'resource/1018'
    'family'
    'resource/1042'
    'resource/1043'
    'resource/1044'
    'books-media'
    'resource/1524'
    'glossary'
    'selectedworks'
)

African_pages=(
    'Horse'
    'Pair'
    'Drum'
    'Mask'
    'Tusk'
    'Linguist'
    'Veranda'
    'Power'
    'Mask2'
    'Figure'
    'Neckrest'
    'Mary'
    'lesson'
    'resource/1010'
    'resource/1011'
    'resource/1009'
    'family'
    'resource/1038'
    'resource/1036'
    'resource/1037'
    'books-media'
    'resource/1869'
    'glossary'
    'selectedworks'
    'artwork/189597'
    'artwork/15457'
    'artwork/158772'
    'artwork/151385'
    'artwork/145678'
    'artwork/189595'
    'artwork/51809'
    'artwork/125774'
    'artwork/99538'
    'artwork/132676'
    'artwork/146961'
    'artwork/189596'
    'artwork/65187'
    'artwork/146941'
    'artwork/102611'
    'artwork/111401'
)

American_pages=(
    'MrsHubbard'
    'high-chest'
    'Bar-room'
    'Cotopaxi'
    'Zenobia'
    'Freedman'
    'Grey-Silver'
    'Herring-Net'
    'Tiffany'
    'Dinner'
    'Glass'
    'At-Mouquins'
    'lesson'
    'resource/1241'
    'resource/1013'
    'resource/1014'
    'family'
    'resource/1039'
    'resource/1040'
    'resource/1041'
    'books-media'
    'resource/1870'
    'glossary'
    'selectedworks'
)

Goldberg_pages=(
    'overview'
    'Industry'
    'Community'
    'Furniture'
    'Leisure'
    'City'
    'Humanist'
    'Towers'
    'NewYork'
    'Hospital'
    'RiverCity'
    'selectedworks'
    'additional_resources'
    'photographs'
    'resource/1872'
    'resource/1865'
    'resource/1886'
    'marinacity'
)

AncientIndian_pages=(
    'Cache'
    'Figurine'
    'Model'
    'Mural'
    'Ball'
    'Vase'
    'Stone'
    'Pendant'
    'Mantle'
    'Vessel'
    'Messenger'
    'Beaker'
    'lesson'
    'resource/1019'
    'resource/1020'
    'resource/1021'
    'family'
    'resource/1045'
    'resource/1047'
    'resource/1046'
    'books-media'
    'resource/1871'
    'glossary'
    'selectedworks'
)

Chinese_pages=(
    'Bell'
    'Pillow'
    'Dish'
    'Pendant'
    'Jifu'
    'Plate'
    'Buddha'
    'Jar'
    'Pigsty'
    'Demon'
    'Vessel'
    'Landscape'
    'lesson'
    'resource/1877'
    'resource/1878'
    'resource/1879'
    'family'
    'resource/1880'
    'resource/1881'
    'resource/1882'
    'books-media'
    'resource/1868'
    'glossary'
    'selectedworks'
)

Renaissance_pages=(
    'Dragon'
    'Ulysses'
    'Virgin'
    'Crucifixion'
    'Assumption'
    'Annunciation'
    'Man'
    'Still'
    'Holy'
    'Salome'
    'Patmos'
    'FamilyConcert'
    'lesson'
    'resource/1026'
    'resource/1076'
    'resource/1028'
    'resource/1029'
    'resource/1030'
    'family'
    'resource/1052'
    'resource/1053'
    'resource/1051'
    'books-media'
    'resource/1873'
    'glossary'
    'selectedworks'
)

Rococo_pages=(
    'Fete'
    'Rinaldo'
    'Grape'
    'Graces'
    'Madame'
    'Maragato'
    'Combat'
    'Stoke'
    'Mere'
    'Peasants'
    'Bust'
    'Jesus'
    'lesson'
    'resource/1031'
    'resource/1032'
    'resource/1033'
    'family'
    'resource/1055'
    'resource/1054'
    'resource/1056'
    'books-media'
    'resource/1347'
    'glossary'
    'selectedworks'
)

TASS_pages=(
    'index'
    'overview'
    'Motherland-Calls'
    'Art-Weapon'
    'Studio'
    'Heroic-Past'
    'USSR-USA'
    'Abroad'
    'Bondage-Partisans'
    'Posters'
    'Stalingrad'
    'Occupiers-Liberators'
    'Battle-Europe'
    'Destruction'
    'Camps'
    'Victory'
    'Stencil-Technique'
    'stencils'
    'prints'
    'resource/1809'
    'additional-resources'
    'resource/1811'
    'resource/1025'
    'resource/1810'
    'artists'
    'Moa'
    'Aliakrinskii'
    'Cheremnykh'
    'Deni'
    'Denisovskii'
    'Ivanov'
    'Kostin'
    'Kukryniksy'
    'Lebedev'
    'Liushin'
    'Maiakovskii'
    'Milashevskii'
    'Nisskii'
    'Plotnov'
    'Sarkisian'
    'Savitskii'
    'Shukhmin'
    'Skalia'
    'Sokolov'
    'Solovev'
    'Vialov'
    'Volkov'
    'Writers'
    'Bednyi'
    'Brik'
    'Nina-Cheremnykh'
    'Kumach'
    'Levidova'
    'Marshak'
    'Mashistov'
    'Rublev'
    'Spasskii'
    'Zharov'
    'Poster-Search'
)

Three_Graces_pages=(
    'overview'
    'origins'
    'leisure'
    'not-mothers'
    'erotic'
    'photos'
    '1900'
    '1910'
    '1920'
    '1930'
    '1940'
    '1950'
    '1960'
    'selectedworks'
    'comments'
)

B_Encounters_pages=(
    'themes'
    'Disasters-War'
    'Brangwyn'
    'Imperial-Branding'
    'Cripples-Portfolio'
    'Wounded-Warriors'
    'Mystical-Images-War'
    'France'
    'Miseries-of-War'
    'artwork'
    'artwork/119385'
    'artwork/80831'
    'artwork/94607'
    'artwork/7962'
    'artwork/8051'
    'artwork/31034'
    'artwork/119383'
    'artwork/13563'
    'artwork/25342'
    'artwork/124886'
    'artwork/109935'
    'artwork/73307'
    'artwork/209598'
    'artwork/209605'
    'artwork/76328'
    'artwork/23112'
    'artwork/111315'
    'artwork/195665'
    'artwork/190400'
    'artwork/203795'
    'artwork/23686'
    'artwork/76084'
    'artwork/77107'
    'artwork/122388'
    'artwork/122378'
    'artwork/122381'
    'artwork/7955'
    'artwork/77057'
    'artwork/193898'
    'artwork/208173'
    'artwork/146403'
)

Harlequin_pages=(
    'artists'
    'Manet-Punch'
    'Degas-Harlequin'
    'Cezanne-Harlequin'
    'Cezanne-Study'
    'Picasso-Jester'
    'Picasso-Harlequin'
    'artwork'
    'artwork/139059'
    'artwork/47136'
    'artwork/88370'
    'artwork/207856'
    'artwork/51370'
    'artwork/20522'
    'artwork/159631'
)

Hyperlinks_pages=(
    'overview'
    'designers'
    'GantTee'
    'Heijdens'
    'Matsuda'
    'Meindertsma'
    'Pohflepp-Ginsberg'
    'Stamen'
    'Troika'
    'designers-projects'
    'artwork'
    'artwork/204456'
    'artwork/206748'
    'artwork/205055'
    'artwork/208170'
    'artwork/204509'
    'artwork/206755'
    'artwork/208169'
    'artwork/204519'
)

Marin_pages=(
    'overview'
    'themes'
    'return'
    'NewMexico'
    'NewYork'
    'StieglitzOKeeffe'
    'Maine'
    'CapeSplit'
    'framing'
    '1910s'
    '1920s'
    '1930s'
    '1940s'
    'artwork'
    'artwork/66327'
    'artwork/113430'
    'artwork/27977'
    'artwork/2911'
    'artwork/2902'
    'artwork/65955'
    'artwork/113432'
    'artwork/66356'
    'artwork/65963'
    'artwork/65987'
    'artwork/110856'
    'artwork/200812'
    'artwork/66007'
    'artwork/66011'
    'artwork/46323'
    'artwork/66108'
    'artwork/199870'
    'artwork/65958'
    'artwork/65972'
    'artwork/65975'
    'artwork/65996'
    'artwork/66002'
    'videos'
)

Arms_and_Armor_pages=(
    'overview'
    'themes'
    'fashion'
    'art'
    'harding'
    'artwork'
    'artwork/106377'
    'artwork/106279'
    'artwork/106311'
    'artwork/106282'
    'artwork/106286'
    'artwork/106197'
    'artwork/106201'
    'artwork/118551'
    'artwork/106195'
    'artwork/106300'
    'artwork/106290'
    'artwork/106505'
    'artwork/106508'
    'artwork/106510'
    'artwork/106511'
    'artwork/106512'
    'artwork/106513'
    'artwork/106518'
    'artwork/116363'
    'artwork/22278'
    'artwork/12791'
    'artwork/23366'
    'artwork/4066'
    'artwork/867'
    'artwork/110527'
    'resource/1247'
    'resource/1246'
    'map'
    'events'
)

Cartier_Bresson_pages=(
    'overview'
    'themes'
    'AfterWar'
    'OldWorlds'
    'NewWorlds'
    'Photo-Essays'
    'PortraitsBeauty'
    'Encounters'
    'Modern'
    'Prints'
    'artwork'
    'artwork/204985'
    'artwork/204677'
    'artwork/204744'
    'artwork/204880'
    'artwork/204704'
    'artwork/204697'
    'artwork/204715'
    'artwork/204936'
    'artwork/204951'
    'artwork/204759'
)

LouisSullivan_pages=(
    'overview'
    'themes'
    'Siskind'
    'Nickel'
    'GarrickTheater'
    'DrawingToCast'
    'artwork'
    'artwork/50913'
    'artwork/50916'
    'artwork/50919'
    'artwork/50922'
    'artwork/54599'
    'artwork/54612'
    'artwork/54620'
    'artwork/54624'
    'artwork/158526'
    'artwork/158529'
    'artwork/158530'
    'artwork/158533'
    'artwork/158591'
    'artwork/49113'
    'artwork/49116'
    'artwork/49120'
    'artwork/49127'
    'artwork/49128'
    'artwork/124556'
    'artwork/141957'
    'artwork/141970'
    'artwork/141973'
    'artwork/190648'
    'artwork/148031'
    'artwork/190647'
    'artwork/190991'
    'artwork/190972'
    'artwork/190974'
    'artwork/90689'
    'artwork/105696'
    'artwork/90695'
    'artwork/63151'
    'artwork/73543'
    'artwork/203556'
    'artwork/203555'
    'artwork/17435'
    'AdditionalResources'
)

VictPhotoColl_pages=(
    'overview'
    'exhbthemes'
    'womensociety'
    'making'
    'motifs'
    'rules'
    'MadameB'
    'MadameB1'
    'artwork'
    'artwork/201514'
    'artwork/201515'
    'artwork/198216'
    'artwork/198126'
    'artwork/201512'
    'artwork/201517'
    'artwork/201511'
    'artwork/198204'
    'artwork/201521'
    'artwork/198121'
    'artwork/185495'
)

Ways500_pages=(
    'overview'
    'exhibitions'
    'event'
    'events/6'
    'events/3'
    'events/5'
    'events/4'
    'events/8'
    'events/9'
    'events'
    'partners'
    'HubbardDance'
    'PoetryFoundation'
    'books'
    'resource/929'
    'artwork'
    'artwork/196430'
    'artwork/182416'
    'artwork/188845'
    'artwork/193334'
    'artwork/63817'
    'artwork/79307'
    'artwork/14591'
    'artwork/20684'
    'artwork/187528'
    'artwork/102131'
    'artwork/58135'
    'artwork/73795'
)

CaseWine_pages=(
    'overview'
    'exhibthemes'
    'viticulture'
    'religion'
    'secular'
    'motif'
    'pressing'
    'winestorage'
    'contemporary'
    'artwork'
    'artwork/177'
    'artwork/4281'
    'artwork/561'
    'artwork/147877'
    'artwork/84573'
    'artwork/63525'
    'artwork/51526'
    'artwork/25853'
    'artwork/198902'
    'artwork/197957'
    'artwork/198505'
    'artwork/150770'
    'artwork/100961'
    'artwork/117272'
    'artwork/15401'
    'artwork/87654'
    'artwork/118284'
    'artwork/30709'
    'artwork/43714'
    'artwork/51577'
    'artwork/62460'
    'artwork/79349'
    'artwork/2166'
    'artwork/49657'
    'artwork/99780'
    'artwork/132364'
    'artwork/117266'
    'artwork/157157'
    'artwork/145246'
    'artwork/181778'
    'selfguide'
    'glossary'
)

BeyondGoldenClouds_pages=(
    'overview'
    'exhibthemes'
    'screens_in_use'
    'poetryscreens'
    'beyondpaint'
    'tachi'
    'FrankLloyd'
    'artwork'
    'artwork/7634'
    'artwork/191638'
    'artwork/191643'
    'artwork/198874'
    'artwork/191659'
    'artwork/75068'
    'artwork/198916'
    'artwork/11272'
    'artwork/198899'
    'artwork/160015'
    'artwork/145673'
    'artwork/199843'
    'artwork/198906'
    'artwork/198908'
    'artwork/191644'
    'artwork/191661'
    'artwork/191646'
    'artwork/192018'
    'artwork/198910'
    'artwork/191662'
    'artwork/76645'
    'artwork/191647'
    'artwork/146559'
    'artwork/191599'
    'artwork/191598'
    'artwork/160016'
    'artwork/191664'
    'artwork/156474'
    'artwork/191650'
    'artwork/62558'
    'artwork/191665'
    'artwork/185359'
    'conservation'
    'tools'
    'pretreatment'
    'deconst'
    'core_recon'
    'resource/850'
    'reading'
    'getinvolved'
)

CyTwombly_pages=(
    'overview'
    'exhibthemes'
    'seascapes'
    'peony'
    'salalah'
    'artwork'
    'artwork/189901'
    'artwork/189902'
    'artwork/189904'
    'artwork/189905'
    'artwork/189906'
    'artwork/189907'
    'artwork/195823'
    'artwork/195821'
    'artwork/194399'
    'artwork/194401'
    'artwork/194398'
    'artwork/195825'
    'artwork/195826'
    'artwork/195827'
    'artwork/195828'
    'artwork/195829'
    'artwork/195830'
    'artwork/195831'
    'artwork/189949'
    'artwork/189965'
    'artwork/189960'
    'artwork/189957'
    'artwork/193339'
    'artwork/193347'
    'artwork/193520'
    'artwork/193522'
    'map'
)

Munch_pages=(
    'overview'
    'constructing'
    'isolation'
    'interior'
    'street'
    'anxiety'
    'femme_fatale'
    'nature'
    'artwork'
    'artwork/196591'
    'artwork/17251'
    'artwork/196567'
    'artwork/81539'
    'artwork/154235'
    'artwork/196625'
    'artwork/196574'
    'artwork/196570'
    'artwork/196645'
    'artwork/196583'
    'artwork/17229'
    'artwork/196573'
    'artwork/111372'
    'artwork/196653'
    'artwork/196590'
    'artwork/182202'
    'artwork/196582'
    'artwork/196601'
    'artwork/17213'
    'artwork/19204'
    'artwork/17235'
    'artwork/196613'
    'artwork/17255'
    'artwork/88396'
    'artwork/196581'
    'artwork/196587'
    'artwork/196616'
    'artwork/196577'
    'artwork/196624'
    'artwork/17343'
    'tools'
    'etching'
    'lithography'
    'woodcut'
    'chronology'
    'map'
    'readings'
)

divineart_pages=(
    'overview'
    'usefunctap'
    'tapcontext'
    'warrevolution'
    'industrialization'
    'tapdesign'
    'weavingstruc'
    'colortap'
    'tapAIC'
    'artwork'
    'artwork/6789'
    'artwork/6792'
    'artwork/111307'
    'artwork/25958'
    'artwork/58661'
    'artwork/73059'
    'artwork/18166'
    'artwork/65167'
    'artwork/78965'
    'artwork/40724'
    'artwork/147056'
    'artwork/49664'
    'artwork/14696'
    'artwork/189775'
    'artwork/75668'
    'artwork/139798'
    'artwork/96698'
    'artwork/49225'
    'artwork/49222'
    'artwork/49208'
    'artwork/78972'
    'artwork/8619'
    'artwork/80479'
    'artwork/79796'
    'artwork/76634'
    'map'
)

silkroad_pages=(
    'about'
    'Lessons'
    'resource/930'
    'resource/1527'
    'resource/1528'
    'resource/1530'
    'resource/1531'
    'resource/1532'
    'resource/1533'
    'resource/1534'
    'resource/1535'
    'resource/1536'
    'bibliography'
    'imagegal'
    'artwork'
    'artwork/69109'
    'artwork/74217'
    'artwork/40707'
    'artwork/147007'
    'artwork/34286'
    'artwork/27925'
    'artwork/10435'
    'artwork/35381'
    'artwork/49603'
    'artwork/147008'
    'artwork/86467'
    'artwork/80194'
    'artwork/86380'
    'credits'
)

v360degrees_pages=(
    'overview'
    'partners'
    'exhibitions'
    'events/6'
    'events/20'
    'events/5'
    'events/8'
    'symposia'
    'events'
    'video'
    'facebookapp'
    'artwork'
    'artwork/55906'
    'artwork/8027'
    'artwork/65709'
    'artwork/177'
    'artwork/88419'
    'artwork/87479'
)

benin_pages=(
    'overview'
    'exhibthemes'
    'oba'
    'warrior'
    'conflict'
    'palace'
    'court'
    'leopard'
    'royal'
    'rituals'
    'conquest'
    'kingdom'
    'map'
    '16thcentury'
    'artwork'
    'artwork/189874'
    'artwork/189829'
    'artwork/189881'
    'artwork/189068'
    'artwork/189073'
    'artwork/195413'
    'artwork/189085'
    'artwork/190162'
    'artwork/190664'
    'artwork/189474'
    'artwork/180750'
    'artwork/189860'
    'artwork/189865'
    'artwork/51809'
    'artwork/189884'
    'artwork/189883'
    'artwork/189491'
    'artwork/189885'
    'artwork/189045'
    'artwork/189503'
    'artwork/189108'
    'artwork/189103'
    'artwork/190110'
    'artwork/189111'
    'artwork/189037'
    'artwork/189036'
    'artwork/189051'
    'artwork/189042'
    'artwork/189476'
    'artwork/189105'
    'artwork/189475'
    'artwork/189061'
    'artwork/189029'
    'artwork/189823'
    'artwork/189851'
    'artwork/189830'
    'artwork/189074'
    'artwork/190179'
    'artwork/190979'
    'videos'
)

hopper_pages=(
    'overview'
    'exhibthemes'
    'earlywork'
    'gloucester'
    'maine'
    'thecity'
    'nighthawks'
    'capecod'
    'latework'
    'artwork'
    'artwork/36038'
    'artwork/193525'
    'artwork/193526'
    'artwork/193531'
    'artwork/193529'
    'artwork/193528'
    'artwork/193533'
    'artwork/111628'
    'artwork/193530'
    'artwork/193535'
    'artwork/193537'
    'addrsrcs'
    'chronology'
    'reading'
)

homer_exhb_pages=(
    'overview'
    'exhibthemes'
    'earlywatercolors'
    'england'
    'proutsneck'
    'adirondacks'
    'tropics'
    'resource'
    'resource/480'
    'resource/1094'
    'resource/664'
    'resource/641'
    'resource/577'
    'resource/607'
    'resource/606'
    'resource/608'
    'resource/605'
    'resource/603'
    'resource/610'
    'resource/579'
    'resource/604'
    'resource/599'
    'resource/600'
    'resource/598'
    'resource/624'
    'resource/626'
    'resource/625'
    'resource/1041'
    'resource/1526'
    'resource/585'
    'resource/589'
    'resource/609'
    'resource/85'
    'resource/1243'
    'resource/1870'
    'resource/260'
    'resource/315'
    'resource/109'
    'resource/169'
    'resource/586'
    'resource/19'
    'resource/26'
    'resource/584'
    'resource/151'
    'resource/1087'
    'resource/344'
    'resource/627'
    'resource/623'
    'resource/619'
    'resource/618'
    'resource/1381'
    'resource/614'
    'resource/615'
    'resource/1927'
    'artwork'
    'artwork/16840'
    'artwork/16788'
    'artwork/25865'
    'artwork/93433'
    'artwork/113100'
    'artwork/16823'
    'artwork/38666'
    'artwork/16776'
    'artwork/16794'
    'artwork/16831'
    'reading'
    'behindscenes'
)

homer_pages=(
    'behindscenes'
    'background'
    'about'
    'tools'
    'homerstools'
    'moderntools'
    'watercolor'
    'artwork'
    'artwork/45349'
    'artwork/183669'
    'artwork/189157'
    'artwork/16803'
    'artwork/16800'
    'artwork/16837'
    'artwork/113064'
    'artwork/16788'
    'artwork/16791'
    'artwork/16840'
    'artwork/16815'
    'artwork/16818'
    'artwork/93433'
    'artwork/16779'
    'artwork/16812'
    'artwork/16821'
    'artwork/16834'
    'artwork/14837'
    'artwork/16785'
    'artwork/16772'
    'artwork/16782'
    'artwork/16797'
    'artwork/113100'
    'artwork/16823'
    'artwork/99603'
    'artwork/183668'
    'artwork/38666'
    'artwork/16776'
    'artwork/16794'
    'artwork/16831'
    'artwork/189152'
    'map'
    'resource'
    'resource/480'
    'resource/664'
    'resource/641'
    'resource/570'
    'resource/565'
    'resource/580'
    'resource/592'
    'resource/577'
    'resource/607'
    'resource/606'
    'resource/608'
    'resource/605'
    'resource/591'
    'resource/574'
    'resource/582'
    'resource/603'
    'resource/597'
    'resource/583'
    'resource/610'
    'resource/601'
    'resource/567'
    'resource/579'
    'resource/581'
    'resource/604'
    'resource/599'
    'resource/600'
    'resource/566'
    'resource/588'
    'resource/573'
    'resource/594'
    'resource/578'
    'resource/587'
    'resource/598'
    'resource/593'
    'resource/624'
    'resource/626'
    'resource/625'
    'resource/1012'
    'resource/1526'
    'resource/585'
    'resource/589'
    'resource/644'
    'resource/575'
    'resource/609'
    'resource/602'
    'resource/109'
    'resource?page=1'
    'resource/595'
    'resource/586'
    'resource/26'
    'resource/584'
    'resource/627'
    'resource/590'
    'resource/638'
    'resource/639'
    'resource/572'
    'resource/622'
    'resource/623'
    'resource/620'
    'resource/619'
    'resource/621'
    'resource/618'
    'resource/1381'
    'resource/613'
    'resource/614'
    'resource/611'
    'resource/615'
    'glossary'
    'bibliography'
)

Kings_Queens_pages=(
    'overview'
    'themes'
    'France'
    'ChristianKing'
    'LoireValley'
    'DukesBourbon'
    'North'
    'DailyLife'
    'ParisArt'
    'Italy'
    'artwork'
    'artwork/208045'
    'artwork/16327'
    'artwork/208025'
    'artwork/208026'
    'artwork/208036'
    'artwork/6607'
    'artwork/208001'
    'artwork/205184'
    'artwork/207969'
    'artwork/205172'
    'artwork/207971'
    'artwork/208024'
    'artwork/22607'
    'artwork/71521'
    'artwork/184371'
    'artwork/16307'
    'artwork/16309'
    'artwork/16312'
    'artwork/16316'
    'artwork/25749'
    'artwork/183006'
    'artwork/25319'
    'artwork/193362'
    'Timeline'
    'Map'
)

Avant_Garde_pages=(
    'overview'
    'artists'
    'Klutsis'
    'Lissitzky'
    'Sutnar'
    'Teige'
    'Zwart'
    'artwork'
    'artwork/199409'
    'artwork/199261'
    'artwork/199186'
    'artwork/199245'
    'artwork/199474'
    'artwork/199176'
    'artwork/199171'
    'artwork/199416'
    'artwork/199107'
    'artwork/199109'
    'artwork/199219'
    'artwork/199420'
    'artwork/199136'
    'artwork/199098'
    'artwork/199292'
    'artwork/199210'
)

ApostlesBeauty_pages=(
    'overview'
    'exhibitionthemes'
    'japanism'
    'amerarts'
    'pictorialist'
    'chicagoreform'
    'prarieschool'
    'resource/931'
    'artwork'
    'artwork/38836'
    'artwork/16551'
    'artwork/47661'
    'artwork/74705'
    'artwork/104105'
    'artwork/197860'
    'artwork/186047'
    'artwork/191283'
    'artwork/121377'
    'artwork/185905'
    'artwork/191419'
    'artwork/193171'
    'artwork/66261'
    'artwork/66832'
    'artwork/66789'
    'artwork/195530'
    'artwork/185758'
    'artwork/193750'
    'artwork/47335'
    'artwork/36161'
    'artwork/190558'
)

Tagore_pages=(
    'overview'
    'early-works'
    'nature'
    'pictures'
    'faces'
    'artworks'
    'events'
)

modernwing_pages=(
    'overview'
    'public'
    'green'
    'architect'
    'amenities'
    'dining'
    'ryan'
    'families'
    'student_teachers'
    'selectedworks'
    'building'
    'tools'
    'books'
)

LightYears_pages=(
    'overview'
    'camera'
    'misunderstandings'
    'invisibility'
    'painting'
    'materials'
    'selectedworks'
)

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
    elif [ "$site" = "Modern" ] ; then
	pages=( "${Modern_pages[@]}" )
    elif [ "$site" = "Lichtenstein" ] ; then
	pages=( "${Lichtenstein_pages[@]}" )
    elif [ "$site" = "AfricanAmerican" ] ; then
	pages=( "${AfricanAmerican_pages[@]}" )
    elif [ "$site" = "IrvingPennArchives" ] ; then
	pages=( "${IrvingPennArchives_pages[@]}" )
    elif [ "$site" = "Fashioning-Object" ] ; then
	pages=( "${Fashioning_Object_pages[@]}" )
    elif [ "$site" = "Parcours" ] ; then
	pages=( "${Parcours_pages[@]}" )
    elif [ "$site" = "Rethink-Typologies" ] ; then
	pages=( "${Rethink_Typologies_pages[@]}" )
    elif [ "$site" = "ArtVisit" ] ; then
	pages=( "${ArtVisit_pages[@]}" )
    elif [ "$site" = "Matisse" ] ; then
	pages=( "${Matisse_pages[@]}" )
    elif [ "$site" = "Impressionism" ] ; then
	pages=( "${Impressionism_pages[@]}" )
    elif [ "$site" = "Indian" ] ; then
	pages=( "${Indian_pages[@]}" )
    elif [ "$site" = "African" ] ; then
	pages=( "${African_pages[@]}" )
    elif [ "$site" = "American" ] ; then
	pages=( "${American_pages[@]}" )
    elif [ "$site" = "Goldberg" ] ; then
	pages=( "${Goldberg_pages[@]}" )
    elif [ "$site" = "AncientIndian" ] ; then
	pages=( "${AncientIndian_pages[@]}" )
    elif [ "$site" = "Chinese" ] ; then
	pages=( "${Chinese_pages[@]}" )
    elif [ "$site" = "Renaissance" ] ; then
	pages=( "${Renaissance_pages[@]}" )
    elif [ "$site" = "Rococo" ] ; then
	pages=( "${Rococo_pages[@]}" )
    elif [ "$site" = "TASS" ] ; then
	pages=( "${TASS_pages[@]}" )
    elif [ "$site" = "Three-Graces" ] ; then
	pages=( "${Three_Graces_pages[@]}" )
    elif [ "$site" = "B-Encounters" ] ; then
	pages=( "${B_Encounters_pages[@]}" )
    elif [ "$site" = "Harlequin" ] ; then
	pages=( "${Harlequin_pages[@]}" )
    elif [ "$site" = "Hyperlinks" ] ; then
	pages=( "${Hyperlinks_pages[@]}" )
    elif [ "$site" = "Marin" ] ; then
	pages=( "${Marin_pages[@]}" )
    elif [ "$site" = "Arms-and-Armor" ] ; then
	pages=( "${Arms_and_Armor_pages[@]}" )
    elif [ "$site" = "Cartier-Bresson" ] ; then
	pages=( "${Cartier_Bresson_pages[@]}" )
    elif [ "$site" = "LouisSullivan" ] ; then
	pages=( "${LouisSullivan_pages[@]}" )
    elif [ "$site" = "VictPhotoColl" ] ; then
	pages=( "${VictPhotoColl_pages[@]}" )
    elif [ "$site" = "500Ways" ] ; then
	pages=( "${Ways500_pages[@]}" )
    elif [ "$site" = "CaseWine" ] ; then
	pages=( "${CaseWine_pages[@]}" )
    elif [ "$site" = "BeyondGoldenClouds" ] ; then
	pages=( "${BeyondGoldenClouds_pages[@]}" )
    elif [ "$site" = "CyTwombly" ] ; then
	pages=( "${CyTwombly_pages[@]}" )
    elif [ "$site" = "Munch" ] ; then
	pages=( "${Munch_pages[@]}" )
    elif [ "$site" = "divineart" ] ; then
	pages=( "${divineart_pages[@]}" )
    elif [ "$site" = "silkroad" ] ; then
	pages=( "${silkroad_pages[@]}" )
    elif [ "$site" = "360degrees" ] ; then
	pages=( "${v360degrees_pages[@]}" )
    elif [ "$site" = "benin" ] ; then
	pages=( "${benin_pages[@]}" )
    elif [ "$site" = "hopper" ] ; then
	pages=( "${hopper_pages[@]}" )
    elif [ "$site" = "homer_exhb" ] ; then
	pages=( "${homer_exhb_pages[@]}" )
    elif [ "$site" = "homer" ] ; then
	pages=( "${homer_pages[@]}" )
    elif [ "$site" = "Kings-Queens" ] ; then
	pages=( "${Kings_Queens_pages[@]}" )
    elif [ "$site" = "Avant-Garde" ] ; then
	pages=( "${Avant_Garde_pages[@]}" )
    elif [ "$site" = "ApostlesBeauty" ] ; then
	pages=( "${ApostlesBeauty_pages[@]}" )
    elif [ "$site" = "Tagore" ] ; then
	pages=( "${Tagore_pages[@]}" )
    elif [ "$site" = "modernwing" ] ; then
	pages=( "${modernwing_pages[@]}" )
    elif [ "$site" = "LightYears" ] ; then
	pages=( "${LightYears_pages[@]}" )
    fi
}

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
	       if [[ $page == *"/"* ]]; then
		   wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site/${page/\/*/\/} http://www.artic.edu/aic/collections/exhibitions/$site/$page
	       else
		   wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site/$page http://www.artic.edu/aic/collections/exhibitions/$site/$page

		   if [[ "$page" != "artwork" && "$page" != "artworks" && "$page" != "event" && "$page" != "events" && "$page" != "comments" && "$page" != "map" && "$page" != "tools" && "$page" != "resource" && "$page" != "resource?page=1" ]] ; then
		       ind=1
		       until [[ $(curl -s http://www.artic.edu/aic/collections/exhibitions/$site/$page/$ind | pcregrep -M "<div id=\"content\">(\n| )+<div id=\"content-content\" class=\"clear-block\">( )+</div>(\n| )+<\!-- /content-content -->(\n| )+</div>") ]]; do
			   wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site/$page http://www.artic.edu/aic/collections/exhibitions/$site/$page/$ind
			   let "ind++"
		       done
		   fi
	       fi

	   done

	   # For all the sub pages, wget links and images that are in Javascript objects
	   grep -roE "resource_link\":\"[\\\\\/a-zA-Z0-9-]+" * | cut -f3- -d\" | sed -E 's/\\\//\//g' | xargs -I % wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site http://www.artic.edu/%
	   grep -roE "resource_image_thumbnail\":\"[\\\\\/a-zA-Z0-9_\.:-]+" * | cut -f3- -d\" | sed -E 's/\\\//\//g' | xargs -I % wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site %
	   grep -roE "artwork_link\":\"[\\\\\/a-zA-Z0-9-]+" * | cut -f3- -d\" | sed -E 's/\\\//\//g' | xargs -I % wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site http://www.artic.edu/%
	   grep -roE "object_image_thumbnail\":\"[\\\\\/a-zA-Z0-9_\.:-]+" * | cut -f3- -d\" | sed -E 's/\\\//\//g' | xargs -I % wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site %
	   grep -roE "object_image_medium\":\"[\\\\\/a-zA-Z0-9_\.:-]+" * | cut -f3- -d\" | sed -E 's/\\\//\//g' | xargs -I % wget $WGET_PARAMS --directory-prefix=$OUTPUT/$site %

	   # Get large images
	   find . -name '*' -type f -depth 2 -exec grep -o "http:\/\/www.artic.edu\/aic\/collections\/citi\/images\/standard\/[a-zA-Z]*\/[a-zA-Z0-9_]*\/[0-9a-z_.]*" {} \; | xargs -I % wget --timestamping --directory-prefix=$OUTPUT/$site %

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
