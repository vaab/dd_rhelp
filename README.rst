What is ``dd_rhelp`` ?
----------------------

``dd_rhelp`` is a bash script that handles a very usefull program written in C
by Kurt Garloff which is called ``dd_rescue``, it roughly act as the ``dd``
linux command with the caracteristic to NOT stop when it falls on read/write
errors.

This makes ``dd_rescue`` the best tool for recovering hard drive having bad
sectors. (``dd_rescue`` can be found here:
http://www.garloff.de/kurt/linux/ddrescue )

But using it is quite time consuming. This is where ``dd_rhelp`` come to help.

In short, ``dd_rhelp`` will use ``dd_rescue`` on your entire disc, BUT it will
try to gather the maximum valid data before trying for ages on bunches of
badsectors. So if you leave ``dd_rhelp`` work for infinite time, it'll have the
same effect as a simple ``dd_rescue``. But because you might not have this
infinite time (this could indeed take really long in some cases... ),
``dd_rhelp`` will jump over bad sectors whenever it encounters too much in a
row. In the long run, it'll parse all your device with ``dd_rescue``.

You can Ctrl-C it whenever you want, and rerun-it at will, it'll resume it's
job as it depends on the log files ``dd_rescue`` creates.

In addition, progress will be shown in a ASCII picture of your device beeing
rescued.

As stated by Kurt Garloff for his ``dd_rescue`` program: "Just one note: It
does work. I unfortunately did not just create this program for fun ..."

``dd_rhelp`` goes the same as it has saved me YEARS on my hard drive.

Important note
--------------

For some times, ``dd_rhelp`` was the only tool (AFAIK) that did this type of
job, but since a few years, it is not true anymore: Antonio Diaz did write a
ideal replacement for my tool: GNU 'ddrescue'.

Yes, this is not very clever to have called a tool the same name that
``dd_rescue`` from Kurt Garloff (catch the subtle difference between 'ddrescue'
and ``dd_rescue`` ?), but it seems that it was done by intent as we warned
Antonio Diaz from the fact it would probably mess users in this tiny world of
hard drive recovery tools.

Nevertheless, I really encourage you to use this replacement tool if it works
for you (and it should be the case). Why ? Understand first what we are
comparing:

  - ``dd_rhelp`` (in dirty bash script) + ``dd_rescue`` (in C) in one hand
  - ddrescue (in C) in the other.

``dd_rhelp`` was meant as a quick hack to implement what ``dd_rescue`` didn't
do, and what couldn't be done at that time (AFAIK).

It could be some cases where ddrescue won't work, and this is the major reason
why I keep maintaining ``dd_rhelp``. It is important to tell me and Antonio Diaz
when these cases occur.

Now that you are enlightened, you are free to use ``dd_rhelp``.

Why do people want to use ``dd_rhelp`` ?
----------------------------------------

Well, you do not WANT to use ``dd_rhelp``. I hope you'll never HAVE TO use it.

Basically, if you have bad sector corrupting your filesystem you'll have
several solutions depending on the filesystem itslef, the partition table, and
what remains accessible...

In some recovering process, as a first stage, you'll need to secure all the
remaining data of your disk (or partition) in a file or partition on a
healthier device.  Often, next operation is to fsck.* your recovered data to
rebuild the damaged filesystem information. Whith chance, you will be able to
mount the result and access files. These could then be in various states
depending of how they have been affected by the damages. Possible file states
are ranging from completely recovered without any further work, to lost,
damaged, scrambled, and often anonymously collected in your filesystem
lost+found directory...

``dd_rhelp`` and ``dd_rescue`` are meant to be in the very first phase only:
securing your remaining data into a another file.

``dd_rescue`` which has been created by Kurt Garloff, is a great program. And
could already help you without ``dd_rhelp``. But in some case, like disks
cluttered with bad sectors, it can be time consuming to use for 2 main reasons:

  1. it does straight recovery, and thus can spend months making it's path in a
  solid bunch of bad sectors before rescuing hole portions of perfectly sain
  data hidden just after.

  2. if you decide to manoeuver ``dd_rescue`` to stop him when he's bumping in
  large sequences of bad sectors and try to start it from spots to spots in
  normal or reverse direction (as ``dd_rescue`` options allows this), then this
  can require a lot of YOUR time.

It is where ``dd_rhelp`` comes to help: it is a wrapper for ``dd_rescue``. This
means it'll call it with various arguments to change it's start position or the
direction of the scanning process. It'll guide ``dd_rescue`` into a new
behavior which will lead to rescuing much more data in the beginning of the
process all over the disk.

If you didn't really understood, here's another explanation :

Why do people want to use ``dd_rhelp`` ? (v2)
---------------------------------------------

This can really take a long time if you have much bad sectors. (and I had this
problem).

As bad sectors tends to be in large groups and these groups seems to tend to be
dispatched on drive, and if you just launch ``dd_rescue`` on the beginning of
your drive and there is a large group of bad sectors coming next, you could be
waiting for years before rescuing any data. While waiting, your anxiety will be
free to grow as you won't have answer to these dreadful questions: - Is there
any valid data to rescue AFTER this chunk ?  - How big is this chunk ?  - When
will I get answer to these two first question ?

So your solution with ``dd_rescue`` is to stop ``dd_rescue``, and "jump" ahead
randomly and try to copy from a chosen offset. Then you could again fall on a
group of bad sectors...  and then you should stop ``dd_rescue`` and jump
somewhere else on your drive.  This behavior involves the user's constant
presence (you !).

The idea of the ``dd_rhelp`` shell script is to do this job: launching
``dd_rescue`` for you on the disk while trying to get the max amount of data
out of your disk in a minimum of time. It'll be jumping over bad blocks, using
the reverse copy option of ``dd_rescue`` to pin out bad sector group and rescue
as much data as you could have rescued manualy.

Why use ``dd_rhelp`` and not ``dd_rescue`` ?
--------------------------------------------

This is a good question. ``dd_rhelp`` uses ``dd_rescue`` to compute a recovery
path through the device that will focus on valid data recovering. This recovery
path will go through all the device, exactly as ``dd_rescue`` could do it on
its own without any path. This means that ``dd_rhelp`` will save you time ONLY
IF YOU INTEND TO CANCEL ITS JOB BEFORE THE END of a full recovery.

Why wouldn't you want a full recovery ? because a considerable amount of time
is taken to try to rescue badsectors. This amount of time can be mesured in
days, month, years, depending on your device capacity and its
defectiveness. You might not want to spend this time knowing that 99 percent of
this time will be taken to look at badsector and won't lead to any more data
recovering...

``dd_rhelp`` shifts this useless waiting time to the end of the process. Using
``dd_rescue`` straight throughout your device make waiting time dependent on
the badsector distribution.

Think about ``dd_rescue`` standalone if you only intend (and can afford) to
wait until a full ``dd_rescue`` scan. ``dd_rhelp`` optimizes only the order in
which this full scan will occur to focus on recovery of what will be
recoverable in first. So in the end, launching ``dd_rhelp`` for a full scan
will take exactly the same time ``dd_rescue`` would have taken plus a
considerable time which correspond to the overhead of calculating its path.

How should I use it ?
---------------------

This shell script is very basic and not well written, but it supports the
"--help" and "--version" of GNU Coding Standard. It should be quite
straight-forward to use.

so go for a::

  dd_rhelp --version

When running ``dd_rhelp`` you can safely Ctrl-C, or kill ``dd_rhelp``, it'll
resume its job the next time you call it.

Olivier SANTIANO, a french ``dd_rhelp`` user shared his experience of complete
process of recovering his hard drive with ``dd_rhelp`` and post-``dd_rhelp``
recovery work: http://f1efq.free.fr/save.htm (in french)

How do I install this package ?
-------------------------------

Since 0.1.0, ``dd_rhelp`` is directly usable (you can copy it to a directory in
your path, or use it directly out of the box).


How does it work ?
-------------------

``dd_rhelp`` uses log files made by ``dd_rescue``. Precisely, it searches for
the "Summary report" that ``dd_rescue`` prints when its job is over.

  1. ``dd_rhelp`` creates itself an internal representation of what has been
  parsed with ``dd_rescue``.

  2. It'll find the greatest part of the disk that hasn't been tested and will
  launch ``dd_rescue`` from the middle of this part backwards, then forwards
  until it rescues without error all data, or until it falls on 5 consecutive
  read errors.

  3. Go back to step 1 unless everything has been rescued with ``dd_rescue``
  ...


Requirements ?
--------------

It worked fine for me (home made distrib) on big harddrives (partitions of 15
Gigs). Received positive feedbacks on large partition (60 Gigs and 200 Gigs),
and it should only be limited by the linux kernel limitation. Though the bash
script could be longer to compute next position in very large disk with lots of
bad sectors scatered all over your disk.

It worked on Debian, Ubuntu, and on a Knoppix CD. After each release, I test it
on a knoppix with a 1.44M diskette with badsectors or a damaged CD-ROM/DVD-ROM.

Darwin/MacOSX should be supported. This support is erratical, so more feedback
are appreciated.

If you have any other experiences of ``dd_rhelp``, please let me know.

.. note:: This shell script needs version >= 1.03 of ``dd_rescue`` ! And was
          tested with all version up to ``1.28``.


How can I contribute ?
''''''''''''''''''''''

The source code is on github_. Feel free to fork it and start hacking around,
I'll be gratefull to receive some pull requests.

.. _github: http://github.com/vaab/dd_rhelp

You should also note that ``dd_rhelp`` code is separated in 2 parts:

- the libraries that are in the beginning of the file
- the actual ``dd_rhelp`` code which is at the end of the file

The library are actually included when I have to create a new package. They are
accessible on a different repository than dd_rhelp code itself. These library
are called ``kal-shlib-*``.

kal-shlib-common_ contains the code included in ``dd_rhelp``.

kal-shlib-pretty_, kal-shlib-shunit_, are the repositories for the libraries
used (and included) in ``dd_rhelp.test``, the unit test file.

.. _kal-shlib-common: http://github.com/vaab/kal-shlib-common
.. _kal-shlib-pretty: http://github.com/vaab/kal-shlib-pretty
.. _kal-shlib-shunit: http://github.com/vaab/kal-shlib-shunit

