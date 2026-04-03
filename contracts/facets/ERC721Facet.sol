//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import{AppStorage} from "../libraries/AppStorage.sol";



contract NFTBuild {
    AppStorage internal s;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenID);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenID);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    function mint(address to, string memory uri) external {
    require(s.owner == msg.sender);
    s.perowner[s.totalSupply += 1] = to;
    s.balances[to] += 1;
    s.tokenURI[s.totalSupply] = uri;
    emit Transfer(address(0), to, s.totalSupply);
    }

    function transferFrom(address from, address to, uint256 tokenID) external {
        require(s.owner == msg.sender || s.getapprove[tokenID] == msg.sender || s.approveOperator[from][msg.sender]);
        require(to != address(0));
        require(from == s.perowner[tokenID]);

        s.perowner[tokenID] = to;
        s.balances[from] -= 1;
        s.balances[to] += 1;
        delete s.getapprove[tokenID];

        emit Transfer(from, to, tokenID);


    }

    function approve(address to, uint256 tokenID) external {
        require(to != address(0));
        require(msg.sender == s.perowner[tokenID]);

        s.getapprove[tokenID] = to;

        emit Approval(msg.sender, to, tokenID);

    }

    function setApprovalForAll(address to, bool approved) external {
        require(to != address(0));

        s.approveOperator[msg.sender][to] = approved;

        emit ApprovalForAll(msg.sender, to, approved);
    }

    function ownerOf(uint256 tokenID) external view returns(address) {
        return s.perowner[tokenID];
    }

    function balanceOf(address owner) external view returns(uint256) {
        return s.balances[owner];
    }

    function getApproved(uint256 tokenID) external view returns(address) {
        return s.getapprove[tokenID];
    }


    function isApprovedForAll(address owner, address operator) external view returns(bool) {
        return s.approveOperator[owner][operator];
    }

    function tokenURI(uint256 tokenID) external view returns(string memory) {
    return s.tokenURIs[tokenID];
    }   


}