//SPDX-License-Identifier:MIT
pragma solidity 0.8.23;

interface ISlice {
    function owner() external view returns(address);
    function destroy(address,address,bytes32) external;
    
}