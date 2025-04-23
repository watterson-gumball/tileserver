#!/bin/bash

service apache2 restart
sudo -u _renderd service renderd restart

tail -f /dev/null
