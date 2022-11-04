\#!/bin/bash 

 echo "==================================================" 

 echo " _ ______ ___ __________________"; 

 echo " / |/ / __ \/ _ \/ __/ _/ __/_ __/"; 

 echo " / / /_/ / // / _/_/ /_\ \ / / "; 

 echo "/_/|_/\____/____/___/___/___/ /_/ "; 

 echo -e "\e[0m" 

 echo "=================================================="  

   sleep 2 

  \############ SET PROPERTIES ######### 

  ADDRESS="defund1727xexluyvmgz3dgha8a9654yn3cerz8dw6xdg" 

 VALIDATOR="defundvaloper1727xexluyvmgz3dgha8a9654yn3cerz8yxpzt2" 

 KEY_NAME="boylikegirl" 

 PASS="jj123456" 

 CHAIN_ID="defund-private-2" 

 GAS_VALUE="auto" 

 \#FEE_VALUE="" 

  \############ AUTO DELEGATION ######### 

  \# Withdraw 

 while : 

 do 

 echo $PASS | defundd tx distribution withdraw-rewards "${VALIDATOR}" --from "${KEY_NAME}" --commission --chain-id=${CHAIN_ID} --gas="${GAS_VALUE}" -y 

  sleep 20s 

  AVAILABLE_COIN=$(defundd query bank balances ${ADDRESS} --output json | jq -r '.balances | map(select(.denom == "ufetf")) | .[].amount' | tr -cd [:digit:]) 

 KEEP_FOR_FEES=100000 

 AMOUNT=$(($AVAILABLE_COIN - $KEEP_FOR_FEES)) 

 AMOUNT_FINAL=$AMOUNT"ufetf" 

   \# Delegate 

 echo $PASS | defundd tx staking delegate "${VALIDATOR}" "${AMOUNT_FINAL}" --from "${KEY_NAME}" --chain-id=${CHAIN_ID} -y 

 date 

 sleep 90s 

 done; 