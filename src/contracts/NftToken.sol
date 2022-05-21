// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { ERC721 } from "solmate/tokens/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

error MintPriceNotPaid();
error MaxSupply();
error NonExistentTokenURI();
error WithdrawTransfer();

contract NftERC721 is ERC721('Hack Money', 'TNF'), Ownable {
    uint256 public currentTokenId;
    uint256 public constant TOTAL_SUPPLY = 10e10;

    function mintTo(address recipient) 
    public 
    onlyOwner 
    payable 
    returns (uint256) {
        uint256 newItemId = ++currentTokenId;
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    function tokenURI(uint256 id) 
    public 
    view 
    virtual 
    override 
    returns (string memory) {
        return Strings.toString(id);
    }
}
