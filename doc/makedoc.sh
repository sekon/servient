#!/bin/sh

if [ ! -e servient.tex ]
then
	echo "Please run from inside the doc directory"
	exit
fi
rm -rf temp
mkdir temp
pdflatex -output-directory=temp/ servient.tex
pdflatex -output-directory=temp/ servient.tex
