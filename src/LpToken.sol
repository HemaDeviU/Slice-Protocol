//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "solmate/tokens/ERC20.sol";

contract LpToken is ERC20 {
    constructor () ERC20() {}
    function mint(address to, uint256 amount) public onlyOwner{
        _mint(to,amount);
    }
    function burn(address from, uitn256 amount) public onlyOwner{
        _burn(from,amount);
    }
}