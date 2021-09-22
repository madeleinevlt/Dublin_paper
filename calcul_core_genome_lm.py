#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import glob
import numpy as np
import os, argparse, re
from dask import delayed,compute
import resource, sys
resource.setrlimit(resource.RLIMIT_STACK, (2**31,-1))
sys.setrecursionlimit(10**8)


def diff (a,b):
   return(sum(a != b))

def merge(a,b):
   return(a * b)

def readcov(file,x):
   with open(file, "r") as fillin :
     r=np.array(list((int(line.split()[2])>=x) for line in fillin), dtype=bool)
     if sum(r) < 4000000 :
        print("A SUPPR")
     print(file, str(sum(r)))
   return(r)

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--directory", action="store", required=True, dest="depth_dir",default="/global/scratch/m.desousaviolante/sca_dublin/iVarcall_DUBLIN_sans_conta/all_depth/*_depth",  help="directory containing depth file of all samples")
parser.add_argument("-r", "--reference_size", action="store", dest="ref_size", default=1, type=int, help="lenght of the reference genome in bp [default:%(default)d]")
parser.add_argument("-x", "--depth", action="store", dest="depth", default=30, type=int, help="minimum depth on any sample for a position to be kept in the core [default:%(default)d]")
params = parser.parse_args()


list_files=glob.glob(os.path.join(params.depth_dir,"*depth"))


core= np.ones(params.ref_size, dtype=bool)
reff= np.ones(params.ref_size, dtype=bool)
L = []
list_id=[]
for file in list_files :
    id=file.split("/")[-1].split("_")[0]
    list_id.append(id)
    pass_sample_positions = delayed(readcov)(file,params.depth) # np.array(list((int(line.split()[2])>=params.depth) for line in fillin), dtype=bool))
    print(pass_sample_positions)
    L.append(pass_sample_positions)
covertures=compute(L, scheduler='processes')[0]
u=[]
for i in covertures:
   tot=delayed(diff)(reff,i)
   u.append(tot)

for i in covertures:
   core=delayed(merge)(core,i)
results=compute(core,scheduler='processes')[0]
total_dec=compute(u,scheduler='processes')[0]
a=sum(results)
print("coregenome at "+str(params.depth)+"x in "+ str(len(list_id))+ " samples : " + str(a))
      
