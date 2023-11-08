// SPDX-License-Identifier: MIT
pragma solidity > 0.8 .0;
import "../interface/iLoupe.sol";
import "../Core.sol";

contract Loupe is iLoupe, Core {
    /// These functions are expected to be called frequently by tools.

    /// @notice Gets all facet addresses and their four byte function selectors.
    /// @return _facets Array of Facet
    function facets() external view returns(Facet[] memory _facets) {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        address[] memory _contracts = DS.contracts;
        bytes4[] memory _functions;
        uint cLen = _contracts.length;
        uint fLen;
        uint fCount;
        uint cCount;
        address _facet;
        for (uint h = 0; h < cLen; h++) {
            _facet = _contracts[h];
            _functions = DS.functions[_facet];
            fLen = _functions.length;
            bytes4[] memory _selectors = new bytes4[](_functions.length) ;
            fCount = 0;
            for (uint i = 0; i < fLen; i++) {
                if (DS.toContract[_functions[i]] == _facet) {
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
    function facetFunctionSelectors(address _facet) external view returns(bytes4[] memory _selectors) {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        bytes4[] memory _functions = DS.functions[_facet];
        uint len = _functions.length;
        uint count;
        while(len > 0){
            if (DS.toContract[_functions[--len]] == _facet) {
                _selectors[count++] = _functions[len];
            }
        }
    }

    /// @notice Get all the facet addresses used by a diamond.
    /// @return Facet addresses_
    function facetAddresses() external view returns(address[] memory) {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        return DS.contracts;
    }

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _selector The function selector.
    /// @return The facet address.
    function facetAddress(bytes4 _selector) external view returns(address) {
        DATA storage DS;
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        return DS.toContract[_selector];
    }
}