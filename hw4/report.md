# Task 1
```
root@10 vagrant]# zpool list
NAME     SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
test_1  1.88G   114K  1.87G        -         -     0%     0%  1.00x    ONLINE  -
test_2  1.88G   114K  1.87G        -         -     0%     0%  1.00x    ONLINE  -
test_3  1.88G   114K  1.87G        -         -     0%     0%  1.00x    ONLINE  -
test_4  1.88G   120K  1.87G        -         -     0%     0%  1.00x    ONLINE  -
test_5  3.75G   166K  3.75G        -         -     0%     0%  1.00x    ONLINE  -

[root@10 vagrant]# zfs get all | grep compression
test_1  compression           lzjb                   local
test_2  compression           lz4                    local
test_3  compression           gzip                   local
test_4  compression           zle                    local
test_5  compression           zstd-fast              local

[root@10 vagrant]# for i in {1..5}; do wget -P /test_$i https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.82.tar.xz; mkdir /test_$i/linux_kernel; tar -xf /test_$i/linux-5.10.82.tar.xz -C /test_$i/linux_kernel ; done

[root@10 vagrant]# ls -l /test_*
/test_1:
total 113811
-rw-r--r--. 1 root root 116458148 Nov 26 09:48 linux-5.10.82.tar.xz
drwxr-xr-x. 3 root root         3 Nov 27 15:09 linux_kernel

/test_2:
total 113802
-rw-r--r--. 1 root root 116458148 Nov 26 09:48 linux-5.10.82.tar.xz
drwxr-xr-x. 3 root root         3 Nov 27 15:10 linux_kernel

/test_3:
total 113801
-rw-r--r--. 1 root root 116458148 Nov 26 09:48 linux-5.10.82.tar.xz
drwxr-xr-x. 3 root root         3 Nov 27 15:10 linux_kernel

/test_4:
total 113802
-rw-r--r--. 1 root root 116458148 Nov 26 09:48 linux-5.10.82.tar.xz
drwxr-xr-x. 3 root root         3 Nov 27 15:12 linux_kernel

/test_5:
total 113802
-rw-r--r--. 1 root root 116458148 Nov 26 09:48 linux-5.10.82.tar.xz
drwxr-xr-x. 3 root root         3 Nov 27 15:12 linux_kernel


[root@10 vagrant]# zfs list
NAME     USED  AVAIL     REFER  MOUNTPOINT
test_1   550M  1.21G      550M  /test_1
test_2   493M  1.27G      493M  /test_2
test_3   365M  1.39G      365M  /test_3
test_4  1.05G   712M     1.05G  /test_4
test_5   434M  3.20G      434M  /test_5


[root@10 vagrant]# zfs get all | grep compressratio | grep -v ref
test_1  compressratio         2.14x                  -
test_2  compressratio         2.40x                  -
test_3  compressratio         3.28x                  -
test_4  compressratio         1.07x                  -
test_5  compressratio         2.74x                  -


test_3 = gzip-9  # WINNER
```
# Task 2
```
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg" -O zfs_task1.tar.gz && rm -rf /tmp/cookies.txt

tar -xzf zfs_task1.tar.gz 


[root@10 vagrant]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
 action: The pool can be imported using its name or numeric identifier, though
		some features will not be available without an explicit 'zpool upgrade'.
	 config:

	otus                                 ONLINE
	 mirror-0                           ONLINE
	   /home/vagrant/zpoolexport/filea  ONLINE
	   /home/vagrant/zpoolexport/fileb  ONLINE

zpool import -d zpoolexport/ otus

root@10 vagrant]# zpool status
  pool: otus
 state: ONLINE
status: Some supported features are not enabled on the pool. The pool can
	still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
	the pool may no longer be accessible by software that does not support
	the features. See zpool-features(5) for details.
config:

	NAME                                 STATE     READ WRITE CKSUM
	otus                                 ONLINE       0     0     0
	 mirror-0                           ONLINE       0     0     0
	   /home/vagrant/zpoolexport/filea  ONLINE       0     0     0
	   /home/vagrant/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

  pool: test_1
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	test_1      ONLINE       0     0     0
	 sdb       ONLINE       0     0     0

errors: No known data errors

  pool: test_2
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	test_2      ONLINE       0     0     0
	 sdc       ONLINE       0     0     0

errors: No known data errors

  pool: test_3
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	test_3      ONLINE       0     0     0
	 sdd       ONLINE       0     0     0

errors: No known data errors

  pool: test_4
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	test_4      ONLINE       0     0     0
	 sde       ONLINE       0     0     0

errors: No known data errors

  pool: test_5
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	test_5      ONLINE       0     0     0
	 sdf       ONLINE       0     0     0


[root@10 vagrant]# zfs get type otus
NAME  PROPERTY  VALUE       SOURCE
otus  type      filesystem  -
[root@10 vagrant]# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
[root@10 vagrant]# zfs get compression otus
NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local
[root@10 vagrant]# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     lo
```
# Task 3
```
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG" -O otus_task2.file && rm -rf /tmp/cookies.txt

zfs receive otus/test@today < otus_task2.file 

[root@10 vagrant]# cd /otus/test/
[root@10 test]# ls -la
total 2591
drwxr-xr-x. 3 root    root         11 May 15  2020 .
drwxr-xr-x. 4 root    root          4 Nov 27 16:18 ..
-rw-r--r--. 1 root    root          0 May 15  2020 10M.file
-rw-r--r--. 1 root    root     727040 May 15  2020 cinderella.tar
-rw-r--r--. 1 root    root         65 May 15  2020 for_examaple.txt
-rw-r--r--. 1 root    root          0 May 15  2020 homework4.txt
-rw-r--r--. 1 root    root     309987 May 15  2020 Limbo.txt
-rw-r--r--. 1 root    root     509836 May 15  2020 Moby_Dick.txt
drwxr-xr-x. 3 vagrant vagrant       4 Dec 18  2017 task1
-rw-r--r--. 1 root    root    1209374 May  6  2016 War_and_Peace.txt
-rw-r--r--. 1 root    root     398635 May 15  2020 world.sql

[root@10 file_mess]# find /otus/test/ -name "secret_message"
/otus/test/task1/file_mess/secret_message
[root@10 file_mess]# cat /otus/test/task1/file_mess/secret_message 
https://github.com/sindresorhus/awesome
```
