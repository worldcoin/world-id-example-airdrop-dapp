import { defaultAbiCoder as abi } from "@ethersproject/abi";
import type { VerificationResponse } from "@worldcoin/id";
import worldID from "@worldcoin/id";
import React from "react";

export const WorldIDComponent = ({
  signal,
  setProof,
}: {
  signal: string;
  setProof: (proof: VerificationResponse) => void;
}): JSX.Element => {
  const enableWorldID = async (): Promise<void> => {
    try {
      const result = await worldID.enable();
      setProof(result);
      console.log("World ID verified successfully: ", result);
    } catch (error) {
      console.error(error);
      enableWorldID().catch(console.error.bind(console));
    }
  };
  React.useEffect(() => {
    if (!worldID.isInitialized()) {
      worldID.init("world-id-container", {
        actionId:
          "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000116d657368614170702f61697264726f7031000000000000000000000000000000",
        signal: abi.encode(["address"], [signal]),
      });
    }
    if (!worldID.isEnabled()) {
      enableWorldID().catch(console.error.bind(console));
    }
  }, []);
  return <div id="world-id-container" />;
};
