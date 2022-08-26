// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <=0.8.11;

contract Auction {
    address payable internal auctionOwner; // Owner of the auctoin
    uint256 public auctionStart; // Start epoch time
    uint256 public auctionEnd; // End epoch time
    bool public ended;


    uint256 public oneWei = 1000000000000000000;
    uint256 public highestBid; // Highest amount bid in Eth
    address payable public  highestBidder; // Highest bidder

    address payable recipient;

    address[] bidders; // Array of bidders
    mapping(address => uint256) public bids; // Mapping matching the address of bidder with their total bid

    enum auctionState {STARTED, OVER, FINALISED, CANCELLED}
    auctionState public STATE; // Auction state (STARTED)

    string ipfs;

    struct NewAuction {
        address payable owner;
        string name;
        string description;
        uint256 startingPrice;
        uint256 auctionDuration;
        uint256 minIncrement;
        string ipfsHash;
    }

    NewAuction public myNewAuction;

    /** 
        Modifiers
        notOwner - Checks sender is not the owner of auction
        validAuction - Checks if auction is still valid
        validBid - Checks the bid is valid
        withdrawWinChecks - Checks before a seller can withdraw highest bid
        withdrawBidChecks - Checks before a bidder can withdraw their bid
        auctionOver - Checks if auction is over

    */
    modifier notOwner() {
        require(
            msg.sender != myNewAuction.owner,
            "You are the owner, you cannot bid on your item"
        );
        _;
    }

    modifier validAuction() {
        if (block.timestamp >= auctionEnd) {
            STATE = auctionState.OVER;
            emit AuctionOverEvent( "This auction is over",  myNewAuction.name, myNewAuction.description, auctionEnd, STATE);
        }
        require(STATE != auctionState.OVER, "This auction is over!");
        _;
    }

    modifier auctionBidders() {
        require(bidders.length >0, "there is no bidders");
        _;
    }

    modifier validBid() {
        require(
            msg.value > myNewAuction.startingPrice * oneWei,
            "Bid has to be more than starting price"
        );
        require(
            msg.value > highestBid,
            "Bid has to be more than the highest bid"
        );
        if (highestBid != 0) {
            require(
                (msg.value - highestBid) >= myNewAuction.minIncrement * oneWei,
                "Bid has to be more than the bid increment"
            );
        } else {
            require(
                (msg.value - (myNewAuction.startingPrice * oneWei)) >=
                    myNewAuction.minIncrement * oneWei,
                "Bid has to be more than the bid increment"
            );
        }
        _;
    }

    modifier withdrawWinChecks(){
        require(block.timestamp > auctionEnd, "This auction is not over!"); 
        require(msg.sender ==  myNewAuction.owner, "You are not the owner of the auction"); 
        require(!ended, "You have already withdrawn the highest bid.");
        _;
    }

    modifier withdrawBidChecks() {
        require(msg.sender !=  myNewAuction.owner, "Only bidders can perform this action");
        require(bids[msg.sender] > 0, "There are no bids");
        _;
    }

    /**
        Functions
    */
    function bid() payable public virtual returns (bool) {}
    function withdrawWinnings () public virtual returns(bool) {}
    function withdrawBid () public payable virtual returns(bool) {}
    function getHighestBidder () public payable virtual returns (address) {}
    function showSender() public virtual returns (address) {}
    function returnTime() public virtual returns (uint256) {}
    function returnContents() public virtual returns 
         (address, string memory, string memory, uint256, uint256, uint256, uint256, auctionState){}
    function transferHighestBid() payable public virtual auctionBidders returns(bool){}
    function refundBidders() payable public virtual auctionBidders returns(bool){}
    function returnState() public virtual returns (auctionState) {}
    function getIpfsHash() public virtual returns(string memory){}
    
    /**
        Events
    */
    event CreatedEvent(string message, address payable owner, uint256 time);
    event BidEvent(address indexed highestBidder, uint256 highestBid, address sender);
    event AuctionDetailsEvent( string name,  string description, uint256 startingPrice, uint256 auctionDuration, 
                               uint256 minIncrement, string ipfsHash, uint256 auctionStart, uint256 auctionEnd, auctionState state);
    event AuctionOverEvent( string message, string name, string description, uint256 auctionEnd, auctionState state);
    event ProviderWithdrawsEvent(string message, uint256 highestBid, address sender);
    event BidderWithdrawsEvent(string message, uint256 bid, address sender);
    event HighestBidderEvent(string message, address sender);
    
}

