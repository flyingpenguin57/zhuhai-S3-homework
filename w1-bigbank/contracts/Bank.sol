// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Bank {
    //account to balance
    mapping(address => uint) public accountBalance;

    //top3 deposit address
    address[3] public top3;

    //withdraw, only admin can do this
    function _withdraw(uint amount) internal {
        require(amount <= address(this).balance, "insufficient balance!");
        address payable to = payable(msg.sender);
        to.transfer(amount);
    }

    //sort top3
    function sort() internal {
        if (
            accountBalance[msg.sender] > accountBalance[top3[top3.length - 1]]
        ) {
            if (inTop3(msg.sender)) {
                _sort();
            } else {
                top3[top3.length - 1] = msg.sender;
                _sort();
            }
        }
    }

    //in top3 or not
    function inTop3(address addr) private view returns (bool) {
        for (uint i = 0; i < top3.length; i++) {
            if (addr == top3[i]) {
                return true;
            }
        }
        return false;
    }

    function _sort() private {
        for (uint i = top3.length - 1; i >= 1; i--) {
            if (accountBalance[top3[i]] > accountBalance[top3[i - 1]]) {
                address temp = top3[i - 1];
                top3[i - 1] = top3[i];
                top3[i] = temp;
            }
        }
    }
}
