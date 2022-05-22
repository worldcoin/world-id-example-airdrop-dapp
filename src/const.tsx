import WalletConnectProvider from "@walletconnect/web3-provider";

export const provider = new WalletConnectProvider({
  rpc: {
    80001: "https://matic-mumbai.chainstacklabs.com",
  },
  clientMeta: {
    name: "katan",
    description: "Biggest airdrop is here! World ID example app.",
    url: "https://github.com/worldcoin/world-id-example-airdrop-dapp",
    icons: [
      document.head.querySelector<HTMLLinkElement>("link[rel~=icon]")!.href,
    ],
  },
});

export const CONTRACT_ADDRESS =
  process.env.WLD_CONTRACT_ADDRESS || // eslint-disable-line @typescript-eslint/prefer-nullish-coalescing
  "0x9337CaE163bCd25D1802C3485AA6B65569d83142";

export const CONTRACT_ABI = [
  // Function to claim the airdrop
  "function claim (address receiver, string memory score, uint256 root, uint256 nullifierHash, uint256[8] calldata proof)",
];
