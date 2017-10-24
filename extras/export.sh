#!/bin/bash

# Extras Microsite Export
#
# Script to export all of the microsites we used to host on Racksapce to static sites. These were
# all created between 2012 and 2016 to promote museum exhibitions.
#
# Directory structure on `extras` for assests like images were distributed, and didn't always follow
# programmable conventions. Some folders of assets were copied over personally, and aren't reflected
# in this script.

OUTPUT='sites'
WGET_PARAMS="--page-requisites --convert-links --domains=artic.edu --no-host-directories --no-directories --timestamping " #  --adjust-extension --no-clobber --no-parent

# Array of sites to export
sites=(
    # 'http://extras.artic.edu/mcqueen'
    # 'http://extras.artic.edu/adjaye'
    # 'http://extras.artic.edu/armoryshow'
    # 'http://extras.artic.edu/holiday2016'
    # 'http://extras.artic.edu/holidaygreetings'
    # 'http://extras.artic.edu/picasso'
    # 'http://extras.artic.edu/studiogang'
    'http://extras.artic.edu/magritte/time-transfixed'
    # 'http://extras.artic.edu/artandappetite'
    # 'http://extras.artic.edu/impress-fashion'
    # 'http://extras.artic.edu/city-lost-found'
    # 'http://extras.artic.edu/art-throb'
    # 'http://extras.artic.edu/photography-is'
    # 'http://extras.artic.edu/van-gogh-bedrooms'
)

# Arrays of sub-pages for each microsite
mcqueen_pages=(
    'http://extras.artic.edufloor-plan.json'
    'http://extras.artic.edu/images/mcqueen/brochure-floor-plan2_700.jpg'
    'http://extras.artic.edu/images/mcqueen/brochure-floor-plan-overlay2_700.jpg'
    'http://extras.artic.edu/images/mcqueen/charlotte_2000.jpg'
)

adjaye_pages=(
    'http://extras.artic.edu/images/adjaye/Adjaye_DC-Facade_main_2000.jpg'
    'http://extras.artic.edu/images/adjaye/Adjaye_Peace-Center_main_2000.jpg'
    'http://extras.artic.edu/images/adjaye/Adjaye_Francis-A-Gregory-Library_main_2000.jpg'
    'http://extras.artic.edu/images/adjaye/Adjaye_Idea-Store-2_main_2000.jpg'
    'http://extras.artic.edu/images/adjaye/Adjaye_Skolkovo-Russia_main_2000.jpg'
    'http://extras.artic.edu/images/adjaye/DC_2000.jpg'
    'http://extras.artic.edu/images/adjaye/Adjaye_Portrait-2_main_2000.jpg'
    'http://extras.artic.edu/utility/calendar?url=http%3A%2F%2Fwww.artic.edu%2Fcalendar%3Fdate1%3D09-04-2015%26date2%3D09-04-2016%26keyword%3Dadjaye'
    'http://extras.artic.edu/images/adjaye/Adjaye_Smithsonian-NMAAHC_main_2000.jpg'

)

