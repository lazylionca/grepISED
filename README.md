# grepISED
A bash script to extract information from Canadian ISED PDFs for Licensed PTP radios.

requires sh, ash, or bash or similar, so linux or mobaxterm
requires pdfgrep: https://pdfgrep.org/
    
    sudo apt-get install pdfgrep

or from whatever repository you use (I use ~~arch~~ manjaro, btw)


Installation:
Just download the file, move it to your working folder and make it executable:

    chmod a+r grepISED.sh

Then install pdfgrep.


Usage:

Install pdfgrep if you haven't.

Copy the ISED document and the script file to the same folder.

    sh grepISED ISED-numbers-00x.pdf


The script will output a text file with what I consider to be the important information needed to configure licensed radios.
