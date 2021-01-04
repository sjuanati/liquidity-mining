// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "./UnderlyingToken.sol";
import "./LpToken.sol";
import "./GovernanceToken.sol";

contract LiquidityPool is LpToken {
    mapping(address => uint256) public checkpoints; // to calculate the governance tokens reward
    UnderlyingToken public underlyingToken;
    GovernanceToken public governanceToken;
    // inverstors will earn 1 governance token per block for each underlying token they invest
    uint256 public constant REWARD_PER_BLOCK = 1;

    constructor(address _underlyingToken, address _governanceToken) {
        underlyingToken = UnderlyingToken(_underlyingToken);
        governanceToken = GovernanceToken(_governanceToken);
    }

    // investors provide liquidity by depositing underlying tokens
    function deposit(uint256 amount) external {
        if (checkpoints[msg.sender] == 0) {
            checkpoints[msg.sender] = block.number;
        }
        _distributeRewards(msg.sender);
        underlyingToken.transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    // redeem LP tokens
    function withdraw(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "not enough LP tokens");
        _distributeRewards(msg.sender);
        underlyingToken.transfer(msg.sender, amount);
        _burn(msg.sender, amount);
    }

// Prob.1: there could be uncontrolled inflation (the more liquidity provided, the more governance token minted, existing governance token will decrease
// Sol.1: distribute a fixeed amount of Gov tokens for each block for the whole liquidity pool, and this will be shared based on the liquidity of each investor
    function _distributeRewards(address beneficiary) internal {
        uint256 checkpoint = checkpoints[beneficiary];
        if (block.number - checkpoint > 0) {
            // assuming exchange rate between LP token & Underlying token is 1:1
            uint256 distributionAmount =
                balanceOf(beneficiary) *
                    (block.number - checkpoint) *
                    REWARD_PER_BLOCK;
            governanceToken.mint(beneficiary, distributionAmount);
            checkpoints[beneficiary] = block.number;
        }
    }
}
