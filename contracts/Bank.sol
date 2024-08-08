// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/math/Math.sol";

contract Bank {
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // event

    address public immutable owner;

    constructor() payable {
        owner = msg.sender;
    }

    receive() external payable {}

    function withDraw() public onlyOwner {
        // payable(msg.sender).transfer(address(this).balance);
        // selfdestruct(payable(msg.sender));
    }
}

contract Weth {
    using Math for uint256;

    mapping(address => uint256) balanceOf;
    mapping(address => mapping(address => uint256)) allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Deposit(address indexed from, uint256 amount);
    event WithDraw(address indexed account, uint256 amount);
    event Approve(
        address indexed originAccount,
        address indexed proxyAccount,
        uint256 amount
    );

    receive() external payable {}

    function deposit() external payable {
        address account = msg.sender;
        uint256 amount = msg.value;

        require(account != address(0));
        require(amount > 0);

        (bool success, uint256 result) = balanceOf[account].tryAdd(amount);
        if (success) {
            balanceOf[account] = result;
            emit Deposit(account, amount);
        } else {
            revert("");
        }
    }

    function withDraw(uint256 _amount) external {
        address account = msg.sender;
        uint256 amount = balanceOf[account];

        require(amount >= _amount);
        (bool success, uint256 restAmount) = amount.trySub(_amount);
        if (success) {
            balanceOf[account] = restAmount;
            emit WithDraw(account, _amount);
        } else {
            revert();
        }
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function approve(address proxyAddress, uint256 _amount) external {
        address originAccount = msg.sender;
        uint256 originAmount = balanceOf[originAccount];

        require(originAmount > _amount);

        (bool success, uint256 result) = originAmount.trySub(_amount);
        if (success) {
            balanceOf[originAccount] = result;
            allowance[originAccount][proxyAddress] += result;
            emit Approve(originAccount, proxyAddress, _amount);
        } else {
            revert("");
        }
    }

    function transfer(address toAds, uint256 amount) public returns (bool) {
        return transferFrom(msg.sender, toAds, amount);
    }

    function transferFrom(
        address src,
        address toAds,
        uint256 amount
    ) public returns (bool) {
        require(balanceOf[src] >= amount);
        if (src != msg.sender) {
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }
        balanceOf[src] -= amount;
        balanceOf[toAds] += amount;
        emit Transfer(src, toAds, amount);
        return true;
    }
}

contract ToDo {
    struct Task {
        string content;
        bool status;
    }

    Task[] private taskList;

    function createTask(string memory _content) public returns (bool) {
        taskList.push(Task({content: _content, status: false}));
        return true;
    }

    function modityContent(
        uint256 index,
        string memory _content
    ) external returns (bool) {
        taskList[index].content = _content;
        return true;
    }
}

contract CrowdFunding {
    address private immutable beneficiary;
    uint256 private immutable fundTarget;
    uint256 public fundCurrent;

    mapping(address => uint256) funders;

    constructor(address _beneficiary, uint256 _fundTarget) {
        beneficiary = _beneficiary;
        fundTarget = _fundTarget;
    }

    // function contribute() external payable {
    //     require(AVAILABLED, "CrowdFunding is closed");

    //     // 检查捐赠金额是否会超过目标金额
    //     uint256 potentialFundingAmount = fundingAmount + msg.value;
    //     uint256 refundAmount = 0;

    //     if (potentialFundingAmount > fundingGoal) {
    //         refundAmount = potentialFundingAmount - fundingGoal;
    //         funders[msg.sender] += (msg.value - refundAmount);
    //         fundingAmount += (msg.value - refundAmount);
    //     } else {
    //         funders[msg.sender] += msg.value;
    //         fundingAmount += msg.value;
    //     }

    //     // 更新捐赠者信息
    //     if (!fundersInserted[msg.sender]) {
    //         fundersInserted[msg.sender] = true;
    //         fundersKey.push(msg.sender);
    //     }

    //     // 退还多余的金额
    //     if (refundAmount > 0) {
    //         payable(msg.sender).transfer(refundAmount);
    //     }
    // }
}

contract MultiSigWallet {
    // 状态变量
    address[] public owners;
    mapping(address => bool) public isOwner;
    // 多少钱包同意
    uint256 public required;
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool exected;
    }
    Transaction[] public transactions;

    // key:交易id
    mapping(uint256 => mapping(address => bool)) public approved;

    // 事件
    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    // receive
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // 函数修改器
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }
    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "tx doesn't exist");
        _;
    }
    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }
    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].exected, "tx is exected");
        _;
    }

    // 构造函数
    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "owner required");
        require(
            _required > 0 && _required <= _owners.length,
            "invalid required number of owners"
        );
        for (uint256 index = 0; index < _owners.length; index++) {
            address owner = _owners[index];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner is not unique"); // 如果重复会抛出错误
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }

    // 函数
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function submit(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns (uint256) {
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, exected: false})
        );
        emit Submit(transactions.length - 1);
        return transactions.length - 1;
    }

    // 执行同意
    function approv(
        uint256 _txId
    ) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function execute(
        uint256 _txId
    ) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(getApprovalCount(_txId) >= required, "approvals < required");
        Transaction storage transaction = transactions[_txId];
        transaction.exected = true;
        (bool sucess, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(sucess, "tx failed");
        emit Execute(_txId);
    }

    function getApprovalCount(
        uint256 _txId
    ) public view returns (uint256 count) {
        for (uint256 index = 0; index < owners.length; index++) {
            if (approved[_txId][owners[index]]) {
                count += 1;
            }
        }
    }

    function revoke(
        uint256 _txId
    ) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(approved[_txId][msg.sender], "tx not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}
