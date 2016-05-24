#!/bin/sh

#  SimpleWebServer.sh
#  SimpleWebServer
#
#  Created by TmRocha89 on 23/05/16.
#  Copyright © 2016 TmRocha89. All rights reserved.


cd ${1}
python -m SimpleHTTPServer ${2}
