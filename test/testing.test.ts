import {Actor, HttpAgent, agent} from "@dfinity/agent";
import {Principal} from "@dfinity/principal";
import {expect, test} from "vitest";
import hdkey from "hdkey";
import crypto from "crypto";
import fetch from "isomorphic-fetch";
import bip39 from "bip39";
import {identityFromSeed} from "./identity";
import {createActor} from "./actor";
const host = "http://localhost:8000/";
import {seed1,seed2,seed3} from "./local_env_file.js";
import {idlFactory} from "../src/declarations/relay_wallet_backend/relay_wallet_backend.did.js";
import {idlFactory as ledgerIdlFactory} from "../src/declarations/ledger/ledger.did.js";
import {idlFactory as walletIdlFactory} from "../src/declarations/wallet/wallet.did.js";
import canisterIds from "../.dfx/local/canister_ids.json";
const createWalletCanisterId= canisterIds.relay_wallet_backend.local; 
const ledgerCanisterId = canisterIds.ledger.local;
const seedIdentity= await identityFromSeed(seed1);
const seedIdentity2= await identityFromSeed(seed2);
const seedIdentity3 = await identityFromSeed(seed3);

const seedPrincipal = (await seedIdentity).getPrincipal();
const seedPrincipal2 = (await seedIdentity2).getPrincipal();
const seedPrincipal3 = (await seedIdentity3).getPrincipal();

console.log("seedPrincipal",seedPrincipal.toString());
console.log("seedPrincipal2",seedPrincipal2.toString());
console.log("seedPrincipal3",seedPrincipal3.toString());

const seedOption= {agentOptions: {
  host:host,
  fetch,
  identity: seedIdentity,
}};

const seedOption2= {agentOptions: {
  host: host,
  fetch,
  identity: seedIdentity2,
}};

const seedOption3= {agentOptions: {
  host: host,
  fetch,
  identity: seedIdentity3,
}}

const seedActor = await createActor(createWalletCanisterId,seedOption,idlFactory);
const seedActor2 = await createActor(createWalletCanisterId,seedOption2,idlFactory);
const seedActor3 = await createActor(createWalletCanisterId,seedOption3,idlFactory);
const seedIcpActor= await createActor(ledgerCanisterId,seedOption,ledgerIdlFactory);
const seedIcpActor2= await createActor(ledgerCanisterId,seedOption2,ledgerIdlFactory);
const seedIcpActor3= await createActor(ledgerCanisterId,seedOption3,ledgerIdlFactory);


