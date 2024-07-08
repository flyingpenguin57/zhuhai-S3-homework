const ethers = require('ethers');

// 编码数字为bytes
const number = 1000000;
const coder = ethers.AbiCoder.defaultAbiCoder();
encodedData = coder.encode(["address","uint"], ["0xB34db0d5aA577998c10c80d76F87AfE58b024e5F",1]);
console.log(encodedData); // 输出: 0x0000000000000000000000000000000000000000000000000000000000003039
