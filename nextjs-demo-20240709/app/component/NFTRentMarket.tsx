// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getDatabase, ref, set } from "firebase/database";
import { useState } from "react";
import { ethers } from "ethers";



export default function NFTRentMarket(curAccount: any, publicClient: any, nftRentMarketCa: any) {

  const [ca, setca] = useState<any>()
  const [tokenId, setTokenId] = useState<any>()
  const [dailyRent, setDailyRent] = useState<any>()
  const [max_rental_duration, set_max_rental_duration] = useState<any>()
  const [min_collateral, set_min_collateral] = useState<any>()
  const [list_endtime, set_list_endtime] = useState<any>()
  const onCaIn = (event: any) => {
    setca(event.target.value);
  }
  const onTokenIdIn = (event: any) => {
    setTokenId(event.target.value);
  }
  const onDailyRentIn = (event: any) => {
    setDailyRent(event.target.value);
  }
  const onMaxRentDurationIn = (event: any) => {
    set_max_rental_duration(event.target.value);
  }
  const onMinColIn = (event: any) => {
    set_min_collateral(event.target.value);
  }
  const onListEndTimeIn = (event: any) => {
    set_list_endtime(event.target.value);
  }

  const firebaseConfig = {
    apiKey: "AIzaSyBnftJGg1xK3HeOTS295PCXi3lgTY-0jno",
    authDomain: "liqinghao-dapp.firebaseapp.com",
    projectId: "liqinghao-dapp",
    storageBucket: "liqinghao-dapp.appspot.com",
    messagingSenderId: "877947391753",
    appId: "1:877947391753:web:c2f98cb84b96db4a39cdd8",
    measurementId: "G-WWKED09CYQ",
    // The value of `databaseURL` depends on the location of the database
    databaseURL: "https://liqinghao-dapp-default-rtdb.asia-southeast1.firebasedatabase.app",
  };

  // Initialize Firebase
  const app = initializeApp(firebaseConfig);


  // Initialize Realtime Database and get a reference to the service
  const database = getDatabase(app);

  async function writeRentInfo() {

    //sign
    const signature = await sign()
    console.log(signature)

    const id = ca + tokenId
    set(ref(database, 'rentInfo/' + id), {
      maker: curAccount,
      ca: ca,
      tokenId: tokenId,
      dailyRent: dailyRent,
      max_rental_duration: max_rental_duration,
      min_collateral: min_collateral,
      list_endtime: list_endtime,
      signature: signature
    });
  }

  const sign = async () => {
    let provider = new ethers.BrowserProvider(window.ethereum)
    let signer = await provider.getSigner();
    const chainId = await publicClient.getChainId()

    //domain,要和合约中的定义完全一致
    const domain = {
      name: "NFTRentMarket",
      version: "1",
      chainId: chainId,
      verifyingContract: nftRentMarketCa,
    };

    //格式化数据的类型，要和合约中的定义完全一致
    //Borrow(address maker,address nft_ca,
    //uint256 token_id,uint256 daily_rent,
    //uint256 max_rental_duration,
    //uint256 min_collateral,uint256 list_endtime)
    const types = {
      Borrow: [
        { name: "maker", type: "address" },
        { name: "nft_ca", type: "address" },
        { name: "token_id", type: "uint256" },
        { name: "daily_rent", type: "uint256" },
        { name: "max_rental_duration", type: "uint256" },
        { name: "min_collateral", type: "uint256" },
        { name: "list_endtime", type: "uint256" }
      ],
    };

    //格式化数据具体内容
    const message = {
      maker: curAccount,
      nft_ca: ca,
      token_id: tokenId,
      daily_rent: dailyRent,
      max_rental_duration: max_rental_duration,
      min_collateral: min_collateral,
      list_endtime: list_endtime
    };
    // 获得signer后调用signTypedData方法进行eip712签名
    const signature = await signer.signTypedData(domain, types, message);
    console.log("Signature:", signature);
    console.log(curAccount,ca,tokenId,dailyRent,max_rental_duration,min_collateral,list_endtime)
    return signature;
  }

  return (
    <div>
      <h1>nft rent market</h1>
      <button className="bg-blue-300 rounded-md" onClick={writeRentInfo}>publish rent info</button>
      <div>------input area------</div>
      nft合约地址:<input onInput={onCaIn}></input>
      <br></br>
      tokenId:<input onInput={onTokenIdIn}></input>      <br></br>
      每日租金:<input onInput={onDailyRentIn}></input>      <br></br>
      最大租赁时长:<input onInput={onMaxRentDurationIn}></input>      <br></br>
      最小抵押:<input onInput={onMinColIn}></input>      <br></br>
      挂单结束时间:<input onInput={onListEndTimeIn}></input>      <br></br>
    </div>
  );

}


