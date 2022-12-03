module {
 public type TxReceipt = {
    #Ok:Nat;
    #Err: {
        #TxSuccessArchiveFailed;
         #InsufficientAllowance;
         #InvalidSubaccount;
         #InsufficientBalance;
         #ErrorOperationStyle;
         #Unauthorized;
         #LedgerTrap;
         #ErrorTo;
         #Other: Text;
         #BlockUsed;
         #AmountTooSmall;
    };
  };  
   public type CallResult = {
        #reply: Blob;
        #proposal: Nat; //sha256 of ["wallet_proposal"] + [Principal of self] + ["nonce"] + [stable Nonce]
    };
};

