// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";

/** erc20代币 */
contract Hulio is ERC20 {
    //构造函数
    constructor() ERC20("Hulio", "HU") {}

    //erc20 transfer失败
    error ERC1363TransferFailed(address to, uint256 value);
    //回调onTransferReceived失败
    error ERC1363ReceiveFailed(address to);

    //transfer and invoke hook (if to is a contract)
    function transferAndCall(address to, uint256 value, bytes calldata data) public returns (bool) {
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
