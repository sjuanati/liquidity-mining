// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract UnderlyingToken is ERC20 {
    constructor() ERC20('Lp Token', 'LTK') {}

    // development only
    function faucet(address to, uint amount) external {
        _mint(to, amount);
    }
}
