# .dotfiles
My dotfiles configurations.

## Installing
To install my configurations, clone this repository in your home directory and run the install script.

To run the script, specify which operating system you are on. For example, on Ubuntu you would do:

```
$ ./install.sh ubuntu
```

Make sure that you are running as root when installing on ubuntu, as the commands in my script for installing are:

```
apt install
```
rather than 

```
sudo apt install
```

## Neovim

My configs at the moment require Neovim version 0.7.0+, so make sure the version matches or is above that.
