// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import {Manager} from "./library/Manager.sol";
import {Utils} from "./Utils.sol";
import "./interface/iERC165.sol";

error Paused();
error OnlyDev(address);
error DuplicateLibrary(address _contract);
error DuplicateFunction(bytes4 _function, address _contract);
error InvalidFunctionLength(uint256 _length, bytes4[] _functions);
error InvalidFunction(bytes4);
error LibraryNotActive(address _contract);
error LibraryLocked();
error DelegateCallFailed(address _contract);
error StaticCallFailed(bytes _input, bytes _error);
error GovLock(uint64 _since);

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

/**
 * @title
 * @author
 * @notice
 * Based on EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
 */

contract Carbon is iERC165 {
    bytes32 public immutable DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        return (
            DS.libraries[interfaceId] != address(0) || DS.libraries[interfaceId] == address(type(uint160).max)
                || interfaceId == iERC165.supportsInterface.selector
        );
    }

    constructor() {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        DS.dev = msg.sender;
        DS.locked[address(0)] = true; // lock zero addr
        DS.locked[address(type(uint160).max)] = true; // lock 0xffff...ffff address
            //Carbon(payable(this)).init(_manager);
    }

    function toggle() external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        DS.paused = !DS.paused;
    }

    function init(address _library) external {
        (bool ok, bytes memory _ret) = _library.delegatecall(msg.data);
        if (!ok) {
            if (_ret.length == 0) {
                revert DelegateCallFailed(_library);
            }
            assembly {
                revert(add(32, _ret), mload(_ret))
            }
        }
    }

    fallback(bytes calldata) external payable returns (bytes memory _output) {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (DS.paused) revert Paused(); // contract paused
        address _contract = DS.libraries[msg.sig];
        if (_contract == address(0)) revert InvalidFunction(msg.sig);
        bool ok;
        (ok, _output) = _contract.delegatecall(msg.data);
        if (!ok) {
            if (_output.length == 0) revert DelegateCallFailed(_contract);
            assembly {
                revert(add(32, _output), mload(_output))
            }
        }
    }

    receive() external payable {
        revert();
    }
}
