// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
/**
 * erc20代币合约
 */
contract Hulio is ERC20 {

    //domain separator
    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) public nonces;

    /**
     * 构造函数
     */
    constructor() ERC20("Hulio", "HU") {
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("Hulio")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    //erc20 transfer失败
    error ERC1363TransferFailed(address to, uint256 value);
    //回调onTransferReceived失败
    error ERC1363ReceiveFailed(address to);
    //无效的签名
    error invalidSignature(address revocerdAddr, bytes32 digest);


    /**
     * mint, 暂时允许所有人挖
     */
    function mint() external {
        _mint(msg.sender, 10 ** 9);
    }

    /**
     * transfer and invoke hook (if to is a contract)
     */
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

    /**
     * permit
     */
    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        nonces[owner]++,
                        deadline
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        if (recoveredAddress == address(0) || recoveredAddress != owner) {
            revert invalidSignature(recoveredAddress, digest);
        }
        _approve(owner, spender, value);
    }

    function getDigest(
        address owner,
        address spender,
        uint value,
        uint deadline
    ) public view returns (bytes32) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        nonces[owner],
                        deadline
                    )
                )
            )
        );
        return digest;
    }

    /**
     * invoke hook
     */
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
