sweeper
==

Invests your spare cash in a stock of your choice. Converts your deposit currency and submits a LOC (limit on close) buy order just before the NYSE closing auction each weekday. Only runs when you have sufficient cash balance in your Interactive Brokers account.

## Installation

Create a free AWS account: https://aws.amazon.com/free

Sign in to the AWS console. In AWS Cloudshell, run the following code:

    git clone https://github.com/zac-scheiwe/sweeper.git
    cd sweeper
    bash aws-create.sh

Parameters explained:




For more information about the Docker container: https://github.com/UnusualAlpha/ib-gateway-docker
