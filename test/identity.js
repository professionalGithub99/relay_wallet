import { Secp256k1KeyIdentity } from "@dfinity/identity";
import hdkey from "hdkey";
import bip39 from "bip39";
export const identityFromSeed= async(phrase) => {
  const seed = await bip39.mnemonicToSeed(phrase);
  const root = hdkey.fromMasterSeed(seed);
  const addrnode = root.derive("m/44'/223'/0'/0/0");
  return Secp256k1KeyIdentity.fromSecretKey(addrnode.privateKey);
};
