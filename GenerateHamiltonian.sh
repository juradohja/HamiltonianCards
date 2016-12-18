#!/bin/bash
cd /home/sejo/processing-3.2.2
path="/home/sejo/Dropbox/Escenaconsejo/Processing/sketchbook/git/HamiltonianCards/results/"
echo $path
for a in 01 02 03
do
	for f in 2017 Cup Heart2017 HiSmile Hope IHeartITP Love SmileITP snowman Star Tree
	do 
		./processing-java --sketch=/home/sejo/Dropbox/Escenaconsejo/Processing/sketchbook/git/HamiltonianCards --run --design $f.txt --path $a.txt;

		mv -v $path"result.pdf" $path$a"_"$f".pdf";
	done
done
