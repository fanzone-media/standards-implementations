// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

// modules
import "../DigitialCertificate/LSP4DigitalCertificate.sol";

contract LSP7ReputationBadge is  LSP4DigitalCertificate {
        // Issuer of reputation badge
        address private _issuer;

        constructor(
            address _owner,
            string memory name,
            string memory symbol,
            address[] memory defaultOperators
        ) 
        
        LSP4DigitalCertificate(_owner, name, symbol, defaultOperators)
        public {
             // set the issuer
            _issuer = _owner;
        }

        modifier onlyIssuer(address recipient) {
            if(_msgSender() != _issuer) {
                require(recipient == _issuer, 
                "LSP7ReputationBadge: transfer to non-issuer");
            }
            _;
        }


        function getIssuer() public view returns (address) {
            return _issuer;
        }

        // recipient can either be the zero address or issuer
        function transfer(address recipient, uint256 amount) public override onlyIssuer(recipient) returns (bool) {
            require(recipient != address(0), "LSP7ReputationBadge: transfer to the zero address");

            address from = _msgSender();

            _callTokensToSend(from, from, recipient, amount, "", "");

            _move(from, from, recipient, amount, "", "");

            _callTokensReceived(from, from, recipient, amount, "", "", false);

            return true;
        }

        function send(address recipient, uint256 amount, bytes memory data) public override virtual onlyIssuer(recipient) {
            _send(_msgSender(), recipient, amount, data, "", true);
        }
}