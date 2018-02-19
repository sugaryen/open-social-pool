#!/bin/bash

#ellamain:
screen -dmS ellageth /path/to/geth --rpc --ws --unlock="./ellauser" --password="./ellapass" --max-peers=500 --extra-data="ellaism.io" --identity="ellaism.io" --cache=128 

sleep 5

#pool2b:
screen -dmS ellapool2b /var/www/pool.ellaism.io/open-ethereum-pool /var/www/pool.ellaism.io/pool2b.json

sleep 5

#pool4b:
screen -dmS ellapool4b /var/www/pool.ellaism.io/open-ethereum-pool /var/www/pool.ellaism.io/pool4b.json

sleep 5

#pool9b:
screen -dmS ellapool9b /var/www/pool.ellaism.io/open-ethereum-pool /var/www/pool.ellaism.io/pool9b.json

sleep 5

#api:
screen -dmS ellaapi /var/www/pool.ellaism.io/open-ethereum-pool /var/www/pool.ellaism.io/api.json

sleep 5

#unlocker:
screen -dmS ellaunlocker /var/www/pool.ellaism.io/open-ethereum-pool /var/www/pool.ellaism.io/unlocker.json

sleep 5

#payout:
screen -dmS ellapayout /var/www/pool.ellaism.io/open-ethereum-pool /var/www/pool.ellaism.io/payout.json

sleep 5

# Sample start for stats reporting to stats.ellaism.org
#netintelligence:
#cd /root/ellaism-net-intelligence-api/ && pm2 start /root/ellaism-net-intelligence-api/app.json

exit 0
