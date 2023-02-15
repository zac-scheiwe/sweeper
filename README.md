<img align="left" src="https://github.com/zac-scheiwe/sweeper/blob/master/logo.png" height="180" /> 

sweeper
==

Daily automatic currency conversion and stock purchasing for Interactive Brokers. Converts your deposit currency and submits a LOC (limit on close) buy order for your stock just before the NYSE closing auction each weekday. Only runs when you have sufficient cash balance in your Interactive Brokers account.

## Installation

Create a free AWS account: https://aws.amazon.com/free

Sign in to the AWS console. In AWS Cloudshell, run the following code:

    git clone https://github.com/zac-scheiwe/sweeper.git
    cd sweeper
    bash aws-create.sh

| Parameter             | Description                                                         | Default                    |
| --------------------- | ------------------------------------------------------------------- | -------------------------- |
| `DEPOSIT_CURRENCY`    | The currency of your spare cash balance                             | NZD                        |
| `TRADE_CURRENCY`      | The currency your stock is traded in                                | USD                        |
| `DEPOSIT_BALANCE_THRESHOLD` | **live** or **paper**                                               | **paper**                  |
| `READ_ONLY_API`       | **yes** or **no** ([see](resources/config.ini#L316))                | **not defined**            |
| `VNC_SERVER_PASSWORD` | VNC server password. If not defined, no VNC server will be started. | **not defined** (VNC disabled)|
| `TWS_USERID`          | The TWS **username**.                                               |                            |
| `TWS_PASSWORD`        | The TWS **password**.                                               |                            |
| `TRADING_MODE`        | **live** or **paper**                                               | **paper**                  |
| `READ_ONLY_API`       | **yes** or **no** ([see](resources/config.ini#L316))                | **not defined**            |
| `VNC_SERVER_PASSWORD` | VNC server password. If not defined, no VNC server will be started. | **not defined** (VNC disabled)|
| `TWS_USERID`          | The TWS **username**.                                               |                            |
| `TWS_PASSWORD`        | The TWS **password**.                                               |                            |
| `TRADING_MODE`        | **live** or **paper**                                               | **paper**                  |
| `READ_ONLY_API`       | **yes** or **no** ([see](resources/config.ini#L316))                | **not defined**            |
| `VNC_SERVER_PASSWORD` | VNC server password. If not defined, no VNC server will be started. | **not defined** (VNC disabled)|

For more information about the Docker container: https://github.com/UnusualAlpha/ib-gateway-docker
