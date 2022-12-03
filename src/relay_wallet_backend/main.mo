import Ledger "canister:ledger";
import CL "mo:conversion_library/Account";
import Wallet "./Wallet";
import Principal "mo:base/Principal";
import ExpCycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
actor {
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
  public shared (msg) func whoami() : async Principal {
        return msg.caller;
  };
};
