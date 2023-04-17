#!/bin/bash

for file in install_paratec.sh  install.sh  readme.txt
do
dos2unix $file
done

for i in bin src
do
cd $i

for file in `ls *`
do
dos2unix $file 
done

cd ../
done

cd example
for i in BN_monolayer  GaAs  Zr2CO2  Zr2CO2_new
do
cd  $i
for file in `ls *`
do
dos2unix $file
done
cd ../
done 


