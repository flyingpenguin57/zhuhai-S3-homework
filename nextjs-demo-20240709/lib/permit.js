import { ethers } from 'ethers';

const PERMIT_TYPEHASH = ethers.utils.id("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
const DOMAIN_TYPEHASH = ethers.utils.id("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

export async function getPermitSignature({
    privateKey,
    tokenAddress,
    owner,
    spender,
    value,
    nonce,
    deadline,
    name,
    version,
    chainId
}) {
    const wallet = new ethers.Wallet(privateKey);
    const domainSeparator = ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(
            ['bytes32', 'bytes32', 'bytes32', 'uint256', 'address'],
            [
                DOMAIN_TYPEHASH,
                ethers.utils.id(name),
                ethers.utils.id(version),
                chainId,
                tokenAddress
            ]
        )
    );

    const structHash = ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(
            ['bytes32', 'address', 'address', 'uint256', 'uint256', 'uint256'],
            [PERMIT_TYPEHASH, owner, spender, value, nonce, deadline]
        )
    );

    const digest = ethers.utils.keccak256(
        ethers.utils.solidityPack(
            ['bytes1', 'bytes1', 'bytes32', 'bytes32'],
            ['0x19', '0x01', domainSeparator, structHash]
        )
    );

    const signature = await wallet.signMessage(ethers.utils.arrayify(digest));
    const { r, s, v } = ethers.utils.splitSignature(signature);

    return { r, s, v };
}
