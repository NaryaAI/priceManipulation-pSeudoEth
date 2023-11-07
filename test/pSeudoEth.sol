// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./interface.sol";
import "../src/factory.sol";
import "../src/pair.sol";
import "../src/router.sol";
import "../src/weth9.sol";
import "../src/pETH.sol";

contract PairCoreSetup is Test {
    IWETH9 public weth;
    ERC20_pETH pETH;

    // uniswapV2系统
    Iu_factory u_factory;
    Iu_router u_router;
    IPair pair;

    uint256 public constant AMOUNT = 100000000000000;
    uint256 public beforeAttack;
    uint256 public afterAttack;

    constructor() public{
        // 部署WETH9
        weth = IWETH9(deployHelper_weth());
        vm.label(address(weth), "weth");

        // 部署漏洞合约
        pETH = new ERC20_pETH("pETH","pETH");
        vm.label(address(pETH), "pETH");

        // 创建uniswapV2系统
        u_factory = Iu_factory(deployHelper_u_factory());
        vm.label(address(u_factory), "u_factory");

        // 部署u_router
        u_router = Iu_router(deployHelper_u_router(address(u_factory), address(weth)));
        vm.label(address(u_router), "u_router");

        // 部署pair
        pair = IPair(u_factory.createPair(address(weth),address(pETH)));
        vm.label(address(pair), "pair");

        // 准备好钱，然后添加流动性
        deal(address(weth),address(this),AMOUNT);
        pETH.mint(AMOUNT);

        // 添加流动性
        weth.approve(address(u_router),type(uint).max);
        pETH.approve(address(u_router),type(uint).max);
        weth.approve(address(pair),type(uint).max);
        pETH.approve(address(pair),type(uint).max);
        u_router.addLiquidity(address(pETH),address(weth),AMOUNT,AMOUNT,0,0,address(this),type(uint).max);


        // 准备之前攻击
        deal(address(weth),address(this),AMOUNT);
        beforeAttack = weth.balanceOf(address(this));

        address[] memory path = new address [](2);
        (path[0], path[1]) = (address(weth), address(pETH));
        u_router.swapExactTokensForTokensSupportingFeeOnTransferTokens( AMOUNT, 0, path, address(this), type(uint).max);
    }

    function exploit() public{
        // this.skim();
        address[] memory path = new address [](2);  
        (path[0], path[1]) = (address(pETH), address(weth));
        uint256 pEth_amount = pETH.balanceOf(address(this));

        u_router.swapExactTokensForTokensSupportingFeeOnTransferTokens(pEth_amount, 0, path, address(this), type(uint).max);

        afterAttack = weth.balanceOf(address(this));
    }

    function skim() public{
        // 由于pETH没有开源，我们无法得知合约的具体实现细节，
        // 但是我们知道，skim的效果是使得用户的balanceOf()余额增多
        deal(address(pETH),address(this),pETH.balanceOf(address(this)) + 10000000000000);
        // beforeAttack = 0;
    }

    // 部署WETH
    function deployHelper_weth() public returns (address addr) {
        bytes memory bytecode = WETH9_BYTECODE;
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
    }

    // 部署u_factory
    function deployHelper_u_factory() public returns (address addr) {
        bytes memory bytecode = BYTECODE_factory;
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

contract callRouter{
    PairCoreSetup instance;
    
    constructor() public{
        instance = new PairCoreSetup();
    }

    function checkIfAttackSuccess() public returns(bool){
        instance.exploit();
        if(instance.beforeAttack() < instance.afterAttack()){
            return true;
        }else{
            return false;
        }
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