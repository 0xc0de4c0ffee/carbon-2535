// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "../Core.sol";

library Manager {
    bytes32 public constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    event ContractAdded(address indexed _contract, bytes4[] _functions);
    event ContractRemoved(address indexed _contract);
    event FunctionsAdded(address indexed _contract, bytes4[] _functions);
    event FunctionsRemoved(address indexed _contract, bytes4[] _functions);

    //using ManagerLib for DATA;
    function getDS() private view returns (DATA storage DS) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            DS.slot := position
        }
        if (msg.sender != DS.GOV) revert OnlyGovContract(DS.GOV);
    }

    function newContract(address _contract, bytes4[] calldata _functions) external {
        DATA storage DS = getDS();
        if (DS.isLocked[_contract]) revert ContractLocked();
        if ((DS.functions[_contract].length) != 0) {
            revert DuplicateContract(_contract);
        }
        for (uint256 i = 0; i < _functions.length; i++) {
            if (DS.toContract[_functions[i]] != address(0)) {
                revert DuplicateFunction(_functions[i], DS.toContract[_functions[i]]);
            }
            DS.toContract[_functions[i]] = _contract;
        }
        DS.functions[_contract] = _functions;
        DS.contracts.push(_contract);
        emit ContractAdded(_contract, _functions);
    }

    function removeContract(address _contract) external {
        DATA storage DS = getDS();
        if (DS.isLocked[_contract]) revert ContractLocked();
        bytes4[] memory _functions = DS.functions[_contract];
        if (_functions.length == 0) {
            revert ContractNotActive(_contract);
        }
        for (uint256 i = 0; i < _functions.length; i++) {
            if (DS.toContract[_functions[i]] == _contract) {
                delete DS.toContract[_functions[i]];
            }
        }
        delete DS.functions[_contract];
        emit ContractRemoved(_contract);
    }

    function replaceContract(address _old, address _new) external {
        DATA storage DS = getDS();
        if (DS.isLocked[_old]) {
            revert ContractLocked();
        }
        if (DS.functions[_old].length == 0) {
            revert ContractNotActive(_old);
        }
        if (DS.functions[_new].length != 0) {
            revert DuplicateContract(_new);
        }
        bytes4[] memory _functions = DS.functions[_old];
        for (uint256 i = 0; i < _functions.length; i++) {
            if (DS.toContract[_functions[i]] == _old) {
                DS.toContract[_functions[i]] = _new;
                DS.functions[_new].push(_functions[i]);
            }
        }
        delete DS.functions[_old];
        emit ContractRemoved(_old);
        emit ContractAdded(_new, DS.functions[_new]);
    }

    function addFunctions(address _contract, bytes4[] calldata _functions) external {
        DATA storage DS = getDS();
        if (DS.isLocked[_contract]) {
            revert ContractLocked();
        }
        bytes4[] storage _list = DS.functions[_contract];
        if (_list.length == 0) {
            revert ContractNotActive(_contract);
        }
        bytes4 _f;
        for (uint256 i = 0; i < _functions.length; i++) {
            _f = _functions[i];
            if (DS.toContract[_f] != address(0)) {
                revert DuplicateFunction(_f, DS.toContract[_f]);
            }
            DS.toContract[_f] = _contract;
            _list.push(_f);
        }
        emit FunctionsAdded(_contract, _functions);
    }

    function removeFunctions(address _contract, bytes4[] calldata _functions) external {
        DATA storage DS = getDS();
        if (DS.isLocked[_contract]) {
            revert ContractLocked();
        }
        bytes4 _f;
        uint256 len = _functions.length;
        while (len > 0) {
            _f = _functions[--len];
            if (DS.toContract[_f] != _contract) {
                revert DuplicateFunction(_f, DS.toContract[_f]);
            }
            delete DS.toContract[_f];
        }
        emit FunctionsRemoved(_contract, _functions);
    }

    function replaceFunctions(address _src, address _dst, bytes4[] calldata _functions) external {
        DATA storage DS = getDS();
        if (DS.isLocked[_src]) {
            revert ContractLocked();
        }
        uint256 oLen = DS.functions[_src].length;
        if (oLen == 0) {
            revert ContractNotActive(_src);
        }
        //if (DS.functions[_dst].length != 0) {
        //    revert DuplicateContract(_dst);
        //}
        for (uint256 i = 0; i < _functions.length; i++) {
            if (DS.toContract[_functions[i]] != _src) {
                revert InvalidFunction(_functions[i]);
            }
            DS.toContract[_functions[i]] = _dst;
            --oLen;
        }
        if (oLen == 0) {
            delete DS.functions[_src];
            emit ContractRemoved(_src);
        } else {
            emit FunctionsRemoved(_src, _functions);
        }
        DS.functions[_dst] = _functions;
        emit FunctionsAdded(_dst, _functions);
    }
}
