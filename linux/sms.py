#!/usr/bin/python

import gvoice
import sys

if len(sys.argv) < 3:
#    print "You must provide both a number and a message!"
    exit()

gv_login = gvoice.GoogleVoiceLogin('eric.s.crosson@gmail.com', 'wocnfjsoidjif898')
text_sender = gvoice.TextSender(gv_login)

text_sender.text = sys.argv[2]
text_sender.send_text(sys.argv[1])

#if text_sender.response:
#   print 'Success! Message sent!'
#else:
#   print 'Failure! Message not sent!'
