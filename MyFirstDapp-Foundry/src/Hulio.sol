// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";

/**
 * erc20代币合约
 */
contract Hulio is ERC20Permit {

    //生成签名对象使用
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    //构造函数
    constructor() ERC20Permit("Hulio") ERC20("Hulio", "HU") {}

    //erc20 transfer失败
    error ERC1363TransferFailed(address to, uint256 value);
    //回调onTransferReceived失败
    error ERC1363ReceiveFailed(address to);

    //mint, 暂时允许所有人挖
    function mint() external {
        _mint(msg.sender, 10 ** 9);
    }

    //获取签名对象
    function getDigest(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                nonces(owner),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);
        return hash;
    }

    //transfer and invoke hook (if to is a contract)
    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) public returns (bool) {
        //1. transfer
        if (!transfer(to, value)) {
            revert ERC1363TransferFailed(to, value);
        }

        //2. invoke hook
        _checkOnTransferReceived(_msgSender(), to, value, data);

        return true;
    }

    //invoke hook
    function _checkOnTransferReceived(
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) private {
        //not a contract address
        if (to.code.length == 0) {
            return;
        }

        //invoke hook
        try
            IERC1363Receiver(to).onTransferReceived(
                _msgSender(),
                from,
                value,
                data
            )
        returns (bytes4 retval) {
            if (retval != IERC1363Receiver.onTransferReceived.selector) {
                revert ERC1363ReceiveFailed(to);
            }
        } catch (bytes memory reason) {
            revert ERC1363ReceiveFailed(to);
        }
    }
}
