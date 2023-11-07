// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./interface.sol";
import "../src/factory.sol";
import "../src/pair.sol";
import "../src/router.sol";
import "../src/weth9.sol";
import "../src/pETH.sol";

contract deployer{
    // 部署WETH
    function deployHelper_weth(bytes memory _bytecode) public returns (address addr) {
        bytes memory bytecode = _bytecode;
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
    }

    // 部署u_factory
    function deployHelper_u_factory(bytes memory _bytecode) public returns (address addr) {
        bytes memory bytecode = _bytecode;
        // 构造器有参数
        bytes memory bytecode_withConstructor = abi.encodePacked(bytecode, abi.encode(address(msg.sender)));
        assembly {
            addr := create(0, add(bytecode_withConstructor, 0x20), mload(bytecode_withConstructor))
        }
    }

    // 部署u_router
    function deployHelper_u_router(address _u_factory, address _weth) public returns (address addr) {
        bytes memory bytecode = BYTECODE_router;
        // 构造器有参数
        bytes memory bytecode_withConstructor = abi.encodePacked(bytecode, abi.encode(address(_u_factory), address(_weth)));
        assembly {
            addr := create(0, add(bytecode_withConstructor, 0x20), mload(bytecode_withConstructor))
        }
    }
}

contract PairCoreSetup is Test {
    IWETH9 public weth;
    ERC20_pETH public pETH;

    // uniswapV2系统
    Iu_factory public u_factory;
    Iu_router public u_router;
    IPair public pair;

    uint256 public constant AMOUNT = 100000000000000;
    uint256 public beforeAttack;
    uint256 public afterAttack;

    constructor(address _weth, address _u_factory, address _u_router) public{
        // 部署WETH9
        weth = IWETH9(_weth);

        // 部署漏洞合约
        pETH = new ERC20_pETH("pETH","pETH");

        // 创建uniswapV2系统
        u_factory = Iu_factory(_u_factory);

        // 部署u_router
        u_router = Iu_router(_u_router);

        // 部署pair
        pair = IPair(u_factory.createPair(address(weth),address(pETH)));

    }

    function prepare1() public {
        // 准备好钱，然后添加流动性
        // deal(address(weth),address(this),AMOUNT);
        pETH.mint(AMOUNT);

        // 添加流动性
        weth.approve(address(u_router),type(uint).max);
        pETH.approve(address(u_router),type(uint).max);
        weth.approve(address(pair),type(uint).max);
        pETH.approve(address(pair),type(uint).max);
        u_router.addLiquidity(address(pETH),address(weth),AMOUNT,AMOUNT,0,0,address(this),type(uint).max);
    }

    function prepare2() public {
        // 准备之前攻击
        // deal(address(weth),address(this),AMOUNT);
        beforeAttack = weth.balanceOf(address(this));

        address[] memory path = new address [](2);
        (path[0], path[1]) = (address(weth), address(pETH));
        u_router.swapExactTokensForTokensSupportingFeeOnTransferTokens( AMOUNT, 0, path, address(this), type(uint).max);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        address _pETH,
        address _weth
    ) public{
        // this.skim();
        address[] memory path = new address [](2);  
        (path[0], path[1]) = (address(_pETH), address(_weth));
        uint256 pEth_amount = pETH.balanceOf(address(this));

        u_router.swapExactTokensForTokensSupportingFeeOnTransferTokens( pEth_amount, 0, path, address(this), type(uint).max);

        afterAttack = weth.balanceOf(address(this));
    }

    function skim() public{
        // 由于pETH没有开源，我们无法得知合约的具体实现细节，
        // 但是我们知道，skim的效果是使得用户的balanceOf()余额增多
        deal(address(pETH),address(this),pETH.balanceOf(address(this)) + 10000000000000);
        // beforeAttack = 0;
    }


}

contract callRouter{
    PairCoreSetup public instance;
    
    constructor( address _weth, address _u_factory, address _u_router) public{
        instance = new PairCoreSetup(  _weth, _u_factory, _u_router );
    }

    function checkIfAttackSuccess() public returns(bool){
        if(instance.beforeAttack() < instance.afterAttack()){
            return true;
        }else{
            return false;
        }
    }

    function prepare1() public {
        instance.prepare1();
    }

    function prepare2() public {
        instance.prepare2();
    }

    function skim() public{
        instance.skim();
    }
    function swapExactTokensForTokens() public{
        // call to router, but no effect, so we don't do anything
    }
    function addLiquidity() public{
        // call to router, but no effect, so we don't do anything
    }
    function addLiquidityETH() public{
        // call to router, but no effect, so we don't do anything
    }
    function factory() public{
        // call to router, but no effect, so we don't do anything
    }
    function getAmountIn() public{
        // call to router, but no effect, so we don't do anything
    }
    function removeLiquidity() public{
        // call to router, but no effect, so we don't do anything
    }
    function removeLiquidityETH() public{
        // call to router, but no effect, so we don't do anything
    }
    function removeLiquidityETHSupportingFeeOnTransferTokens() public{
        // call to router, but no effect, so we don't do anything
    }
    function removeLiquidityETHWithPermit() public{
        // call to router, but no effect, so we don't do anything
    }
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens() public{
        // call to router, but no effect, so we don't do anything
    }
    function removeLiquidityWithPermit() public{
        // call to router, but no effect, so we don't do anything
    }
    function swapExactETHForTokensSupportingFeeOnTransferTokens() public{
        // call to router, but no effect, so we don't do anything
    }
    function swapExactTokensForETH() public{
        // call to router, but no effect, so we don't do anything
    }
    function swapExactTokensForETHSupportingFeeOnTransferTokens() public{
        // call to router, but no effect, so we don't do anything
    }
    function swapTokensForExactETH() public{
        // call to router, but no effect, so we don't do anything
    }
    function swapExactTokensForTokensSupportingFeeOnTransferTokens() public{
        // call to router, but no effect, so we don't do anything
    }
    function swapTokensForExactTokens() public{
        // call to router, but no effect, so we don't do anything
    }

}