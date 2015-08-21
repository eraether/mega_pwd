# mega_pwd
Dynamically shorten directory names.  Intended for use as part of your $PS1.

# How it works
The current working path is split into folders.  Each of these folders is then assigned a weight.  This weight determines the maximum number of characters that can be used to print that folder.  The default algorithm to assign a weight is

    y = x^0.5

which means that the closer the folder is to the current working directory (and the higher the x), the more weight it has.  There are currently 5 different algorithms defined for computing the weight, which can be readily swapped out.

# Demo
The following demo shows how the script performs when navigating down 15 directories.  Any files under $HOME are prefixed with a tilde(~).  The entire time, the pwd string is below the specified cap of 30 characters.
![Demo Image](http://i.imgur.com/C6XOs8R.png)

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
GNU Public License.  See LICENSE.

# How to set up
1) Clone this repo, (git clone https://github.com/eraether/mega_pwd.git)

2) Add source /path/to/repo/example_prompt to your ~/.profile

3) That's it!
