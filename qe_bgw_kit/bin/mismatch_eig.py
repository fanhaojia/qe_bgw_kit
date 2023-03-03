#!/usr/bin/env python
#coding: utf-8

import numpy as np
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt

nb1=3      #the starting band index of sigma
nb=22      #the ending band index of sigma
nb_new=48  #the new band number

data = np.loadtxt('pwscf.eig_GW')
nk = len(data) // nb
new_len=nk*nb_new
print (nb, nk, nb_new,new_len)

data1 = np.loadtxt('pwscf.eig_DFT')


fb=open('./pwscf.eig','w')
fb=open('./pwscf.eig','a+')
for i in range(nk):
    for j in range(nb):
        n=i*nb+j
        if j<nb1-1:
            shift=data[nb1+i*nb-1][2]-data1[nb1+i*nb_new-1][2]
            egv="%.12f" % (float(data1[j+i*nb_new][2]+shift))
            lie='  '+str(int(data[n][0]))+'    '+str(int(data[n][1]))+'    '+str(egv)
            #print ('**  ', n,'   ', nb1+i*nb-1, '   ', nb1+i*nb_new-1, '    ', n+i*nb_new,'    ',data1[j+i*nb_new][2], shift,data1[j+i*nb_new][2]+shift)
            fb.writelines(lie)
            fb.write("\n") 
        else:
            #n=i*nb+j
            egv="%.12f" % (float(data[n][2]))
            lie='  '+str(int(data[n][0]))+'    '+str(int(data[n][1]))+'    '+str(egv)
            fb.writelines(lie)
            fb.write("\n")
            if j == nb-1:
                shift=data[n][2]-data1[n+i*(nb_new-nb)][2]
                #print (n, n+i*(nb_new-nb),'           ', shift)
                for l in range(nb+1, nb_new+1):
                    egv="%.12f" % (float(data1[l-1+i*nb_new][2]+shift))
                    lie='  '+str(l)+'    '+str(i+1)+'    '+str(egv)
                    #print ('**  ', l-1+i*nb_new, '   ',data1[l-1+i*nb_new][2])
                    fb.writelines(lie)
                    fb.write("\n") 
fb.close()
