import { Button } from "@/common/Button/Button";
import { useToggle } from "@/common/hooks/use-toggle";
import { Icon } from "@/common/Icon";
import { CONTRACT_ABI, CONTRACT_ADDRESS, provider } from "@/const";
import { midEllipsis } from "@/utils";
import { defaultAbiCoder as abi } from "@ethersproject/abi";
import successSvg from "@static/success.svg";
import { utils as worldIDUtils, Widget } from "@worldcoin/id";
import { VerificationResponse } from "@worldcoin/id/dist/types";
import cn from "classnames";
import { ethers } from "ethers";
import React from "react";
import { Background } from "./Background/Background";
import { Modal } from "./Modal/Modal";
import type { ModalContent } from "./Modal/modal-variants";
import { modalVariants } from "./Modal/modal-variants";

enum Screen {
  Initial,
  Confirm,
  Congratulations,
}

export const App = React.memo(function App() {
  const [screen, setScreen] = React.useState(Screen.Initial);
  const [worldIDProof, setWorldIDProof] =
    React.useState<VerificationResponse | null>(null);
  const [walletAddress, setWalletAddress] = React.useState("");
  const [txHash, setTxHash] = React.useState(""); // hash of the executed airdrop

  const [modalContent, setModalContent] = React.useState<ModalContent>(
    modalVariants.confirmation,
  );
  const modal = useToggle();

  const connectWallet = React.useCallback(async () => {
    try {
      //  Enable session (triggers QR Code modal)
      provider
        .enable()
        .then(() => {
          setWalletAddress(provider.accounts[0]);
          setScreen(Screen.Confirm);
        })
        .catch((error) => console.error(error));
    } catch (err) {
      console.error(err);
    }
  }, [provider]);

  const logout = () => {
    provider?.disconnect().catch(console.error.bind(console));
    window.location.reload();
  };

  const claimAction = async () => {
    if (!worldIDProof) {
      throw "World ID proof is missing.";
    }

    const web3Provider = new ethers.providers.Web3Provider(provider);
    const daiContract = new ethers.Contract(
      CONTRACT_ADDRESS,
      CONTRACT_ABI,
      web3Provider.getSigner(),
    );

    // eslint-disable-next-line
    const claimResult = await daiContract.claim(
      walletAddress,
      worldIDProof.merkle_root,
      worldIDProof.nullifier_hash,
      abi.decode(["uint256[8]"], worldIDProof.proof)[0],
      { gasLimit: 10000000 },
    );
    setTxHash((claimResult as Record<string, string>).hash);
    console.log("Airdrop claimed successfully!", claimResult);
  };

  const claim = async () => {
    setModalContent(modalVariants.pending);
    modal.toggle("on");

    try {
      await claimAction();
      modal.toggle("off");
      setScreen(Screen.Congratulations);
    } catch (error) {
      console.error("Error executing transaction:", error);
      setModalContent(modalVariants.fail);
    }
  };

  const modalButtonAction = React.useCallback(
    () => modal.toggle("off"),
    [modal],
  );

  return (
    <div className="relative grid h-full w-full content-between bg-0f0b16 px-6 pt-5 xs:px-16 xs:pb-4.5 xs:pt-9">
      <Background />
      <div
        className={cn(
          "relative grid gap-y-10 2xl:gap-y-64",
          { "xs:gap-y-25": screen !== Screen.Congratulations },
          { "xs:gap-y-48": screen === Screen.Congratulations },
        )}
      >
        <header className="flex items-center py-2.5">
          <p
            className="text-20 font-bold text-ffffff xs:text-32"
            style={{ flexGrow: 1 }}
          >
            Mesha
          </p>
          {walletAddress && (
            <div className="font-bold text-ffffff">
              {midEllipsis(walletAddress, 12)}{" "}
              <b>
                -{" "}
                <button
                  className="cursor-pointer font-bold"
                  onClick={logout}
                >
                  Logout
                </button>
              </b>
            </div>
          )}
        </header>

        {screen !== Screen.Congratulations && (
          <div className="grid justify-items-center gap-y-3 justify-self-center text-ffffff xs:gap-y-4">
            <h1 className="text-16 font-bold xs:text-24">
              BIGGEST AIRDROP IS HERE!
            </h1>

            <div className="mt-2 grid justify-items-center text-48 lg:text-80 xs:mt-0 xs:block">
              <span className="font-black text-df57bc ">Get $50 </span>
              <span className="font-black">in Mesha</span>
            </div>

            <p className="mb-5 text-center text-14 xs:mb-8 xs:text-18">
              Mesha is live and ready to use. Login to claim your tokens for
              free.
            </p>

            {screen === Screen.Initial && (
              <div className="grid justify-items-center gap-y-3 ">
                <Button
                  onClick={connectWallet}
                  type="button"
                  className="bg-df57bc hover:bg-df57bc/70"
                >
                  Connect Wallet to Claim
                </Button>

                <p className="text-14 xs:text-12">
                  To test this flow, connect a wallet on Testnet
                </p>
              </div>
            )}

            {screen === Screen.Confirm && (
              <div className="grid w-full max-w-[254px] gap-y-8">
                {walletAddress && (
                  <Widget
                    signal={walletAddress}
                    action_id={worldIDUtils.hashBytes(CONTRACT_ADDRESS).digest}
                    on_success={(proof) => setWorldIDProof(proof)}
                    // eslint-disable-next-line @typescript-eslint/no-empty-function
                    on_error={() => {}}
                  />
                )}

                <Button
                  type="button"
                  className="w-full bg-df57bc hover:bg-df57bc/70"
                  disabled={!worldIDProof}
                  onClick={claim}
                >
                  Claim
                </Button>
              </div>
            )}
          </div>
        )}

        {screen === Screen.Congratulations && (
          <div className="grid max-w-[314px] justify-items-center gap-y-3 justify-self-center">
            <Icon
              src={successSvg}
              className="mb-3 h-12 w-12"
              useMask={false}
            />
            <h1 className="text-24 font-bold text-ffffff xs:text-30">
              CONGRATULATIONS!
            </h1>
            <p className="text-center text-14 text-ffffff xs:text-18">
              Your tokens have been claimed and they are now available in your
              wallet!
            </p>
            <p className="text-center text-14 text-ffffff xs:text-18">
              Your transaction hash is:{" "}
              <code
                title={txHash}
                style={{ maxWidth: 100, fontFamily: "monospace" }}
              >
                {midEllipsis(txHash, 20)}
              </code>{" "}
              (view on{" "}
              <a
                href={`https://mumbai.polygonscan.com/tx/${txHash}`}
                target="_blank"
                style={{ color: "#df57bc" }}
                rel="noreferrer"
              >
                Polygonscan
              </a>
              )
            </p>
          </div>
        )}
      </div>

      {screen === Screen.Initial && (
        <div
          className={cn(
            "relative -mx-6 max-w-[1088px] justify-self-center px-6 xs:w-full",
            "border-t border-df57bc bg-0f0b16 py-3 text-df57bc xs:rounded-10 xs:border xs:text-center",
          )}
        >
          <span>
            Mesha is a mock client app to showcase how World ID works.{" "}
          </span>
          <a
            href="/"
            className="underline decoration-1 transition-opacity hover:opacity-80"
          >
            Learn more
          </a>
        </div>
      )}

      <Modal
        status={modalContent.status}
        description={modalContent.description}
        buttonText={modalContent.button}
        icon={modalContent.icon}
        visibility={modal.state}
        onClick={modalButtonAction}
      />
    </div>
  );
});
