// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";



// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "hardhat/console.sol";
// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";
// We inherit the contract we imported. This means we'll have access
// to the inherited contract's meth2ods.
contract KatanNFT is ERC721URIStorage, Ownable{
  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
  // So, we make a baseSvg variable here that all our NFTs can use.
  string baseSvg = '<svg width="240" height="320" viewBox="0 0 540 320" fill="green"><text x="15" y="170">';
  string svg2 = '</text> <text x="250" y="220">';
  constructor() ERC721 ("KatanNFT", "KTN") {
    console.log("This is my NFT contract");
  }


  event NewKatanNFTMinted(string sndr, uint256 tokenId);

  function getScore(string memory sndr) external view returns (uint256) {
    return addscore[sndr];
  }

  function st2num(string memory numString) public pure returns(uint) {
        uint  val=0;
        bytes   memory stringBytes = bytes(numString);
        for (uint  i =  0; i<stringBytes.length; i++) {
            uint exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
           uint jval = uval - uint(0x30);
   
           val +=  (uint(jval) * (10**(exp-1))); 
        }
      return val;
    }
  mapping(string => uint256) addscore;

  function mint(string memory score, string memory adr) public { 
    uint256 newItemId = _tokenIds.current();
    string memory finalSvg = string(abi.encodePacked("<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 500 500'><defs><linearGradient id='myGradient'><stop offset='10%' stop-color='#49ab81' /><stop offset='95%' stop-color='#317256' /></linearGradient></defs><g stroke='black' fill=\"url('#myGradient')\" strokeWidth='10'><path d='M539,1 L1,1 L1,329 L463,329 L493,300 L539,300 Z'/></g><rect width='100%' height='100%' fill='none'/> <text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle' font-size='3em'> Karma:", score, "</text><text x= '50px' y= '100px'>",adr,"</text></svg>"));
    //string(abi.encodePacked(baseSvg, adr, svg2, "bruh",'</text></svg>'));

    //mapping to store score for each address
    addscore[adr] = st2num(score);
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    score,
                    '", "description": "Your credit NFT score.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );
    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
  
    // We'll be setting the tokenURI later!
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
  }
  
}