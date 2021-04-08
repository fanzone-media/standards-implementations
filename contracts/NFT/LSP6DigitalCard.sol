// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

// modules
import "erc725/contracts/ERC725/ERC725Y.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract LSP6DigitalCard is Pausable, ERC725Y {

    // Here to track token holders, for future migration TODO remove in main chain
    // makes transfers to expensive
    bytes32[] public dataKeys;


    constructor(
        address newOwner
    )
    ERC725Y(newOwner)
    public {}

    // Here to track allow future migration TODO remove in main chain
    function pause()
    external
    whenNotPaused
    {
        _pause();
    }

    // Here to track allow future migration TODO remove in main chain
    function unpause()
    external
    whenPaused
    {
        _unpause();
    }

    function dataCount() public view returns (uint256) {
        return dataKeys.length;
    }

    function allDataKeys() public view returns (bytes32[] memory) {
        return dataKeys;
    }

    /* Public functions */

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
