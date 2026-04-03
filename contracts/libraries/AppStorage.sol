//SPDX-License-Identifer: MIT
pragma solidity ^0.8.24;

struct Appstorage {
    string name;
    string symbol;
    uint256 totalSupply;
    address owner;

    mapping(uint256 => address) perowner;
    mapping(address => uint256) balances;
    mapping(address => uint256) getapprove;
    mapping(address => mapping(address => bool)) approveOperator;
    mapping(uint256 => string) tokenURIs;
}

