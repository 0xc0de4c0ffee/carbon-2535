// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Core.sol";
import "./interface/iUtils.sol";

abstract contract Utils is iERC173, iERC165 {
    bytes32 public immutable DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        DATA storage DS;
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := _slot
        }
        return (DS.libraries[interfaceId] != address(0) || interfaceId == iERC165.supportsInterface.selector);
    }

    function DeactivateContract() external {
        DATA storage DS;
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        DS.paused = true;
    }
    function ActivateContract() external {
        DATA storage DS;
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        DS.paused = false;
    }

    function toggleLibrary(address _library) external {
        DATA storage DS;
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        DS.locked[_library] = !DS.locked[_library];
    }

    function init(address _library) external {
        DATA storage DS;
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        if (_library.code.length == 0) revert OnlyContract();
        (bool ok, bytes memory _ret) = _library.delegatecall(msg.data);
        if (!ok) {
            if (_ret.length == 0) revert DelegateCallFailed(_library);
            assembly {
                revert(add(32, _ret), mload(_ret))
            }
        }
    }

    function initWithBytecode(bytes memory _code) external {
        DATA storage DS;
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        address _library;
        assembly {
            _library := create(0, add(_code, 0x20), mload(_code))
        }
        if (_library.code.length == 0) revert ContractCreateFailed();
        (bool ok, bytes memory _ret) =
            _library.delegatecall(abi.encodeWithSelector(iUtils.init.selector, _library));
        if (!ok) {
            if (_ret.length == 0) revert DelegateCallFailed(_library);
            assembly {
                revert(add(32, _ret), mload(_ret))
            }
        }
    }

    function owner() external view returns (address) {
        DATA storage DS;
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := _slot
        }
        return DS.dev;
    }

    function transferOwnership(address _newDev) external {
        DATA storage DS;
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        DS.dev = _newDev;
        emit OwnershipTransferred(msg.sender, _newDev);
    }
    /*
    /// @dev Not part of ERC173
    function acceptOwnership() external {
        DATA storage DS;
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.newDev) revert OnlyDev(DS.newDev);
        emit OwnershipTransferred(DS.dev, msg.sender);
        DS.dev = msg.sender;
    }
    */
}
