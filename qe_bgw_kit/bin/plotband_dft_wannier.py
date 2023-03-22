#!/usr/bin/env python
#coding: utf-8

import numpy as np
import matplotlib as mpl
##mpl.use('Agg')
import matplotlib.pyplot as plt
import os

def to_mathrm(s):
    return r'$\mathrm{%s}$'%(s)

def plot_wannier_band(nk=219, vbm=20, ylims=[-8, 8], kticks=[0.00000, 1.11510, 1.75826, 3.04652], \
                      klabels=[r'\Gamma', 'M', 'K', r'\Gamma'], fname='pwscf_band.dat', shift=False, kscale=1.0):
    data = np.loadtxt(fname)
    n=len(data)
    nb = n // nk
    print ("There are ", nb, " bands in Wannier data.")
    x= data[:nk,0]*kscale
    energy= data[:,1].reshape(nb,nk)
    if shift is True:
        print ('Energy to be shift:    ', np.amax(energy[vbm-1]))
        energy-= np.amax(energy[vbm-1])
        
    if os.path.exists('./pwscf_band.gnu'):
        f=open('./pwscf_band.gnu','r')
        lines=f.readlines()
        print(lines[-2])
        ll=lines[-2].split()
        f.close()

    for i in range(nb):
        p1, = plt.plot(x, energy[i], ls='-', color='black', lw=2, zorder=2)
   
    plt.xticks(kticks, map(to_mathrm,  klabels))
    for p in kticks:
        plt.axvline(p, color='#cccccc', ls='--')
    plt.xlim(x[0], x[-1])
    plt.ylim(ylims[0],ylims[1])


def plot_dft_band(nk=121, vbm=20, ylims=[-8, 8], kticks=[0.00000, 0.5774, 0.9104, 1.5774], \
                  klabels=[r'\Gamma', 'M', 'K', r'\Gamma'], fname='band.dat.gnu', shift=False, kscale=1.0):
    data = np.loadtxt(fname)
    n=len(data)
    nb = n // nk
    print ("Reading", fname,", there are ", nb, " bands in DFT band data.")
    x= data[:,0]*kscale

    energy= data[:,1].reshape(nb,nk)
    print (np.amax(energy[vbm-1]), np.amin(energy[vbm]), '   ####energy gap:   ', np.amin(energy[vbm])-np.amax(energy[vbm-1]))
    if shift is True:
        print ('Energy to be shift:    ', np.amax(energy[vbm-1]))
        print ('Index of kpints of VBM: ', np.argmax(energy[vbm-1]))
        print ('Energy shift of VBM from G point: ', (np.amax(energy[vbm-1])-energy[vbm-1][0]))
        energy-= np.amax(energy[vbm-1])

    cb_vb_gap=[]
    for i in range(nk):
        cb_vb_gap.append(energy[vbm][i]-energy[vbm-1][i])
    print ('Min direct gap',cb_vb_gap[0], min(cb_vb_gap))
    print ('Index of min gap', cb_vb_gap.index(min(cb_vb_gap)))
    print ('Band Gap', min(energy[vbm])-max(energy[vbm-1]))
    
    ek=energy.reshape(-1, n)
    p_s = plt.scatter(x, ek, color='red', marker='o', s=5)
       
    plt.xlim(x[0], x[-1])
    plt.ylim(ylims[0],ylims[1])
    
    
fig, ax = plt.subplots(figsize=(6,6))

plot_wannier_band(nk=219, vbm=20, ylims=[-8, 8], kticks=[0.00000, 1.11510, 1.75826, 3.04652], \
                  klabels=[r'\Gamma', 'M', 'K', r'\Gamma'], fname='pwscf_band.dat', shift=True)
    
print ("###############################################################################################")

plot_dft_band(nk=121, vbm=20, ylims=[-8, 8], kticks=[0.00000, 0.5774, 0.9104, 1.5774], \
                      klabels=[r'\Gamma', 'M', 'K', r'\Gamma'], fname='band.dat.gnu', shift=True, kscale=3.04652/1.5774)

plt.axhline(0, color='#cccccc', ls='--',zorder=-10)
plt.yticks(fontsize =17)
plt.xticks(fontsize =17)
plt.tick_params(axis='y',direction='in')
#plt.legend([lmf, lqp], ['LDA', 'GW'], loc='lower right')
plt.ylabel('Energy (eV)',fontsize=20)
plt.savefig('QE_wannier_compare.png',dpi=600)
plt.show()




