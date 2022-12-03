dfx identity use minter
cp src/relay_wallet_backend/ledger/ledger.private.did src/relay_wallet_backend/ledger/ledger.did
export MINT_ACC=$(dfx ledger account-id)
dfx identity use local_wallet 
export LEDGER_ACC=$(dfx ledger account-id)
export ARCHIVE_CONTROLLER=$(dfx identity get-principal)
export ACCOUNT_ID1=1e125971fdafe356689f31df205921fa359b854d0b288176c43f2f8cbf9c49f5
export ACCOUNT_ID2=7c6d898f4f55dfd4888a0634153536f96328c2c7a1a9f877ecb6d03195f4e1f3
export ACCOUNT_ID3=fd0b9f22446fb08a4850cfb65b94ab4fda937d0f6267bcf327c27fce2ed0753e
dfx deploy --mode reinstall ledger --argument '(record {minting_account = "'${MINT_ACC}'"; initial_values = vec { record { "'${ACCOUNT_ID1}'"; record { e8s=100_000_000_000 } }; record { "'${ACCOUNT_ID2}'"; record { e8s=100_000_000_000 } }; record { "'${ACCOUNT_ID3}'"; record { e8s=300_000_000_000 } };}; send_whitelist = vec {}; archive_options = opt record { trigger_threshold = 2000; num_blocks_to_archive = 1000; controller_id = principal "'${ARCHIVE_CONTROLLER}'" }})'
cp src/relay_wallet_backend/ledger/ledger.public.did src/relay_wallet_backend/ledger/ledger.did
dfx canister call ledger account_balance '(record { account = '$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$ACCOUNT_ID1'")]) + "}")')' })'
dfx canister call ledger account_balance '(record { account = '$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$ACCOUNT_ID2'")]) + "}")')' })'
dfx canister call ledger account_balance '(record { account = '$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$ACCOUNT_ID3'")]) + "}")')' })'
dfx deploy relay_wallet_backend
