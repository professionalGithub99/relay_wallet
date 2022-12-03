import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Hex "mo:conversion_library/Hex";
import Map "mo:hashmap/Map";
import Nat64 "mo:base/Nat64";
module{
  let {thash} = Map;
  public type HashUtils<K> = Map.HashUtils<K>;
  public func principal_blob_to_text(_principal:Principal, _blob:Blob):Text
  {
    let principal = Principal.toText(_principal);
    let blob = Hex.encode(Blob.toArray(_blob));
    return principal#blob;
  }; 
    public func remove_or_put<K, V>(isZero: (V) -> Bool, map: Map.Map<K, V>, hashUtils: HashUtils<K>, keyParam: K,_value:V):?V{
    if(isZero(_value) == false){
      return Map.put(map,hashUtils,keyParam,_value);
    }
    else{
      return Map.remove(map,hashUtils,keyParam);
    };
  };
  public func isZeroNat64(value:Nat64):Bool{
    return (value == 0);
  };

};
