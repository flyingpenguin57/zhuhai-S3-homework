"use client"

import { useState } from 'react';
import { ethers } from 'ethers';
import { getBalance, sendToken } from '../lib/contract';
import { MetaMaskInpageProvider } from "@metamask/providers";

declare global {
  interface Window{
    ethereum?:MetaMaskInpageProvider
  }
}

export default function Home() {
    const [balance, setBalance] = useState(null);
    const [recipient, setRecipient] = useState('');
    const [amount, setAmount] = useState('');
    const [loading, setLoading] = useState(false);

    async function fetchBalance() {
        const accounts = await window?.ethereum?.request({ method: 'eth_requestAccounts' });
        const balance = await getBalance(accounts[0]);
        setBalance(balance);
    }

    return (
        <div>
            <h1>ERC-20 Token Interaction</h1>
            <button onClick={fetchBalance}>Get Balance</button>
            {balance !== null && <p>Balance: {balance}</p>}
            <div>
                <input
                    type="text"
                    value={recipient}
                    onChange={(e) => setRecipient(e.target.value)}
                    placeholder="Recipient Address"
                />
                <input
                    type="text"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    placeholder="Amount"
                />
                <button disabled={loading}>
                    {loading ? 'Sending...' : 'Send Token'}
                </button>
            </div>
        </div>
    );
}

