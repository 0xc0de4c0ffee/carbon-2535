// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

interface iManager {
    function init(address _this) external;
    function newContract(address _contract, bytes4[] calldata _functions) external;
    function removeContract(address _contract) external;
    function replaceContract(address _old, address _new) external;
    function addFunctions(address _contract, bytes4[] calldata _functions) external;
    function removeFunctions(address _contract, bytes4[] calldata _functions) external;
    function replaceFunctions(address _old, address _new, bytes4[] calldata _functions) external;
}
