#!/bin/bash -x
mkdir -p data/static/hemem64/logs
mkdir -p data/static/hemem64/gups

rm data/static/hemem64/logs/*
rm data/static/hemem64/gups/*

./../run_perf.sh >/dev/null 2>&1 &
run_perf_pid=$!

RUN_DRAMSIZE=$((64*1024*1024*1024))
RUN_NVMSIZE=$((256*1024*1024*1024))

rm data/static/hemem64/gups/gups-isolated-setup.txt
sleep 1
nice -20 numactl -N0 -m0 --physcpubind=4-13 -- env HEMEM_MGR_START_CPU=0 PEBS_START_CPU=4 HEMEM_NUM_CORES=8 DRAMSIZE=$RUN_DRAMSIZE NVM_SIZE=$RUN_NVMSIZE DRAMOFFSET=0 NVMOFFSET=0 START_CPU=4 LD_PRELOAD=/home/amanda/hemem/src/libhemem.so ./gups-pebs 8 0 38 8 36 0 /tmp/gups-isolated.txt > data/static/hemem64/gups/gups-isolated-setup.txt &
gups_pid=$!
./../wait-gups.sh data/static/hemem64/gups/gups-isolated-setup.txt
sleep 30
sleep 200
kill -s USR2 $gups_pid
sleep 1
kill -9 ${gups_pid}
cp /tmp/log-$gups_pid.txt data/static/hemem64/logs/gups-isolated-log.txt
cp /tmp/gups-isolated.txt  data/static/hemem64/gups/isolated-gups.txt

sleep 5

rm data/static/hemem64/gups/bggups-setup.txt
rm data/static/hemem64/gups/gups-gups-setup.txt
sleep 1
nice -20 numactl -N0 -m0 --physcpubind=14-23 -- env HEMEM_MGR_START_CPU=2 PEBS_START_CPU=14 HEMEM_NUM_CORES=8 DRAMSIZE=$RUN_DRAMSIZE NVM_SIZE=$RUN_NVMSIZE DRAMOFFSET=$RUN_DRAMSIZE NVMOFFSET=$RUN_NVMSIZE START_CPU=14 LD_PRELOAD=/home/amanda/hemem/src/libhemem.so ./gups-pebs 8 0 38 8 36 0 data/static/hemem64/gups/bggups.txt > data/static/hemem64/gups/bggups-setup.txt &
bggups_pid=$!
perf stat -e instructions -I 1000 -p ${bggups_pid} -o data/static/hemem64/gups/bggups-ipc.txt &
./../wait-gups.sh data/static/hemem64/gups/bggups-setup.txt
nice -20 numactl -N0 -m0 --physcpubind=4-13 -- env HEMEM_MGR_START_CPU=0 PEBS_START_CPU=4 HEMEM_NUM_CORES=8 DRAMSIZE=$RUN_DRAMSIZE NVM_SIZE=$RUN_NVMSIZE DRAMOFFSET=0 NVMOFFSET=0 START_CPU=4  LD_PRELOAD=/home/amanda/hemem/src/libhemem.so ./gups-pebs 8 0 38 8 36 0 /tmp/gups-gups.txt > data/static/hemem64/gups/gups-gups-setup.txt &
gups_pid=$!
./../wait-gups.sh data/static/hemem64/gups/gups-gups-setup.txt
sleep 30
sleep 200
kill -s USR2 $gups_pid
sleep 1
kill -9 ${gups_pid}
kill -9 ${bggups_pid}
cp /tmp/log-$gups_pid.txt data/static/hemem64/logs/gups-gups-log.txt
cp /tmp/gups-gups.txt  data/static/hemem64/gups/gups-gups.txt

sleep 5

rm data/static/hemem64/gups/gapbs.txt
rm data/static/hemem64/gups/gups-gapbs-setup.txt
sleep 1
nice -20 numactl -N0 -m0 --physcpubind=14-23 -- env HEMEM_MGR_START_CPU=2 PEBS_START_CPU=14 HEMEM_NUM_CORES=8 DRAMSIZE=$RUN_DRAMSIZE NVM_SIZE=$RUN_NVMSIZE DRAMOFFSET=$RUN_DRAMSIZE NVMOFFSET=$RUN_NVMSIZE OMP_THREAD_LIMIT=8 LD_PRELOAD=/home/amanda/hemem/src/libhemem.so ./../apps/gapbs/bc -n 50 -g 29 > data/static/hemem64/gups/gapbs.txt &
gapbs_pid=$!
perf stat -e instructions -I 1000 -p ${gapbs_pid} -o data/static/hemem64/gups/gapbs-ipc.txt  &
./../wait-gapbs.sh data/static/hemem64/gups/gapbs.txt
nice -20 numactl -N0 -m0 --physcpubind=4-13 -- env HEMEM_MGR_START_CPU=0 PEBS_START_CPU=4 HEMEM_NUM_CORES=8 DRAMSIZE=$RUN_DRAMSIZE NVM_SIZE=$RUN_NVMSIZE DRAMOFFSET=0 NVMOFFSET=0 START_CPU=4 LD_PRELOAD=/home/amanda/hemem/src/libhemem.so ./gups-pebs 8 0 38 8 36 0 /tmp/gups-gapbs.txt > data/static/hemem64/gups/gups-gapbs-setup.txt &
gups_pid=$!
./../wait-gups.sh data/static/hemem64/gups/gups-gapbs-setup.txt
sleep 30
sleep 200
kill -s USR2 $gups_pid
sleep 1
kill -9 ${gups_pid}
kill -9 ${gapbs_pid}
cp /tmp/log-$gups_pid.txt data/static/hemem64/logs/gups-gapbs-log.txt
cp /tmp/gups-gapbs.txt  data/static/hemem64/gups/gapbs-gups.txt

sleep 5

rm data/static/hemem64/gups/bt.txt
rm data/static/hemem64/gups/gups-bt-setup.txt
sleep 1
nice -20 numactl -N0 -m0 --physcpubind=14-23 -- env HEMEM_MGR_START_CPU=2 PEBS_START_CPU=14 HEMEM_NUM_CORES=8 DRAMSIZE=$RUN_DRAMSIZE NVM_SIZE=$RUN_NVMSIZE DRAMOFFSET=$RUN_DRAMSIZE NVMOFFSET=$RUN_NVMSIZE OMP_THREAD_LIMIT=8 LD_PRELOAD=/home/amanda/hemem/src/libhemem.so ./../apps/nas-bt-c-benchmark/NPB-OMP/bin/bt.E -n 50 -g 28 > data/static/hemem64/gups/bt.txt &
bt_pid=$!
perf stat -e instructions -I 1000 -p ${bt_pid} -o data/static/hemem64/gups/bt-ipc.txt  &
./../wait-bt.sh data/static/hemem64/gups/bt.txt
nice -20 numactl -N0 -m0 --physcpubind=4-13 -- env HEMEM_MGR_START_CPU=0 PEBS_START_CPU=4 HEMEM_NUM_CORES=8 DRAMSIZE=$RUN_DRAMSIZE NVM_SIZE=$RUN_NVMSIZE DRAMOFFSET=0 NVMOFFSET=0 START_CPU=4 LD_PRELOAD=/home/amanda/hemem/src/libhemem.so ./gups-pebs 8 0 38 8 36 0 /tmp/gups-bt.txt > data/static/hemem64/gups/gups-bt-setup.txt &
gups_pid=$!
./../wait-gups.sh data/static/hemem64/gups/gups-bt-setup.txt
sleep 30
sleep 200
kill -s USR2 $gups_pid
sleep 1
kill -9 ${gups_pid}
kill -9 ${bt_pid}
cp /tmp/log-$gups_pid.txt data/static/hemem64/logs/gups-bt-log.txt
cp /tmp/gups-bt.txt  data/static/hemem64/gups/bt-gups.txt


#gnuplot data/miss-ratio-colocate.sh
#gnuplot data/gups-colocate.sh

kill -9 ${run_perf_pid}
pkill perf
