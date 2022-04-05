const { assert } = require("chai");
const AuctionList = artifacts.require("./AuctionList.sol");

contract("AuctionList", (accounts) => {
  before(async () => {
    this.auctionList = await AuctionList.deployed();
  });

  it("deploys successfully", async () => {
    const address = await this.auctionList.address;
    assert.notEqual(address, 0x0);
    assert.notEqual(address, "");
    assert.notEqual(address, null);
    assert.notEqual(address, undefined);
  });

  it("checks auction is empty", async () => {
    const auctionCount = await this.auctionList.getAllAuctions();
    assert.equal(auctionCount.length, 0);
    console.log("\t Auction Count is", auctionCount.length);
  });

  it("creates one auction", async () => {
    const newAuction = await this.auctionList.createAuctions(
      accounts[0],
      "Test Auction",
      "Test Auction Description",
      20,
      2,
      1
    );
    const auctionCount = await this.auctionList.getAllAuctions();
  });

  it("auction count is 1", async () => {
    const auctionCount = await this.auctionList.getAllAuctions();
    assert.equal(auctionCount.length, 1);
    console.log("\t Auction Count is", auctionCount.length);
  });

  it("creates two auctions", async () => {
    const auction1 = await this.auctionList.createAuctions(
      accounts[0],
      "Auction 5",
      "Auction 5's Description",
      10,
      4,
      2
    );
    const auction2 = await this.auctionList.createAuctions(
      accounts[0],
      "Auction 2",
      "Auction 2's Description",
      15,
      2,
      3
    );
    const auctionCount = await this.auctionList.getAllAuctions();
  });

  it("auction count is 3", async () => {
    const auctionCount = await this.auctionList.getAllAuctions();
    assert.equal(auctionCount.length, 3);
    console.log("\t Auction Count is", auctionCount.length);
  });

  // Check how to delete auctions
});
