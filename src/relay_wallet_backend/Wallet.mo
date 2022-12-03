import Account "mo:conversion_library/Account";
import Map "mo:hashmap/Map";
import Cycles "mo:base/ExperimentalCycles";
import ExpIC "mo:base/ExperimentalInternetComputer";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Ledger "canister:ledger";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import T "./Types";
import IC "./IC";
import Management "./Management";
import Utils "./Utils";


//approve transfer create wallet workflow
//check canister. If not exist and not full, create wallet 

actor class Wallet(_owner:Principal) = this
{
  
  public type CallResult = T.CallResult;
  var owner:Principal = _owner;
  var icp_fee:Nat64 = 10000;
  let {thash} = Map;
  let icp_approval_map= Map.new<Text,Nat64>();
  let ic = actor("aaaaa-aa"):IC.IC;
  let managementActor = actor("aaaaa-aa"):Management.Self;
  var tx_count:Nat = 0;
 

  public shared({caller}) func call(_principal:Principal,_function:Text,_data:Blob): async CallResult 
  {
    var expICCall = await ExpIC.call(_principal,_function,_data);
    return #reply(expICCall);
  };
  public shared({caller}) func cycles_balance() : async Nat {
    assert(caller == owner);
    var canister_status = await managementActor.canister_status({canister_id = Principal.fromActor(this)});
    return canister_status.cycles;      
  };
  func _default_account_blob():Blob
  {
    let account = Account.accountIdentifier(Principal.fromActor(this),Account.defaultSubaccount());
    return account;
  };

public func default_account():async Text
  {
    var accountIdBlob = _default_account_blob();
    return Account.accountIdBlobToText(accountIdBlob);
  };

  public query func default_account_blob():async Blob
  {
     return _default_account_blob();
  };
  public query func get_approval_map():async [(Text,Nat64)]
  {
    return Iter.toArray(Map.entries<Text,Nat64>(icp_approval_map));
  };

  //approve first checks whether _from_subaccount is a 32 byte array
  //if so, it puts together _sender and _from_subaccount
  public shared({caller}) func approve(_sender:Principal,_from_subaccount:?Ledger.SubAccount, _amount:Nat64) : async T.TxReceipt{
    if(_amount > icp_fee){
      if(caller ==_owner){
        //first check to make sure subaccount is only 32 bytes
        switch(_from_subaccount){
          case(? subaccount){
            switch(subaccount.size()){
              case(32){
                var principal_blob_hash = Utils.principal_blob_to_text(_sender,subaccount);
                Map.set<Text,Nat64>(icp_approval_map,thash, principal_blob_hash ,_amount);
                tx_count:=tx_count+1;
                return #Ok(tx_count);
              };
              case(_){
                return #Err(#InvalidSubaccount);
              };
            };
          };
          case(_){
            var principal_hash = Principal.toText(_sender);
            Map.set<Text,Nat64>(icp_approval_map,thash, principal_hash ,_amount);
            tx_count:=tx_count+1;
           return #Ok(tx_count);
          };
        };
      }
      else{
        return #Err(#Unauthorized);
      };
    }
    else{
      return #Err(#AmountTooSmall);
    };
  };

  public shared({caller}) func transfer(_transfer_args:Ledger.TransferArgs): async T.TxReceipt{
    //check whether caller is owner or another user
    //if the caller is the user use the ledger and transfer
    //otherwise check hash the caller and _transfer_args.from_subaccount
    //the amount available to transfer in the icp_approval_map
    //if enough transfer then send from wallet
    //else return an #Err(#InsufficientAllowance)
    var text_hash:Text = "";
    var approved_amount:Nat64 = 0;
    var transfer_response:Ledger.TransferResult= #Ok(Nat64.fromNat(1));
    switch(Principal.equal(caller,owner)){
      case(true){
transfer_response:= await Ledger.transfer(_transfer_args);
      };
      case(false){
        //first check if _from_subaccount is null
        //if not, the principal alone is the key
        //then check if it is 32 bytes
        //if it is, hash it with the caller and make that the search key
        //if it is not return an #Err(#InvalidSubaccount)
        //using the key, check whether it exists in the icp_approval_map
        //if so, if ensure token fee + amount > the value from the hashmap throw an error
        //if not, try to transfer
        //get the response from the attempted transfer
        //if ok return a tx count
        //if not throw an error
        switch(_transfer_args.from_subaccount){
          case(? from_subaccount){
            switch(from_subaccount.size()){
              case(32){text_hash := Utils.principal_blob_to_text(caller,from_subaccount); };
                                  case(_){return #Err(#InvalidSubaccount);};
            };
          };
          case(_){text_hash := Principal.toText(caller);};
        };
        switch(Map.get(icp_approval_map,thash,text_hash)){
          case(? amount_approved){
            if(amount_approved >= (_transfer_args.fee.e8s + _transfer_args.amount.e8s)){
              //subtract and remove amount first
              approved_amount := amount_approved;
              var attempted_transfer_amount:Nat64 = 0;
              attempted_transfer_amount := (_transfer_args.fee.e8s + _transfer_args.amount.e8s);
              Debug.print("attempted_transfer_amount"#debug_show(attempted_transfer_amount));
              var prev_value = Utils.remove_or_put<Text,Nat64>(Utils.isZeroNat64,icp_approval_map,thash,text_hash, approved_amount - attempted_transfer_amount);
              Debug.print("prev_value"#debug_show(prev_value));
              //THERE IS A LOGICAL REASON FOR US TO SUBTRACT THE AMOUNT FIRST!!!
              //IN THE OFF CHANCE THE LEDGER SENDS ICP BUT IS UNABLE TO REMOVE FROM THE APPROVAL ALLOWANCE, THE APPROVED PERSON MAY BE ABLE TO SEND TWICE THE APPROVED AMOUNT.
              //IN THE CASE WHERE WE SUBTRACT APPROVAL FIRST, THEN RE-ADD THE AMOUNT IF THERE IS A TRANSFER FAILURE, THIS CASE IS NOT AS BAD
              //THE WORST THING THAT HAPPENS IS ESSENTIALLY A CANCELLED APPROVAL THAT MAY HAVE TO BE APPROVED AGAIN
transfer_response:= await Ledger.transfer(_transfer_args);
            }
            else{
              return #Err(#InsufficientAllowance);
            };
          };
          case(_){
            return #Err(#Unauthorized);
          };
        };
      };
    };
        switch(transfer_response){
          case(Ok ){
            tx_count+=1;
            return #Ok(tx_count);};
          case(_){
          var put_back_value = Utils.remove_or_put<Text,Nat64>(Utils.isZeroNat64,icp_approval_map,thash,text_hash, approved_amount);
          return #Err(#Other("failed during transfer"));};
        };
    };

    public shared (msg) func public_key() : async { #Ok : { public_key: Blob }; #Err : Text } {
      let caller = Principal.toBlob(msg.caller);
      try {
        let { public_key } = await ic.ecdsa_public_key({
            canister_id = null;
            derivation_path = [ caller ];
            key_id = { curve = #secp256k1; name = "dfx_test_key" };
            });
#Ok({ public_key })
      } catch (err) {
#Err(Error.message(err))
      }
    };
    public shared (msg) func sign(message_hash: Blob) : async { #Ok : { signature: Blob };  #Err : Text } {
      assert(message_hash.size() == 32);
      let caller = Principal.toBlob(msg.caller);
      try {
        Cycles.add(10_000_000_000);
        let { signature } = await ic.sign_with_ecdsa({
            message_hash;
            derivation_path = [ caller ];
            key_id = { curve = #secp256k1; name = "dfx_test_key" };
            });
#Ok({ signature })
      } catch (err) {
#Err(Error.message(err))
      }
    };

  };
