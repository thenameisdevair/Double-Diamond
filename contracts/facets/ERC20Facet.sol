// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AppStorage} from "../libraries/AppStorage.sol";

contract ERC20Facet {
    AppStorage internal s;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function mint(address to, uint256 amount) external {
        require(msg.sender == s.owner, "Not owner");
        s.erc20Balances[to] += amount;
        s.erc20TotalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(s.erc20Balances[msg.sender] >= amount, "Insufficient balance");
        require(to != address(0), "Zero address");
        s.erc20Balances[msg.sender] -= amount;
        s.erc20Balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "Zero address");
        s.allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(s.erc20Balances[from] >= amount, "Insufficient balance");
        require(s.allowance[from][msg.sender] >= amount, "Insufficient allowance");
        require(to != address(0), "Zero address");
        s.allowance[from][msg.sender] -= amount;
        s.erc20Balances[from] -= amount;
        s.erc20Balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return s.erc20Balances[account];
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return s.allowance[owner][spender];
    }

    function totalSupply() external view returns (uint256) {
        return s.erc20TotalSupply;
    }
}