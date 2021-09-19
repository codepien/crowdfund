//SPDX-License-Identifier: MIT;

pragma solidity ^0.6.7;

//get the ABI for the price feed contract
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract Payable {
    
    //set owner so we can require for withdraws
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        
        require(msg.sender == owner);
        _;
    }
    
    mapping(address => uint) balance;
    
    address[] fromAddessArray;
    
    //people can contribute to the crowdfunding
    function fund() public payable {
        
        uint minimumUSD = 50 * 10 **18;
        require(conversion(msg.value) > minimumUSD);
        
        balance[msg.sender] += msg.value;
        fromAddessArray.push(msg.sender);
    
    }
    
    //test run with the Aggregator ABI
    function getVersion() public view returns(uint) {
        
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        return priceFeed.version();
    }
    
    //actual price for the kovan testnet
    function getPrice() public view returns(uint) {
        
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint(answer * 10000000000);
    }
    
    //convert ETH to USD
    function conversion(uint _ethAMount) public view returns(uint) {
        uint priceUSD = getPrice();
        uint dollarAmount = (_ethAMount * priceUSD)/100000000000000000;
        return dollarAmount;
    }
    
    //transfer fund out
    function withdraw(uint _amount) public onlyOwner {
        require(address(this).balance >= _amount);
        msg.sender.transfer(_amount);
    }
}