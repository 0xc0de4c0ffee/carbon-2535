// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "../interface/iLoupe.sol";
import "../Carbon.sol";
/**
 * @title
 * @author
 * @notice
 *
 * | Selector | Function |
 * | -------- | -------- |
 * | 7a0ed627 | facets() |
 * | adfca15e | facetFunctionSelectors(address) |
 * | 52ef6b2c | facetAddresses() |
 * | cdffacc6 | facetAddress(bytes4) |
 *
 * [0x7a0ed627, 0xadfca15e, 0x52ef6b2c, 0xcdffacc6]
 */

library Loupe {
    bytes32 public constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    function getDS() private pure returns (DATA storage DS) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
    }
    /// @notice Gets all facet addresses and their four byte function selectors.
    /// @return _facets Array of Facet

    function facets() external view returns (Facet[] memory _facets) {
        DATA storage DS = getDS();
        address[] memory _contracts = DS.contracts;
        bytes4[] memory _functions;
        uint256 cLen = _contracts.length;
        uint256 fLen;
        uint256 fCount;
        uint256 cCount;
        address _facet;
        for (uint256 h = 0; h < cLen; h++) {
            _facet = _contracts[h];
            _functions = DS.functions[_facet];
            fLen = _functions.length;
            bytes4[] memory _selectors = new bytes4[](_functions.length);
            fCount = 0;
            for (uint256 i = 0; i < fLen; i++) {
                if (DS.libraries[_functions[i]] == _facet) {
                    _selectors[fCount++] = _functions[i];
                }
            }
            //if()
            _facets[cCount++] = Facet(_facet, _selectors);
        }
    }

    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return _selectors
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory _selectors) {
        DATA storage DS = getDS();
        bytes4[] memory _functions = DS.functions[_facet];
        uint256 len = _functions.length;
        uint256 count;
        while (len > 0) {
            if (DS.libraries[_functions[--len]] == _facet) {
                _selectors[count++] = _functions[len];
            }
        }
    }

    /// @notice Get all the facet addresses used by a diamond.
    /// @return Facet addresses_
    function facetAddresses() external view returns (address[] memory) {
        DATA storage DS = getDS();
        return DS.contracts;
    }

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _selector The function selector.
    /// @return The facet address.
    function facetAddress(bytes4 _selector) external view returns (address) {
        DATA storage DS = getDS();
        return DS.libraries[_selector];
    }
}
