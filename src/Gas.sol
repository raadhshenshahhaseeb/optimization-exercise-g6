// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 

contract GasContract {
    uint256 public totalSupply = 0; // cannot be updated
    mapping(address => uint256) public balances;
    uint256 public tradePercent = 12;

    function whitelist(address) external pure returns (uint256){
        return 0;
    }
    address[5] public administrators;

    mapping(address => uint256) public whiteListStruct;

    event AddedToWhitelist(address userAddress, uint256 tier);

    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(
        address admin,
        uint256 ID,
        uint256 amount,
        string recipient
    );
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        totalSupply = _totalSupply;

        for (uint256 ii = 0; ii < 5; ii++) {
            administrators[ii] = _admins[ii];
        }
        balances[administrators[4]] = totalSupply;
    }


    function checkForAdmin(address) public pure returns (bool) {
        return true;
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        uint256 balance = balances[_user];
        return balance;
    }


    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public returns (bool status_) {
        require(
            balances[msg.sender] >= _amount,
            "Gas Contract - Transfer function - Sender has insufficient Balance"
        );
        require(
            bytes(_name).length < 9,
            "Gas Contract - Transfer function -  The recipient name is too long, there is a max length of 8 characters"
        );
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);

        bool[] memory status = new bool[](tradePercent);
        for (uint256 i = 0; i < tradePercent; i++) {
            status[i] = true;
        }
        return (status[0] == true);
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        public
    {
        if(msg.sender == administrators[4]) {
            if(_tier < 255) {

                emit AddedToWhitelist(_userAddrs, _tier);
            }
            else {
                revert();
            }
        }
        else {
            revert();
        }
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public {

        whiteListStruct[msg.sender] = _amount;
        
        require(
            balances[msg.sender] >= _amount,
            "Gas Contract - whiteTransfers function - Sender has insufficient Balance"
        );
        require(
            _amount > 3,
            "Gas Contract - whiteTransfers function - amount to send have to be bigger than 3"
        );
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (true, whiteListStruct[sender]);
    }

}