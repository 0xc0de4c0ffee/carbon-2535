// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

error Paused();
error OnlyDev(address);
error DuplicateLibrary(address _contract);
error DuplicateFunction(bytes4 _function, address _contract);
error InvalidFunctionLength(uint256 _length, bytes4[] _functions);
error InvalidFunction(bytes4);
error InactiveLibrary(address _contract);
error LibraryLocked();
error DelegateCallFailed(address _contract);
error StaticCallFailed(bytes _input, bytes _error);
error ContractCreateFailed();
error OnlyContract();

struct DATA {
    bool paused;
    address dev;
    address newDev;
    //function to library map
    mapping(bytes4 => address) libraries;
    // library lock map
    mapping(address => bool) locked;
    // library to functions list
    mapping(address => bytes4[]) functions;
    // list of all libraries
    address[] contracts;
}