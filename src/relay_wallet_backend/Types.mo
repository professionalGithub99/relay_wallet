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
};

