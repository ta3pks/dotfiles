#!/bin/bash
img="$HOME/bg_images/$(ls ~/bg_images/|sort -R|head -n1)"
feh --bg-scale $img
