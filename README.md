## Requirements

* node v16.14.0
* npm v6.14.0
* truffle v5.4.32
* ganache-cli (or desktop app)
* Solidity v0.5.16
* Web3.js v1.5.3

## To get started
1 . clone and start this project first and React-auction-app second.

2 . Install dependencies
`npm install`

3 . Open ganache desktop (or run ganache-cli : https://www.npmjs.com/package/ganache-cli ).

4 . Create a new workspace, click add project and import truffle-config.js file.

5 . Start the project
`truffle migrate --reset`

6 . Copy "Auction.json", "AuctionList.json" & "MyAuction.json" files in ethereum-auction-app/build/contracts under react-auction-app/src/abi.

7 . Go to React-auction-app and start the project.