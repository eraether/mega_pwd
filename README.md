# mega_pwd
Dynamically shorten directory names.  Intended for use as part of your $PS1.

# Demo
The following demo shows how the script performs when navigating down 11 directories.

  [eugene@eugene-VirtualBox /]$ cd home
  [eugene@eugene-VirtualBox /home]$ cd eugene
  [eugene@eugene-VirtualBox ~]$ cd development
  [eugene@eugene-VirtualBox ~/development]$ cd scheduler
  [eugene@eugene-VirtualBox ~/development/scheduler]$ cd autoscheduler
  [eugene@eugene-VirtualBox ~/developm/scheduler/autoscheduler]$ cd app
  [eugene@eugene-VirtualBox ~/dvlpmnt/scheduler/autoscheduler/app]$ cd controllers[eugene@eugene-VirtualBox ~/dvl/schdl/atschdl/app/controllers]$ cd concerns
  [eugene@eugene-VirtualBox ~/dvl/schd/atsch/app/cntrllr/concerns]$ cd my_concern
  [eugene@eugene-VirtualBox ~/dv/sch/ats/app/cntrl/cncrn/my_concern]$ cd demo
  [eugene@eugene-VirtualBox ~/dv/sch/ats/app/cntrl/cncrn/my_cn/demo]$ cd complete
  [eugene@eugene-VirtualBox ~/d/sc/at/app/cnt/cnc/my_c/demo/complete]$ pwd
  /home/eugene/development/scheduler/autoscheduler/app/controllers/concerns/my_concern/demo/complete
  [eugene@eugene-VirtualBox ~/d/sc/at/app/cnt/cnc/my_c/demo/complete]$ 

# How to set up
1) Clone this repo, (git clone https://github.com/eraether/mega_pwd.git)

2) Add the following to your ~/.profile file:

CURRENT_DIRECTORY=$(ruby ~/path/to/mega_pwd/pretty_pwd.rb)

PS1="\u@\h ${CURRENT_DIRECTORY} \$"


That's it!
