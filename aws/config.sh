#!/bin/bash
cd "$(dirname "$0")"

# Name given to AWS resources created
NAME="sweeper"

# Docker image url
IMAGE_LOCATION="ghcr.io/zac-scheiwe/sweeper:master"

# Removes first and last "" from string
unwrap () {
	sed -e 's/^"//' -e 's/"$//' <<<"$1"
}

# Set ACCOUNT_ID
aws sts get-caller-identity > temp.json
ACCOUNT_ID=$(unwrap $(jq '.Account' temp.json))

user_parameters=(
	"DEPOSIT_CURRENCY"
	"TRADE_CURRENCY"
	"DEPOSIT_BALANCE_THRESHOLD"
	"TRADE_BALANCE_THRESHOLD"
	"STOCK_TICKER"
	"TRADING_MODE"
	"TWS_USERID"
	"TWS_PASSWORD"
	"RECEIVER_EMAIL_ADDRESS"
	"SENDER_GMAIL_ADDRESS"
	"SENDER_GMAIL_APP_PASSWORD"
)

user_parameter_defaults=(
	"NZD"
	"USD"
	1000
	700
	"VT"
	"live/paper"
	"user123"
	"twsPassword"
	"your.email@email.com"
	"ibkr.sweeper@gmail.com"
	"ymxbpneqchhvcati"
)

const_parameters=(
	"BPS_SAFETY"
	"READ_ONLY_API"
)

const_parameter_defaults=(
	20
	"no"
)

put_parameter () {
	aws ssm put-parameter \
	--name $1 \
	--type "SecureString" \
	--value $2 \
	--overwrite \
	> /dev/null
}

parameter_input () {
	echo -n "$1 [$2]: "
	read value
	if [[ $value != "" ]]; then
		put_parameter $1 $value;
	fi
}