// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import {Manager} from "./library/Manager.sol";
import {Utils} from "./Utils.sol";
import "./interface/iERC165.sol";
import "./Core.sol";

/**
 * @title
 * @author
 * @notice
 * Based on EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
 */

contract Carbon is Utils {
    //bytes32 public immutable DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");
    address Dev; // ??fallback/backup

    constructor() {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        DS.dev = msg.sender;
        DS.locked[address(0)] = true; // lock zero addr
        DS.locked[address(type(uint160).max)] = true; // lock 0xffff...ffff address
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
