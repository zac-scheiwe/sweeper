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

Fill in your job parameters as prompted. If left blank, the default is used. The job will NOT run with only default parameter values. You can edit your parameters directly in AWS Systems Manager -> Parameter Store.

| Parameter             | Description                                                         | Default                    |
| --------------------- | ------------------------------------------------------------------- | -------------------------- |
| `DEPOSIT_CURRENCY`    | The currency of your spare cash balance                             | NZD                        |
| `TRADE_CURRENCY`      | The currency your stock is traded in                                | USD                        |
| `DEPOSIT_BALANCE_THRESHOLD` | The necessary deposit currency balance for sweeper to convert currency | 1000              |
| `TRADE_BALANCE_THRESHOLD`   | The necessary trade currency balance for sweeper to purchase stock     | 700               |
| `STOCK_TICKER`        | The stock you would like to buy                                     | VT                         |
| `TRADING_MODE`        | **live** or **paper**                                               | **paper**                  |
| `TWS_USERID`          | Your Interactive Brokers username                                   | user123                    |
| `TWS_PASSWORD`        | Your Interactive Brokers password                                   | twsPassword                |
| `RECEIVER_EMAIL_ADDRESS`    | Email address to receive job failure notifications            | your.email@email.com       |
| `SENDER_GMAIL_ADDRESS`      | Gmail address to send job failure notifications               | throwaway@gmail.com        |
| `SENDER_GMAIL_PASSWORD`     | Gmail app password                                            | throwawaypassword          |

For more information about the Docker container: https://github.com/UnusualAlpha/ib-gateway-docker