armoryshow_pages=(
    'http://extras.artic.edu/armoryshow/setting-the-stage'
    'http://extras.artic.edu/armoryshow/cast'
    'http://extras.artic.edu/armoryshow/show'
    'http://extras.artic.edu/armoryshow/program-notes'
    'http://extras.artic.edu/armoryshow/audience'
    'http://extras.artic.edu/armoryshow/finale'
    'http://extras.artic.edu/armoryshow/legacy'
    'http://extras.artic.edu/armoryshow/bibliography'
    'http://extras.artic.edu/armoryshow/credits'
    'http://extras.artic.edu/data/armoryshow/floor-plan.json'
    'http://extras.artic.edu/data/armoryshow/25-ne.json'
    'http://extras.artic.edu/data/armoryshow/25-sw.json'
    'http://extras.artic.edu/data/armoryshow/26.json'
    'http://extras.artic.edu/data/armoryshow/50-ne.json'
    'http://extras.artic.edu/data/armoryshow/50-sw.json'
    'http://extras.artic.edu/data/armoryshow/51.json'
    'http://extras.artic.edu/data/armoryshow/52-ne.json'
    'http://extras.artic.edu/data/armoryshow/52-se.json'
    'http://extras.artic.edu/data/armoryshow/53-ne.json'
    'http://extras.artic.edu/data/armoryshow/53-se.json'
    'http://extras.artic.edu/data/armoryshow/staircase-n.json'
    'http://extras.artic.edu/data/armoryshow/staircase-s.json'
    'http://extras.artic.edu/images/armoryshow/gallery-floor-plan_540.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery-floor-plan_540overlay.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery-floor-plan_540overlay.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery/25-ne_2000.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery/25-sw_2000.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery/25-sw-wave.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery/26_2000.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery/50-ne_2000.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery/50-sw_2000.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery/51_2000.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery/52-ne_2000.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery/52-se_2000.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery/53-ne_2000.jpg'
    'http://extras.artic.edu/images/armoryshow/gallery/53-se_2000.jpg'
    'http://extras.artic.edu/media/armoryshow/2015-Annual-Tax-Return_Form_990.pdf'
    'http://extras.artic.edu/media/armoryshow/catalogue-chicago.pdf'
    'http://extras.artic.edu/media/armoryshow/catalogue-of-original-drawings-by-picasso.pdf'
    'http://extras.artic.edu/media/armoryshow/cezanne.pdf'
    'http://extras.artic.edu/media/armoryshow/eddy-collection-1922.pdf'
    'http://extras.artic.edu/media/armoryshow/for-and-against.pdf'
    'http://extras.artic.edu/media/armoryshow/odilon-redon.pdf'
    'http://extras.artic.edu/media/armoryshow/sculptors-architecture.pdf'
    'http://extras.artic.edu/media/armoryshow/the-cubies.pdf'
    'http://extras.artic.edu/armoryshow/show/gallery/50-ne'
    'http://extras.artic.edu/armoryshow/show/gallery/50-sw'
    'http://extras.artic.edu/armoryshow/show/gallery/staircase-n'
    'http://extras.artic.edu/armoryshow/show/gallery/staircase-s'
    'http://extras.artic.edu/armoryshow/show/gallery/51'
    'http://extras.artic.edu/armoryshow/show/gallery/52-ne'
    'http://extras.artic.edu/armoryshow/show/gallery/52-se'
    'http://extras.artic.edu/armoryshow/show/gallery/53-ne'
    'http://extras.artic.edu/armoryshow/show/gallery/53-se'
    'http://extras.artic.edu/armoryshow/show/gallery/25-ne'
    'http://extras.artic.edu/armoryshow/show/gallery/25-sw'
    'http://extras.artic.edu/armoryshow/show/gallery/26'
)

holiday2016_pages=(
)

holidaygreetings_pages=(
)

picasso_pages=(
)

studiogang_pages=(
    'http://extras.artic.edu/images/studiogang/1-nature-lrg.jpeg'
    'http://extras.artic.edu/images/studiogang/2-density-lrg.jpeg'
    'http://extras.artic.edu/images/studiogang/3-community-lrg.jpeg'
    'http://extras.artic.edu/images/studiogang/4-performance-lrg.jpeg'
)

magritte_pages=(
    'http://extras.artic.edu/magritte/time-transfixed/text-only'
    'http://extras.artic.edu/magritte/time-transfixed/resources'
)