contract MyAuction is Auction {
    constructor( address payable _owner, string memory _name, string memory _description, uint256 _startingPrice, uint256 _auctionDuration, uint256 _minIncrement, string memory _ipfsHash) {
        auctionOwner == _owner;

        myNewAuction.owner = _owner;
        myNewAuction.name = _name;
        myNewAuction.description = _description;
        myNewAuction.startingPrice = _startingPrice;
        myNewAuction.auctionDuration = _auctionDuration;
        myNewAuction.minIncrement = _minIncrement;
        myNewAuction.ipfsHash = _ipfsHash;

        auctionStart = block.timestamp;
        auctionEnd = auctionStart + (_auctionDuration * 60);

        STATE = auctionState.STARTED;
        //emit CreatedEvent("Auction Created for: " , auctionOwner , block.timestamp);
        emit AuctionDetailsEvent(myNewAuction.name, myNewAuction.description,  myNewAuction.startingPrice, _auctionDuration,
                                 myNewAuction.minIncrement, myNewAuction.ipfsHash, auctionStart, auctionEnd, STATE );
    }

    function bid() payable public override notOwner validAuction validBid returns (bool)
    {
        highestBidder = payable(msg.sender);
        highestBid = msg.value;
        bidders.push(msg.sender); // Add bidder's address to the array of participant
        bids[msg.sender] = bids[msg.sender] + msg.value; // Update participant's bid in mapping bids
        emit BidEvent(highestBidder, highestBid, msg.sender); // Announce new highest bid and bidder
        return true; // Successful execution
    }

   /*function withdrawWinnings () public override withdrawWinChecks returns (bool)
    {
        ended = true;

        recipient = myNewAuction.owner;
        recipient.transfer(highestBid);

        STATE = auctionState.FINALISED;
        emit ProviderWithdrawsEvent("Provider withdraws: ", highestBid, msg.sender); // Announce winnings withdrawn
        return true;
    }*/

    /*function withdrawBid() public payable override withdrawBidChecks returns (bool)
    { 
        uint amount;
        if (msg.sender == highestBidder){
            recipient = highestBidder;
            amount = bids[msg.sender] - highestBid;
        }
        else {
            recipient = payable(msg.sender);
            amount = bids[msg.sender];
        }
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit BidderWithdrawsEvent("Bidder withdraws bid: ", amount, msg.sender); // Announce bid withrawn
        return true;
    }*/

    function getHighestBidder() public payable override returns(address)
    {
        emit HighestBidderEvent("The highest bidder and winner of the auction is", highestBidder);
        return highestBidder;     
    }

    function showSender() public view override returns (address) {
        return (msg.sender);
    }

    function returnTime() public view override returns (uint256) {
        return block.timestamp;
    }

    function returnContents() public view override
        returns (address, string memory, string memory, uint256, uint256, uint256, uint256, auctionState)
    {
        return (myNewAuction.owner, myNewAuction.name, myNewAuction.description,  myNewAuction.startingPrice,
                myNewAuction.auctionDuration, myNewAuction.minIncrement, auctionEnd, STATE);
    }

    function returnSenderBid(address _sender) public view returns(uint256){
        return bids[_sender];
    }

    function transferHighestBid() payable public virtual override auctionBidders returns(bool){
       
        /*transfer highest bid to auction owner*/
        ended = true;
        
        recipient = myNewAuction.owner;
        recipient.transfer(highestBid);
        STATE=auctionState.OVER;
        emit ProviderWithdrawsEvent("Provider withdraws: ", highestBid, msg.sender); // Announce winnings withdrawn
        return true;

    }

    function refundBidders() payable public virtual override auctionBidders returns(bool){
         /*refund bidders*/
        if (bidders.length> 1) {
            for (uint256 i = 0; i < bidders.length - 1; i++) {
                recipient = payable(bidders[i]);
                recipient.transfer(
                    bids[bidders[i]]
                );
            }
        }
        return true;
    }

    function returnState() public view override returns (auctionState) {
        return STATE;
    }

    function getIpfsHash() public view override returns (string memory){
        return myNewAuction.ipfsHash;
     
    }

}
