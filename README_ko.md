## Open Source Ethereum Social (ETSC) Mining Pool

![Main page of open-social-pool](https://raw.githubusercontent.com/ethereumsocial/open-social-pool/master/misc/open-social-pool.PNG)

[![Discord](https://discordapp.com/api/guilds/417146776974262273/widget.png)](https://discord.gg/h6vsEuw) [![Build Status](https://travis-ci.org/ethereumsocial/open-social-pool.svg?branch=master)](https://travis-ci.org/ethereumsocial/open-social-pool) [![Go Report Card](https://goreportcard.com/badge/github.com/ethereumsocial/open-social-pool)](https://goreportcard.com/report/github.com/ethereumsocial/open-social-pool)

### Features

**This pool is being further developed to provide an easy to use pool for EtherSocial miners. This software is functional however an optimised release of the pool is expected soon. Testing and bug submissions are welcome!**

* Support for HTTP and Stratum mining
* Detailed block stats with luck percentage and full reward
* Failover geth instances: geth high availability built in
* Modern beautiful Ember.js frontend
* Separate stats for workers: can highlight timed-out workers so miners can perform maintenance of rigs
* JSON-API for stats
* PPLNS block reward
* Multi-tx payout at once
* Beautiful front-end highcharts embedded

#### Proxies

* [Ether-Proxy](https://github.com/sammy007/ether-proxy) HTTP proxy with web interface
* [Stratum Proxy](https://github.com/Atrides/eth-proxy) for Ethereum Social

## Ethereum Social (ETSC)

### Ethereum Social Pool 운영자 분들께서는 [discord](https://discord.gg/h6vsEuw) 채널에 참가해 주시기 바랍니다.

### Ethereum Social (ETSC) Pool list

* [Official Pool](http://pool.ethereumsocial.kr)
* [Reversegainz Pool](http://etsc.reversegainz.info)
* [GO池|GO Pool](http://etscpool.gominer.cn)
* [SoloPool.org](https://etsc.solopool.org)
* [Comining.io](https://comining.io)
* [miningpool.city](http://etsc.miningpool.city)

## 간단한 ETSC 풀 구축 방법

### 리눅스에 구축하는 법

준비물:

  * go >= 1.10
  * redis-server >= 2.8.0
  * nodejs >= 4 LTS
  * nginx
  * geth (multi-geth)

**Ubuntu 16.04 LTS 버전 이용을 추천드립니다.**

### go lang 설치

    $ sudo apt-get install -y build-essential golang-1.10-go unzip
    $ sudo ln -s /usr/lib/go-1.10/bin/go /usr/local/bin/go

### redis-server 설치

    $ sudo apt-get install redis-server

레디스는 127.0.0.1 포트에만 개방하시기 바랍니다. 또한 추가 보안을 위해서 [비밀번호](http://geekcoders.tistory.com/entry/Redis-Password-%EC%84%A4%EC%A0%95) 설정을 추천드립니다.

### nginx 설치

    $ sudo apt-get install nginx

### NODE 설치

    $ curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    $ sudo apt-get install -y nodejs

### multi-geth 설치

    $ wget https://github.com/ethereumsocial/multi-geth/releases/download/v1.8.4rc1/multi-geth-linux-v1.8.4rc1.zip
    $ unzip multi-geth-linux-v1.8.4rc1.zip
    $ sudo mv geth /usr/local/bin/geth

### multi-geth 실행

우분투에서는 screen 명령어를 사용하는 방법이 있지만 서버 관리에는 service 데몬이 편하므로 여기서는 serviced 를 사용하겠습니다.

먼저, 서비스를 등록합니다.

    $ sudo nano /etc/systemd/system/ethereumsocial.service

다음 예시를 참고하여 서비스 설정을 합니다.

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

다음 명령어로 서비스를 실행할 수 있습니다.

    $ sudo systemctl enable ethereumsocial
    $ sudo systemctl start ethereumsocial

노드의 로그를 볼 경우 다음 명령어를 칩니다.

    $ sudo systemctl status ethereumsocial

Geth 콘솔에 접근하고자 하는 경우 아래 명령어를 칩니다.

    $ geth attach

풀에서 사용할 계정을 새로 생성하고 지갑을 열어줍니다. 그래야 출금이 됩니다. 이 과정은 지갑을 재구동할 때마다 빠뜨리지 말고 실행해야합니다.

    > personal.newAccount()
    > personal.unlockAccount(eth.accounts[0],"비밀번호",40000000)

### Ethereum Social pool 설치

    $ git config --global http.https://gopkg.in.followRedirects true
    $ git clone https://github.com/ethereumsocial/open-social-pool
    $ cd open-social-pool
    $ make all

다음을 했을 때 open-social-pool 이 나오면 빌드 성공입니다.

    $ ls ~/open-social-pool/build/bin/

### Ethereum Social pool 설정

    $ mv config.example.json config.json
    $ nano config.json

아래 부분을 보고 설정을 합니다.

```javascript
{
  // CPU 코어수입니다.
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
    // 해시가 너무 몰려서 reject이 자주 발생하는 경우에는 난이도를 적절히 올려주어야합니다.
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
    // Frontend Chart related settings
    "poolCharts":"0 */20 * * * *",
    "poolChartsNum":74,
    "minerCharts":"0 */20 * * * *",
    "minerChartsNum":74

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
    // 풀피를 받을 주소입니다. 서버내의 지갑 주소로 해도 되지만 서버로의 해킹 공격이 많기 때문에 가능하면 서버 외부의 개인지갑 주소로 하는 것이 안전합니다.
    "poolFeeAddress": "",
    // 풀 제작자에게 풀피 중 일부를 기증하는 부분입니다. 현재 풀 피중의 10%를 기증하는 것으로 설정되어 있습니다. 만일 풀피가 1%라면 그 중의 10%이므로 0.1%가 개발자에게 갑니다.
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
    "requirePeers": 2,
    // Run payouts in this interval
    "interval": "12h",
    // Geth instance node rpc endpoint for payouts processing
    "daemon": "http://127.0.0.1:8545",
    // Rise error if can't reach geth in this amount of time
    "timeout": "10s",
    // Address with pool balance 풀 coinbase 지갑의 주소.
    "address": "0x0",
    // Let geth to determine gas and gasPrice
    "autoGas": true,
    // Gas amount and price for payout tx (advanced users only)
    "gas": "21000",
    "gasPrice": "50000000000",
    // 채굴보상 분배 최소량입니다. 현재 1 ETSC로 설정되어 있습니다.
    "threshold": 1000000000,
    // Perform BGSAVE on Redis after successful payouts session
    "bgsave": false
    "concurrentTx": 10
  }
}
```

If you are distributing your pool deployment to several servers or processes,
create several configs and disable unneeded modules on each server. (Advanced users)

I recommend this deployment strategy:

* Mining instance - 1x (it depends, you can run one node for EU, one for US, one for Asia)
* Unlocker and payouts instance - 1x each (strict!)
* API instance - 1x


### Pool 실행
마찬가지로 service를 생성하고 풀 서비스를 시작합니다.

    $ sudo nano /etc/systemd/system/etherpool.service

다음 예시를 참고하여 서비스 설정을 합니다.

```
[Unit]
Description=Ethereum Social pool
After=ethereumsocial.target

[Service]
Type=simple
ExecStart=/home/<your-user-name>/open-social-pool/build/bin/open-social-pool /home/<your-user-name>/open-social-pool/config.json

[Install]
WantedBy=multi-user.target
```

아래 명령어로 풀을 실행합니다.

    $ sudo systemctl enable etherpool
    $ sudo systemctl start etherpool

풀 서비스 디버깅을 할 경우 아래 명령어를 칩니다.

    $ sudo systemctl status etherpool

여기까지해서 백엔드 작동을 완료했습니다.

### 방화벽 오픈

이 서비스들을 작동시키리면 방화벽을 오픈해야합니다. 기본적으로 우분투 방화벽 설정을 한 곳도 있고 안한 곳도 있는데 각자의 환경에 맞추어 방화벽을 오픈합니다.
80,443,8080,8888,8008 을 열어주면 됩니다.

## Frontend 설치

### 설정파일 수정

    $ nano ~/open-social-pool/www/config/environment.js

다음 부분을 적절히 변경합니다.

    BrowserTitle: 'Ethereum Social Mining Pool',
    ApiUrl: '//your-pool-domain/',
    HttpHost: 'http://your-pool-domain',
    StratumHost: 'your-pool-domain',
    PoolFee: '1%',

The frontend is a single-page Ember.js application that polls the pool API to render miner stats.

    $ cd ~/open-social-pool/www
    $ sudo npm install -g ember-cli@2.9.1
    $ sudo npm install -g bower
    $ npm install
    $ bower install
    $ sudo chown -R $USER:$GROUP ~/.npm
    $ sudo chown -R $USER:$GROUP ~/.config
    $ ./build.sh
    $ cp -R ~/open-social-pool/www/dist ~/www

위 처럼 풀의 홈페이지 부분 프론트엔드를 만들었습니다. 그리고 그 파일을 서비스할 디렉토리 www로 복사합니다.

nginx를 설정해야합니다.

    $ sudo nano /etc/nginx/sites-available/default

다음 설정파일을 보고 적절히 수정합니다.

    # Default server configuration
    # nginx 설정 예제.

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


설정이 완료됐으면 다음을 실행합니다.

    $ sudo service nginx restart

웹브라우저에서 자신의 홈페이지 또는 IP를 입력해봅니다.
화면이 제대로 뜨고 있다면 풀 설치 성공입니다.

### Extra) How To Secure the pool frontend with Let's Encrypt (https)

This guide was originally referred from [digitalocean - How To Secure Nginx with Let's Encrypt on Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04)

First, install the Certbot's Nginx package with apt-get

```
$ sudo add-apt-repository ppa:certbot/certbot
$ sudo apt-get update
$ sudo apt-get install python-certbot-nginx
```

And then open your nginx setting file, make sure the server name is configured!

```
$ sudo nano /etc/nginx/sites-available/default
. . .
server_name <your-pool-domain>;
. . .
```

Change the _ to your pool domain, and now you can obtain your auto-renewaled ssl certificate for free!

```
$ sudo certbot --nginx -d <your-pool-domain>
```

Now you can access your pool's frontend via https! Share your pool link!
