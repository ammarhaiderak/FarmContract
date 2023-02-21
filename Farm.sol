pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract MyFarm is ERC20, Ownable {
    event Deposit(address, uint);
    event Withdraw(address, uint);

    mapping(address => uint) userLastClaimed;

    uint notifyTimestamp;
    
    constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        _mint(msg.sender, initialSupply);
    }

    
    function invest() external payable {
        uint _amount = msg.value;
        address _sender = msg.sender;
        require(_amount > 0, "you cannot invest 0");
        _mint(_sender, _amount);       // minting same amount of tokens to for simplicity
        emit Deposit(_sender, _amount);
    }

    function withdraw() external {
        uint _shares = balanceOf(msg.sender);
        address _sender = msg.sender;
        require(_shares > 0, "your investment is zero");
        _burn(_sender, _shares);
        emit Withdraw(_sender, _shares);
    }

    function notifyProfit() external onlyOwner {
        notifyTimestamp = block.timestamp;
    }

    function claimProfit() external {
        address _sender = msg.sender;
        if(userLastClaimed[_sender] != 0) {
            require(userLastClaimed[_sender] != notifyTimestamp);
        }
        else {
            userLastClaimed[_sender] = notifyTimestamp;
        }
        _transferProfit(_sender);
    }

    function _transferProfit(address _user) internal {
        address _farm = address(this);
        require(_farm.balance > 0, "farm balance is insufficient");
        uint profit = balanceOf(_user) * _farm.balance / totalSupply();
        require(profit > 0, "insufficient profit");
        address payable _receiver = payable (_user);
        require(_receiver.send(profit), "failed to transfer");
    }
}
