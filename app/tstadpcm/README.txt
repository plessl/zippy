---------------------------------------------------------------------------
adpcm
---------------------------------------------------------------------------

Making and running adpcm

1) cd and make in toplevel directory (simzippy_co)

      cd simzippy_co
      make

2) start cosimulation environment

      cd cosim   
      ./runsim.sh &
   
   add signals of interest to ModelSim waveform viewer (optional)

   start cosimulation

      run -all  (in ModelSim command window)

3) run application

      cd simzippy_co
      ./simple/sim-zippy -enable_zippy ./app/tstor/tstadpcm_zippy.ss

4) stop cosimulation

	Manually quit ModelSim via File->Quit



run ADPCM on large array (without virtualization)

   ../../simple/sim-zippy -enable_zippy ./tstadpcm_zippy.ss

run ADPCM on SimpleScalar only

   ../../simple/sim-zippy ./tstadpcm_zippy_noarray.ss

