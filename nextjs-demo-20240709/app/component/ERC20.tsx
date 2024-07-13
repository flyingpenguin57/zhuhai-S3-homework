'use client'

import { useState } from 'react';
import { abi } from '../abi/Hulio.json'
import { ethers } from "ethers";

export default function ERC20(publicClient: any, walletClient: any, erc20ReadContract: any, curAccount: any, erc20CA: any) {

    console.log("is wallet connected?")
    console.log(walletClient)

    //erc20 total supply
    const [totalSupply, setTotalSupply] = useState<any>(0);

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

    //获取total supply
    const getTotalSupply = async () => {
        let totalSupply = await erc20ReadContract.read.totalSupply()
        console.log(totalSupply)
        setTotalSupply(totalSupply);
    }

    //查看余额
    const getBalance = async () => {
        const balance = await erc20ReadContract.read.balanceOf([curAccount]) //读取balance
        console.log(balance)
        setBalance(balance) //设置当前用户balance
    }

    //mint
    const mint = async () => {
        const { request } = await publicClient.simulateContract({
            account: curAccount,
            address: erc20CA,
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
            address: erc20CA,
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
            address: erc20CA,
            abi: abi,
            functionName: 'permit',
            args: [from, to, value, deadline, v, r, s],
        })
        console.log(walletClient)
        await walletClient.writeContract(request)
    }

    //签名
    const sign = async () => {
        let provider = new ethers.BrowserProvider(window.ethereum)
        let signer = await provider.getSigner();
        const chainId = await publicClient.getChainId()
        const nonce = await erc20ReadContract.read.nonces([from])

        //domain,要和合约中的定义完全一致
        const domain = {
            name: "Hulio",
            version: "1",
            chainId: chainId,
            verifyingContract: erc20CA,
        };

        //格式化数据的类型，要和合约中的定义完全一致
        const types = {
            Permit: [
                { name: "owner", type: "address" },
                { name: "spender", type: "address" },
                { name: "value", type: "uint256" },
                { name: "nonce", type: "uint256" },
                { name: "deadline", type: "uint256" },
            ],
        };

        //格式化数据具体内容
        const message = {
            owner: from,
            spender: to,
            value: value,
            nonce: nonce,
            deadline: deadline
        };
        // 获得signer后调用signTypedData方法进行eip712签名
        const signature = await signer.signTypedData(domain, types, message);
        console.log("Signature:", signature);
        // 解析签名
        const r = signature.slice(0, 66); // 0x + 32 字节
        const s = '0x' + signature.slice(66, 130); // 32 字节
        const v = '0x' + signature.slice(130, 132); // 1 字节

        console.log(`r: ${r}`);
        console.log(`s: ${s}`);
        console.log(`v: ${v}`);
    }

    return (
        <div>
            <h1>ERC-20 Token Interaction</h1>
            <button className='bg-blue-400 rounded-md' onClick={getTotalSupply}>get total supply</button>
            <div>totalSupply:{totalSupply?.toString()}</div>
            <button className='bg-green-300 rounded-md' onClick={getBalance}>get balance</button>
            <div>balance:{balance?.toString()}</div>
            <button className='bg-blue-400 rounded-md' onClick={mint}>mint</button>
            <br></br>
            <button className='bg-green-300 rounded-md' onClick={transfer}>transfer</button>
            <br></br>
            <button className='bg-purple-300 rounded-md' onClick={sign}>sign</button>
            <br></br>
            <button className='bg-yellow-300 rounded-md' onClick={permit}>permit</button>

            <div>-------input area-------</div>
            from:   <input type="text" onChange={handleFromChange} />
            <br></br>
            to:    <input type="text" onChange={handleToChange} />
            <br></br>
            value:   <input type="text" onChange={handleValueChange} />
            <br></br>
            deadline:<input type="text" onChange={handleDeadlineChange} />
            <br></br>
            v:    <input type="text" onChange={handleVChange} />
            <br></br>
            r:    <input type="text" onChange={handleRChange} />
            <br></br>
            s:    <input type="text" onChange={handleSChange} />
            <br></br>
            <br></br>
        </div>
    );
}