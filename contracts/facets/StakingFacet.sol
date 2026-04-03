// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AppStorage} from "../libraries/AppStorage.sol";

contract StakingFacet {
    AppStorage internal s;

    event Staked(address indexed staker, uint256 indexed tokenId);
    event Unstaked(address indexed staker, uint256 indexed tokenId);
    event RewardsClaimed(address indexed staker, uint256 amount);

    function stake(uint256 tokenId) external {
        require(s.perowner[tokenId] == msg.sender, "Not token owner");
        require(s.stakedTokens[msg.sender] == 0, "Already staking");

        s.perowner[tokenId] = address(this);
        s.stakedTokens[msg.sender] = tokenId;
        s.stakeTimestamp[msg.sender] = block.timestamp;

        emit Staked(msg.sender, tokenId);
    }

    function unstake() external {
        uint256 tokenId = s.stakedTokens[msg.sender];
        require(tokenId != 0, "Nothing staked");

        _calculateRewards(msg.sender);

        s.perowner[tokenId] = msg.sender;
        s.stakedTokens[msg.sender] = 0;
        s.stakeTimestamp[msg.sender] = 0;

        emit Unstaked(msg.sender, tokenId);
    }

    function claimRewards() external {
        require(s.stakedTokens[msg.sender] != 0, "Nothing staked");
        _calculateRewards(msg.sender);

        uint256 rewards = s.stakingRewards[msg.sender];
        require(rewards > 0, "No rewards");

        s.stakingRewards[msg.sender] = 0;
        s.erc20Balances[msg.sender] += rewards;
        s.erc20TotalSupply += rewards;

        emit RewardsClaimed(msg.sender, rewards);
    }

    function _calculateRewards(address staker) internal {
        uint256 timeStaked = block.timestamp - s.stakeTimestamp[staker];
        uint256 rewards = timeStaked * 1e18 / 1 days;
        s.stakingRewards[staker] += rewards;
        s.stakeTimestamp[staker] = block.timestamp;
    }

    function pendingRewards(address staker) external view returns (uint256) {
        if (s.stakedTokens[staker] == 0) return 0;
        uint256 timeStaked = block.timestamp - s.stakeTimestamp[staker];
        return s.stakingRewards[staker] + (timeStaked * 1e18 / 1 days);
    }

    function stakedToken(address staker) external view returns (uint256) {
        return s.stakedTokens[staker];
    }
}