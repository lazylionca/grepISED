#!/usr/bin/env sh

# Extracts useful info from ISED Application PDFs.
# Created Mar 9, 2022 - Roy
# updated Aug 1, 2023 - Roy

# requires pdfgrep
# https://pdfgrep.org/
# sudo apt-get install pdfgrep


# got filename?
if [ $# -eq 0 ]; then
    echo "no filename provided"
    exit 1
fi

# file exists?
if [ -f "$1" ]; then
	f=$1
else 
    echo "$1 not found"
	exit 1
fi

echo "Parsing $f"


# notes:
# sed -n '1 p'  extracts line 1
# sed -n '2 p'  extracts line 2
# xargs removes whitespace
# ${s1:45} removes the first 45 characters from var s1


# client name
e="Client Reference"
line=$(pdfgrep -i "$e" "$f")
cr=$( echo ${line:${#e}+1} | xargs)
t="ISED_$cr.txt"
echo "Target file: $t"
echo ISED Doc:  $f  >  $t
echo Link Name: $cr >> $t


e="Circuit length"
line=$(pdfgrep -i "$e" "$f" | xargs)
echo Link Distance: ${line:${#e}+1} >> $t


# Get the quantity of channel, we'll use this further down
e="Indicate the initial number of RF channels required"
l=$(pdfgrep -i "$e" "$f" | sed -n '1 p' | xargs)
ci=${l:${#e}+1} 
echo Channel Info: $ci >> $t
echo >>$t


e="Municipality and street address or site name"
s1=$(pdfgrep -i "$e" "$f" | sed -n '1 p' | xargs)
s2=$(pdfgrep -i "$e" "$f" | sed -n '2 p' | xargs)


e="Antenna diameter"
a1=$(pdfgrep -i "$e" "$f" | sed -n '1 p' | xargs)
a2=$(pdfgrep -i "$e" "$f" | sed -n '2 p' | xargs)


echo Station 1: ${s1:45} >>$t
echo Dish Size: ${a1:17} >>$t
echo >> $t


echo Station 2: ${s2:45} >>$t
echo Dish Size: ${a2:17} >>$t
echo >> $t


# If there is more than one channel, we need to get details for each, so we loop.
# I've never had more than two channels so I can't guarantee how this works.

# convert string to integer
# We found one typo in one pdf one time, so we adapt: on -=> one
c=$( cut -f 1 -d " " <<< $ci)
if [ $c == on ]; then n=1 ; fi
if [ $c == one ]; then n=1 ; fi
if [ $c == two ]; then n=2 ; fi
if [ $c == three ]; then n=3 ; fi
if [ $c == four ]; then n=4 ; fi
if [ $c == five ]; then n=5 ; fi
if [ $c == six ]; then n=6 ; fi
if [ $c == seven ]; then n=7 ; fi
if [ $c == eight ]; then n=8 ; fi
if [ $c == nine ]; then n=9 ; fi
if [ $c == ten ]; then n=10 ; fi


a=(
"Occupied Bandwidth"
"Unfaded Received Signal Level"
"Polarization"
)

for (( x=1; x<=$n; x++ ))
do  

	echo Channel $x: >>$t

	e="Lower Frequency \[MHz\]"
	l=$(pdfgrep -i "$e" "$f" | sed -n "$x p" | xargs)
	echo Lower Frequency: ${l:22} >>$t

	e="Upper Frequency \[MHz\]"
	l=$(pdfgrep -i "$e" "$f" | sed -n "$x p" | xargs)
	echo Upper Frequency: ${l:22} >>$t

	e="Station transmitting on the upper frequency"
	l=$(pdfgrep -i "$e" "$f" | sed -n "$x p" | xargs)
	
	txh="${l: -1}"
	#txh=${l:44}
	
	
	if [ "$txh" == "1" ]; then s="Station $txh - ${s1:45}" ; fi
	if [ "$txh" == "2" ]; then s="Station $txh - ${s2:45}" ; fi
	echo Tx High Site: $s >> $t

	for e in "${a[@]}"; do
		l=$(pdfgrep "$e" "$f" | sed -n "$x p" | xargs)
		echo $e: ${l:${#e}+1} >> $t
	done
	
done
# Thats all folks
