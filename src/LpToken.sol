//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "solmate/auth/Owned.sol";
import "solmate/tokens/ERC20.sol";


contract LpToken is Owned, ERC20 {
    constructor () Owned(msg.sender) ERC20("SLICE","SL",18)  {}
    function mint(address to, uint256 amount) public onlyOwner{
        _mint(to,amount);
    }
    function burn(address from, uint256 amount) public onlyOwner{
        _burn(from,amount);
    }
}