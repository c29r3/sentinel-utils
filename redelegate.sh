#!/bin/bash

SELF_ADDR="sent1t4dqww9r5rdne79uxk8ytpcfkermsd0vnef3kw"
OPERATOR="sentvaloper1t4dqww9r5rdne79uxk8ytpcfkermsd0vvukue8"
WALLET_NAME="sentinel"
CHAIN_ID="sentinelhub-2"
REST="http://135.181.60.250:1320"
RPC="http://135.181.60.250:29657"
read -sp 'Password: ' WALLET_PWD
BIN_FILE="$HOME/go/bin/sentinelhub"
TOKEN="udvpn"


while true; do
    # withdraw reward
    seq=$(curl -s ${REST}/auth/accounts/${SELF_ADDR} | jq -r .result.value.sequence)
    echo -e "$WALLET_PWD\n$WALLET_PWD\n" | $BIN_FILE tx distribution withdraw-rewards $OPERATOR -b sync --commission --sequence $seq --node $RPC --fees 1000$TOKEN --chain-id $CHAIN_ID --from $WALLET_NAME -y
    
    sleep 15

    # check current balance
    BALANCE=$($BIN_FILE query bank balances $SELF_ADDR -o json --node $RPC | jq -r .balances[0].amount)
    echo CURRENT BALANCE IS: $BALANCE

    RESTAKE_AMOUNT=$(( $BALANCE - 5000000 ))

    if (( $RESTAKE_AMOUNT >=  25000000 ));then
        echo "Let's delegate $RESTAKE_AMOUNT of REWARD tokens to $SELF_ADDR"
        # delegate balance
        code=$(echo -e "$WALLET_PWD\n$WALLET_PWD\n" | $BIN_FILE tx staking delegate $OPERATOR "$RESTAKE_AMOUNT"$TOKEN -b sync --node ${RPC} --fees 2000$TOKEN --chain-id $CHAIN_ID --from $WALLET_NAME -y | jq .code)
        echo $code
        if [[ $code == "32" ]]; then
          seq=$(echo $seq+1 | bc)
          echo -e "$WALLET_PWD\n$WALLET_PWD\n" | $BIN_FILE tx staking delegate $OPERATOR "$RESTAKE_AMOUNT"$TOKEN -b sync -s $seq --node ${RPC} --fees 2000$TOKEN --chain-id $CHAIN_ID --from $WALLET_NAME -y
        fi
    else
        echo "Reward is $RESTAKE_AMOUNT"
    fi
    echo "DONE"
    sleep 10800
done