//basic path of testing approval of icp transfer
//the tests we will run... 
//
//
//
//
//check that seedprincipal2 wallet has the icp sent from seedprincipal1's wallet
//check that seedPrincipal1's wallet amount and approval hasmap has been updated
test("create wallet", async () => {

//first create a wallet with seedprincipal1 using seedActor
//then create a wallet with seedprincipal2 using seedActor2
//get the default account of seedprincipal1's wallet
const seedWalletPrincipal = await seedActor.create_wallet(seedPrincipal);
const seedWallet2Principal = await seedActor2.create_wallet(seedPrincipal2);

//create an actor of principal1's wallet canister using principal1's identity
//create an actor of principal2's wallet canister using principal2's identity
const seedWalletActor = await createActor(seedWalletPrincipal,seedOption,walletIdlFactory);
const seedWalletActor2 = await createActor(seedWalletPrincipal,seedOption2,walletIdlFactory);

//create an actor of principal2's wallet canister using principal2's identity
const seedWallet2Actor2 = await createActor(seedWallet2Principal,seedOption2,walletIdlFactory);

const seedWalletDefaultAccountIdBlob= await seedWalletActor.default_account_blob();
const seedWallet2DefaultAccountIdBlob= await seedWallet2Actor2.default_account_blob();
const seedWalletDefaultAccountIdText= await seedWalletActor.default_account();
const seedWallet2DefaultAccountIdText= await seedWallet2Actor2.default_account();

console.log("text of seedWalletDefaultAccountId",seedWalletDefaultAccountIdText);
console.log("text of seedWallet2DefaultAccountId",seedWallet2DefaultAccountIdText);

//get account id of seedPrincipl
//check balance of the seedPrincipal
const seedPrincipalDefaultAccountIdBlob = await seedActor.callerToAccountId();
const seedPrincipalDefaultAccountIdText = await seedActor.callerToAccountIdText();
console.log("seedPrincipalDefaultAccountIdText",seedPrincipalDefaultAccountIdText);
const seedIcpActorBalance = await seedIcpActor.account_balance({account:seedPrincipalDefaultAccountIdBlob});
console.log("seedIcpActorBalance",seedIcpActorBalance);


//then send icp to the seedPrincipals wallet from seedprincipal
//then recheck the balance of the seedPrincipal
//then check the balance of the seedpPrincipals wallet
const seedIcpActorTransfer = await seedIcpActor.transfer({memo:1,amount:{e8s:100000000},fee:{e8s:10000},from_subaccount:[],to:seedWalletDefaultAccountIdBlob,created_at_time:[]});
const seedIcpActorBalance1 = await seedIcpActor.account_balance({account:seedPrincipalDefaultAccountIdBlob});
var seedActorWalletBalance = await seedIcpActor.account_balance({account:seedWalletDefaultAccountIdBlob});
console.log("seedIcpActorBalance1",seedIcpActorBalance1);
console.log("seedActorWalletBalance",seedActorWalletBalance);


//___TODO:change the seedprincipal approval of seedprincipal2 to approve seedprincipal2's wallet instead, then use call raw on seedprincipal2's wallet to send icp to itself form seedprincipal1's wallet____// 
//approve seedprincipal wallet to allow seedPrincipal2 to send to seedprincpal2's wallet 
//view the approvals of seedPrincipal1's wallet
//transfer the amount to seedPrincipal2's wallet
const seedActorWalletApprove = await seedWalletActor.approve(seedPrincipal2,[],10000000);
var seedActorWalletApprovalMap = await seedWalletActor.get_approval_map();
console.log("seedActorWalletApprovalMap",seedActorWalletApprovalMap);
var seedActor2WalletApprovalMap = await seedWalletActor2.get_approval_map();
console.log("seedActor2WalletApprovalMap",seedActor2WalletApprovalMap);

//try to transfer using seedPrincipal2 with wallet 1
var seedActor2WalletTransfer = await seedWalletActor2.transfer({memo:1,amount:{e8s:490000},fee:{e8s:10000},from_subaccount:[],to:seedWallet2DefaultAccountIdBlob,created_at_time:[]});
//view the balance of seedPrincipal2's wallet
//make sure the balance of seedPrincipal1's wallet has been updated along with the approval hashmap
var seedActor2WalletBalance = await seedIcpActor2.account_balance({account:seedWallet2DefaultAccountIdBlob});
seedActorWalletBalance = await seedIcpActor.account_balance({account:seedWalletDefaultAccountIdBlob});
seedActorWalletApprovalMap = await seedWalletActor.get_approval_map();

console.log("seedActor2WalletTransfer",seedActor2WalletTransfer);
console.log("seedActor2WalletBalance",seedActor2WalletBalance);
console.log("seedActorWalletBalance",seedActorWalletBalance);
console.log("seedActorWalletApprovalMap",seedActorWalletApprovalMap);


//transfer an unauthorized amount from seedPrincipal1's wallet to seedPrincipal2's wallet as seedPrincipal2
seedActor2WalletTransfer = await seedWalletActor2.transfer({memo:1,amount:{e8s:9490001},fee:{e8s:10000},from_subaccount:[],to:seedWallet2DefaultAccountIdBlob,created_at_time:[]});
//view the balance of seedPrincipal2's wallet
//make sure the balance of seedPrincipal1's wallet has been updated along with the approval hashmap
seedActor2WalletBalance = await seedIcpActor2.account_balance({account:seedWallet2DefaultAccountIdBlob});
seedActorWalletBalance = await seedIcpActor.account_balance({account:seedWalletDefaultAccountIdBlob});
seedActorWalletApprovalMap = await seedWalletActor.get_approval_map();
console.log("seedActor2WalletTransfer should be unauthorized",seedActor2WalletTransfer);
console.log("seedActor2WalletBalance",seedActor2WalletBalance);
console.log("seedActorWalletBalance",seedActorWalletBalance);
console.log("seedActorWalletApprovalMap",seedActorWalletApprovalMap);

//transfer from seedPrincipal1's wallet to seedPrincipal2's wallet as seedPrincipal1
const seedActorWalletTransfer = await seedWalletActor.transfer({memo:1,amount:{e8s:490000},fee:{e8s:10000},from_subaccount:[],to:seedWallet2DefaultAccountIdBlob,created_at_time:[]});
seedActor2WalletBalance = await seedIcpActor2.account_balance({account:seedWallet2DefaultAccountIdBlob});
seedActorWalletBalance = await seedIcpActor.account_balance({account:seedWalletDefaultAccountIdBlob});
seedActorWalletApprovalMap = await seedWalletActor.get_approval_map();
console.log("transfer from seedPrincipal1's wallet to seedPrincipal2's wallet as seedPrincipal1",seedActorWalletTransfer);
console.log("seedActor2WalletBalance",seedActor2WalletBalance);
console.log("seedActorWalletBalance",seedActorWalletBalance);
console.log("seedActorWalletApprovalMap",seedActorWalletApprovalMap);


//__todo try flushing the approval aka the full amount left to send.
//__todo try to approve more than the wallet holds, try to send more then wallet holds 
//__todo try to approve more than wallet holds try to send less than wallet holds

},50000);

/*const seedActorPrincipalText = await seedActor.caller_principal_to_account_id_text();
const seedActorPrincipalText2 = await seedActor2.caller_principal_to_account_id_text();
const seedActorPrincipalText3 = await seedActor3.caller_principal_to_account_id_text();
console.log("seedprincipal accountid",seedActorPrincipalText);
console.log("seedprincipal2 accountid",seedActorPrincipalText2);
console.log("seedprincipal3 accountid",seedActorPrincipalText3);

const seedIcpActor= await createActor(ledgerCanisterId,seedOption,ledgerIdlFactory);
const seedIcpActor2= await createActor(ledgerCanisterId,seedOption2,ledgerIdlFactory);
const seedIcpActor3= await createActor(ledgerCanisterId,seedOption3,ledgerIdlFactory);*/
