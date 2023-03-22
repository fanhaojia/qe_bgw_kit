#!/usr/bin/env python
#coding: utf-8

import numpy as np
import linecache
import xml.etree.ElementTree as ET 

def split_line_int(line):
    out=[]
    wlist=line.split(' ')
    for word in wlist:
        if len(word)>0 and word != ' ' :
            if word[-1]== '\n':
                if len(word[:-1])>0 and word[:-1]!='':
                    out.append(int(word[:-1]))
            else:
                out.append(int(word))
    return out

def split_line_float(line):
    out=[]
    wlist=line.split(' ')
    for word in wlist:
        if len(word)>0 and word != ' ' :
            if word[-1]== '\n':
                if len(word[:-1])>0 and word[:-1]!='':
                    out.append(float(word[:-1]))
            else:
                out.append(float(word))
    return np.array(out) 

def read_points(file):
    nk = split_line_int(linecache.getline(file, 2))[0]
    kpt=[]
    for i in range(nk):
        kline=linecache.getline(file, i+3)
        kpt.append(split_line_float(kline))
    return kpt

################################################Mian#############################################
inf='pwscf.xml'

tree = ET.parse(inf)
root = tree.getroot()
tot_nb=int(root[3][10][13][2].attrib['size'])
nk=int(root[3][10][11].text)


band_start=1                #defalut is 1 
band_end=tot_nb             #default is tot_nb
spin=0                      #0 is spin unpolarized, 1 or 2 is spin-polarized
nb=band_end-band_start+1
vbm_shift=0.906001624               #ks[vb]+vbm_shift
cbm_shift=2.582777876               #ks[vb]+cbm_shift
vbm=40                              #vbm band index 

if spin >0:
    spin_list1=[1 for i in range (tot_nb)]
    spin_list2=[2 for i in range (tot_nb)]
    band1=[i for i in range(tot_nb)]
    band2=[i for i in range(tot_nb)]
    ns=2
else:
    spin_list=[1 for i in range (tot_nb)]
    band=[i for i in range(1, tot_nb+1)]
    ns=1
    
kpt_pw=[];ks=[]
for ks_energy in tree.iter(tag='ks_energies'):
    line=ks_energy[0].text
    kp=line.split(' ')
    k=[]
    for j in range(3):
        k.append(eval(kp[j]))
    kpt_pw.append(k)
    
    line=ks_energy[2].text
    en=split_line_float(line)
    en_=en*27.2114079527
    ks.append(list(en_))

kpt=read_points('kpoints')    

fb=open('eqp_co.dat_new','w')
fb=open('eqp_co.dat_new','a+')


for ik in range(nk):
    #kline=' \n'
    kline = '%13.9f%13.9f%13.9f%8i\n' % (kpt[ik][0], kpt[ik][1], kpt[ik][2], ns*nb)
    fb.writelines(kline) 
    ib=0
    for j in range(nb):
        ib=ib+1
        if ib >=band_start and ib <=vbm:
            #print (ik, ib)
            bline = '%8i%8i%15.9f%15.9f\n' % (spin_list[ib-1], band[ib-1], ks[ik][ib-1], ks[ik][ib-1]+vbm_shift)
            fb.writelines(bline)
        elif ib >vbm  and ib <=band_end:
            bline = '%8i%8i%15.9f%15.9f\n' % (spin_list[ib-1], band[ib-1], ks[ik][ib-1], ks[ik][ib-1]+cbm_shift)
            fb.writelines(bline)
        else:
            bline = '%8i%8i%15.9f%15.9f\n' % (spin_list[ib-1], band[ib-1], ks[ik][ib-1], ks[ik][ib-1])
            fb.writelines(bline)
            
fb.close()
    
