// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AppStorage} from "../libraries/AppStorage.sol";
import {Base64} from "../libraries/Base64.sol";

contract SVGFacet {
    AppStorage internal s;

    function setTokenSVG(uint256 tokenId, string memory svg) external {
        require(msg.sender == s.owner, "Not owner");
        require(s.perowner[tokenId] != address(0), "Token does not exist");
        s.tokenURIs[tokenId] = svg;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(s.perowner[tokenId] != address(0), "Token does not exist");
        string memory svg = s.tokenURIs[tokenId];

        string memory json = string(abi.encodePacked(
            '{"name": "', s.name, ' #', _toString(tokenId), '",',
            '"description": "On-chain NFT",',
            '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'
        ));

        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        ));
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}