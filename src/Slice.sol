//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./Pair.sol";
import "solmate/auth/Owned.sol";
import "libr/SafeERC20Namer.sol";
//to create and trade fraction nfts
contract Slice  is Owned{
    using SafeERC20Namer for address;
    //pairs[nft][baseToken][merkleRoot] => pair
    mapping(address => mapping(address => mapping(bytes32 => address)))
    public pairs;
    event Create(address indexed nft, address indexed baseToken,bytes32 indexed merkleRoot);
    event Destroy(address indexed nft,address indexed baseToken,bytes32 indexed merkleRoot);


    constructor() Owned(msg.sender){}


    function create(address nft, address baseToken,bytes32 merkleRoot) public returns (Pair pair){
        require(pairs[nft][baseToken][merkleRoot]==address(0),"Pair already exists");
        require(nft.code.length > 0, "Invalid NFT contract");
        require(baseToken.code.length > 0 || baseToken == address(0),"Invalidbase token contract");

string memory baseTokenSymbol = baseToken == address(0) ? "ETH" : baseToken.tokenSymbol();
string memory nftSymbol = nft.tokenSymbol();
string memory nftName = nft.tokenName();
string memory pairSymbol = string.concat(nftSymbol,":",baseTokenSymbol);
pair = new Pair(nft,baseToken, merkleRoot,pairSymbol,nftName,nftSymbol);

pairs[nft][baseToken][merkleRoot] = address(pair);
emit Create(nft, baseToken, merkleRoot);

    }
    function destroy(address nft, address baseToken,bytes32 merkleRoot) public {
        require(msg.sender ==pairs[nft][baseToken][merkleRoot],"Only pair can destro itself");
        delete pairs[nft][baseToken][merkleRoot];
        emit Destroy(nft,baseToken,merkleRoot);
    }
    
}