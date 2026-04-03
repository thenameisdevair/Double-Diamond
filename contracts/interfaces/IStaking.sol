// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IStaking {
    event Staked(address indexed staker, uint256 indexed tokenId);
    event Unstaked(address indexed staker, uint256 indexed tokenId);
    event RewardsClaimed(address indexed staker, uint256 amount);

    function stake(uint256 tokenId) external;
    function unstake() external;
    function claimRewards() external;
    function pendingRewards(address staker) external view returns (uint256);
    function stakedToken(address staker) external view returns (uint256);
}