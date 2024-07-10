"use client"

import { createPublicClient, http, getContract, createWalletClient, custom, parseSignature, keccak256, encodePacked, encodeAbiParameters, toBytes, recoverMessageAddress, hexToBytes, toHex } from 'viem'
import { sepolia, mainnet } from 'viem/chains'
import { abi } from '../lib/Hulio.json'
import { useState } from 'react';

export default function Home() {

    //erc20 total supply
    const [totalSupply, setTotalSupply] = useState<any>(0);
    //当前连接账号
    const [curAccount, setCurAccount] = useState<any>();
    //当前账号erc20余额
    const [balance, setBalance] = useState<any>();
    //from
    const [from, setFrom] = useState<any>();
    //to
    const [to, setTo] = useState<any>();
    //value
    const [value, setValue] = useState<any>()
    //deadline
    const [deadline, setDeadline] = useState<any>();
    //v
    const [v, setV] = useState<any>();
    //r
    const [r, setR] = useState<any>();
    //s
    const [s, setS] = useState<any>();

    const handleFromChange = (event: any) => {
        setFrom(event.target.value);
    };

    const handleToChange = (event: any) => {
        setTo(event.target.value);
    };

    const handleValueChange = (event: any) => {
        setValue(event.target.value);
    };

    const handleDeadlineChange = (event: any) => {
        setDeadline(event.target.value);
    };

    const handleVChange = (event: any) => {
        setV(event.target.value);
    };

    const handleRChange = (event: any) => {
        setR(event.target.value);
    };

    const handleSChange = (event: any) => {
        setS(event.target.value);
    };

    //初始一个public client
    const publicClient = createPublicClient({
        chain: sepolia,
        transport: http("https://sepolia.infura.io/v3/1d37b9d398af4b81baca54ea5f164f17")
    })

    //初始一个wallet client，一开始还没有连接钱包，并不存在
    let walletClient: any = undefined;

    //erc20合约地址
    const hulioAddress = "0xDDe775C7AFc2F15C24211F8a4243D18aDd07716C";

    //read contract,只能读数据
    const readContract = getContract({ address: hulioAddress, abi, client: publicClient })

    //获取total supply
    const getTotalSupply = async () => {
        let totalSupply = await readContract.read.totalSupply()
        console.log(totalSupply)
        setTotalSupply(totalSupply);
    }

    //连接钱包
    const connectWallet = async () => {
        console.log("start connect wallet...")
        walletClient = createWalletClient({
            chain: sepolia,
            transport: custom(window.ethereum!)
        })
        const [address] = await walletClient.getAddresses()
        setCurAccount(address);//设置当前连接的用户
        console.log(address)
        const balance = await readContract.read.balanceOf([address]) //读取balance
        console.log(balance)
        setBalance(balance) //设置当前用户balance
    }

    //查看余额
    const getBalance = async () => {
        const balance = await readContract.read.balanceOf([curAccount]) //读取balance
        console.log(balance)
        setBalance(balance) //设置当前用户balance
    }

    //mint
    const mint = async () => {
        const { request } = await publicClient.simulateContract({
            account: curAccount,
            address: hulioAddress,
            abi: abi,
            functionName: 'mint',
        })
        console.log(walletClient)
        await walletClient.writeContract(request)
        console.log("minting...")
    }

    //转账
    const transfer = async () => {
        const { request } = await publicClient.simulateContract({
            account: curAccount,
            address: hulioAddress,
            abi: abi,
            functionName: 'transfer',
            args: [to, value],
        })
        console.log(walletClient)
        await walletClient.writeContract(request)
    }

    //permit
    const permit = async () => {
        const { request } = await publicClient.simulateContract({
            account: curAccount,
            address: hulioAddress,
            abi: abi,
            functionName: 'permit',
            args: [from, to, value, deadline, v, r, s],
        })
        console.log(walletClient)
        await walletClient.writeContract(request)
    }

    //签名
    const sign = async () => {

        console.log(from, to, value, deadline)
        const digest:any = await readContract.read.getDigest([from, to, value, deadline])
        console.log("digest:" + digest)

        //调用钱包签名
        const signature_1 = await walletClient.signMessage({
            account: curAccount,
            message: digest,
        })
        console.log(signature_1)

        const address1 = await recoverMessageAddress({ 
            message: digest,
            signature: signature_1,
          })
        console.log("revocered addr" + address1) 

        const { v, r, s } = parseSignature(signature_1);
        console.log(curAccount, to, value, deadline)
        console.log(v, r, s)
    }

    return (
        <div>
            <h1>ERC-20 Token Interaction</h1>
            <button className='bg-blue-400 rounded-md' onClick={getTotalSupply}>get total supply</button>
            <div>totalSupply:{totalSupply?.toString()}</div>
            <button className='bg-orange-300 rounded-md' onClick={connectWallet}>connect wallet</button>
            <div>account:{curAccount}</div>
            <button className='bg-green-300 rounded-md' onClick={getBalance}>get balance</button>
            <div>balance:{balance?.toString()}</div>
            <button className='bg-blue-400 rounded-md' onClick={mint}>mint</button>
            <br></br>
            <button className='bg-green-300 rounded-md' onClick={transfer}>transfer</button>
            <br></br>
            <button className='bg-purple-300 rounded-md' onClick={sign}>sign</button>
            <br></br>
            <button className='bg-yellow-300 rounded-md' onClick={permit}>permit</button>

            <br></br>
            from:   <input type="text" onChange={handleFromChange} />
            <br></br>
            to:    <input type="text" onChange={handleToChange} />
            <br></br>
            value:   <input type="text" onChange={handleValueChange} />
            <br></br>
            deadline:<input type="text" onChange={handleDeadlineChange} />
            <br></br>
            v:    <input type="text" onChange={handleVChange} />            <br></br>
            r:    <input type="text" onChange={handleRChange} />            <br></br>
            s:    <input type="text" onChange={handleSChange} />            <br></br>

        </div>
    );
}

