var AuctionList = artifacts.require("AuctionList");
var Auction = artifacts.require("Auction");
var MyAuction = artifacts.require("MyAuction");

module.exports = function (deployer) {
  deployer.deploy(Auction);
  //deployer.deploy(MyAuction);
  deployer.deploy(AuctionList);
};
