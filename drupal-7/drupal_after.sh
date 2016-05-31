#!/bin/sh

cd $DOCROOT

drush updb -y
drush cc all