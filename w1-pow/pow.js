const crypto = require('crypto');

//取哈希值
function sha256(data) {
    return crypto.createHash('sha256').update(data).digest('hex');
}

//挖矿
function mineHash(prefix, zeroCount) {
    let nonce = 0; //初始nonce=0
    let hash = ''; //初始hash
    const startTime = Date.now(); //开始时间

    //当hash值不是以zeroCount个数的0开始时，继续循环
    while (!hash.startsWith('0'.repeat(zeroCount))) {
        hash = sha256(prefix + nonce);
        nonce++;
    }

    const endTime = Date.now();//结束时间
    const elapsedTime = (endTime - startTime) / 1000; // Convert to seconds

    return {
        elapsedTime,
        nonce: nonce - 1,
        hash
    };
}

const nickname = 'hulio'; // my nick name

console.log('Mining hash with 4 leading zeros...');
let result = mineHash(nickname, 4);
console.log(`Time taken: ${result.elapsedTime} seconds`);
console.log(`Nonce: ${result.nonce}`);
console.log(`Hash: ${result.hash}`);

console.log('Mining hash with 5 leading zeros...');
result = mineHash(nickname, 5);
console.log(`Time taken: ${result.elapsedTime} seconds`);
console.log(`Nonce: ${result.nonce}`);
console.log(`Hash: ${result.hash}`);
