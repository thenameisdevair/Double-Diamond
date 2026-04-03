// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AppStorage} from "../libraries/AppStorage.sol";

contract BorrowerFacet {
    AppStorage internal s;

    event TokenBorrowed(address indexed borrower, uint256 indexed tokenId, uint256 returnTime);
    event TokenReturned(address indexed borrower, uint256 indexed tokenId);

    function borrow(uint256 tokenId, uint256 duration) external {
        require(s.perowner[tokenId] != address(0), "Token does not exist");
        require(!s.borrowRecords[tokenId].active, "Token already borrowed");
        require(s.perowner[tokenId] != msg.sender, "Owner cannot borrow own token");

        // Borrower pays 10 ERC20 tokens as collateral
        uint256 collateral = 10 * 1e18;
        require(s.erc20Balances[msg.sender] >= collateral, "Insufficient collateral");

        s.erc20Balances[msg.sender] -= collateral;
        s.erc20Balances[address(this)] += collateral;

        s.borrowRecords[tokenId] = BorrowRecord({
            borrower: msg.sender,
            returnTime: block.timestamp + duration,
            active: true
        });

        s.perowner[tokenId] = msg.sender;

        emit TokenBorrowed(msg.sender, tokenId, block.timestamp + duration);
    }

    function returnToken(uint256 tokenId) external {
        BorrowRecord storage record = s.borrowRecords[tokenId];
        require(record.active, "Token not borrowed");
        require(record.borrower == msg.sender, "Not borrower");

        address originalOwner = s.perowner[tokenId];

        // Return collateral if returned on time
        uint256 collateral = 10 * 1e18;
        if (block.timestamp <= record.returnTime) {
            s.erc20Balances[msg.sender] += collateral;
            s.erc20Balances[address(this)] -= collateral;
        }

        s.perowner[tokenId] = originalOwner;
        record.active = false;
        record.borrower = address(0);

        emit TokenReturned(msg.sender, tokenId);
    }

    function getBorrowRecord(uint256 tokenId) external view returns (
        address borrower,
        uint256 returnTime,
        bool active
    ) {
        BorrowRecord storage record = s.borrowRecords[tokenId];
        return (record.borrower, record.returnTime, record.active);
    }
}