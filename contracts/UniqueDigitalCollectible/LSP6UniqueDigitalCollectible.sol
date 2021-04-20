// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

// modules
import "../ERC725/ERC725Y.sol";
import "../Tokens/ERC721-UniversalReceiver.sol";

import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";


contract LSP6UniqueDigitalCollectible is Pausable, ERC725Y, ERC721UniversalReceiver {
    using EnumerableSet for EnumerableSet.UintSet;
    
    uint256 private _currentTokenID = 1;

    /// @notice the array list of key in ERC725Y standard.
    bytes32[] public dataKeys;

    /// @notice token id -> creator address of NFT
    mapping (uint256 => address) public creators;

    constructor(
        address newOwner,
        string memory name,
        string memory symbol,
        string memory baseURI
    )
    ERC725Y(newOwner)
    ERC721UniversalReceiver(name, symbol)
    public {
        _setBaseURI(baseURI);
    }
    
    /* View functions */
    
    function dataCount() public view returns (uint256) {
        return dataKeys.length;
    }

    function allDataKeys() public view returns (bytes32[] memory) {
        return dataKeys;
    }

    /* Public functions */

    /**
     * @notice Here to track allow future migration TODO remove in main chain
     */
    function pause()
    external
    whenNotPaused
    {
        _pause();
    }

    /**
     * @notice Here to track allow future migration TODO remove in main chain
     */
    function unpause()
    external
    whenPaused
    {
        _unpause();
    }

    /**
     * @notice Sets the key/value pair
     * @param _key bytes32 the key of the metadata
     * @param _value bytes the value of the metadata
     */
    function setData(bytes32 _key, bytes memory _value)
    external
    override
    onlyOwner
    {
        if(store[_key].length == 0) {
            dataKeys.push(_key); // 30k more gas on initial set
        }
        store[_key] = _value;
        emit DataChanged(_key, _value);
    }

    /**
     @notice Mints a NFT AND when minting to a contract checks if the beneficiary is a 721 compatible
     @param _to Recipient of the NFT
     @return uint256 The token ID of the NFT that was minted
     */
    function mint(address _to) public returns(uint256) {
        require(_to != address(0), "LSP6UniqueDigitalCollectible.mint: Recipient is zero address");

        uint256 _id = _currentTokenID++;

        // Mint token and set token URI
        _safeMint(_to, _id);

        // Set creator address of token Id
        creators[_id] = _to;

        return _id;
    }

    /**
     @notice Mints a bunch of NFTs AND checks if the recipient contract is a 721 compatible
     @param _to Recipient of the NFT
     @param _amount amount of copies
     */
    function mintMany(address _to, uint256 _amount) public {
        require(_to != address(0), "LSP6UniqueDigitalCollectible.mintMany: Recipient is zero address");

        for(uint256 i = 0 ; i < _amount; i++) {
            uint256 _id = _currentTokenID++;

            // Mint token and set token URI
            _safeMint(_to, _id);

            // Set creator address of token Id
            creators[_id] = _to;
        }
    }

    /**
     @notice Burns a NFT
     @dev Only the owner or an approved sender can call this method
     @param _tokenId the token ID to burn
     */
    function burn(uint256 _tokenId) external {
        require(_exists(_tokenId), "LSP6UniqueDigitalCollectible.burn: nonexistent token");
        require(
            _isApprovedOrOwner(msg.sender, _tokenId), "LSP6UniqueDigitalCollectible.burn: Only garment owner or approved"
        );
        
        // Destroy token mappings
        _burn(_tokenId);

        // Clean up designer mapping
        delete creators[_tokenId];
    }

    /* Internal functions */

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner)
    public
    override
    onlyOwner
    {
        Ownable.transferOwnership(newOwner);
    }
}   