artandappetite_pages=(
    'http://extras.artic.edu/artandappetite/recipe/cooking-with-the-curator'
    'http://extras.artic.edu/artandappetite/recipe/sheepes-tongue-pie'
    'http://extras.artic.edu/artandappetite/recipe/maccaroni-pudding'
    'http://extras.artic.edu/artandappetite/recipe/potted-pigeons'
    'http://extras.artic.edu/artandappetite/recipe/spaghetti-alla-napolitana'
    'http://extras.artic.edu/artandappetite/recipe/jellied-chicken-loaf'
    'http://extras.artic.edu/artandappetite/recipe/lobster-thermidor'
    'http://extras.artic.edu/artandappetite/recipe/peter-coenen-baked-halibut-en-persillade'
    'http://extras.artic.edu/artandappetite/recipe/paul-kahan-lobster-thermidor-sausage'
    'http://extras.artic.edu/artandappetite/recipe/douglas-katz-chicken'
    'http://extras.artic.edu/artandappetite/recipe/douglas-katz-eggplant-reuben'
    'http://extras.artic.edu/artandappetite/recipe/bill-kim-tea-smoked-duck-breast'
    'http://extras.artic.edu/artandappetite/recipe/tony-cathy-mantuano-turkey'
    'http://extras.artic.edu/artandappetite/recipe/marcus-samuelsson-meatballs'
    'http://extras.artic.edu/artandappetite/recipe/pickled-cauliflowers-broccoli'
    'http://extras.artic.edu/artandappetite/recipe/succotash-a-la-tecumseh'
    'http://extras.artic.edu/artandappetite/recipe/oat-meal-peanut-bread'
    'http://extras.artic.edu/artandappetite/recipe/vegetable-hash'
    'http://extras.artic.edu/artandappetite/recipe/mushroom-cheese-biscuits'
    'http://extras.artic.edu/artandappetite/recipe/karyn-calabrese-veggie-potato-pot-pies'
    'http://extras.artic.edu/artandappetite/recipe/franco-diaz-turkey-and-chanterelles'
    'http://extras.artic.edu/artandappetite/recipe/graham-elliot-seafood-chowder'
    'http://extras.artic.edu/artandappetite/recipe/erik-freeberg-eggplant-caponata'
    'http://extras.artic.edu/artandappetite/recipe/jason-gorman-mushroom-cheese-biscuit'
    'http://extras.artic.edu/artandappetite/recipe/jason-gorman-sweet-corn-spoonbread'
    'http://extras.artic.edu/artandappetite/recipe/tim-graham-green-bean-casserole-dip'
    'http://extras.artic.edu/artandappetite/recipe/michael-kornick-maine-lobster'
    'http://extras.artic.edu/artandappetite/recipe/carrie-nahabedian-early-winter-blancmange'
    'http://extras.artic.edu/artandappetite/recipe/megan-neubeck-spicy-peanut-soup'
    'http://extras.artic.edu/artandappetite/recipe/yves-roubaud-oysters-rockefeller'
    'http://extras.artic.edu/artandappetite/recipe/marcus-samuelsson-chicken-nuggets'
    'http://extras.artic.edu/artandappetite/recipe/marcus-samuelsson-pear-pumpkin-salad'
    'http://extras.artic.edu/artandappetite/recipe/mark-steuer-cornbread-with-foie-gras'
    'http://extras.artic.edu/artandappetite/recipe/lee-wolen-molasses-cake'
    'http://extras.artic.edu/artandappetite/recipe/dough-nuts-a-yankee-cake'
    'http://extras.artic.edu/artandappetite/recipe/pumpkin-pie'
    'http://extras.artic.edu/artandappetite/recipe/molasses-cake'
    'http://extras.artic.edu/artandappetite/recipe/delicious-apple-pudding'
    'http://extras.artic.edu/artandappetite/recipe/tomato-soup-cake'
    'http://extras.artic.edu/artandappetite/recipe/paul-fehribach-persimmon-pudding-pie'
    'http://extras.artic.edu/artandappetite/recipe/christian-gaborit-pumpkin-cheesecake'
    'http://extras.artic.edu/artandappetite/recipe/meg-galus-chocolate-chunk-gingersnaps'
    'http://extras.artic.edu/artandappetite/recipe/meg-galus-sweet-potato-pudding-bonbons'
    'http://extras.artic.edu/artandappetite/recipe/andrew-johnson-apple-fritter'
    'http://extras.artic.edu/artandappetite/recipe/edward-kim-holiday-fruitcake-pie'
    'http://extras.artic.edu/artandappetite/recipe/eric-mansavage-fruitcake'
    'http://extras.artic.edu/artandappetite/recipe/heather-terhune-pumpkin-mousse-tart'
    'http://extras.artic.edu/artandappetite/recipe/joseph-rose-berthas-famous-brownie'
    'http://extras.artic.edu/artandappetite/recipe/syllabub'
    'http://extras.artic.edu/artandappetite/recipe/caudle-cup'
    'http://extras.artic.edu/artandappetite/recipe/baltimore-egg-nogg'
    'http://extras.artic.edu/artandappetite/recipe/bronx-cocktail'
    'http://extras.artic.edu/artandappetite/recipe/rob-roy-cocktail'
    'http://extras.artic.edu/artandappetite/recipe/brian-duncan-peach-and-cranberry-bellini'
    'http://extras.artic.edu/artandappetite/recipe/billy-helmkamp-autumn-sweater'
    'http://extras.artic.edu/artandappetite/recipe/eden-laurin-ginger-the-housekeeper'
    'http://extras.artic.edu/artandappetite/recipe/cory-morris-spanish-brandy'
    'http://extras.artic.edu/artandappetite/recipe/clint-rogers-gift-to-be-humble'
    'http://extras.artic.edu/artandappetite/recipe/adam-seger-homemade-ginger-beer'
    'http://extras.artic.edu/artandappetite/recipe/adam-seger-christopher-morley-cocktail'
    'http://extras.artic.edu/artandappetite/recipe/adam-seger-hot-rum-flip'
    'http://extras.artic.edu/artandappetite/chefs'
)

impress_fashion_pages=(
)

city_lost_found_pages=(
    'http://extras.artic.edu/city-lost-found/cities'
    'http://extras.artic.edu/city-lost-found/new-york'
    'http://extras.artic.edu/city-lost-found/chicago'
    'http://extras.artic.edu/city-lost-found/los-angeles'
    'http://extras.artic.edu/images/city_lost_found/chicago_1_2x.jpg'
)

