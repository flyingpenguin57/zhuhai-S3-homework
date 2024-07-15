const { keccak256 } = require("viem")

let address = [
'0x5B38Da6a701c568545dCfcB03FcB875f56beddC4',
'0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2',
'0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db',
'0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB'
]
let addressHash = []
address.map((x)=>{
    addressHash.push(keccak256(x))
})
console.log(addressHash)

let v1 = keccak256(addressHash[0], addressHash[1])
let v2 = keccak256(addressHash[2], addressHash[3])
console.log(v1,v2)
console.log(keccak256(v1,v2))