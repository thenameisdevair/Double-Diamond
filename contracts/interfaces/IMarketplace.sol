// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IMarketplace {
    event Listed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event Unlisted(uint256 indexed tokenId, address indexed seller);
    event Purchased(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);

    function listToken(uint256 tokenId, uint256 price) external;
    function unlistToken(uint256 tokenId) external;
    function buyToken(uint256 tokenId) external;
    function getListing(uint256 tokenId) external view returns (address seller, uint256 price, bool active);
    function getListings() external view returns (uint256[] memory);
}