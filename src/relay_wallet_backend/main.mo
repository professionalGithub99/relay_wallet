import Ledger "canister:ledger";
import CL "mo:conversion_library/Account";
import Wallet "./Wallet";
import Principal "mo:base/Principal";
import ExpCycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Management "./Management";
actor {
    var managementActor:Management.Self = actor("aaaaa-aa");
//create some kind of monitoring system to print the amount of cycles in the current canister and also the new canister. Curious is creating a new canister is a linear function of the amount of cycles you add.
  public func create_wallet(_owner:Principal) : async Principal{
    Debug.print("balance "#debug_show(ExpCycles.balance()));
    Debug.print("available"#debug_show(ExpCycles.available()));
    ExpCycles.add(200000000000);
    let new_wallet = await Wallet.Wallet(_owner); 
    return Principal.fromActor(new_wallet);
  };
  public func blobToPrincipal(blob:Blob) : async Principal {
    return Principal.fromBlob(blob);
  };
  public func PrincipalToBlob(principal:Principal) : async Blob {
    return Principal.toBlob(principal);
  };
  public shared({caller}) func  callerToAccountId() : async Blob {
    return CL.accountIdentifier(caller,CL.defaultSubaccount());
  };
  public shared({caller}) func callerToAccountIdText():async Text {
    return CL.accountIdBlobToText(CL.accountIdentifier(caller,CL.defaultSubaccount()));
  };
  public shared (msg) func whoami() : async Principal {
        return msg.caller;
  };
  //first check ExpCycles.balance() and then ExpCycles.available() and then ExpCycles.add(200000000000) and then ExpCycles.balance() and then ExpCycles.available() then view avaialable() again.
  public shared({caller}) func testExpirementalCycles():async Nat{
    Debug.print(" ");
    Debug.print("balance pre create"#debug_show(ExpCycles.balance()));
    Debug.print("available"#debug_show(ExpCycles.available()));
    ExpCycles.add(200000000000);
    let new_wallet = await Wallet.Wallet(caller);
    Debug.print("balance post create"#debug_show(ExpCycles.balance()));
    Debug.print("refunded"#debug_show(ExpCycles.refunded()));
    let new_wallet_status = await managementActor.canister_status({canister_id = Principal.fromActor(new_wallet)});
    Debug.print("new walllet cycles"#debug_show(new_wallet_status.cycles));
    ExpCycles.add(200000000000);
    Debug.print("balance before sending toWallet"#debug_show(ExpCycles.balance()));
    await managementActor.deposit_cycles({canister_id = Principal.fromActor(new_wallet)});
    Debug.print("balance after sending toWallet"#debug_show(ExpCycles.balance()));
    let wallet_new_status_post_topup= await managementActor.canister_status({canister_id = Principal.fromActor(new_wallet)});
    Debug.print("new walllet cycles post topup"#debug_show(wallet_new_status_post_topup.cycles));
    
    return ExpCycles.available();
  };
};