art_throb_pages=(
    'http://extras.artic.edu/js/art_throb/quiz_models.json'
)

photography_is_pages=(
)

van_gogh_bedrooms_pages=(
    'http://extras.artic.edu/van-gogh-bedrooms/about-paintings'
    'http://extras.artic.edu/van-gogh-bedrooms/timeline'
    'http://extras.artic.edu/van-gogh-bedrooms/quiz'
    'http://extras.artic.edu/van-gogh-bedrooms/ask-vincent'
    'http://extras.artic.edu/van-gogh-bedrooms/videos'
    'http://extras.artic.edu/van-gogh-bedrooms/offers'
    'http://extras.artic.edu/van-gogh-bedrooms/about-paintings/chair'
    'http://extras.artic.edu/van-gogh-bedrooms/about-paintings/bed'
    'http://extras.artic.edu/van-gogh-bedrooms/about-paintings/window'
    'http://extras.artic.edu/van-gogh-bedrooms/about-paintings/floor'
    'http://extras.artic.edu/van-gogh-bedrooms/about-paintings/portraits'
    'http://extras.artic.edu/js/van_gogh/quiz-data.json'
)


# All variables in bash are global, so this method doesn't need to return anything.
# It just sets the value for `pages` that will be used in subsequent calls.
function set_pages_var()
{
    if [ "$site" = "mcqueen" ] ; then
	pages=( "${mcqueen_pages[@]}" )
    elif [ "$site" = "adjaye" ] ; then
	pages=( "${adjaye_pages[@]}" )
    elif [ "$site" = "armoryshow" ] ; then
	pages=( "${armoryshow_pages[@]}" )
    elif [ "$site" = "holiday2016" ] ; then
	pages=( "${holiday2016_pages[@]}" )
    elif [ "$site" = "holidaygreetings" ] ; then
	pages=( "${holidaygreetings_pages[@]}" )
    elif [ "$site" = "picasso" ] ; then
	pages=( "${picasso_pages[@]}" )
    elif [ "$site" = "studiogang" ] ; then
	pages=( "${studiogang_pages[@]}" )
    elif [ "$site" = "artandappetite" ] ; then
	pages=( "${artandappetite_pages[@]}" )
    elif [ "$site" = "impress-fashion" ] ; then
	pages=( "${impress_fashion_pages[@]}" )
    elif [ "$site" = "city-lost-found" ] ; then
	pages=( "${city_lost_found_pages[@]}" )
    elif [ "$site" = "art-throb" ] ; then
	pages=( "${art_throb_pages[@]}" )
    elif [ "$site" = "photography-is" ] ; then
	pages=( "${photography_is_pages[@]}" )
    elif [ "$site" = "van-gogh-bedrooms" ] ; then
	pages=( "${van_gogh_bedrooms_pages[@]}" )
    elif [ "$site" = "magritte/time-transfixed" ] ; then
	pages=( "${magritte_pages[@]}" )
    fi
}

for fullsiteurl in "${sites[@]}"
do
   : 
   site=${fullsiteurl:24}

   echo "Getting ${site}..."

   outputdir=${site}
   if [ $site = 'magritte/time-transfixed' ]; then
       outputdir='magritte'
   fi

   # Get index page
   wget $WGET_PARAMS --directory-prefix=$OUTPUT/$outputdir $fullsiteurl

   # Get all subpages
   set_pages_var

   for fullpageurl in "${pages[@]}"
   do
       :
       wget $WGET_PARAMS --directory-prefix=$OUTPUT/$outputdir $fullpageurl
   done

   cd $OUTPUT/$outputdir/
   if [ $outputdir = 'magritte' ]; then
       mv time-transfixed index.html
   else
       mv $site index.html
   fi

   # Clean up spaces
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E 's/&#32;/ /g' {} \;

   # Rereference Js and image references
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!http://extras.artic.edu!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/time-transfixed!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/data/$outputdir/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/media/$outputdir/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/images/city_lost_found/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/images/art_throb/content/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/images/art_throb/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/images/photography_is/artworks/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/images/photography_is/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/images/van_gogh/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/images/$outputdir/tiles/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/images/$outputdir/gallery/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/images/$outputdir/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/js/art_throb/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/js/van_gogh/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/js/$outputdir/!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/utility!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/recipe!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/show/gallery!!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!/js/openseadragon/images/!!g" {} \;

   # Clean up links
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!$outputdir#!#!g" {} \;
   LC_ALL=C find . -name '*' -type f -exec sed -i "" -E "s!$outputdir/about-paintings/!$outputdir/!g" {} \;

   # Clean up robots.txt
   rm robots.txt*

   cd ../../
done
