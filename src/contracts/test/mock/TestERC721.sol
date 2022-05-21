// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { ERC721 } from "solmate/tokens/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract TestERC721 is ERC721('Test NFT', 'TNF') {
    uint256 public currentTokenId;

    function mintTo(address recipient) public payable returns (uint256) {
        uint256 newItemId = ++currentTokenId;
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return Strings.toString(id);
    }
}
