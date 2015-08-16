# mega_pwd
Dynamically shorten directory names.  Intended for use as part of your $PS1.

# How it works
This script defines a number of mathematical functions that assign a weight to a directory based on how deep it is relative to the current directory.  This weight then determines the maximum number of characters that can be taken up by the directory name when it is displayed for you.  The default function is 
    importance = position^0.5
which puts more weight on directories deeper down (and thus closer to your current directory).  

# Demo
The following demo shows how the script performs when navigating down 11 directories.

    [/]$ cd home
    [/home]$ cd eugene
    [~]$ cd development
    [~/development]$ cd scheduler
    [~/development/scheduler]$ cd autoscheduler
    [~/developm/scheduler/autoscheduler]$ cd app
    [~/dvlpmnt/scheduler/autoscheduler/app]$ cd controllers[eugene@eugene-VirtualBox ~/dvl/schdl/atschdl/app/controllers]$ cd concerns
    [~/dvl/schd/atsch/app/cntrllr/concerns]$ cd my_concern
    [~/dv/sch/ats/app/cntrl/cncrn/my_concern]$ cd demo
    [~/dv/sch/ats/app/cntrl/cncrn/my_cn/demo]$ cd complete
    [~/d/sc/at/app/cnt/cnc/my_c/demo/complete]$ pwd
    /home/eugene/development/scheduler/autoscheduler/app/controllers/concerns/my_concern/demo/complete
    [~/d/sc/at/app/cnt/cnc/my_c/demo/complete]$ 

# LICENSE
MIT

# How to set up
1) Clone this repo, (git clone https://github.com/eraether/mega_pwd.git)

2) Add the following to your ~/.profile file:

CURRENT_DIRECTORY=$(ruby ~/path/to/mega_pwd/pretty_pwd.rb)

PS1="\u@\h ${CURRENT_DIRECTORY} \$"


That's it!
