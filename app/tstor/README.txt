---------------------------------------------------------------------------
tstor
---------------------------------------------------------------------------

Making and running tstor:

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
      ./simple/sim-zippy -enable_zippy ./app/tstor/tstor_zippy.ss

4) stop cosimulation

	Manually quit ModelSim via File->Quit

