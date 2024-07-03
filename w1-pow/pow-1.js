const crypto = require('crypto');

// 生成公私钥对
function generateKeyPair() {
    return crypto.generateKeyPairSync('rsa', {
        modulusLength: 2048,
        publicKeyEncoding: {
            type: 'spki',
            format: 'pem'
        },
        privateKeyEncoding: {
            type: 'pkcs8',
            format: 'pem'
        }
    });
}

// SHA-256 哈希计算
function sha256(data) {
    return crypto.createHash('sha256').update(data).digest('hex');
}

// 挖矿函数，找到符合条件的哈希值
function mineHash(prefix, zeroCount) {
    let nonce = 0;
    let hash = '';
    const startTime = Date.now();

    while (!hash.startsWith('0'.repeat(zeroCount))) {
        hash = sha256(prefix + nonce);
        nonce++;
    }

    const endTime = Date.now();
    const elapsedTime = (endTime - startTime) / 1000; // Convert to seconds

    return {
        elapsedTime,
        nonce: nonce - 1,
        hash
    };
}

// 使用私钥对数据签名
function signData(privateKey, data) {
    const sign = crypto.createSign('SHA256');
    sign.update(data);
    sign.end();
    return sign.sign(privateKey, 'hex');
}

// 使用公钥验证签名
function verifySignature(publicKey, data, signature) {
    const verify = crypto.createVerify('SHA256');
    verify.update(data);
    verify.end();
    return verify.verify(publicKey, signature, 'hex');
}

// 主要流程
const nickname = 'hulio'; 
const { publicKey, privateKey } = generateKeyPair();

console.log('公钥:', publicKey);
console.log('私钥:', privateKey);

console.log('Mining hash with 4 leading zeros...');
const result = mineHash(nickname, 4);
console.log(`Time taken: ${result.elapsedTime} seconds`);
console.log(`Nonce: ${result.nonce}`);
console.log(`Hash: ${result.hash}`);

const data = nickname + result.nonce;
const signature = signData(privateKey, data);
console.log('Signature:', signature);

const isValid = verifySignature(publicKey, data, signature);
console.log('Signature valid:', isValid);
