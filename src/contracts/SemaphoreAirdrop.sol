// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { ByteHasher } from './libraries/ByteHasher.sol';
import { ISemaphore } from './interfaces/ISemaphore.sol';


/// @title Semaphore Single Airdrop Manager
/// @author Miguel Piedrafita
/// @notice Template contract for airdropping tokens to Semaphore group members
contract SemaphoreAirdrop is ERC721, ERC721URIStorage{
    using ByteHasher for bytes;

    ///////////////////////////////////////////////////////////////////////////////
    ///                                  ERRORS                                ///
    //////////////////////////////////////////////////////////////////////////////

    /// @notice Thrown when trying to update the airdrop amount without being the manager
    error Unauthorized();

    /// @notice Thrown when attempting to reuse a nullifier
    error InvalidNullifier();

    ///////////////////////////////////////////////////////////////////////////////
    ///                                  EVENTS                                ///
    //////////////////////////////////////////////////////////////////////////////

    /// @notice Emitted when an airdrop is successfully claimed
    /// @param receiver The address that received the airdrop
    event AirdropClaimed(address receiver);

    /// @notice Emitted when the airdropped amount is changed
    /// @param amount The new amount that participants will receive
    event AmountUpdated(uint256 amount);

    ///////////////////////////////////////////////////////////////////////////////
    ///                              CONFIG STORAGE                            ///
    //////////////////////////////////////////////////////////////////////////////

    /// @dev The Semaphore instance that will be used for managing groups and verifying proofs
    ISemaphore internal immutable semaphore;

    /// @dev The Semaphore group ID whose participants can claim this airdrop
    uint256 internal immutable groupId;

    /// @notice The address that manages this airdrop, which is allowed to update the `airdropAmount`.
    address public immutable manager = msg.sender;

    /// @notice The amount of tokens that participants will receive upon claiming
    uint256 public airdropAmount;

    uint256 public currentTokenId;

    /// @dev Whether a nullifier hash has been used already. Used to prevent double-signaling
    mapping(uint256 => bool) internal nullifierHashes;

    ///////////////////////////////////////////////////////////////////////////////
    ///                               CONSTRUCTOR                              ///
    //////////////////////////////////////////////////////////////////////////////

    /// @notice Deploys a SemaphoreAirdrop instance
    /// @param _semaphore The Semaphore instance that will manage groups and verify proofs
    /// @param _groupId The ID of the Semaphore group that will be eligible to claim this airdrop
    constructor(
        ISemaphore _semaphore,
        uint256 _groupId
    )ERC721("NftERC721", "TNFT") {
        semaphore = _semaphore;
        groupId = _groupId;
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                               CLAIM LOGIC                               ///
    //////////////////////////////////////////////////////////////////////////////

    /// @notice Claim the airdrop
    /// @param receiver The address that will receive the tokens
    /// @param root The of the Merkle tree
    /// @param nullifierHash The nullifier for this proof, preventing double signaling
    /// @param proof The zero knowledge proof that demostrates the claimer is part of the Semaphore group
    function claim(
        address receiver,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) public 
    {
        if (nullifierHashes[nullifierHash]) revert InvalidNullifier();
        semaphore.verifyProof(
            root,
            groupId,
            abi.encodePacked(receiver).hashToField(),
            nullifierHash,
            abi.encodePacked(address(this)).hashToField(),
            proof
        );

        nullifierHashes[nullifierHash] = true;
        uint256 tokenId = safeMint(receiver, "example");
    }


    ///////////////////////////////////////////////////////////////////////////////
    ///                               MINTING LOGIC                               ///
    //////////////////////////////////////////////////////////////////////////////

    /// @notice Minting the NFT
    /// @param to The address that will receive the tokens
    /// @param uri URI if the NFT minted
    function safeMint(address to, string memory uri) public returns(uint256){
        uint256 tokenId = ++currentTokenId;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }


    ///////////////////////////////////////////////////////////////////////////////
    ///                               BURN LOGIC                               ///
    //////////////////////////////////////////////////////////////////////////////

    /// @notice Burning the NFT
    /// @param tokenId of the NFT to burn
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }


    ///////////////////////////////////////////////////////////////////////////////
    ///                               GET TOKEN URI LOGIC                               ///
    //////////////////////////////////////////////////////////////////////////////

    /// @notice Getting the URI of NFT
    /// @param tokenId of the NFT to fetch
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                               CONFIG LOGIC                             ///
    //////////////////////////////////////////////////////////////////////////////

    /// @notice Update the number of claimable tokens, for any addresses that haven't already claimed. Can only be called by the deployer
    /// @param amount The new amount of tokens that should be airdropped
    function updateAmount(uint256 amount) public {
        if (msg.sender != manager) revert Unauthorized();

        airdropAmount = amount;
        emit AmountUpdated(amount);
    }
}