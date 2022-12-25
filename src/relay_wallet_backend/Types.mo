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
        #notAllowed;
    };
    
    public type NeuronId = { id : Nat64 };
    public type ConfigureWalletCommand = {
        #addToken: {
            principal: Principal; 
            standard: Text; 
            symbol: Text};
        #removeToken: Principal;
        #addNNSNeuron: {
            #Subaccount : [Nat8];
            #NeuronId : NeuronId;
            };
        #removeNNSNeuron: {
            #Subaccount : [Nat8];
            #NeuronId : NeuronId;
        };
         #addSNSNeuron: {
            #Subaccount : [Nat8];
            #NeuronId : NeuronId;
            };
        #removeSNSNeuron:{
            #Subaccount : [Nat8];
            #NeuronId : NeuronId;
        };
        #addNFT: {
            principal: Principal; 
            standard: Text; 
            collection: Text};
        #removeNFT: Principal;
        #addAllow: { 
            principal: Principal; 
            function: Text; 
            service: Text}; 
        };

    public type ConfigureWalletResponse = {
     #TokenAdded;
     #TokenRemoved;
     #NNSNeuronAdded;
     #NNSNeuronRemoved;
     #SNSNeuronAdded;
     #SNSNeuronRemoved;
     #NFTAdded;
     #NFTRemoved;
     #AllowAdded;
    };
    public type ConfigureWalletError = {
     #TokenAlreadyAdded;
     #TokenDoesNotExist;
     #NNSNeuronAlreadyAdded;
     #NNSNeuronDoesNotExist;
     #SNSNeuronAlreadyAdded;
     #SNSNeuronDoesNotExist;
     #NFTAlreadyAdded;
     #NFTDoesNotExist;
     #AllowAlreadyAdded;
     #Other;
    };

};

