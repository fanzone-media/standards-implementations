// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

// interfaces
import "../_LSPs/ILSP1_UniversalReceiver.sol";
import "@openzeppelin/contracts/introspection/ERC165Checker.sol";


// modules
import "./ERC721.sol";


contract ERC721UniversalReceiver is ERC721 {

    bytes4 private constant _INTERFACE_ID_LSP1 = 0x6bb56a14;
    
    bytes32 constant internal _TOKENS_SENDER_INTERFACE_HASH =
    0xb160c0eefa5ecaf0fa0d5581edd09cbd9984167c5ff01e6d46edf4a32f8cb056; // keccak256("ERC721TokensSender")

    bytes32 constant internal _TOKENS_RECIPIENT_INTERFACE_HASH =
    0x1a390d7bc26668ce664c1baefcaf52537fdcf7d739d62afe45eaf38fc9a628f9; // keccak256("ERC721TokensRecipient")
    
    constructor(string memory name, string memory symbol) ERC721(name, symbol) internal {}
    
    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal override returns (bool)
    {

        // if (from.isContract()) {
        //     if (ERC165Checker.supportsERC165(from) && ERC165Checker.supportsInterface(from, _INTERFACE_ID_LSP1)) {
        //         bytes memory encodedData = abi.encodePacked(from, to, tokenId, _data);
        //         ILSP1(from).universalReceiver(_TOKENS_SENDER_INTERFACE_HASH, encodedData);
        //     }
        //     else {
        //         revert("ERC721: transfer to non ERC721Receiver implementer");
        //     }
        // }

        if (to.isContract()) {
            if (ERC165Checker.supportsERC165(to) && ERC165Checker.supportsInterface(to, _INTERFACE_ID_LSP1)) {
                bytes memory encodedData = abi.encodePacked(from, to, tokenId, _data);
                ILSP1(to).universalReceiver(_TOKENS_RECIPIENT_INTERFACE_HASH, encodedData);
            }
            else {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            }
        }
        return true;
    }
}
