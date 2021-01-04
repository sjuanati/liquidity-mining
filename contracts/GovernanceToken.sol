// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

// Only the owner of the contract will be able to mint new governance tokens
contract GovernanceToken is ERC20, Ownable {
    constructor() ERC20('Governance Token', 'GTK') Ownable() {}

    function mint(address to, uint amount) external onlyOwner {
        _mint(to, amount);
    }
}