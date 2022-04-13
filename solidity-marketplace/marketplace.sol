// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract MarketPlace {
    receive() external payable {}
    fallback() external payable {}

    struct Item { 
        uint id;
        string name;
        address owner;
    }

    enum StateSale {
        OnSale,
        Sold,
        Cancelled 
    }

    struct Sale { 
        uint id;
        uint item_id;
        uint256 price;
        StateSale state;
        address seller;
        address buyer;
    }

    mapping(uint => Item) public itemById;
    mapping(uint => Sale) public saleById;
    uint256 idCounter;

    constructor() {
        idCounter = 0;
    }

    function getNextId() public returns (uint256) {
        idCounter++;
        return idCounter;
    }

    function getItemById(uint id) public view returns (Item memory) {
        return itemById[id];
    }

    function getSaleById(uint id) public view returns (Sale memory) {
        return saleById[id];
    }

    function newItem(string memory name) public {
        uint256 nextId = getNextId();
        itemById[nextId] = Item(
            nextId,
            name,
            msg.sender);
    }

    function newSale(uint256 itemId, uint256 price) public {
        uint256 nextId = getNextId();
        address buyer = msg.sender;

        saleById[nextId] = Sale(
            nextId,
            itemId,
            price,
            StateSale.OnSale,
            address(this),
            buyer);
    }

    modifier isSaleOnSale (uint idSale) {
        require (saleById[idSale].state == StateSale.OnSale, "Sale should have the state on sale");
        _;
    }

    modifier isTransferAmountEnough(uint256 idSale) {
        require(msg.value >= saleById[idSale].price, "The transfert money is not enough for the item" );
        _;
    }

    function buyItem(uint256 idSale) payable public isSaleOnSale(idSale) isTransferAmountEnough(idSale) {
        saleById[idSale].buyer = msg.sender;

        //retour de monnaie s'il y a eu trop d'argent lors du transfer
        uint retourMonnaie = msg.value - saleById[idSale].price;
        if(retourMonnaie > 0)
            payable(msg.sender).transfer(retourMonnaie);

        //solde la vente
        saleById[idSale].state = StateSale.Sold;
    }

    function cancelSale(uint idSale) public isSaleOnSale(idSale) {
        saleById[idSale].state = StateSale.Cancelled;
    }

}