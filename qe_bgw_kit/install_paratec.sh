#!/bin/bash

AA="$"
KK="$AA"KIT_PATH
PP="$AA"PATH
QQ="$AA"DFT_BIN
BB="$AA"BGW_BIN
TT="$AA"tools_bin

export KIT_PATH=$PWD
export BGW_BIN=/share/opt/apps/BGW/1.0.4-2d-3p/bin
export DFT_BIN=/share/opt/apps/paratec_MKL_pz/bin
export PYTHON_PATH=/share/opt/miniconda3/bin
pseudo_dir=""'/home/jiafanhao/work/MXene/paratec/pot'""

cat >./src/environment_variable<<!
#!/bin/bash
AA="$"
KK="$AA"KIT_PATH
PP="$AA"PATH
QQ="$AA"DFT_BIN
BB="$AA"BGW_BIN
TT="$AA"tools_bin
##########In the following, you can set as default##############
export use_poscar=.True.                   #using POSCAR in format of VASP to get the cell file

##########You must set the following enivronmental varies ##############
module load compiler/intel/2017_up7
export KIT_PATH=$PWD
export tools_bin=$PWD/bin
export BGW_BIN=$BGW_BIN
export DFT_BIN=$DFT_BIN

pseudo_dir=$pseudo_dir
export PATH=/usr/bin:$PP
export PATH=$PYTHON_PATH:$PP
!

cat > ./src/compiler<<!
ulimit -s unlimited
ulimit -l unlimited
module load compiler/intel/2017_up7
export MKL_DEBUG_CPU_TYPE=5
export MKL_CBWR=AVX2
export FI_PROVIDER=mlx
export I_MPI_PIN_DOMAIN=numa
export MPI_exe="mpirun --bind-to l3cache --map-by l3cache -genv I_MPI_FABRICS=shm:tcp -genv I_MPI_PIN_CELL=1 -genv KMP_AFFINITY verbose,granularity=fine,compact -bootstrap lsf"
!

cat > ./src/paratec <<!
export PW_exe=/share/opt/apps/paratec_MKL_pz/bin/paratec.mpi
!

cat > ./src/BGW_cplx_1 <<!
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

cat > ./src/BGW_real_1 <<!
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

cat >./bin/paratec_prepare<<! 
#!/bin/bash
export KIT_PATH=$KIT_PATH
echo "################Started the prepartions##########"
cat $KK/src/environment_variable >prepare_paratec.sh
cat input_paratec_bgw >>prepare_paratec.sh

cat $KK/src/paratec >>prepare_paratec.sh

cat $KK/src/paratec_main >>prepare_paratec.sh
cat $KK/src/paratec_job >>prepare_paratec.sh

echo "rm *prepare* " >>prepare_paratec.sh

chmod +x prepare_paratec.sh
./prepare_paratec.sh all >log.paratec.prepare
echo "################Finished##########"
echo "################See log.paratec.prepare for details##########"
!
chmod +x ./bin/paratec_prepare

cat >./bin/bgw_prepare_paratec<<! 
#!/bin/bash
export KIT_PATH=$KIT_PATH
echo "################Started the prepartions##########"
cat $KK/src/environment_variable >prepare_bgw_paratec.sh
cat input_paratec_bgw >>prepare_bgw_paratec.sh

cat $KK/src/BGW_real_1 >>prepare_bgw_paratec.sh
cat $KK/src/BGW_cplx_1 >>prepare_bgw_paratec.sh

cat $KK/src/bgw_main_paratec >>prepare_bgw_paratec.sh
cat $KK/src/bgw_job_paratec >>prepare_bgw_paratec.sh

echo "rm *prepare* " >>prepare_bgw_paratec.sh

chmod +x prepare_bgw_paratec.sh
./prepare_bgw_paratec.sh all >log.bgw.paratec.prepare
echo "################Finished##########"
echo "################See log.bgw.paratec.prepare for details##########"
!
chmod +x ./bin/bgw_prepare_paratec
cd ./bin
chmod +x *
cd ../

echo "Plase add export PATH="$PWD/bin":"$AA"PATH to your local .bashrc file."
#echo "export PATH="$PWD/bin:"$AA"PATH"" >>~/.bashrc
#source ~/.bashrc
echo "Please check your ~/.bashrc ..."

echo "Finished."
