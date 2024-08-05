// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20MinerReward is ERC20 {
    event LogNewAlert(string description, address indexed _from, uint256 _n);

    constructor() ERC20("MinerReward", "MRW") {}

    function _reward() public {
        _mint(block.coinbase, 20);
        emit LogNewAlert("_rewarded", block.coinbase, block.number);
    }

    // _mint 铸币/转账
//      铸造新代币：创建新的代币并增加代币总供应量。
//      分发代币：将铸造的代币分配到指定的账户地址。
//      更新账户余额：调整接收账户的代币余额。
//      更新总供应量：增加代币的总供应量，以反映新创建的代币数量。

    // function _update(address from, address to, uint256 value) internal virtual {
    //     if (from == address(0)) {
    //         // Overflow check required: The rest of the code assumes that totalSupply never overflows
    //         _totalSupply += value;
    //     } else {
    //         uint256 fromBalance = _balances[from];
    //         if (fromBalance < value) {
    //             revert ERC20InsufficientBalance(from, fromBalance, value);
    //         }
    //         unchecked {
    //             // Overflow not possible: value <= fromBalance <= totalSupply.
    //             _balances[from] = fromBalance - value;
    //         }
    //     }

    //     if (to == address(0)) {
    //         unchecked {
    //             // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
    //             _totalSupply -= value;
    //         }
    //     } else {
    //         unchecked {
    //             // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
    //             _balances[to] += value;
    //         }
    //     }

    //     emit Transfer(from, to, value);
    // }
}
