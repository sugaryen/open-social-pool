## Open Source Ethereum Social (ETSC) Mining Pool

[![Build Status](https://travis-ci.org/ellaism/open-ethereum-pool.svg?branch=master)](https://travis-ci.org/ellaism/open-ethereum-pool)

[![Discord](https://discordapp.com/api/guilds/417146776974262273/widget.png)](https://discord.gg/h6vsEuw) [![Build Status](https://travis-ci.org/ethereumsocial/open-social-pool.svg?branch=master)](https://travis-ci.org/ethereumsocial/open-social-pool) [![Go Report Card](https://goreportcard.com/badge/github.com/ethereumsocial/open-social-pool)](https://goreportcard.com/report/github.com/ethereumsocial/open-social-pool)

### For korean readme go to [README-ko.md](https://github.com/ethereumsocial/open-social-pool/blob/master/README_ko.md)

### Features  

**This pool is being further developed to provide an easy to use pool for Ethereum Social miners. Testing and bug submissions are welcome!**

* Support for HTTP and Stratum mining
* Detailed block stats with luck percentage and full reward
* Failover geth instances: geth high availability built in
* Modern beautiful Ember.js frontend
* Separate stats for workers: can highlight timed-out workers so miners can perform maintenance of rigs
* JSON-API for stats
* PPLNS block reward

#### Proxies

* [Ether-Proxy](https://github.com/sammy007/ether-proxy) HTTP proxy with web interface
* [Stratum Proxy](https://github.com/Atrides/eth-proxy) for Ethereum Social

## Ethereum Social (ETSC)

### Ethereum Social Pool operators please join the [discord](https://discord.gg/h6vsEuw) channel for the further updates about ETSC!!

### Ethereum Social (ETSC) Pool list

* [Official Pool](http://pool.ethereumsocial.kr)
* [Reversegainz Pool](http://etsc.reversegainz.info)
* [GO池|GO Pool](http://etscpool.gominer.cn)
* [SoloPool.org](https://etsc.solopool.org)
* [Comining.io](https://comining.io)

## Guide to make your very own ETSC mining pool

### Building on Linux

Dependencies:

  * go >= 1.10
  * redis-server >= 2.8.0
  * nodejs >= 4 LTS
  * nginx
  * geth (multi-geth)

**I highly recommend to use Ubuntu 16.04 LTS.**

### Install go lang

    $ sudo apt-get install -y build-essential golang-1.10-go unzip
    $ sudo ln -s /usr/lib/go-1.10/bin/go /usr/local/bin/go

### Install redis-server

    $ sudo apt-get install redis-server

It is recommended to bind your DB address on 127.0.0.1 or on internal ip. Also, please set up the password for advanced security!!!

### Install nginx

    $ sudo apt-get install nginx

Search on Google for nginx-setting

### Install NODE

This will install the latest nodejs

    $ curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    $ sudo apt-get install -y nodejs

### Install multi-geth

    $ wget https://github.com/ethereumsocial/multi-geth/releases/download/v1.8.3/multi-geth-linux-v1.8.3.zip
    $ unzip multi-geth-linux-v1.8.3.zip
    $ sudo mv geth /usr/local/bin/geth

### Run multi-geth

If you use Ubuntu, it is easier to control services by using serviced.

    $ sudo nano /etc/systemd/system/ethereumsocial.service

Copy the following example

```
[Unit]
Description=Ethereum Social for Pool
After=network-online.target

[Service]
ExecStart=/usr/local/bin/geth --social --cache=1024 --rpc --extradata "Mined by <your-pool-domain>" --ethstats "<your-pool-domain>:NewEthereumSocial@stats.ethereumsocial.kr"
User=<your-user-name>

[Install]
WantedBy=multi-user.target
```

Then run multi-geth by the following commands

    $ sudo systemctl enable ethereumsocial
    $ sudo systemctl start ethereumsocial

If you want to debug the node command

    $ sudo systemctl status ethereumsocial

Run console

    $ geth attach

Register pool account and open wallet for transaction. This process is always required, when the wallet node is restarted.

    > personal.newAccount()
    > personal.unlockAccount(eth.accounts[0],"password",40000000)

### Install Ethereum Social Pool

    $ git clone https://github.com/ethereumsocial/open-social-pool
    $ cd open-social-pool
    $ make all

If you face open-social-pool after ls ~/open-social-pool/build/bin/, the installation has completed.

    $ ls ~/open-social-pool/build/bin/

### Set up Ethereum Social pool

    $ mv config.example.json config.json
    $ nano config.json

Set up based on commands below.

```javascript
{
  // The number of cores of CPU.
  "threads": 2,
  // Prefix for keys in redis store
  "coin": "etsc",
  // Give unique name to each instance
  "name": "main",
  // PPLNS rounds
  "pplns": 9000,

  "proxy": {
    "enabled": true,

    // Bind HTTP mining endpoint to this IP:PORT
    "listen": "0.0.0.0:8888",

    // Allow only this header and body size of HTTP request from miners
    "limitHeadersSize": 1024,
    "limitBodySize": 256,

    /* Set to true if you are behind CloudFlare (not recommended) or behind http-reverse
      proxy to enable IP detection from X-Forwarded-For header.
      Advanced users only. It's tricky to make it right and secure.
    */
    "behindReverseProxy": false,

    // Stratum mining endpoint
    "stratum": {
      "enabled": true,
      // Bind stratum mining socket to this IP:PORT
      "listen": "0.0.0.0:8008",
      "timeout": "120s",
      "maxConn": 8192
    },

    // Try to get new job from geth in this interval
    "blockRefreshInterval": "120ms",
    "stateUpdateInterval": "3s",
    // If there are many rejects because of heavy hash, difficulty should be increased properly.
    "difficulty": 2000000000,

    /* Reply error to miner instead of job if redis is unavailable.
      Should save electricity to miners if pool is sick and they didn't set up failovers.
    */
    "healthCheck": true,
    // Mark pool sick after this number of redis failures.
    "maxFails": 100,
    // TTL for workers stats, usually should be equal to large hashrate window from API section
    "hashrateExpiration": "3h",

    "policy": {
      "workers": 8,
      "resetInterval": "60m",
      "refreshInterval": "1m",

      "banning": {
        "enabled": false,
        /* Name of ipset for banning.
        Check http://ipset.netfilter.org/ documentation.
        */
        "ipset": "blacklist",
        // Remove ban after this amount of time
        "timeout": 1800,
        // Percent of invalid shares from all shares to ban miner
        "invalidPercent": 30,
        // Check after after miner submitted this number of shares
        "checkThreshold": 30,
        // Bad miner after this number of malformed requests
        "malformedLimit": 5
      },
      // Connection rate limit
      "limits": {
        "enabled": false,
        // Number of initial connections
        "limit": 30,
        "grace": "5m",
        // Increase allowed number of connections on each valid share
        "limitJump": 10
      }
    }
  },

  // Provides JSON data for frontend which is static website
  "api": {
    "enabled": true,
    "listen": "0.0.0.0:8080",
    // Collect miners stats (hashrate, ...) in this interval
    "statsCollectInterval": "5s",
    // Purge stale stats interval
    "purgeInterval": "10m",
    // Fast hashrate estimation window for each miner from it's shares
    "hashrateWindow": "30m",
    // Long and precise hashrate from shares, 3h is cool, keep it
    "hashrateLargeWindow": "3h",
    // Collect stats for shares/diff ratio for this number of blocks
    "luckWindow": [64, 128, 256],
    // Max number of payments to display in frontend
    "payments": 50,
    // Max numbers of blocks to display in frontend
    "blocks": 50,

    /* If you are running API node on a different server where this module
      is reading data from redis writeable slave, you must run an api instance with this option enabled in order to purge hashrate stats from main redis node.
      Only redis writeable slave will work properly if you are distributing using redis slaves.
      Very advanced. Usually all modules should share same redis instance.
    */
    "purgeOnly": false
  },

  // Check health of each geth node in this interval
  "upstreamCheckInterval": "5s",

  /* List of geth nodes to poll for new jobs. Pool will try to get work from
    first alive one and check in background for failed to back up.
    Current block template of the pool is always cached in RAM indeed.
  */
  "upstream": [
    {
      "name": "main",
      "url": "http://127.0.0.1:8545",
      "timeout": "10s"
    },
    {
      "name": "backup",
      "url": "http://127.0.0.2:8545",
      "timeout": "10s"
    }
  ],

  // This is standard redis connection options
  "redis": {
    // Where your redis instance is listening for commands
    "endpoint": "127.0.0.1:6379",
    "poolSize": 10,
    "database": 0,
    "password": ""
  },

  // This module periodically remits ether to miners
  "unlocker": {
    "enabled": false,
    // Pool fee percentage
    "poolFee": 1.0,
    // the address is for pool fee. Personal wallet is recommended to prevent from server hacking.
    "poolFeeAddress": "",
    // Amount of donation to a pool maker. 10 percent of pool fee is donated to a pool maker now. If pool fee is 1 percent, 0.1 percent which is 10 percent of pool fee should be donated to a pool maker.
    "donate": true,
    // Unlock only if this number of blocks mined back
    "depth": 120,
    // Simply don't touch this option
    "immatureDepth": 20,
    // Keep mined transaction fees as pool fees
    "keepTxFees": false,
    // Run unlocker in this interval
    "interval": "10m",
    // Geth instance node rpc endpoint for unlocking blocks
    "daemon": "http://127.0.0.1:8545",
    // Rise error if can't reach geth in this amount of time
    "timeout": "10s"
  },

  // Pay out miners using this module
  "payouts": {
    "enabled": true,
    // Require minimum number of peers on node
    "requirePeers": 5,
    // Run payouts in this interval
    "interval": "12h",
    // Geth instance node rpc endpoint for payouts processing
    "daemon": "http://127.0.0.1:8545",
    // Rise error if can't reach geth in this amount of time
    "timeout": "10s",
    // Address with pool coinbase wallet address.
    "address": "0x0",
    // Let geth to determine gas and gasPrice
    "autoGas": true,
    // Gas amount and price for payout tx (advanced users only)
    "gas": "21000",
    "gasPrice": "50000000000",
    // The minimum distribution of mining reward. It is 1 ETSC now.
    "threshold": 1000000000,
    // Perform BGSAVE on Redis after successful payouts session
    "bgsave": false
  }
}
```

If you are distributing your pool deployment to several servers or processes,
create several configs and disable unneeded modules on each server. (Advanced users)

I recommend this deployment strategy:

* Mining instance - 1x (it depends, you can run one node for EU, one for US, one for Asia)
* Unlocker and payouts instance - 1x each (strict!)
* API instance - 1x


### Run Pool
It is required to run pool by serviced. If it is not, the terminal could be stopped, and pool doesn’t work.

    $ sudo nano /etc/systemd/system/etherpool.service

Copy the following example

```
[Unit]
Description=Etherpool
After=ethereumsocial.target

[Service]
Type=simple
ExecStart=/home/<your-user-name>/open-social-pool/build/bin/open-social-pool /home/<your-user-name>/open-social-pool/config.json

[Install]
WantedBy=multi-user.target
```

Then run pool by the following commands

    $ sudo systemctl enable etherpool
    $ sudo systemctl start etherpool

If you want to debug the node command

    $ sudo systemctl status etherpool

Backend operation has completed so far.

### Open Firewall

Firewall should be opened to operate this service. Whether Ubuntu firewall is basically opened or not, the firewall should be opened based on your situation.
You can open firewall by opening 80,443,8080,8888,8008.

## Install Frontend

### Modify configuration file

    $ nano ~/open-social-pool/www/config/environment.js

Make some modifications in these settings.

    BrowserTitle: 'Ethereum Social Mining Pool',
    ApiUrl: '//your-pool-domain/',
    HttpHost: 'http://your-pool-domain',
    StratumHost: 'your-pool-domain',
    PoolFee: '1%',

The frontend is a single-page Ember.js application that polls the pool API to render miner stats.

    $ cd ~/open-social-pool/www
    $ sudo npm install -g ember-cli@2.9.1
    $ sudo npm install -g bower
    $ sudo chown -R $USER:$GROUP ~/.npm
    $ sudo chown -R $USER:$GROUP ~/.config
    $ npm install
    $ bower install
    $ ./build.sh
    $ cp -R ~/open-social-pool/www/dist ~/www

As you can see above, the frontend of the pool homepage is created. Then, move to the directory, www, which services the file.

Set up nginx.

    $ sudo nano /etc/nginx/sites-available/default

Modify based on configuration file.

    # Default server configuration
    # nginx example

    upstream api {
        server 127.0.0.1:8080;
    }

    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /home/<your-user-name>/www;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }

        location /api {
                proxy_pass http://api;
        }

    }

After setting nginx is completed, run the command below.

    $ sudo service nginx restart

Type your homepage address or IP address on the web.
If you face screen without any issues, pool installation has completed.

### Notes

* Unlocking and payouts are sequential, 1st tx go, 2nd waiting for 1st to confirm and so on. You can disable that in code. Carefully read `docs/PAYOUTS.md`.
* Also, keep in mind that **unlocking and payouts will halt in case of backend or node RPC errors**. In that case check everything and restart.
* You must restart module if you see errors with the word *suspended*.
* Don't run payouts and unlocker modules as part of mining node. Create separate configs for both, launch independently and make sure you have a single instance of each module running.
* If `poolFeeAddress` is not specified all pool profit will remain on coinbase address. If it specified, make sure to periodically send some dust back required for payments.
* DO NOT OPEN YOUR RPC OR REDIS ON 0.0.0.0!!! It will eventually cause coin theft.

### Credits

Made by sammy007. Licensed under GPLv3.
Modified by Akira Takizawa & The Ellaism Project.

#### Contributors

[Alex Leverington](https://github.com/subtly)

### Donations

ETH/ETC/ETSC: 0x24947682e051f136f593c6960fdb6a1550577d3a

![](https://cdn.pbrd.co/images/GP5tI1D.png)

Highly appreciated.
