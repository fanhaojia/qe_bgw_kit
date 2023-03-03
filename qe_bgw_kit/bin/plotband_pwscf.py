#!/usr/bin/env python
#coding: utf-8

import numpy as np
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt

nk = 353
vbm = 18   #the band index of VBM

data = np.loadtxt('pwscf_band.dat')
nb = len(data) // nk
x= data[:nk,0]
energy= data[:,1].reshape((nb,nk))
print ('Energy to be shift:    ', np.amax(energy[vbm-1]))
energy-= np.amax(energy[vbm-1])

fb=open('./Band_new.dat','w')
fb=open('./Band_new.dat','a+')
for i in range(nb):
    for j in range(nk):
        lie=str(x[j])+'    '+str(energy[i][j])
        fb.writelines(lie)
        fb.write("\n")
    fb.writelines('  ')
    fb.write("\n")        
fb.close()
'''f=open('./pwscf_band.gnu','r')
lines=f.readlines()
print(lines[-2])
ll=lines[-2].split()
f.close()'''
for i in range(nb):
    p1, = plt.plot(x, energy[i], ls='-', color='black', lw=2, zorder=2)

def to_mathrm(s):
    return r'$\mathrm{%s}$'%(s)

pos = [0.00000,0.96993,1.52936,2.64989, 3.0]
plt.xticks(pos, map(to_mathrm,  [r'\Gamma', 'K', 'M', r'\Gamma', 'Z']))
for p in pos:
    plt.axvline(p, color='#cccccc', ls='--')
plt.axhline(0, color='#cccccc', ls='--',zorder=-10)
plt.xlim(x[0], x[-1])
plt.ylim(-4,4.0)
plt.yticks(fontsize =17)
plt.xticks(fontsize =17)
plt.tick_params(axis='y',direction='in')
#plt.legend([lmf, lqp], ['LDA', 'GW'], loc='lower right')
plt.ylabel('Energy (eV)',fontsize=20)
plt.savefig('BS.png',dpi=600)
#plt.show()




