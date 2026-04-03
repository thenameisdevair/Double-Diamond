// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;



import {AppStorage} from "../libraries/AppStorage.sol";


contract NFTint {

    AppStorage internal s;

    function init(string memory _name, string memory _symbol, address _owner) external {
        s.name = _name;
        s.symbol = _symbol;
        s.owner = _owner;

    }

}