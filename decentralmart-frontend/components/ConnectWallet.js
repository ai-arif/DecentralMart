"use client";

import { useAccount, useConnect, useDisconnect } from "wagmi";
import { injected } from "wagmi/connectors";

export default function ConnectWallet() {
  const { address, isConnected } = useAccount();

  const { connect, isPending } = useConnect();

  const { disconnect } = useDisconnect();

  const handleConnect = () => {
    connect({ connector: injected() });
  };

  const shortenAddress = (addr) => {
    if (!addr) return "";
    return `${addr.slice(0, 6)}...${addr.slice(-4)}`;
  };

  if (isConnected) {
    return (
      <div className="flex items-center gap-3">
        <div>{shortenAddress(address)}</div>
        <button onClick={() => disconnect()}>Disconnect</button>
      </div>
    );
  }

  return (
    <button onClick={handleConnect} disabled={isPending}>
      {isPending ? "Connecting..." : "Connect Wallet"}
    </button>
  );
}
