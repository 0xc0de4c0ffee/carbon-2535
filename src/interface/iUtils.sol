// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./iERC165.sol";
import "./iERC173.sol";

interface iUtils is iERC165, iERC173 {
    function redAlert() external;
    function lockLibrary(address _library) external;
    function init(address _library) external;
    function initWithBytecode(bytes calldata _code) external;
    function owner() external view returns (address);
    //function transferOwnership(address _newDev) external;
}
