# meg_headcast

The procedure for designing the initial 3D model of the scalp surface and aligning it 
with the coordinate system and the head localizer coils is implemented in `make_headcast.m`. 

The 3D model of the scalp surface is exported to MeshMixer, together with the dewar and a 
number of auxiliary shapes (coils, binoculars, earflaps). In MeshMixer these are put together 
and the dewar is "subtracted from the scalp model. The resulting model can be 3D printed. 

The 3D printed "positive" model is placed in the dewar. Polyurethane foam resin is poured between 
the model and the dewar to fill the gap, thereby creating the "negative" head cast. 

The `prepare_xxx.m` files are only included for reference, these were used to create 
the `.mat` files that are included here. 

