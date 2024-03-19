// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "../Core.sol";
/**
 * @title
 * @author
 * @notice
 *
 * | Sighash  | Function |
 * | -------- | ------------------ |
 * | 7bcb6566 | newLibrary(address,bytes4[]) |
 * | c375c2ef | removeLibrary(address) |
 * | 1ea9e5a1 | replaceLibrary(address,address) |
 * | 32d0daf0 | addFunctions(address,bytes4[]) |
 * | f203661a | removeFunctions(address,bytes4[]) |
 * | adc230f2 | replaceFunctions(address,address,bytes4[]) |
 *
 */

library Manager {
    bytes32 public constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage");
    event NewLibrary(address indexed _library, bytes4[] _functions);
    event RemovedLibrary(address indexed _library);
    event NewFunctions(address indexed _library, bytes4[] _functions);
    event RemovedFunctions(address indexed _library, bytes4[] _functions);
    bytes constant iface =
        abi.encodePacked(
            Manager.newLibrary.selector,
            Manager.removeLibrary.selector,
            Manager.replaceLibrary.selector,
            Manager.addFunctions.selector,
            Manager.removeFunctions.selector,
            Manager.replaceFunctions.selector
        );
    function init(address _this) external {
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        DATA storage DS;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        if (DS.locked[_this]) revert LibraryLocked();
        DS.contracts.push(_this);
        DS.locked[_this] = true;
        DS.libraries[Manager.newLibrary.selector] = _this;
        DS.libraries[Manager.removeLibrary.selector] = _this;
        DS.libraries[Manager.replaceLibrary.selector] = _this;
        DS.libraries[Manager.addFunctions.selector] = _this;
        DS.libraries[Manager.removeFunctions.selector] = _this;
        DS.libraries[Manager.replaceFunctions.selector] = _this;
        DS.functions[_this] = [
            Manager.newLibrary.selector,
            Manager.removeLibrary.selector,
            Manager.replaceLibrary.selector,
            Manager.addFunctions.selector,
            Manager.removeFunctions.selector,
            Manager.replaceFunctions.selector
        ];
        emit NewLibrary(_this, DS.functions[_this]);
    }

    function newLibrary(
        address _library,
        bytes4[] calldata _functions
    ) external {
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        DATA storage DS;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        if (DS.locked[_library]) revert LibraryLocked();
        if ((DS.functions[_library].length) != 0)
            revert DuplicateLibrary(_library);
        for (uint256 i = 0; i < _functions.length; i++) {
            if (DS.libraries[_functions[i]] != address(0)) {
                revert DuplicateFunction(
                    _functions[i],
                    DS.libraries[_functions[i]]
                );
            }
            DS.libraries[_functions[i]] = _library;
        }
        DS.functions[_library] = _functions;
        DS.contracts.push(_library);
        emit NewLibrary(_library, _functions);
    }

    function removeLibrary(address _library) external {
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        DATA storage DS;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        if (DS.locked[_library]) revert LibraryLocked();
        bytes4[] memory _functions = DS.functions[_library];
        if (_functions.length == 0) revert InactiveLibrary(_library);
        for (uint256 i = 0; i < _functions.length; i++) {
            if (DS.libraries[_functions[i]] == _library) {
                delete DS.libraries[_functions[i]];
            }
        }
        delete DS.functions[_library];
        emit RemovedLibrary(_library);
    }

    function replaceLibrary(address _old, address _new) external {
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        DATA storage DS;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        if (DS.locked[_old]) revert LibraryLocked();
        if (DS.functions[_old].length == 0) revert InactiveLibrary(_old);
        if (DS.functions[_new].length != 0) revert DuplicateLibrary(_new);
        bytes4[] memory _functions = DS.functions[_old];
        for (uint256 i = 0; i < _functions.length; i++) {
            if (DS.libraries[_functions[i]] == _old) {
                DS.libraries[_functions[i]] = _new;
                DS.functions[_new].push(_functions[i]);
            }
        }
        delete DS.functions[_old];
        emit RemovedLibrary(_old);
        emit NewLibrary(_new, DS.functions[_new]);
    }

    function addFunctions(
        address _library,
        bytes4[] calldata _functions
    ) external {
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        DATA storage DS;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        if (DS.locked[_library]) revert LibraryLocked();
        bytes4[] storage _list = DS.functions[_library];
        if (_list.length == 0) revert InactiveLibrary(_library);
        bytes4 _f;
        for (uint256 i = 0; i < _functions.length; i++) {
            _f = _functions[i];
            if (DS.libraries[_f] != address(0))
                revert DuplicateFunction(_f, DS.libraries[_f]);
            DS.libraries[_f] = _library;
            _list.push(_f);
        }
        emit NewFunctions(_library, _functions);
    }

    function removeFunctions(
        address _library,
        bytes4[] calldata _functions
    ) external {
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        DATA storage DS;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        if (DS.locked[_library]) revert LibraryLocked();
        bytes4 _f;
        uint256 len = _functions.length;
        while (len > 0) {
            _f = _functions[--len];
            if (DS.libraries[_f] != _library)
                revert DuplicateFunction(_f, DS.libraries[_f]);
            delete DS.libraries[_f];
        }
        emit RemovedFunctions(_library, _functions);
    }

    function replaceFunctions(
        address _src,
        address _dst,
        bytes4[] calldata _functions
    ) external {
        bytes32 _slot = DIAMOND_STORAGE_POSITION;
        DATA storage DS;
        assembly {
            DS.slot := _slot
        }
        if (msg.sender != DS.dev) revert OnlyDev(DS.dev);
        if (DS.locked[_src]) revert LibraryLocked();
        uint256 oLen = DS.functions[_src].length;
        if (oLen == 0) revert InactiveLibrary(_src);
        //if (DS.functions[_dst].length != 0) {
        //    revert DuplicateLibrary(_dst);
        //}
        for (uint256 i = 0; i < _functions.length; i++) {
            if (DS.libraries[_functions[i]] != _src)
                revert InvalidFunction(_functions[i]);
            DS.libraries[_functions[i]] = _dst;
            --oLen;
        }
        if (oLen == 0) {
            delete DS.functions[_src];
            emit RemovedLibrary(_src);
        } else {
            emit RemovedFunctions(_src, _functions);
        }
        DS.functions[_dst] = _functions;
        emit NewFunctions(_dst, _functions);
    }
}
