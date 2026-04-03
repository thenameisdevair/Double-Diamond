// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

struct AppStorage {
    // ERC721
    string name;
    string symbol;
    uint256 totalSupply;
    address owner;
    mapping(uint256 => address) perowner;
    mapping(address => uint256) balances;
    mapping(uint256 => address) getapprove;
    mapping(address => mapping(address => bool)) approveOperator;
    mapping(uint256 => string) tokenURIs;

    // ERC20
    string erc20Name;
    string erc20Symbol;
    uint256 erc20TotalSupply;
    uint8 decimals;
    mapping(address => uint256) erc20Balances;
    mapping(address => mapping(address => uint256)) allowance;

    // Multisig
    address[] signers;
    uint256 requiredSignatures;
    mapping(uint256 => MultisigProposal) proposals;
    uint256 proposalCount;

    // Staking
    mapping(address => uint256) stakedTokens;
    mapping(address => uint256) stakeTimestamp;
    mapping(address => uint256) stakingRewards;

    // Marketplace
    mapping(uint256 => Listing) listings;

    // Borrowing
    mapping(uint256 => BorrowRecord) borrowRecords;
}

struct MultisigProposal {
    address target;
    bytes callData;
    uint256 approvals;
    bool executed;
    mapping(address => bool) approved;
}

struct Listing {
    address seller;
    uint256 price;
    bool active;
}

struct BorrowRecord {
    address borrower;
    uint256 returnTime;
    bool active;
    address originalOwner;
}