// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

/**
 * "Based" on EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
 */
import "./Core.sol";
import "./library/Manager.sol";
import "./Utils.sol";

contract Carbon is iERC165 {
    bytes32 public immutable DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        return (
            DS.toContract[interfaceId] != address(0) || DS.isERC165[interfaceId]
                || interfaceId == iERC165.supportsInterface.selector
        );
    }

    constructor(address _manager) {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        DS.GOV = msg.sender;
        //address _manager = address(new Manager());
        DS.isLocked[_manager] = true;
        DS.contracts.push(_manager);

        DS.toContract[Manager.newContract.selector] = _manager;
        DS.toContract[Manager.removeContract.selector] = _manager;
        DS.toContract[Manager.replaceContract.selector] = _manager;

        //DS.toContract[Utils.owner.selector] = _manager;

        DS.toContract[Manager.addFunctions.selector] = _manager;
        DS.toContract[Manager.removeFunctions.selector] = _manager;
        DS.toContract[Manager.replaceFunctions.selector] = _manager;

        DS.functions[_manager] = [
            Manager.newContract.selector,
            Manager.removeContract.selector,
            Manager.replaceContract.selector,
            Manager.addFunctions.selector,
            Manager.removeFunctions.selector,
            Manager.replaceFunctions.selector,
            Utils.owner.selector
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

    fallback(bytes calldata) external payable returns (bytes memory _output) {
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
        bool ok;
        (ok, _output) = _contract.delegatecall(msg.data);
        if (!ok) {
            if (_output.length == 0) {
                revert DelegateCallFailed(_contract);
            }
            assembly {
                revert(add(32, _output), mload(_output))
            }
        }
    }

    receive() external payable {
        revert();
    }
}
