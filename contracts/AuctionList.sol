// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <=0.8.11;
pragma experimental ABIEncoderV2;
import "./Auction.sol";

contract AuctionList {
    MyAuction[] public auctions;

    struct Details {
        address payable owner;
        string name;
        string description;
        uint256 startingPrice;
        uint256 auctionDuration;
        uint256 minIncrement;
    }
    Details public newDetails;
    Details[] details;

    function createAuctions(
        address payable _owner,
        string memory _name,
        string memory _description,
        uint256 _startingPrice,
        uint256 _auctionDuration,
        uint256 _minIncrement
    ) public payable{
        MyAuction newAuction = new MyAuction(
            _owner,
            _name,
            _description,
            _startingPrice,
            _auctionDuration,
            _minIncrement
        );
        newDetails.owner = _owner;
        newDetails.name = _name;
        newDetails.description = _description;
        newDetails.startingPrice = _startingPrice;
        newDetails.auctionDuration = _auctionDuration;
        newDetails.minIncrement = _minIncrement;


        details.push(newDetails);
        auctions.push(newAuction);
    }

    function getAllAuctions() public view returns (MyAuction[] memory) {
        return auctions;
    }

    function getAllAuctionDetails() public view returns (Details[] memory) {
        return details;
    }
}
