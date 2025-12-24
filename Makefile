# Makefile for deploying scripts with forge
# Usage examples:
# 1) Provide a raw private key (non-interactive):
#    make deploy-token RPC_URL=<rpc> PRIVATE_KEY=<hex_key>
# 2) Provide a keystore file so forge can ask for passphrase interactively:
#    make deploy-token RPC_URL=<rpc> PRIVATE_KEY_FILE=~/my-keystore.json
# 3) Use an RPC-exposed account/address via `--account` (node must expose the account):
#    make deploy-token RPC_URL=<rpc> ACCOUNT=<address>

.PHONY: deploy-resolver deploy-token deploy-produce deploy-trade deploy-all

# Helper to build extra flags depending on available inputs
ifdef PRIVATE_KEY
FORGE_PRIV_FLAG=--private-key ${PRIVATE_KEY}
else
ifdef PRIVATE_KEY_FILE
FORGE_PRIV_FLAG=--private-key-path ${PRIVATE_KEY_FILE}
else
ifdef ACCOUNT
# Use '--account' flag so forge uses the specified account (preferred over --sender)
FORGE_PRIV_FLAG=--account ${ACCOUNT}
else
FORGE_PRIV_FLAG=
endif
endif
endif

deploy-resolver:
	forge script script/DeployResolver.s.sol:DeployResolver \
		--rpc-url ${RPC_URL} ${FORGE_PRIV_FLAG} --broadcast

deploy-token:
	forge script script/DeployTokenCF.s.sol:DeployTokenCF \
		--rpc-url ${RPC_URL} ${FORGE_PRIV_FLAG} --broadcast

deploy-produce:
	forge script script/DeployProduceNFT.s.sol:DeployProduceNFT \
		--rpc-url ${RPC_URL} ${FORGE_PRIV_FLAG} --broadcast

deploy-trade:
	forge script script/DeployTradeNFT.s.sol:DeployTradeNFT \
		--rpc-url ${RPC_URL} ${FORGE_PRIV_FLAG} --broadcast

deploy-all: deploy-resolver deploy-token deploy-produce deploy-trade
	@echo "All deploy scripts executed"
