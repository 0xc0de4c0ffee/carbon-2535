// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Carbon.sol";
import "./interface/iERC165.sol";
import "./interface/iERC173.sol";

abstract contract Utils is iERC173 {
    bytes32 public constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    function owner() external view returns (address) {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        return DS.dev;
    }

    function transferOwnership(address _newDev) external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        DS.newDev = _newDev;
        // signal only
        emit OwnershipTransferred(msg.sender, _newDev);
    }

    /// @dev Not part of ERC173
    function acceptOwnership() external {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (msg.sender != DS.newDev) revert OnlyDev(DS.newDev);
        emit OwnershipTransferred(DS.dev, msg.sender);
        DS.dev = msg.sender;
    }
}
