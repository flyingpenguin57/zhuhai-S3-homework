import { createPublicClient, http, parseAbiItem } from 'viem';
import { mainnet } from 'viem/chains';

const INFURA_PROJECT_ID = '1d37b9d398af4b81baca54ea5f164f17';
const USDC_CONTRACT_ADDRESS = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';

// 初始化 Viem 客户端
const client = createPublicClient({
  chain: mainnet,
  transport: http(`https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`)
});

async function getRecentUSDCTransfers() {
  // 获取最新区块号
  const latestBlock = await client.getBlockNumber();

  // 定义查询的区块范围
  const fromBlock = latestBlock - BigInt(100);
  const toBlock = latestBlock;

  console.log(`查询区块范围: ${fromBlock} - ${toBlock}`);

  // 查询日志事件
  const logs = await client.getLogs({
    fromBlock,
    toBlock,
    address: USDC_CONTRACT_ADDRESS,
    event: parseAbiItem('event Transfer(address indexed, address indexed, uint256)')
  });


  const transfers = logs.map(log => {
    const [from, to, value] = log.args
    return {
      blockNumber: log.blockNumber,
      transactionHash: log.transactionHash,
      from: from,
      to: to,
      value: value?.toString()
    };
  });

  return transfers;
}

getRecentUSDCTransfers().then(transfers => {
  console.log('USDC Transfer 记录:');
  transfers.forEach(transfer => {
    console.log(transfer);
  });
}).catch(error => {
  console.error('查询过程中发生错误:', error);
});
