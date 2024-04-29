//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "solmate/tokens/ERC20.sol";
import "solmate/tokens/ERC721.sol";
import "openzeppelin/utils/math/Math.sol";
import "solmate/utils/SafeTransferLib.sol";
import "solmate/utils/MerkleProofLib.sol";
import "openzeppelin/utils/cryptography/MerkleProof.sol";
import "./LpToken.sol";
impoty "./interfaces/ISlice.sol";

contract Pair {
    using SafeTransferLib for address;
    using SafeTransferLib for ERC20;
    address public immutable nft;
    address public immutable baseToken; // address(0) for ETH
    bytes32 public immutable merkleRoot;

    LpToken public immutable lpToken;
    ISlice public immutable slice;

    event Add(uint256 baseTokenAmount,uint256 fractionalTokenAmount,uint256 lpTokenAmount);

    constructor(address _nft,address _baseToken,bytes32 _merkleRoot,string memory pairSymbol,string memory nftName,string memory nftSymbol) 
        ERC20(string.concat(nftName,"fractional token"),string.concat("f",nftSymbol),18)
    {
        nft = _nft;
        baseToken = _baseToken;
        merkleRoot = _merkleRoot;
        slice = ISlice(msg.sender);
        lpToken = new LpToken(pairSymbol);
    }



    }
    //AMM logic
    function add(uint256 baseTokenAmount,uint256 fractionalTokenAmount,uint256 minLpTokenAmount)public payable returns (uint256 lpTokenAmount)
    {
        require(baseTokenAmount >0 && fractionalTokenAmount > 0,"Input token amount is zero");
        lpTokenAmount = addQuote(baseTokenAmount, fractionalTokenAmount);

    require(ipTokenAmount >= minLpTokenAmount,"Slippage:lp token amount out");
    require(baseToken == address(0) ? msg.value == baseTokenAmount : msg.value == 0, "Invalid ether input");
        if (baseToken != address(0))
        {
         ERC20(baseToken).safeTransferFrom(msg.sender,address(this),baseTokenAmount);
        }
    _transferFrom(msg.sender, address(this), fractionalTokenAmount);
    lpToken.mint(msg.sender, lpTokenAmount);
emit Add(baseTokenAmount, fractionalTokenAmount, lpTokenAmount);


    }
    function remove(uint256 lpTokenAmount,uint256 minBaseTokenOutputAmount,uint256 minFractionalTokenOutputAmount)public returns (uint256 baseTokenOutputAmount,uint256 fractionalTokenOutputAmount)
    {
        (baseTokenOutputAmount, fractionalTokenOutputAmount) = removeQuote(lpTokenAmount);

        require(baseTokenOutputAmount >= minBaseTokenOutputAmount,"Slippage: base token amount out");
        require(fractionalTokenOutputAmount >= minFractionalTokenOutputAmount,"Slippage: fractional token amount out");
        _transferFrom(address(this), msg.sender, fractionalTokenOutputAmount);

        lpToken.burn(msg.sender, lpTokenAmount);

        if (baseToken == address(0)) {
            msg.sender.safeTransferETH(baseTokenOutputAmount);
        } else {
            ERC20(baseToken).safeTransfer(msg.sender, baseTokenOutputAmount);
        }

        emit Remove(baseTokenOutputAmount,fractionalTokenOutputAmount,lpTokenAmount);

    }
    function buy( uint256 outputAmount,uint256 maxInputAmount) public payable returns (uint256) {
        uint256 inputAmount = buyQuote(outputAmount);
        require(inputAmount <= maxInputAmount, "Slippage: amount in");
        require(baseToken == address(0)? msg.value == maxInputAmount: msg.value == 0,"Invalid ether input");
        _transferFrom(address(this), msg.sender, outputAmount);

        if (baseToken == address(0)) {
            uint256 refundAmount = maxInputAmount - inputAmount;
            if (refundAmount > 0) msg.sender.safeTransferETH(refundAmount);
        } else {
            ERC20(baseToken).safeTransferFrom(msg.sender,address(this),inputAmount);
        }

        emit Buy(inputAmount, outputAmount);

        return inputAmount;

    }
    function sell(uint256 inputAmount, uint256 minOutputAmount) public returns (uint256) {
        uint256 outputAmount = sellQuote(inputAmount);
        require(outputAmount >= minOutputAmount, "Slippage: amount out");
        _transferFrom(msg.sender, address(this), inputAmount);
        if (baseToken == address(0)) {
            msg.sender.safeTransferETH(outputAmount);
        } else {
            ERC20(baseToken).safeTransfer(msg.sender, outputAmount);
        }

        emit Sell(inputAmount, outputAmount);

        return outputAmount;
    }

 //nft amm
    function nftAdd()
    {

    }
    function nftRemove()
    {

    }
    function nftBuy()
    {

    }
    function nftSell()
    {

    }
    //wraps
    function wrap()
    {

    }
    function unwrap()
    {

    }
    function _transferFrom()
    {

    }
    //defender
    function exit() public
    {

    }
    //getters
    function price(){}
    function baseTokenReserves(){}
    function fractionalTokenReserves(){}
     

}