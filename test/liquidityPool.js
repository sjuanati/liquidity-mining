const { time } = require('@openzeppelin/test-helpers');
const LiquidityPool = artifacts.require('LiquidityPool.sol');
const GovernanceToken = artifacts.require('GovernanceToken.sol');
const UnderlyingToken = artifacts.require('UnderlyingToken.sol');

contract('LiquidityPool', accounts => {
    const [admin, trader1, trader2, _] = accounts;
    let liquidityPool;
    let governanceToken;
    let underlyingToken;

    beforeEach(async () => {
        // create contract instances
        governanceToken = await GovernanceToken.new();
        underlyingToken = await UnderlyingToken.new();
        liquidityPool = await LiquidityPool.new(underlyingToken.address, governanceToken.address);
        // now only the LiquidityPool contract is admin of GovernanceToken
        await governanceToken.transferOwnership(liquidityPool.address);
        // mint tokens
        await Promise.all([
            underlyingToken.faucet(trader1, web3.utils.toWei('1000')),
            underlyingToken.faucet(trader2, web3.utils.toWei('1000'))
        ]);
    });

    it('should mint 400 governance tokens', async () => {
        await underlyingToken.approve(liquidityPool.address, web3.utils.toWei('100'), { from: trader1 });
        await liquidityPool.deposit(web3.utils.toWei('100'), { from: trader1 });
        await time.advanceBlock();
        await time.advanceBlock();
        await time.advanceBlock();
        await liquidityPool.withdraw(web3.utils.toWei('100'), { from: trader1 });
        const govBalanceTrader1 = await governanceToken.balanceOf(trader1);
        console.log('bal:', web3.utils.fromWei(govBalanceTrader1));
        assert(web3.utils.fromWei(govBalanceTrader1.toString()) === '400');
    })
})