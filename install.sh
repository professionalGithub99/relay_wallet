dfx identity use minter
cp src/relay_wallet_backend/ledger/ledger.private.did src/relay_wallet_backend/ledger/ledger.did
export MINT_ACC=$(dfx ledger account-id)
dfx identity use local_wallet 
export LEDGER_ACC=$(dfx ledger account-id)
export ARCHIVE_CONTROLLER=$(dfx identity get-principal)
dfx deploy ledger --argument '(record {minting_account = "'${MINT_ACC}'"; initial_values = vec { record { "'${LEDGER_ACC}'"; record { e8s=100_000_000_000 } }; }; send_whitelist = vec {}; archive_options = opt record { trigger_threshold = 2000; num_blocks_to_archive = 1000; controller_id = principal "'${ARCHIVE_CONTROLLER}'" }})'
cp src/relay_wallet_backend/ledger/ledger.public.did src/relay_wallet_backend/ledger/ledger.did
dfx canister call ledger account_balance '(record { account = '$(python3 -c 'print("vec{" + ";".join([str(b) for b in bytes.fromhex("'$LEDGER_ACC'")]) + "}")')' })'
dfx deploy relay_wallet_backend
