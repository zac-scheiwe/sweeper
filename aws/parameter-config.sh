#!/bin/bash
cd "$(dirname "$0")"

# Removes first and last "" from string
unwrap () {
	sed -e 's/^"//' -e 's/"$//' <<<"$1"
}

# Set Name
echo -n "Job Name [sweeper]: "
read NAME
if [[ $NAME == "" ]]; then
	NAME="sweeper"
fi

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
	"throwaway@gmail.com"
	"throwawaypassword"
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