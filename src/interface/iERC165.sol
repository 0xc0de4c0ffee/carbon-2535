// SPDX-License-Identifier: WTFPL.ETH
pragma solidity ^0.8.0;

interface iERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}