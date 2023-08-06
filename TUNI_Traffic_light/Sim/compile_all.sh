#
# Skripti kaantaa kaikki vhdl-tiedostot ja tekee niista makefilen
# Ymparistomuuttjat 
#	TMP_DIR 	kertoo mihin hakemistoon kaannetyt fiilut laitetaan.
#	

clear

if [ -z $TMP_DIR ]; then
    echo "Please set env variable TMP_DIR which tells where the codes are compiled to."
    echo "Use e.g. /share/tmp/<user_name>/traf_light_work"
    echo "EXiting script."
    exit 1
fi



# Poistetaan vanha codelib ja tehdaan ja mapataan uusi
echo "1/4 Removing old vhdl library and create new at "
echo $TMP_DIR; echo

mkdir -p $TMP_DIR
rm -rf $TMP_DIR/codelib
vlib $TMP_DIR/codelib
vmap work $TMP_DIR/codelib




echo; echo "2/4 Compiling vhdl codes"; echo

vcom -quiet -check_synthesis -pedanticerrors ../Vhd/traffic_light_pkg.vhd

vcom -quiet -check_synthesis -pedanticerrors ../Vhd/traffic_light_moore_2_noreg.vhd


vcom -quiet -check_synthesis -pedanticerrors ../Vhd/traffic_light_mealy_1_reg.vhd
vcom -quiet -check_synthesis -pedanticerrors ../Vhd/traffic_light_mealy_2a_noreg.vhd
vcom -quiet -check_synthesis -pedanticerrors ../Vhd/traffic_light_mealy_2b_noreg.vhd
vcom -quiet -check_synthesis -pedanticerrors ../Vhd/traffic_light_mealy_3_noreg.vhd


echo
echo


# Testipenkki
echo; echo "3/4 Compiling vhdl testbenches";echo
vcom -quiet ../Tb/tb_traffic_light.vhd



echo;echo "4/4 Creating a new makefile"
rm -f makefile.vhd
vmake $TMP_DIR/codelib > makefile.vhd

echo " --- Done---"
exit 0


