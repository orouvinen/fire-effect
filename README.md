# Fire effect in 189 bytes

Inspired by a recent [post](https://www.reddit.com/r/programming/comments/9o6f91/old_school_vga_fire_animation_using_turbo_pascal/) on reddit that showed
an old school fire effect in written in Turbo Pascal, I dug into my HD to find a very similar thing I wrote.
It's written in 16bit assembly and with the goal of being very small executable but still having a decent looking effect.

The source should be compatible with MASM. Don't remember the exact version - might have been 5 or 6 (?)
Compiled .COM binary file should be 189 bytes.

Here's a short lowish framerate gif of how it looks:

![Fire](screenshots/fire.gif?raw=true)