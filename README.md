# About

This timer is interactive and contains multiple options. You can countdown time based on a point in the future or
set amount of seconds, minutes, and hours passed. When time
runs out, your computer makes a phonetic noise, shouts
a reminder, or issues a command! You can choose the
message. You can can also use the -i option in order
to run it like a stopwatch (indefinite).

# Install on Linux

To get the most out of this, you need to have spd-say
installed. It comes with Ubuntu, but in my experience you need
to install it on a basic Debian operating system. Here's how to install
it on the main linux operating systems:
<pre><code>
#Debian
apt-get install speech-dispatcher
#Fedora
dnf install speech-dispatcher-utils
#Arch
pacman -S speech-dispatcher
#CentOs
yum install speech-dispatcher
</pre></code>

To install the timer script, copy and paste all these commands in your terminal and hit enter:

<pre><code>
git clone https://github.com/ShinyNeonCalvin/Bash-timer-with-voice-reminder
cd Bash-timer-with-voice-reminder
chmod +x timer.sh
</pre></code>
# How to Use

Run the script without options to see how to use all its features:

<pre><code>
./timer.sh
</pre></code>

If you want to simply execute the timer.sh script from any directory on your operating system, add this to your `.bashrc`:

`PATH="$PATH:~/BashTimer"`

Then, you only have to enter `timer.sh` and your preferred options to run it.

# Contributions

If you install it and have issues running it, or you install it and don't like it, it would be
help if you said it in "Issues" in the top menu of the repo.
