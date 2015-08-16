# mega_pwd
Dynamically shorten directory names.  Intended for use as part of your $PS1.

# How it works
The current working path is split into folders.  Each of these folders is then assigned a weight.  This weight determines the maximum number of characters that can be used to print that folder.  The default algorithm to assign a weight is

    y = x^0.5

which means that the closer the folder is to the current working directory (and the higher the x), the more weight it has.  There are currently 5 different algorithms defined for computing the weight, which can be readily swapped out.

# Demo
The following demo shows how the script performs when navigating down 11 directories.  It is using the default sqrt_func_integral function to compute weight.

sqrt_func_integral, y=x^0.5, (low->high)

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

The other functions are shown below for the same folder:

constant_func_integral, y=1, (medium->medium)

    [~/dv/sc/ats/app/cnt/cnc/my_/dem/complete]$ 
    
linear_func_integral, y=x, (low->high)

    [~/d/s/at/ap/cnt/cncr/my_c/demo/complete]$ 
    
parabolic_func_integral, y=x^2, (high->low->high)

    [~/dvlpmn/sch/a/a/c/c/my_/demo/complete]$ 

sin_func_integral, y=sin(x), (low->high->low->high->low->high)
    
    [~/dv/schdl/at/a/cntr/cnc/m/demo/complete]$ 
    
cubic_func_integral, y=x^3, (low->high)

    [~////a/cn/cncr/my_cnc/demo/complete]$ 

# LICENSE
MIT

# How to set up
1) Clone this repo, (git clone https://github.com/eraether/mega_pwd.git)

2) Add the following to your ~/.profile file:

CURRENT_DIRECTORY=$(ruby ~/path/to/mega_pwd/pretty_pwd.rb)

PS1="\u@\h ${CURRENT_DIRECTORY} \$"


That's it!
