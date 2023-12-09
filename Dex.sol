// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IPancakeRouter02 {
    function exactInputSingle(
        IPancakeRouter02.ExactInputSingleParams memory params
    ) external returns (uint);

    function exactOutputSingle(
        IPancakeRouter02.ExactOutputSingleParams memory params
    ) external returns (uint);

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }
}

contract DexExchange {
    address private pancakeV2RouterAddress = ""; //YOUR_PANCAKE_V2_ROUTER_ADDRESS
    address private pancakeV3RouterAddress = "";//YOUR_PANCAKE_V3_ROUTER_ADDRESS
    address private bnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Address of BNB token
    address private wbnbAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // Address of WBNB token
    uint24 private v3DefaultFee = 3000;

    IPancakeRouter02 private pancakeV2Router;
    IPancakeRouter02 private pancakeV3Router;

    constructor() {
        pancakeV2Router = IPancakeRouter02(pancakeV2RouterAddress);
        pancakeV3Router = IPancakeRouter02(pancakeV3RouterAddress);
    }

    function swapETHToBNB(uint256 amountIn) external payable {
        address[] memory path = new address[](2);
        path[0] = wbnbAddress;
        path[1] = bnbAddress;

        pancakeV2Router.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp + 1 hours
        );
    }

    function swapBNBToETH(uint256 amountIn) external {
        address[] memory path = new address[](2);
        path[0] = bnbAddress;
        path[1] = wbnbAddress;

        pancakeV2Router.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp + 1 hours
        );
    }

    function swapETHToBNBV3(uint256 amountIn) external payable {
        IPancakeRouter02.ExactInputSingleParams memory params =
            IPancakeRouter02.ExactInputSingleParams({
                tokenIn: wbnbAddress,
                tokenOut: bnbAddress,
                fee: v3DefaultFee,
                recipient: address(this),
                deadline: block.timestamp + 1 hours,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        pancakeV3Router.exactInputSingle(params);
    }

    function swapBNBToETHV3(uint256 amountIn) external {
        IPancakeRouter02.ExactOutputSingleParams memory params =
            IPancakeRouter02.ExactOutputSingleParams({
                tokenIn: bnbAddress,
                tokenOut: wbnbAddress,
                fee: v3DefaultFee,
                recipient: address(this),
                deadline: block.timestamp + 1 hours,
                amountOut: amountIn,
                amountInMaximum: 0,
                sqrtPriceLimitX96: 0
            });

        pancakeV3Router.exactOutputSingle(params);
    }
}
