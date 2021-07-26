#!/bin/bash

SELF_ADDR="sent1t4dqww9r5rdne79uxk8ytpcfkermsd0vnef3kw"
OPERATOR="sentvaloper1t4dqww9r5rdne79uxk8ytpcfkermsd0vvukue8"
WALLET_NAME="sentinel"
CHAIN_ID="sentinelhub-2"
WALLET_PWD=""
BIN_FILE="/root/go/bin/sentinelhub"
TOKEN="udvpn"


while true; do
    # withdraw reward
    echo -e "$WALLET_PWD\n$WALLET_PWD\n" | $BIN_FILE tx distribution withdraw-rewards $OPERATOR -b sync --commission --fees 1000$TOKEN --chain-id $CHAIN_ID --from $WALLET_NAME -y

    sleep 15

    # check current balance
    BALANCE=$($BIN_FILE query bank balances $SELF_ADDR -o json | jq -r .balances[0].amount)
    echo CURRENT BALANCE IS: $BALANCE

    RESTAKE_AMOUNT=$(( $BALANCE - 5000000 ))

    if (( $RESTAKE_AMOUNT >=  25000000 ));then
        echo "Let's delegate $RESTAKE_AMOUNT of REWARD tokens to $SELF_ADDR"
        # delegate balance
        echo -e "$WALLET_PWD\n$WALLET_PWD\n" | $BIN_FILE tx staking delegate $OPERATOR "$RESTAKE_AMOUNT"$TOKEN -b sync --fees 2000$TOKEN --chain-id $CHAIN_ID --from $WALLET_NAME -y

    else
        echo "Reward is $RESTAKE_AMOUNT"
    fi
    echo "DONE"
    sleep 10800
done
