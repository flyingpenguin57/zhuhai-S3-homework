"use client"

import { createPublicClient, http, getContract, createWalletClient, custom } from 'viem'
import { sepolia, mainnet } from 'viem/chains'
import { abi } from '../lib/Hulio.json'
import { useState } from 'react';
import { keccak256 } from 'ethers';


export default function Home() {

    const [total, setTotal] = useState<any>(0);
    const [addr, setAddr] = useState<any>();
    const [balance, setBalance] = useState<any>();

    //初始一个public client
    const publicClient = createPublicClient({
        chain: sepolia,
        transport: http("https://sepolia.infura.io/v3/1d37b9d398af4b81baca54ea5f164f17")
    })

    let walletClient: any = undefined;

    const address = "0x8bBd273D22A26d1Bd0924Ad6a1378AF9f5558aA2";

    const readcontract = getContract({ address, abi, client: publicClient })

    const getTotalBalance = async () => {
        let totalSupply = await readcontract.read.totalSupply()
        console.log(totalSupply)
        setTotal(totalSupply);
    }

    const connectWallet = async () => {
        console.log("start connect wallet...")
        walletClient = createWalletClient({
            chain: sepolia,
            transport: custom(window.ethereum!)
        })
        console.log(walletClient)
        const [address] = await walletClient.getAddresses()
        setAddr(address);
        console.log(address)
        const bala = await readcontract.read.balanceOf([address])
        console.log(bala)
        setBalance(bala)
    }

    const transfer = async () => {
        const { request } = await publicClient.simulateContract({
            account: addr,
            address: address,
            abi: abi,
            functionName: 'transfer',
            args: ["0xa9528027dFEa6f57442C6Cc9C8313ad3091D60d8", 10000],
        })
        console.log(walletClient)
        await walletClient.writeContract(request)
    }

    const permit = async () => {

    }

    const sign = async () => {

    }

    getTotalBalance()

    return (
        <div>
            <h1>ERC-20 Token Interaction</h1>
            <button className='bg-blue-400 rounded-md' onClick={getTotalBalance}>get total supply</button>
            <div>totalSupply:{total?.toString()}</div>
            <button className='bg-orange-300 rounded-md' onClick={connectWallet}>connect wallet</button>
            <div>account:{addr}</div>
            <div>balance:{balance?.toString()}</div>
            <button className='bg-green-300 rounded-md' onClick={transfer}>transfer to account1 10000hu per time</button>
            <br></br>
            <button className='bg-purple-300 rounded-md' onClick={sign}>sign</button>
            <br></br>
            <button className='bg-yellow-300 rounded-md' onClick={permit}>permit</button>
        </div>
    );
}

