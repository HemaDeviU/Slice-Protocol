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
    function remove()
    {

    }
    function buy()
    {

    }
    function sell()
    {

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