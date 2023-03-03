#!/bin/bash
AA="$"
KK="$AA"KIT_PATH
PP="$AA"PATH
QQ="$AA"QE_BIN
BB="$AA"BGW_BIN
TT="$AA"tools_bin

export KIT_PATH=$PWD
export BGW_BIN=/share/opt/apps/BGW/3.0.1/2017/bin
export QE_BIN=/share/opt/apps/qe/7.1/2017/bin
export PYTHON_PATH=/share/opt/miniconda3/bin
pseudo_dir='/share/opt/apps/qe/pseudo_qe/dojo/sr'
pseudo_dir_soc='/share/opt/apps/qe/pseudo_qe/dojo/fr'

cat >./src/environment_variable<<!
#!/bin/bash
AA="$"
KK="$AA"KIT_PATH
PP="$AA"PATH
QQ="$AA"QE_BIN
BB="$AA"BGW_BIN
TT="$AA"tools_bin
##########In the following, you can set as default##############
export use_poscar=.True.                   #using POSCAR in format of VASP to get the cell file

##########You must set the following enivronmental varies ##############
module load compiler/intel/2017_up7 hdf5
export KIT_PATH=$PWD
export PATH=$PYTHON_PATH
export tools_bin=$PWD/bin
export BGW_BIN=$BGW_BIN
export QE_BIN=$QE_BIN

pseudo_dir=$pseudo_dir
pseudo_dir_soc=$pseudo_dir_soc
export PATH=/usr/bin:$PP
!

cat > ./src/compiler<<!
ulimit -s unlimited
ulimit -l unlimited
module load compiler/intel/2017_up7 hdf5
export MKL_DEBUG_CPU_TYPE=5
export MKL_CBWR=AVX2
export FI_PROVIDER=mlx
export I_MPI_PIN_DOMAIN=numa
export MPI_exe="mpirun --bind-to l3cache --map-by l3cache -genv I_MPI_FABRICS=shm:tcp -genv I_MPI_PIN_CELL=1 -genv KMP_AFFINITY verbose,granularity=fine,compact -bootstrap lsf"
!

cat > ./src/DFT <<!
export QE_BIN=$QE_BIN
PW_exe="$QQ/pw.x < in > ./report"
PW_exe_nk2="$QQ/pw.x -nk 2 -i in > ./report"
PW_exe_nk4="$QQ/pw.x -nk 4 -i in > ./report"
PW_exe_nk8="$QQ/pw.x -nk 8 -i in > ./report"
PW_exe_nk16="$QQ/pw.x -nk 16 -i in > ./report"
PW2BGW_exe="$QQ/pw2bgw.x -in ./pp.in &> ./report.pp"
PW2WAN_exe="$QQ/pw2wannier90.x "
WANNIER_exe=/share/opt/apps/wannier/3.1.0/2018/wannier90.x
!

cat > ./src/BGW_cplx <<!
export BGW_BIN=$BGW_BIN
EPSILON_EXEC="$BB/epsilon.cplx.x"
SIGMA_EXEC="$BB/sigma.cplx.x"
KERNEL="$BB/kernel.cplx.x"
ABSORPTION="$BB/absorption.cplx.x"
EQP_SCRIPT="$BB/eqp.py"
INTEQP_EXEC="$BB/inteqp.cplx.x"
SIG2WAN="$BB/sig2wan.x"
SUM_EV="$BB/summarize_eigenvectors.cplx.x"
!

cat > ./src/BGW_real <<!
export BGW_BIN=$BGW_BIN
EPSILON_EXEC="$BB/epsilon.real.x"
SIGMA_EXEC="$BB/sigma.real.x"
KERNEL="$BB/kernel.real.x"
ABSORPTION="$BB/absorption.real.x"
EQP_SCRIPT="$BB/eqp.py"
INTEQP_EXEC="$BB/inteqp.real.x"
SIG2WAN="$BB/sig2wan.x"
SUM_EV="$BB/summarize_eigenvectors.real.x"
!

cat >./bin/qe_bgw_prepare<<! 
#!/bin/bash
export KIT_PATH=$KIT_PATH
echo "################Started the prepartions##########"
cat $KK/src/environment_variable >prepare_qe_bgw.sh
cat input_qe_bgw >>prepare_qe_bgw.sh

cat $KK/src/DFT >>prepare_qe_bgw.sh
cat $KK/src/BGW_real >>prepare_qe_bgw.sh
cat $KK/src/BGW_cplx >>prepare_qe_bgw.sh

cat $KK/src/qe_main >>prepare_qe_bgw.sh
cat $KK/src/dft_job >>prepare_qe_bgw.sh

cat $KK/src/bgw_main >>prepare_qe_bgw.sh
cat $KK/src/bgw_job >>prepare_qe_bgw.sh

echo "#rm *prepare* " >>prepare_qe_bgw.sh

chmod +x prepare_qe_bgw.sh
./prepare_qe_bgw.sh all >log.qe_bgw.prepare

echo "################Finished##########"
echo "################See log.qe_bgw.prepare for details##########"
!
chmod +x ./bin/qe_bgw_prepare

cat >./bin/qe_prepare<<! 
#!/bin/bash
export KIT_PATH=$KIT_PATH
echo "################Started the prepartions##########"
cat $KK/src/environment_variable >prepare_qe.sh
cat input_qe_bgw >>prepare_qe.sh

cat $KK/src/DFT >>prepare_qe.sh

cat $KK/src/qe_main >>prepare_qe.sh
cat $KK/src/dft_job >>prepare_qe.sh

echo "#rm *prepare* " >>prepare_qe.sh

chmod +x prepare_qe.sh
./prepare_qe.sh all >log.qe.prepare
echo "################Finished##########"
echo "################See log.qe.prepare for details##########"
!
chmod +x ./bin/qe_prepare

cat >./bin/bgw_prepare<<! 
#!/bin/bash
export KIT_PATH=$KIT_PATH
echo "################Started the prepartions##########"
cat $KK/src/environment_variable >prepare_bgw.sh
cat input_qe_bgw >>prepare_bgw.sh

cat $KK/src/BGW_real >>prepare_bgw.sh
cat $KK/src/BGW_cplx >>prepare_bgw.sh

cat $KK/src/bgw_main >>prepare_bgw.sh
cat $KK/src/bgw_job >>prepare_bgw.sh

echo "#rm *prepare* " >>prepare_bgw.sh

chmod +x prepare_bgw.sh
./prepare_bgw.sh all >log.qe.prepare
echo "################Finished##########"
echo "################See log.bgw.prepare for details##########"
!
chmod +x ./bin/bgw_prepare


cd ./bin
chmod +x *
cd ../

echo "Plase add export PATH="$PWD/bin":"$AA"PATH to your local .bashrc file."
#echo "export PATH="$PWD/bin:"$AA"PATH"" >>~/.bashrc
#source ~/.bashrc
echo "Please check your ~/.bashrc ..."

echo "Finished."
