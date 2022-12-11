// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

contract VendingMachine {

    // Declare state variables of the contract
    address payable public owner;
    uint price = 1;
    mapping (address => uint) public cupcakeBalances;
    mapping (address => uint) public buyersQuantitiesPerPurchase;

    // When 'VendingMachine' contract is deployed:
    // 1. set the deploying address as the owner of the contract
    // 2. set the deployed smart contract's cupcake balance to 100
    constructor() {
        owner = payable(msg.sender);
        cupcakeBalances[address(this)] = 100;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can do this operation.");
        _;
    }

    // Allow the owner to increase the smart contract's cupcake balance
    function refill(uint amount) public onlyOwner {
        cupcakeBalances[address(this)] += amount;
    }

    function getPrice() public view onlyOwner returns (uint) {
        return price;
    }

    function setPrice(uint newPrice) public onlyOwner {
        price = newPrice;
    }

    function getVendingMachineCupcakeBalance() public view returns (uint) {
        return cupcakeBalances[address(this)];
    }

    function getVendingMachineEtherBalance() public onlyOwner view returns (uint) {
        return address(this).balance;
    }

    function withdraw() public onlyOwner payable {
        owner.transfer(getVendingMachineEtherBalance());
    }

    address[] private buyers;
    function getBuyers() public view returns (address[] memory, uint[] memory) {
        address[] memory _buyers = new address[] (buyers.length);
        uint[] memory _quantities = new uint[] (buyers.length);

        for (uint i = 0; i < buyers.length; i++) {
            _buyers[i] = buyers[i];
            _quantities[i] = buyersQuantitiesPerPurchase[buyers[i]];
        }

        return (_buyers, _quantities);
    }

    // Allow anyone to purchase cupcakes
    function purchase(uint amount) public payable {
        require(msg.value >= amount * 1 gwei * price, concatenate("The minimum price for purchasing each cupcake in Gwei is", uintToStr(price)));
        require(cupcakeBalances[address(this)] >= amount, "Not enough cupcakes in stock to complete this purchase");
        cupcakeBalances[address(this)] -= amount;

        buyersQuantitiesPerPurchase[msg.sender] += amount;
        buyers.push(msg.sender);
    }

    function uintToStr(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }

        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }

        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }

        str = string(bstr);
    }

    function concatenate(string memory a, string memory b) private pure returns (string memory) {
        return string(bytes.concat(bytes(a), " ", bytes(b)));
    }
}