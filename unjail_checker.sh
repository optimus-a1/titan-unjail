#!/bin/bash

# 验证者地址和账户信息
VALIDATOR_ADDRESS="改为你拉Account Address"
ACCOUNT_NAME="改为你沁Operator Address"
CHAIN_ID="titan-test-4"
FEES="90000uttnt"
GAS="200000"

# 密码（替换为你的实际密钥密码）
KEYRING_PASSPHRASE="你的密钥密码"

# 日志文件
LOG_FILE="/var/log/unjail_checker.log"

while true; do
    # 获取验证者状态
    STATUS=$(titand query staking validator $VALIDATOR_ADDRESS -o json | jq -r '.validator.status')

    # 检查是否为 jailed 状态
    if [ "$STATUS" -eq 3 ]; then
        echo "$(date): Validator is jailed. Attempting to unjail..." | tee -a $LOG_FILE

        # 执行 unjail
        echo -e "$KEYRING_PASSPHRASE\ny" | titand tx slashing unjail \
            --from=$ACCOUNT_NAME \
            --chain-id=$CHAIN_ID \
            --fees=$FEES \
            --gas=$GAS \
            --yes 2>&1 | tee -a $LOG_FILE

        echo "$(date): Unjail attempt complete." | tee -a $LOG_FILE
    else
        echo "$(date): Validator is active. No action needed." | tee -a $LOG_FILE
    fi

    # 等待一小时
    sleep 3600
done
