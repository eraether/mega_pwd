# mega_pwd
Dynamically shorten directory names.  Intended for use as part of your $PS1.

# How to set up
1) Clone this repo, (git clone https://github.com/eraether/mega_pwd.git)
2) Add the following to your .profile

CURRENT_DIRECTORY=$(ruby ~/path/to/mega_pwd/pretty_pwd.rb)

PS1="\u@\h ${CURRENT_DIRECTORY} \$"

That's it!
