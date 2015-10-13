#! /bin/sh
######################################################################################
#
# Description: this script is test the remote auth server is always working,
#              if the server is down,then the wifidog will be stop,after server
#              is up,then will start the wifidog.
# Auth:        GaomingPan
# Version:     v1.0.0
# Date:        2015-09-05
#
#####################################################################################

SERVER_FILE_FOR_TEST=IsAlive.html
SERVER_BASE_PATH=http://$(uci get wifidog_conf.authServer.hostname | awk '{print $2}')
SERVER_PORT=$(uci get wifidog_conf.authServer.httpPort | awk '{print $2}')
SERVER_URL_FOR_TEST=$SERVER_BASE_PATH:$SERVER_PORT/$SERVER_FILE_FOR_TEST



