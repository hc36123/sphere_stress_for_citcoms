#!/bin/bash



# Write stress tensor of each node at radius specified by 'radius' to file 'stress_tensor'
# Use sort and uniq to delete the duplicated lines.
# Note $1 = theta (i.e. colatitude), $2 = phi (i.e. longitude, 0~2pi).
file_prefix="$1/a.stress"
nproc=96
#radius="1 0.9965 0.993 0.9895 0.986 0.9825 0.979 0.9755 0.972 0.9685 0.965 0.95844"
#radius="1 0.99792 0.99583 0.99375 0.99167 0.98958 0.9875 0.98542 0.98333 0.98125 0.97917 0.97708 0.975 0.96944 0.96389 0.95833"
#radius="1 0.99529 0.99058 0.98587 0.98116 0.97645 0.96965 0.96285 0.95604"
radius="1 0.99686 0.99372 0.99058 0.98743 0.98429 0.98115 0.97801 0.97487 0.97173 0.96858 0.96544 0.9623"
step=2100

rm -f stress/*

for rad in $radius; do
    stress_tensor_file=stress_tensor.$step.$rad
    echo -n > $stress_tensor_file

    for i in `seq 1 $nproc`; do
	j=$(($i-1))
    	file_name=$file_prefix.$j.$step

    	awk -v rad=$rad \
	'NR > 2 && $3 == rad {print $1, $2, $4, $5, $6, $7, $8, $9}' \
	< $file_name >> $stress_tensor_file
    done

    awk '!seen[$1,$2]++' $stress_tensor_file > tmp && mv tmp $stress_tensor_file
    wc $stress_tensor_file
done



# Generate sampled points along the great circle from the center of supercontinent
# to a end point. Note the start (center_SC) and end points (end_points) are given
# in the format of 'longtitude/latitude(degree)' and the range of longitude should
# be [0, 360]. 
# After the output data have been written to $great_circle_file, the 1st and 2nd
# columes of the file have colatitides (radian) and longitudes (radian, 0~2pi) of
# sample points, respectively.
center_SC="-100/-60"

i=0
for end_point in `cat circum_supercontinent_points.d`; do
    i=$(($i + 1))
    great_circle_file=great_circle_points.$i
    project -C$center_SC -E$end_point -G50 -Dg -Q |
    awk -v rad=$rad \
	-v pi=3.141592653 \
	'{print (pi / 180.0) * (90 - $2),
		(pi / 180.0) * $1,
		($3 / 6371.0) * (180.0 / pi)
	 }' > $great_circle_file
done

mv stress_tensor* great_* stress
