#!/bin/zsh

DD_VAULT_ADDR=https://vault.us1.ddbuild.io

# The common path prefix for all dd-sdk-ios-apollo-interceptor secrets in Vault.
#
# When using `vault kv put` to write secrets to a specific path, Vault overwrites the entire set of secrets
# at that path with the new data. This means that any existing secrets at that path are replaced by the new
# secrets. For simplicity, we store each secret independently by writing each to a unique path.
DD_APOLLO_SECRETS_PATH_PREFIX='kv/aws/arn:aws:iam::486234852809:role/ci-dd-sdk-ios-apollo-interceptor/'

# Secrets needed for release process only
DD_APOLLO_SECRET__CP_TRUNK_TOKEN="cocoapods.trunk.token"
DD_APOLLO_SECRET__SSH_KEY="ssh.key"

idx=0
declare -A DD_APOLLO_SECRETS
DD_APOLLO_SECRETS[$((idx++))]="$DD_APOLLO_SECRET__CP_TRUNK_TOKEN | Cocoapods token to authenticate 'pod trunk' operations (https://guides.cocoapods.org/terminal/commands.html)"
DD_APOLLO_SECRETS[$((idx++))]="$DD_APOLLO_SECRET__SSH_KEY | SSH key to authenticate 'git clone git@github.com:...' operations"

