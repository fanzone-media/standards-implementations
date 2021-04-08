// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

// modules
import "../Tokens/ERC721-UniversalReceiver.sol";

import "erc725/contracts/ERC725/ERC725Y.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";


contract LSP6UniqueDigitalCollectible is Pausable, ERC725Y, ERC721UniversalReceiver {
    using EnumerableSet for EnumerableSet.AddressSet;

    event tokenCreated(address _to, uint256 _tokenId, uint256 _totalSupply);
    
    uint256 private _currentTokenID = 0;

    bytes32[] public dataKeys;

    mapping (uint256 => address) public creators;

    constructor(
        address newOwner,
        string memory name,
        string memory symbol
    )
    ERC725Y(newOwner)
    ERC721UniversalReceiver(name, symbol)
    public {
    }
    
    /* View functions */
    
    function dataCount() public view returns (uint256) {
        return dataKeys.length;
    }

    function allDataKeys() public view returns (bytes32[] memory) {
        return dataKeys;
    }

    /**
        * @dev calculates the next token ID based on value of _currentTokenID
        * @return uint256 for the next token ID
    */
    function _getNextTokenID() private view returns (uint256) {
        return _currentTokenID.add(1);
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
     @notice Mints a Fanzone NFT AND when minting to a contract checks if the beneficiary is a 721 compatible
     @param _to Recipient of the NFT
     @param _uri URI for the token being minted
     @param _creator Card Creator 
     @return uint256 The token ID of the token that was minted
     */
    function mint(address _to, string calldata _uri, address _creator) public returns(uint256) {

        _assertMintingParamsValid(_uri, _creator);

        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();

        // Mint token and set token URI
        _safeMint(_to, _id);
        _setTokenURI(_id, _uri);

        creators[_id] = _creator;

        return _id;
    }

    /**
     @notice Burns a Fanzone NFT, releasing any composed 1155 tokens held by the token itseld
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

    /**
     @notice Updates the token URI of a given token
     @dev Only creator of token can invoke this method
     @param _id The ID of the token being updated
     @param _uri The new URI
     */
    function setTokenURI( uint256 _id, string calldata _uri) public creatorOnly(_id) {
        _setTokenURI(_id, _uri);
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
    
    /**
        * @dev increments the value of _currentTokenID
    */
    function _incrementTokenTypeId() private  {
        _currentTokenID++;
    }

    /**
     @notice Checks that the URI is not empty and the creator is a real address
     @param _uri URI supplied on minting
     @param _creator Address supplied on minting
     */
    function _assertMintingParamsValid(string calldata _uri, address _creator) pure internal {
        require(bytes(_uri).length > 0, "LSP6UniqueDigitalCollectible._assertMintingParamsValid: Token URI is empty");
        require(_creator != address(0), "LSP6UniqueDigitalCollectible._assertMintingParamsValid: Creator is zero address");
    }
    
    /**
    * @dev Require msg.sender to be the creator of the token id
    */
    modifier creatorOnly(uint256 _id) {
        require(creators[_id] == msg.sender, "ERC1155Tradable#creatorOnly: ONLY_CREATOR_ALLOWED");
        _;
    }
}   
