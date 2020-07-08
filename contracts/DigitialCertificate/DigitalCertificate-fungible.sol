// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

import "../../node_modules/erc725/contracts/ERC725/ERC725Y.sol";

abstract contract DigitalCertificate is ERC725Y {

    bytes32[] public storeKeys;

    // TODO add freeze function to allow migration, add default operator us?

    constructor(address _newOwner) ERC725Y(_newOwner) public {
    }

    /* non-standard public functions */

    function storeCount() public view returns (uint256) {
        return storeKeys.length;
    }

    /* Public functions */

    function setData(bytes32 _key, bytes memory _value)
    override
    external
    onlyOwner
    {
        store[_key] = _value;
        storeKeys.push(_key); // 30k more gas on initial set
        emit DataChanged(_key, _value);
    }


    /* Modifers */

}
