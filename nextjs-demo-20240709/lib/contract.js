import { ethers } from 'ethers';
import { abi } from './MyToken.json';

const INFURA_PROJECT_ID = "1d37b9d398af4b81baca54ea5f164f17";
const CONTRACT_ADDRESS = "0xa2E254a4C4a23e84Ab0d1Fd3E333b0379954f04F";

const provider = new ethers.providers.InfuraProvider('sepolia', INFURA_PROJECT_ID);
const contract = new ethers.Contract(CONTRACT_ADDRESS, abi, provider);

export async function getBalance(address) {
    const balance = await contract.balanceOf(address);
    return ethers.utils.formatUnits(balance, 18);
}

export async function sendToken(signer, to, amount) {
    const contractWithSigner = contract.connect(signer);
    const tx = await contractWithSigner.transfer(to, ethers.utils.parseUnits(amount, 18));
    await tx.wait();
    return tx;
}
