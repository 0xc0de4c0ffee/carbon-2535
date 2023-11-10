// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

error Paused();
error OnlyGovContract(address);
error DuplicateContract(address _contract);
error DuplicateFunction(bytes4 _function, address _contract);
error InvalidFunctionLength(uint256 _length, bytes4[] _functions);
error InvalidFunction(bytes4);
error ContractNotActive(address _contract);
error ContractLocked();
error DelegateCallFailed(address _contract);
error StaticCallFailed(bytes _input, bytes _error);
error GovLock(uint64 _since);

struct DATA {
    bool locked; // lock gov
    address GOV;
    address NewGov;
    //function to proxy contract
    mapping(bytes4 => address) toContract;
    // proxy contract lock
    mapping(address => bool) isLocked;
    // proxy contract to functions list
    mapping(address => bytes4[]) functions;
    // list of all contracts
    // * have to filter inactive contracts in louper view
    address[] contracts;
    // ERC165 Supports^Interface
    mapping(bytes4 => bool) isERC165;
}

abstract contract Core {
    // List of all storage positions
    bytes32 public immutable DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");
    //bytes32 public immutable NOAPI_STORAGE_POSITION = keccak256("eth.noapi.carbon");
}

/**
 * List of main events for base contract
 */
abstract contract Events {
    event ContractAdded(address indexed _contract, bytes4[] _functions);
    event ContractRemoved(address indexed _contract);
    event FunctionsAdded(address indexed _contract, bytes4[] _functions);
    event FunctionsRemoved(address indexed _contract, bytes4[] _functions);

    //ERC173
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
