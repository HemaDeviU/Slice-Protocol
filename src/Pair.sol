//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "solmate/tokens/ERC20.sol";
import "solmate/tokens/ERC721.sol";
import "openzeppelin/utils/math/Math.sol";
import "solmate/utils/SafeTransferLib.sol";
import "solmate/utils/MerkleProofLib.sol";
import "openzeppelin/utils/cryptography/MerkleProof.sol";
import "./LpToken.sol";
import "./interfaces/ISlice.sol";

contract Pair {
    using SafeTransferLib for address;
    using SafeTransferLib for ERC20;
    address public immutable nft;
    address public immutable baseToken; // address(0) for ETH
    bytes32 public immutable merkleRoot;

    LpToken public immutable lpToken;
    ISlice public immutable slice;
    uint256 public closeTimestamp;

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

    function nftAdd(uint256 baseTokenAmount,uint256[] calldata tokenIds,uint256 minLpTokenAmount,bytes32[][] calldata proofs) public payable returns (uint256) {
        uint256 fractionalTokenAmount = wrap(tokenIds, proofs);
        uint256 lpTokenAmount = add(baseTokenAmount,fractionalTokenAmount,minLpTokenAmount);

        return lpTokenAmount;
    }
    function nftRemove(uint256 lpTokenAmount,uint256 minBaseTokenOutputAmount,uint256[] calldata tokenIds)public returns (uint256 baseTokenOutputAmount,uint256 fractionalTokenOutputAmount)
    {
        (baseTokenOutputAmount, fractionalTokenOutputAmount) = remove(lpTokenAmount,minBaseTokenOutputAmount,tokenIds.length * ONE);
        unwrap(tokenIds);
        return (baseTokenOutputAmount, fractionalTokenOutputAmount);

    }
    function nftBuy(uint256[] calldata tokenIds,uint256 maxInputAmount) public payable returns (uint256 inputAmount) {
        inputAmount = buy(tokenIds.length * ONE, maxInputAmount);
        unwrap(tokenIds);

        return inputAmount;
    }
    function nftSell(uint256[] calldata tokenIds,uint256 minOutputAmount,bytes32[][] calldata proofs) public returns (uint256) {
        uint256 inputAmount = wrap(tokenIds, proofs); // fractionalTokenAmount
        uint256 outputAmount = sell(inputAmount, minOutputAmount);
        return outputAmount;
    }
    //wraps
    function wrap(uint256[] calldata tokenIds,bytes32[][] calldata proofs) public returns (uint256 fractionalTokenAmount) {
        _validateTokenIds(tokenIds, proofs);
        require(closeTimestamp == 0, "Wrap: closed");
        fractionalTokenAmount = tokenIds.length * ONE;
        _mint(msg.sender, fractionalTokenAmount);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            ERC721(nft).safeTransferFrom(msg.sender,address(this),tokenIds[i]);
        }
        emit Wrap(tokenIds);
    }
    function unwrap(uint256[] calldata tokenIds) public returns (uint256) {
        uint256 fractionalTokenAmount = tokenIds.length * ONE;
        _burn(msg.sender, fractionalTokenAmount);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            ERC721(nft).safeTransferFrom(address(this),msg.sender,tokenIds[i]
            );
        }

        emit Unwrap(tokenIds);

        return fractionalTokenAmount;
    }
  function _transferFrom(address from,address to,uint256 amount) internal returns (bool) {
        balanceOf[from] -= amount;
        // cannot overflow because the sum of all user
        // balances cannot exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
        return true;
    }

    function _validateTokenIds(uint256[] calldata tokenIds,bytes32[][] calldata proofs) internal view {
        if (merkleRoot == bytes23(0)) return;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            bool isValid = MerkleProofLib.verify(proofs[i],merkleRoot,keccak256(abi.encodePacked(tokenIds[i])));
            require(isValid, "Invalid merkle proof");
        }
    }
    //defender
    function exit() public
    {
        require(slice.owner()==msg.sender,"Close:not owner");
        closeTimestamp = block.timestamp + 1 days;
        slice.destroy(nft, baseToken, merkleRoot);
        emit Close(closeTimestamp);
    }
    function withdraw(uint256 tokenId) public {
        require(slice.owner() == msg.sender,"withdraw:not owner");
        require(closeTimestamp!=0,"Withdraw not initiated");
        require(block.timestamp >= closeTimestamp, "Not withdrawable yet");
        ERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);

        emit Withdraw(tokenId);
    }
    //getters

    function price() public view returns (uint256) {
        return (_baseTokenReserves() * ONE)/fractionalTokenReserves();
    }
     function baseTokenReserves() public view returns (uint256) {
        return _baseTokenReserves();
    }
    function fractionalTokenReserves(public view returns (uint256) {
        return balanceOf[address(this)];
    }
    function _baseTokenReserves() internal view returns (uint256) {
        return baseToken == address(0)? address(this).balance - msg.value : ERC20(baseToken).balanceOf(address(this));
    }
    function buyQuote(uint256 outputAmount) public view returns (uint256) {
        return (outputAmount * 1000 * baseTokenReserves()) / ((fractionalTokenReserves() - outputAmount) * 997);
    }
    function sellQuote(uint256 inputAmount) public view returns (uint256) {
        uint256 inputAmountWithFee = inputAmount * 997;
        return(inputAmountWithFee * baseTokenReserves()) /((fractionalTokenReserves() * 1000) + inputAmountWithFee);
    }
    function addQuote(uint256 baseTokenAmount,uint256 fractionalTokenAmount) public view returns (uint256) {
        uint256 lpTokenSupply = lpToken.totalSupply();
        if (lpTokenSupply > 0) {
            uint256 baseTokenShare = (baseTokenAmount * lpTokenSupply) /baseTokenReserves();
            uint256 fractionalTokenShare = (fractionalTokenAmount *lpTokenSupply) / fractionalTokenReserves();
            return Math.min(baseTokenShare, fractionalTokenShare);
        } else {
            // if there is no liquidity then init
            return Math.sqrt(baseTokenAmount * fractionalTokenAmount);
        }
    }
    function removeQuote( uint256 lpTokenAmount) public view returns (uint256, uint256) {
        uint256 lpTokenSupply = lpToken.totalSupply();
        uint256 baseTokenOutputAmount = (baseTokenReserves() * lpTokenAmount) /lpTokenSupply;
        uint256 fractionalTokenOutputAmount = (fractionalTokenReserves() *lpTokenAmount) / lpTokenSupply;

        return (baseTokenOutputAmount, fractionalTokenOutputAmount);
    }



