#!/bin/sh
codes="67=XF86MonBrightnessDown \
68=XF86MonBrightnessUp \
69=XF86LaunchA \
70=XF86LaunchB \
71=XF86KbdBrightnessDown \
72=XF86KbdBrightnessUp \
73=XF86AudioPrev \
74=XF86AudioPlay \
75=XF86AudioNext \
76=XF86AudioMute \
95=XF86AudioLowerVolume \
96=XF86AudioRaiseVolume \
232=F1 \
233=F2 \
128=F3 \
212=F4 \
237=F5 \
238=F6 \
173=F7 \
172=F8 \
171=F9 \
121=F10 \
122=F11 \
123=F12"
for code in $codes
do
	xmodmap -e "keycode $code"
done
