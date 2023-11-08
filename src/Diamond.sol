// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.0;

/** 
 * "Based" on EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
 * This is NOT compatible with EIP2535
 * 
 */ 
import "./Core.sol";
import "./contracts/Manager.sol";
import "./Carbon.sol";

contract Diamond is iERC165 {
    bytes32 public immutable DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    function supportsInterface(bytes4 interfaceId) external view returns(bool) {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        return (DS.toContract[interfaceId] != address(0) || interfaceId == iERC165.supportsInterface.selector);
    }

    constructor() {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }

        DS.GOV = msg.sender;

        address _addr = address(new Manager());
        DS.isLocked[_addr] = true;
        DS.contracts.push(_addr);

        DS.toContract[Manager.newContract.selector] = _addr;
        DS.toContract[Manager.removeContract.selector] = _addr;
        DS.toContract[Manager.replaceContract.selector] = _addr;

        DS.toContract[Manager.addFunctions.selector] = _addr;
        DS.toContract[Manager.removeFunctions.selector] = _addr;
        DS.toContract[Manager.replaceFunctions.selector] = _addr;

        DS.functions[_addr] = [
            Manager.newContract.selector,
            Manager.removeContract.selector,
            Manager.replaceContract.selector,
            Manager.addFunctions.selector,
            Manager.removeFunctions.selector,
            Manager.replaceFunctions.selector
        ];
    }

    function toggle() external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (msg.sender != DS.GOV) revert OnlyGovContract(DS.GOV);
        DS.locked = !DS.locked;
    }
    /* Not tested && NOT sure
        function multiview(bytes[] calldata _inputs) external view returns(bytes[] memory _output) {
            _output = new bytes[](_inputs.length);
            bool ok;
            for (uint i; i < _inputs.length; i++) {
                (ok, _output[i]) = address(this).staticcall(_inputs[i]);
                if (!ok) {
                    revert StaticCallFailed(_inputs[i], _output[i]);
                }
            }
        }

        function multicall(bytes[] calldata _inputs) external {
            DATA storage DS;
            bytes32 position = DIAMOND_STORAGE_POSITION;
            assembly {
                DS.slot := position
            }
            if (!DS.active) {
                revert Paused();
            }
            bytes4 _function;
            for (uint i; i < _inputs.length; i++) {
                bytes memory _input = _inputs[i];
                assembly {
                    _function := mload(add(_input, 4))
                }
                address _contract = DS.toContract[_function];
                if (_contract == address(0)) {
                    revert InvalidFunction(_function);
                }
                (bool ok, bytes memory _error) = _contract.delegatecall(_input);
                if (!ok) {
                    revert DelegateCallFailed(_contract, _input, _error);
                }
            }
        }
    */
    fallback() external payable {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }

        if (DS.locked) revert Paused(); // system paused

        address _contract = DS.toContract[msg.sig];
        if (_contract == address(0)) {
            revert InvalidFunction(msg.sig);
        }
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _contract, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return (0, returndatasize())
            }
        }
    }

    receive() external payable {
        revert();
    }
}