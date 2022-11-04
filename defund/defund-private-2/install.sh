#!/bin/bash

while true
do

# Logo

echo "============================================================"
curl -s https://raw.githubusercontent.com/ericet/easynodes/master/logo.sh | bash
echo "============================================================"


source ~/.profile

PS3='选择一个操作 '
options=(
"安装必要的环境" 
"安装节点" 
"创建钱包"
"节点日志" 
"查看节点状态" 
"水龙头获得测试币" 
"钱包余额" 
"创建验证人" 
"查看验证人"
"退出")
select opt in "${options[@]}"
               do
                   case $opt in
                   
"安装必要的环境")
echo "============================================================"
echo "准备开始。。。"
echo "============================================================"

#INSTALL DEPEND
echo "============================================================"
echo "Update and install APT"
echo "============================================================"
sleep 3
sudo apt update && sudo apt upgrade -y && \
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

#INSTALL GO
echo "============================================================"
echo "Install GO 1.18.1"
echo "============================================================"
sleep 3
wget https://golang.org/dl/go1.18.1.linux-amd64.tar.gz; \
rm -rv /usr/local/go; \
tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz && \
rm -v go1.18.1.linux-amd64.tar.gz && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.profile && \
source ~/.profile && \
go version > /dev/null

echo "============================================================"
echo "服务器环境准备好了!"
echo "============================================================"
break
;;
            
"安装节点")
echo "============================================================"
echo "输入节点的名称:"
echo "============================================================"
                
read DEFUNDNODE
DEFUNDNODE=$DEFUNDNODE
echo 'export DEFUNDNODE='${DEFUNDNODE} >> $HOME/.profile

echo "============================================================"
echo "输入钱包名称:"
echo "============================================================"
               
read DEFUNDWALLET
DEFUNDWALLET=$DEFUNDWALLET
echo 'export DEFUNDWALLET='${DEFUNDWALLET} >> $HOME/.profile
DEFUNDCHAIN="reb_3333-1"
echo 'export DEFUNDCHAIN='${DEFUNDCHAIN} >> $HOME/.profile
source $HOME/.profile

echo "============================================================"
echo "节点安装开始。。。"
echo "============================================================"

cd $HOME
git clone https://github.com/defund-labs/defund
cd defund.core && git checkout testnet
make install

defundd init $DEFUNDNODE --chain-id $DEFUNDCHAIN

defundd tendermint unsafe-reset-all --home $HOME/.defundd
rm $HOME/.defundd/config/genesis.json
curl -s https://raw.githubusercontent.com/defund-labs/testnet/main/defund-private-2/genesis.json > ~/.defundd/config/genesis.json

# config pruning
indexer="null"
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"

sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.defundd/config/config.toml
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.defundd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.defundd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.defundd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.defundd/config/app.toml




tee $HOME/defundd.service > /dev/null <<EOF
[Unit]
Description=Rebus Testnet Daemon
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which defundd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/defundd.service /etc/systemd/system/

# start service
sudo systemctl daemon-reload
sudo systemctl enable defundd
sudo systemctl restart defundd

echo "============================================================"
echo "节点安装成功!"
echo "============================================================"
break
;;


"创建钱包")
echo "============================================================"
echo "请保存助记词!"
echo "============================================================"
               
defundd keys add $DEFUNDWALLET
DEFUNDADDRWALL=$(defundd keys show $DEFUNDWALLET -a)
DEFUNDVAL=$(defundd keys show $DEFUNDWALLET --bech val -a)
echo 'export DEFUNDVAL='${DEFUNDVAL} >> $HOME/.profile
echo 'export DEFUNDADDRWALL='${DEFUNDADDRWALL} >> $HOME/.profile
source $HOME/.profile

echo "============================================================"
echo "钱包地址: $DEFUNDADDRWALL"
echo "验证人地址: $DEFUNDVAL"
echo "============================================================"
               
break
;;

"查看节点状态")
echo "============================================================"
echo "节点catching_up为false的时候继续下一步"
echo "============================================================"
echo "节点状态 = $(curl -s localhost:26657/status | jq .result | jq .sync_info)"
echo "区块高度 = $(teritorid status 2>&1 | jq ."SyncInfo"."latest_block_height")"
echo "验证人状态 = $(defundd q slashing signing-info $(defundd tendermint show-validator))"
echo "============================================================"
break
;;

"创建验证人")
echo "============================================================"
echo "节点状态为false的时候继续下一步!"
echo "节点状态 = $(curl -s localhost:26657/status)"
echo "============================================================"
               
defundd tx staking create-validator \
  --amount 1000000000000000000adefund\
  --from $DEFUNDWALLET \
  --commission-max-change-rate "0.05" \
  --commission-max-rate "0.20" \
  --commission-rate "0.05" \
  --min-self-delegation "1" \
  --pubkey $(defundd tendermint show-validator) \
  --moniker $DEFUNDNODE \
  --chain-id $DEFUNDCHAIN \
  --gas 300000 \
  -y
break
;;

"钱包余额")
echo "============================================================"
echo "节点名称: $DEFUNDNODE"
echo "钱包地址: $DEFUNDADDRWALL" 
echo "钱包余额: $(defundd query bank balances $DEFUNDADDRWALL)"
echo "============================================================"
break
;;

"查看验证人") 
echo "============================================================"
echo "Account request: $(defundd q auth account $(defundd keys show $DEFUNDADDRWALL -a) -o text)"
echo "Validator info: $(defundd q staking validator $DEFUNDVAL)"
echo "============================================================"
break
;;

"水龙头获得测试币")
request=$request
echo "============================================================"
echo "进入Rebus Discord https://discord.gg/yCKfZY76 的 #faucet 频道"
echo "============================================================"
echo -e "复制粘贴 \033[32m $request $DEFUNDADDRWALL \033[37m"
echo "============================================================"
break
;;

"节点日志")
journalctl -u defundd -f -o cat
break
;;


"退出")
exit
;;

*) echo "invalid option $REPLY";;
esac
done
done
