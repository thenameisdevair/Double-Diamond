// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IBorrower {
    event TokenBorrowed(address indexed borrower, uint256 indexed tokenId, uint256 returnTime);
    event TokenReturned(address indexed borrower, uint256 indexed tokenId);

    function borrow(uint256 tokenId, uint256 duration) external;
    function returnToken(uint256 tokenId) external;
    function getBorrowRecord(uint256 tokenId) external view returns (
        address borrower,
        uint256 returnTime,
        bool active
    );
}