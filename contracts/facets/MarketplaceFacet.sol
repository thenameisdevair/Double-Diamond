// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import {AppStorage} from "../libraries/AppStorage.sol";
import {AppStorage, Listing} from "../libraries/AppStorage.sol";

contract MarketplaceFacet {
    AppStorage internal s;

    event Listed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event Unlisted(uint256 indexed tokenId, address indexed seller);
    event Purchased(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);

    function listToken(uint256 tokenId, uint256 price) external {
        require(s.perowner[tokenId] == msg.sender, "Not token owner");
        require(price > 0, "Price must be greater than zero");
        require(!s.listings[tokenId].active, "Already listed");
        require(!s.borrowRecords[tokenId].active, "Token is borrowed");

        s.listings[tokenId] = Listing({
            seller: msg.sender,
            price: price,
            active: true
        });

        emit Listed(tokenId, msg.sender, price);
    }

    function unlistToken(uint256 tokenId) external {
        Listing storage listing = s.listings[tokenId];
        require(listing.active, "Not listed");
        require(listing.seller == msg.sender, "Not seller");

        listing.active = false;

        emit Unlisted(tokenId, msg.sender);
    }

    function buyToken(uint256 tokenId) external {
        Listing storage listing = s.listings[tokenId];
        require(listing.active, "Not listed");
        require(msg.sender != listing.seller, "Seller cannot buy own token");
        require(s.erc20Balances[msg.sender] >= listing.price, "Insufficient balance");

        address seller = listing.seller;
        uint256 price = listing.price;

        // Transfer ERC20 payment
        s.erc20Balances[msg.sender] -= price;
        s.erc20Balances[seller] += price;

        // Transfer NFT ownership
        s.perowner[tokenId] = msg.sender;
        s.balances[seller] -= 1;
        s.balances[msg.sender] += 1;

        // Clear listing and approval
        delete s.listings[tokenId];
        delete s.getapprove[tokenId];

        emit Purchased(tokenId, msg.sender, seller, price);
    }

    function getListing(uint256 tokenId) external view returns (
        address seller,
        uint256 price,
        bool active
    ) {
        Listing storage listing = s.listings[tokenId];
        return (listing.seller, listing.price, listing.active);
    }

    function getListings() external view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 1; i <= s.totalSupply; i++) {
            if (s.listings[i].active) count++;
        }
        uint256[] memory activeListings = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 1; i <= s.totalSupply; i++) {
            if (s.listings[i].active) {
                activeListings[index] = i;
                index++;
            }
        }
        return activeListings;
    }
}