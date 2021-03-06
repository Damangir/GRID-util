GRID-util: Utility script for work with the N4U Grid
=======

Table of Content
-------

* [Introduction](#introduction)
* [Installation](#installation)
* [Manual](#manual)
  * [Copy files between user interface and storage element back and forth](#copy-files-tofrom-storage-element)
  * [Automatic jobfile creation](#create-a-job-file-automatically)
* [Copyright](#copyright)
* [License](#license)

Introduction
-------
Grid-util is a set of tool to facilitate working with the [N4U grid](https://neugrid4you.eu/) in the command-line mode.

**Grid-util is NOT endorsed by the [N4U Consortium](https://neugrid4you.eu/partners).**

Installation
-------
Download the package using `curl`
```bash
curl -O https://github.com/Damangir/GRID-util/archive/master.zip
```
or using `wget`
```bash
wget https://github.com/Damangir/GRID-util/archive/master.zip
```
Then decopmress the files.
```bash
unzip master.zip
```
If you have administrative right install using:
```bash
sudo su
. GRID-util-master/install.sh
```
otherwise use:
```bash
. GRID-util-master/install.sh
```
Now you can check installation by:
```bash
grid-copy.sh -h
```

If you install in admin mode and ever want to uninstall GRID-util you can do so by:
```bash
sudo su -
uninstall-GRID-util
```

Manual
-------
### Copy files to/from storage element

You can use `grid-copy.sh` to copy batch files between user interface and storage elemet back and forth.

```
usage: grid-copy.sh options

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
grid-copy.sh -l ~/MyShares/to-process -g $PANDORA_GRID_HOME/input -p "*.nii.gz" -u
```

After you process data, suppose the your output is in `$PANDORA_GRID_HOME/output` and is in `tar.bz` format. To bring them back to `~/MyShares/processed` you can use:
```bash
grid-copy.sh -g $PANDORA_GRID_HOME/output -l ~/MyShares/processed -p "*.tar.bz" -d
```
The `grid-copy.sh` will produce a file called `copy_fail`. If any copy failed you will be notified with a note like:
```
There is/are 1 failing(s) in the batch process. The failing processes are written in copy_fail_131122_175431.sh.                                                                                                                                        
You can re-run them using gridcopy.sh -f copy_fail_131122_175431.sh
```

As adviced in the note you can re-run failed copies using:
```bash
grid-copy.sh -f copy_fail_131122_175431.sh
```

The digits at the end the file name means its for the copying on 22 November 2013 17:54:31. If you have many `copy_fail` files, make sure you are using the one you intend to use.

### Create a job file automatically

You can use `grid-jobfile.sh` to create a [jobfile](https://neugrid4you.eu/group/science-gateway/knowledge-base/-/wiki/Main/Express+Lane) when you want to run jobs with `inputDir` located in the grid storage elements (`lfn:`).

```
usage: grid-jobfile.sh OPTIONS

Creates job file for files in a directory.

OPTIONS:
   -g      Grid directory  (in the grid)
   -p      Pattern for files to be added to jobfile (default *.nii.gz)
   -o      Output Jobfile (default only prints it)
   -r      Retry count on copy failure (default 5)
   
   -h      Show this message
```


Copyright
-------
Copyright (C) 2013 [Soheil Damangir](http://www.linkedin.com/in/soheildamangir) - All Rights Reserved

License
-------
[![Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License](https://raw.github.com/Damangir/GRID-util/master/licence.png "Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License")](http://creativecommons.org/licenses/by-nc-sa/3.0/)

GRID-util by [Soheil Damangir](http://www.linkedin.com/in/soheildamangir) is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-nc-sa/3.0/). To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/.


