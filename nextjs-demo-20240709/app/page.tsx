"use client"

import { createPublicClient, http, getContract, createWalletClient, custom, parseSignature, keccak256, encodePacked, encodeAbiParameters, toBytes, recoverMessageAddress, hexToBytes, toHex, verifyMessage } from 'viem'
import { sepolia } from 'viem/chains'
import { useState } from 'react';
import ERC20 from './component/ERC20'
import NFTRentMarket from './component/NFTRentMarket'
import { abi } from './abi/Hulio.json'

export default function Home() {

    //合约地址
    const erc20addr = '0x8FC9DC015D0854534C55860730889F5D09a33910'
    const nftRentMarketCa = '0xc5f125b12508B4B24bC21D910a7f152B71cf2fbC'
    //当前连接账号
    const [curAccount, setCurAccount] = useState<any>();
    //wallet client
    const [wclient, setWclient] = useState<any>();

    //初始一个public client
    const publicClient = createPublicClient({
        chain: sepolia,
        transport: http("https://sepolia.infura.io/v3/1d37b9d398af4b81baca54ea5f164f17")
    })

    //read contract,只能读数据
    const erc20readContract = getContract({ address: erc20addr, abi, client: publicClient })

    //连接钱包
    const connectWallet = async () => {
        console.log("start connect wallet...")
        let walletClient: any = createWalletClient({
            chain: sepolia,
            transport: custom(window.ethereum!)
        })
        const [address] = await walletClient.getAddresses()
        setCurAccount(address);//设置当前连接的用户
        console.log(address)
        setWclient(walletClient)
        console.log(walletClient)
        console.log(wclient)
    }

    return (
        <div className='mt-2 ml-2'>
            <button className='bg-blue-300 rounded-md' onClick={connectWallet}>connect wallet</button>
            <div>Current User: {curAccount}</div>
            <br></br>
            {ERC20(publicClient, wclient, erc20readContract, curAccount, erc20addr)}
            <br></br>
            {NFTRentMarket(curAccount,publicClient,nftRentMarketCa)}
        </div>
    );
}

