#!/bin/bash

cat <<EOF >> ~/.gtkrc-2.0
style "uzbl" {
GtkRange::slider-width = 0
}
widget "Uzbl*" style "uzbl"

EOF
