export LD_LIBRARY_PATH=../src:../Hoard/src:$LD_LIBRARY_PATH
echo 1000000 > /proc/sys/vm/max_map_count

thds=16
upds=1000000000
obj_size=8
iters=3

dramsize=$((128*1024*1024*1024))
nvmsize=$((512*1024*1024*1024))
working_set="30 31 32 33 34 35 36 37 38"

res=./results
prefix=random

mkdir -p ${res}

echo "" > ${res}/${prefix}_single.txt
echo "" > ${res}/${prefix}_double1.txt
echo "" > ${res}/${prefix}_double2.txt

for size in ${working_set}; do
    echo "=== ${size} ===" >> ${res}/${prefix}_single.txt
    echo "=== ${size} ===" >> ${res}/${prefix}_double1.txt
    echo "=== ${size} ===" >> ${res}/${prefix}_double2.txt
    for ((i = 0; i < ${iters}; ++i )); do 
        NVMSIZE=${nvmsize} DRAMSIZE=${dramsize} NVMOFFSET=0 DRAMOFFSET=0 \
            numactl -N0 -m0 -- ./gups-random ${thds} ${upds} ${size} ${obj_size} ${size} >> ${res}/${prefix}_single.txt;
        
        size2=$((${size}-1));
        thds2=$((${thds}/2));

        NVMSIZE=$((${nvmsize}/2)) DRAMSIZE=$((${dramsize}/2)) NVMOFFSET=0 DRAMOFFSET=0 \
            numactl -N0 -m0 -- ./gups-random ${thds2} ${upds} ${size2} ${obj_size} ${size2} >> ${res}/${prefix}_double1.txt &
        NVMSIZE=$((${nvmsize}/2)) DRAMSIZE=$((${dramsize}/2)) NVMOFFSET=$((${nvmsize}/2)) DRAMOFFSET=$((${dramsize}/2)) \
            numactl -N0 -m0 -- ./gups-random ${thds2} ${upds} ${size2} ${obj_size} ${size2} >> ${res}/${prefix}_double2.txt;
        wait;
    done
done