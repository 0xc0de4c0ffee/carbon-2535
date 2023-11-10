// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./iERC165.sol";
import "./iERC173.sol";
import "./iManager.sol";
import "./iLoupe.sol";

interface iMeta is iERC165, iERC173, iLoupe, iManager {}
