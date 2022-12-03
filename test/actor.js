import { Actor, HttpAgent } from "@dfinity/agent";
import fetch from "isomorphic-fetch";
export const createActor = async(canisterId,options,idlFactory) => {
        const agent = new HttpAgent({...options?.agentOptions});
        await agent.fetchRootKey();
    return Actor.createActor(idlFactory, {
    agent,
    canisterId,
    ...options?.actorOptions,
  });
};
