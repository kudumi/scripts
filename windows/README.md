# Windows configuration

I haven't been lucky enough to completely deracinate my life of this
monolithic operating system just yet, and this folder contains my
attempts of coping. Besides some AutoHot Key scripts I wrote in an
attempt to make Windows more tolerable, this folder contains some
interesting material, particularly dealing with booting in Windows.

I place `rc.compat.bat` in the `Startup` folder of every Window box I
use. This script does little more than call `winStartup.sh`, which as
you'll notice is interpreted by the much more powerful Cygwin. Now
that control has been transferred into a Unix-like environment, I do
the sort of stuff that used to be in my rc.local init scripts.
