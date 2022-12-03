/*import { relay_wallet_backend } from "../../declarations/relay_wallet_backend";

document.querySelector("form").addEventListener("submit", async (e) => {
  e.preventDefault();
  const button = e.target.querySelector("button");

  const name = document.getElementById("name").value.toString();

  button.setAttribute("disabled", true);

  // Interact with foo actor, calling the greet method
  const greeting = await relay_wallet_backend.greet(name);

  button.removeAttribute("disabled");

  document.getElementById("greeting").innerText = greeting;

  return false;
});*/
// index.ts
import { Actor, HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
import idlFactory from "./did";
import type { _SERVICE } from "./did";
import { renderIndex } from "./views";
import { renderLoggedIn } from "./views/loggedIn";

const init = async () => {
  const authClient = await AuthClient.create();
  if (await authClient.isAuthenticated()) {
    handleAuthenticated(authClient);
  }
  renderIndex();

  const loginButton = document.getElementById(
    "loginButton"
  ) as HTMLButtonElement;
  loginButton.onclick = async () => {
    await authClient.login({
      onSuccess: async () => {
        handleAuthenticated(authClient);
      },
    });
  };
};

async function handleAuthenticated(authClient: AuthClient) {
  const identity = await authClient.getIdentity();

  const agent = new HttpAgent({ identity });
  console.log(process.env.CANISTER_ID);
  const whoami_actor = Actor.createActor<_SERVICE>(idlFactory, {
    agent,
    canisterId: process.env.CANISTER_ID as string,
  });
  renderLoggedIn(whoami_actor, authClient);
}

init();

