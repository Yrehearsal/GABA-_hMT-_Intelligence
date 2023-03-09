#!/bin/bash
#2019-02-15  lizhe
#$1 Dir
#$2 ID
#$3 VOI Center Coordinates

#######MT#########

Dir='/mnt/v_share/data/D007/MT/T1/'
ID='D007_mt'
Anat=${Dir}${ID}'.nii.gz'
voi_center=(-40.3 -13.2 -30.8) #MRS VOI center coordinates (mm) -L -P -F
voi_size=(20 20 20) #MRS VOI size (mm)
echo ${ID}>>log.txt
echo `date +"%Y-%m-%d %H:%M:%S"` begin >>log.txt

## coordinates range to index range
#get VOI coordinates range (mm)
for((i=0;i<3;i++))
do
lower[$i]=`echo ${voi_center[$i]}-${voi_size[$i]}*0.5 |bc`
upper[$i]=`echo ${voi_center[$i]}+${voi_size[$i]}*0.5 |bc`
done
#echo ${lower[*]}
#echo ${upper[*]}

#get qto_xyz information from header
x=$(fslhd ${Anat} | grep qto_xyz:1)
y=`fslhd ${Anat} | grep qto_xyz:2`
z=`fslhd ${Anat} | grep qto_xyz:3`

#substring
x=${x#*'1'}
y=${y#*'2'}
z=${z#*'3'}

#string to array
arr_x=($x)
arr_y=($y)
arr_z=($z)
origin=(${arr_x[3]} ${arr_y[3]} ${arr_z[3]})

#get voxel size and match LPF-xyz
xx=0
for((i=0;i<3;i++))
do
if [ ${arr_x[$i]} != "0.000000" ];then
  xx=$i
  voxel_size[0]=${arr_x[$i]}
  break
fi
done

yy=0
for((i=0;i<3;i++))
do
if [ ${arr_y[$i]} != "0.000000" ];then
  yy=$i
  voxel_size[1]=${arr_y[$i]}
  break
fi
done

zz=0
for((i=0;i<3;i++))
do
if [ ${arr_z[$i]} != "0.000000" ];then
  zz=$i
  voxel_size[2]=${arr_z[$i]}
  break
fi
done

#get VOI index range
for((i=0;i<3;i++))
do
index1=`echo "(${lower[$i]}- ${origin[$i]})/${voxel_size[$i]}" |bc`
index2=`echo "(${upper[$i]}- ${origin[$i]})/${voxel_size[$i]}" |bc`
if [ ${index1} -lt ${index2} ];then
  delta[$i]=$((${index2}-${index1}))
  min[$i]=${index1}
else
  delta[$i]=$((${index1}-${index2}))
  min[$i]=${index2}
fi
done

#in order "xmin xsize ymin ysize zmin zsize tmin tsize"
range[xx]=${min[0]}" "${delta[0]}
range[yy]=${min[1]}" "${delta[1]}
range[zz]=${min[2]}" "${delta[2]}
range[3]="0 1"
echo 'VOI index range:'${range[*]} 

#use fslmaths to generate VOI   
echo 'Generate VOI...'
fslmaths ${Anat} -mul 0 -add 1 -roi ${range[*]} ${Dir}${ID}-VOI -odt float
echo 'Done'
echo `date +"%Y-%m-%d %H:%M:%S"` Generate VOI Done >>log.txt

#Brain Extraction
echo 'Brain Extraction...'
/home/training/fsl/bin/bet ${Dir}${ID} ${Dir}${ID}'-brain' -f 0.20000000000000007 -g 0 -o
echo 'Done'
echo `date +"%Y-%m-%d %H:%M:%S"` Brain Extraction Done >>log.txt

#Segmentation
echo 'Segmentation...'
/home/training/fsl/bin/fast -t 1 -n 3 -H 0.1 -I 4 -l 20.0 -o ${Dir}${ID}'-brain' ${Dir}${ID}'-brain'
echo 'Done'
echo `date +"%Y-%m-%d %H:%M:%S"` Segmentation Done >>log.txt

#FSL_Calculate Fraction
echo 'Calculate Fration...'
fslstats ${Dir}${ID}'-brain_pve_0.nii.gz' -k ${Dir}${ID}'-VOI.nii.gz' -m >>${Dir}'log.txt'
fslstats ${Dir}${ID}'-brain_pve_1.nii.gz' -k ${Dir}${ID}'-VOI.nii.gz' -m >>${Dir}'log.txt'
fslstats ${Dir}${ID}'-brain_pve_2.nii.gz' -k ${Dir}${ID}'-VOI.nii.gz' -m >>${Dir}'log.txt'


