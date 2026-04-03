// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AppStorage} from "../libraries/AppStorage.sol";

contract NFTDiamondInit {
    AppStorage internal s;

    function init(
        string memory _nftName,
        string memory _nftSymbol,
        string memory _erc20Name,
        string memory _erc20Symbol,
        uint8 _decimals,
        address[] memory _signers,
        uint256 _requiredSignatures
    ) external {
        // ERC721
        s.name = _nftName;
        s.symbol = _nftSymbol;

        // ERC20
        s.erc20Name = _erc20Name;
        s.erc20Symbol = _erc20Symbol;
        s.decimals = _decimals;

        // Multisig
        require(_signers.length > 0, "No signers");
        require(_requiredSignatures <= _signers.length, "Invalid threshold");
        for (uint256 i = 0; i < _signers.length; i++) {
            s.signers.push(_signers[i]);
        }
        s.requiredSignatures = _requiredSignatures;

        s.owner = msg.sender;
    }
}