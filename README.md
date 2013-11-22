GRID-util: Utility script for work with the N4U Grid
=======

Manual
-------
### Copy files to/from storage element

You can use `gridcopy.sh` to copy batch files between user interface and storage elemet back and forth.

```
usage: gridcopy.sh options

Copies batch of files back and forth to the grid.

OPTIONS:
   -l      Local directory (in interface, e.g. ~/MyShares/n4u/to-process)
   -g      Grid directory  (in the grid)
   -p      Pattern for files to be copied (default *.nii.gz)

   -d      Download images from the GRID
   -u      Upload images to the GRID (default)
   -r      Retry count on copy failure (default 5)
   
   -f      Run from fail file generated with previous runs. This option will 
           supress all other options.
   
   -h      Show this message
```

For example in order to copy all `nii.gz` files from `~/MyShares/to-process` folder in user interface to `$PANDORA_GRID_HOME/input` storage element you can use:
```bash
gridcopy.sh -l ~/MyShares/to-process -g $PANDORA_GRID_HOME/input -p "*.nii.gz" -u
```

After you process data, suppose the your output is in `$PANDORA_GRID_HOME/output` and is in `tar.bz` format. To bring them back to `~/MyShares/processed` you can use:
```bash
gridcopy.sh -g $PANDORA_GRID_HOME/output -l ~/MyShares/processed -p "*.tar.bz" -d
```
The `gridcopy.sh` will produce a file called `copy_fail`. If any copy failed you will be notified with a note like:
```
There is/are 1 failing(s) in the batch process. The failing processes are written in copy_fail_131122_175431.sh.                                                                                                                                        
You can re-run them using gridcopy.sh -f copy_fail_131122_175431.sh
```

As adviced in the note you can re-run failed copies using:
```bash
gridcopy.sh -f copy_fail_131122_175431.sh
```

The digits at the end the file name means its for the copying on 22 November 2013 17:54:31. If you have many `copy_fail` files, make sure you are using the one you intend to use.

Copyright
-------
Copyright (C) 2013 Soheil Damangir - All Rights Reserved

Licence
-------
[![Creative Commons License](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png "Creative Commons License")](http://creativecommons.org/licenses/by-nc-nd/3.0/)

GRID-util by [Soheil Damangir](http://www.linkedin.com/in/soheildamangir) is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-nc-sa/3.0/). To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/.


