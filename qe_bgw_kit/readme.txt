##Fanhao Jia v3##
This is a shell script, which is used to automatically create QE-BerkelyGW input files.
It requires input files: input_qe_bgw and POSCAR (see examples)
It can generate DFT dirs: 01scf, 02wfn, 03wfnq, 04wfn_co, 05wfn_fi, 06wfnq_fi, 07wannier, 08bands and 00kgrids (this folder also contains a lot of intermediate output information)
It can generate BGW dirs: eps eps_bse sigma kernel bse intep intep_wannier

poscar_qe                           ! transfer POSCAR to QE format
get_eqp_co_from_pwscf_xml.py        ! get fake eqp_co.dat from the pwscf.xml of 04wfn_co files, you should define kpoints, cbm_shift, vbm_shift 
plotband_pwscf.py                   ! polt pwscf band structure
mismatch_eig.py                     ! match the mismatch between pwscf_DFTGW.eig  and pwscf_GW.eig 
*note 
./qe_bgw_kit/bin/kmesh.pl is modified, its origin version is from the wannier90 package.

######################INSTALLATION################################
You need modify all the environment variables in the install.sh, and some of the PBS header in ./src/PBE*

@cluster: chmod +x install.sh
@cluster: ./install.sh
@cluster: echo "export PATH="$PWD/bin:$PATH"" >>~/.bashrc
@cluster: source ~/.bashrc

######################to lear how to run the shell script, please:################################
@cluster: cd example
@cluster: cd BN_monolayer

@cluster: qe_bgw_prepare    !prepare QE and BGW inputs
or 
@cluster: qe_prepare        !only prepare QE inputs
or 
@cluster: bgw_prepare       !only prepare BGW inputs, need do qe_prepare firstly.


这是一个shell脚本， 它用于自动创建QE-BerkelyGW的输入文件。
它需要输入文件： input_qe_bgw  和 POSCAR
