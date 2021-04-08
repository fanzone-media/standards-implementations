// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LSP6UniqueDigitalCollectible.sol";

/**
 * @notice Collection contract for Fanzone NFTs
 */
contract LSP6Collection is Context {
    using SafeMath for uint256;
    using Address for address payable;

    /// @notice Event emitted only on construction. To be used by indexers
    event LSP6CollectionContractDeployed();

    event MintNFTCollection(
        address beneficiary,
        uint256 amount,
        address creator,
        address athlete
    );

    event BurnNFTCollection(
        uint256 collectionId,
        address athlete
    );

    mapping (address => uint256) public athletes;

    /// @notice Parameters of a NFTs Collection
    struct Collection {
        uint256[] tokenIds;
        uint256 amount;
        address creator;
        address athlete;
    }
    /// @notice ERC721 NFT - the only NFT that can be offered in this contract
    LSP6UniqueDigitalCollectible public lsp6Nft;

    /// @notice Array of NFT
    Collection[] private nftCollection;

    /**
     @param _lsp6Nft NFT token address
     */
    constructor(
        LSP6UniqueDigitalCollectible _lsp6Nft
    ) public {
        require(address(_lsp6Nft) != address(0), "LSP6Collection: Invalid NFT");
        lsp6Nft = _lsp6Nft;

        emit LSP6CollectionContractDeployed();
    }

    /**
     @notice Method for mint the NFT collection with the same metadata
     @param _beneficiary Recipient of the NFT collection
     @param _digitalCardAddresses the list of URIs
     @param _amount the amount of copies 
     @param _creator creator address
     @param _athlete athlete address
     */
    function mintCollection(
        address _beneficiary,
        string[] memory _digitalCardAddresses,
        uint256 _amount,
        address _creator,
        address _athlete
    ) external returns (uint256) {

        Collection memory _newCollection = Collection(new uint256[](0), _amount, _creator, _athlete);
        uint256 _collectionId = nftCollection.length;
        nftCollection.push(_newCollection);
        athletes[_athlete] = _collectionId;

        for (uint i = 0; i < _amount; i ++) {
            uint256 _mintedTokenId = lsp6Nft.mint(_beneficiary, _digitalCardAddresses[i], _creator);
            nftCollection[_collectionId].tokenIds.push(_mintedTokenId);
        }

        emit MintNFTCollection(_beneficiary, _amount, _creator, _athlete);
        return _collectionId;
    }

    /**
     @notice Method for burn the NFT collection by given collection id
     @param _collectionId Id of the collection
     */
    function burnCollection(uint256 _collectionId, address _athlete) external {
        Collection storage collection = nftCollection[_collectionId];

        for (uint i = 0; i < collection.amount; i ++) {
            lsp6Nft.burn(collection.tokenIds[i]);
        }
        emit BurnNFTCollection(_collectionId, _athlete);
        delete nftCollection[_collectionId];
        delete athletes[_athlete];
    }

    /**
     @notice Method for getting the collection by given collection id
     @param _collectionId Id of the collection
     */
    function getNftCollection(uint256 _collectionId)
    external
    view
    returns (uint256[] memory _tokenIds, uint256 _amount, address _creator, address _athlete) {
        Collection memory collection = nftCollection[_collectionId];
        return (
            collection.tokenIds,
            collection.amount,
            collection.creator,
            collection.athlete
        );
    }

    /**
     @notice Method for getting the NFT amount for the given address and collection id
     @param _collectionId Id of the collection
     @param _address Given address
     */
    function balanceOfAddress(uint256 _collectionId, address _address) external view returns (uint256) {
        return _balanceOfAddress(_collectionId, _address);
    }

    /**
     @notice Method for checking if someone owns the collection
     @param _collectionId Id of the collection
     @param _address Given address
     */
    function hasOwnedOf(uint256 _collectionId, address _address) external view returns (bool) {
        Collection storage collection = nftCollection[_collectionId];
        uint256 amount = _balanceOfAddress(_collectionId, _address);
        return amount == collection.amount;
    }

    /**
     @notice Internal method for getting the NFT amount of the collection
     */

    function _balanceOfAddress(uint256 _collectionId, address _address) internal virtual view returns (uint256) {
        Collection storage collection = nftCollection[_collectionId];
        uint256 _amount;
        for (uint i = 0; i < collection.amount; i ++) {
            if (lsp6Nft.ownerOf(collection.tokenIds[i]) == _address) {
                _amount = _amount.add(1);
            }
        }
        return _amount;
    }
}
