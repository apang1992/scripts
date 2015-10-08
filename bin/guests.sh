#!/bin/sh


curl -s  'http://dl.cdn.newrocktech.com/solr/devices/select?q=*%3A*&rows=1000&wt=json&indent=true&_=1442212408243' | jq '.response | .docs' | jq 'map(select(has("user_id") and (.user_id == "85277739" or .user_id == "3174298634")))'
