#****************************************************************************
#* axi4_bfms_env.sh
#*
#* Environment setup script for axi4_bfms
#****************************************************************************


etc_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd)"
rootdir=`cd $etc_dir/.. ; pwd`


export AXI4_BFMS=${rootdir}

# Add a path to the simscripts directory
export PATH=$rootdir/packages/simscripts/bin:$PATH

# Force the PACKAGES_DIR
export PACKAGES_DIR=$rootdir/packages
