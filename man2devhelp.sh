#! /bin/bash

case "$1" in
    'install')
        if [[ ! -d "book" ]] ; then
            echo "Generate book first !!!" ;
            exit 1;
        fi
        sudo mkdir -p /usr/share/devhelp/books/unix-man
        sudo cp -r book/* /usr/share/devhelp/books/unix-man/
        
        exit 0;;

    'uninstall')
        sudo rm -rf /usr/share/devhelp/books/unix-man
        
        exit 0;;

    'clear')
        rm -rf book ;
        rm -f chapter-*.xml ;
        rm -f full-index.txt ;
        
        exit 0;;
        
    'generate')
        rm -rf book ;
        rm -f chapter-*.xml ;
        rm -f full-index.txt ;
    
        apropos --long . | sort -i > full-index.txt

        declare -A arSections ;
        arSections['1']='General commands (tools and utilities)' ;
        arSections['2']='System calls and error numbers' ;
        arSections['3']='Library functions' ;
        arSections['4']='Device drivers' ;
        arSections['5']='File formats' ;
        arSections['6']='Games' ;
        arSections['7']='Miscellaneous information' ;
        arSections['8']='System maintenance and operation commands' ;
        arSections['9']='Kernel internals' ;

        arSections['1P']='Perl commands (tools and utilities)' ;
        arSections['3P']='Perl Library functions' ;
        arSections['3PERL']='Perl Library functions' ;
        arSections['3PM']='Perl M Library functions' ;

        arSections['1SSL']='SSL commands (tools and utilities)' ;
        arSections['3SSL']='SSL Library functions' ;
        arSections['5SSL']='SSL File formats' ;
        arSections['7SSL']='SSL Miscellaneous information' ;
            

        mkdir -p book

        cat > book/index.html <<EOD 
<!DOCTYPE html> 
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Unix manual into Devhelp</title>
    </head>
    <body>
        <h1>Unix manual into Devhelp</h1>
    </body>
</html>  
EOD

        cat full-index.txt | while read sLine; do 
            #echo "$sLine"; 
            
            sCommand="${sLine%% (*}";
            sSection="${sLine#* (}";
            sSection="${sSection%%) *}";
            sSection="${sSection^^}" ;
            sDescription="${sLine##*- }";
            
            echo "Command : ${sCommand} - Section : ${sSection} - Description : ${sDescription}";
            
            sFileSection="book/index-${sSection}.html";
            sFileName="${sSection}/${sCommand}-${sSection}.html";
            
            mkdir -p "book/${sSection}"

            man -Hcat "${sSection}" "${sCommand}" > "book/${sFileName}" 2>/dev/null ;
            echo "      <sub name=\"${sCommand}\" link=\"${sFileName}\" />" >> "chapter-${sSection}.xml";
            
            if [[ ! -f "${sFileSection}" ]] ; then 
                cat > "${sFileSection}" <<EOD 
<!DOCTYPE html> 
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Section ${sSection} - ${arSections[$sSection]}</title>
    </head>
    <body>
        <h1>Section ${sSection} - ${arSections[$sSection]}</h1>
        <h2>list of documented command</h2>
        <dl> 
EOD
            fi
            
            echo "          <dt>${sCommand}</dt><dd>${sDescription}</dd>" >> "${sFileSection}" ;
        done

        cat > book/unix-man.devhelp2 <<EOD 
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<!DOCTYPE book PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "">
<book xmlns="http://www.devhelp.net/book" title="Unix Manuals" link="index.html" base="/usr/share/devhelp/books/unix-man" author="" name="unix-man" version="2" language="unix">
  <chapters>
EOD

        ls chapter-*.xml | while read sFile; do 
            sSection="${sFile%%.*}" ; 
            sSection="${sSection##*-}";
            sSection="${sSection^^}" ;
            
            echo "    <sub name=\"Section ${sSection}\" link=\"index-${sSection}.html\">" >> book/unix-man.devhelp2 ;
            cat $sFile >> book/unix-man.devhelp2 ;
            echo "    </sub>" >> book/unix-man.devhelp2 ;
            
            sFileSection="book/index-${sSection}.html";
            cat >> "${sFileSection}" <<EOD 
        </dl> 
    </body>
</html>
EOD
        done

        cat >> book/unix-man.devhelp2 <<EOD 
  </chapters>
</book>
EOD

        exit 0;;    
    *)
        echo "Usage $0 [clear|generate|install|uninstall]" ;
        exit 0;;
esac
    

