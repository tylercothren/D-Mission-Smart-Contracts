pragma solidity ^0.4.18;

import "./MatchboxBreeding.sol";
import "./ClockAuction.sol";
import "./SaleClockAuction.sol";

/// @title Handles creating auctions for sale and siring of Matchboxes.
///  This wrapper of ReverseAuction exists only so that users can create
///  auctions with only one transaction.
contract MatchboxAuction is KittyOwnership {

    /// @dev The address of the ClockAuction contract that handles sales of Matchboxes. This
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are
    ///  initiated every 15 minutes.
    SaleClockAuction public saleAuction;

    /// @dev Sets the reference to the sale auction.
    /// @param _address - Address of sale contract.
    function setSaleAuctionAddress(address _address) public onlyCEO {
        SaleClockAuction candidateContract = SaleClockAuction(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSaleClockAuction());

        // Set the new contract address
        saleAuction = candidateContract;
    }

    /// @dev Put a Matchbox up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function createSaleAuction(
        uint256 _matchboxId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        public
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If matchbox is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _matchboxId));
        _approve(_matchboxId, saleAuction);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the matchbox.
        saleAuction.createAuction(
            _matchboxId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    /// @dev Transfers the balance of the sale auction contract
    /// to the MatchboxCore contract. We use two-step withdrawal to
    /// prevent two transfer calls in the auction bid function.
    function withdrawAuctionBalances() external onlyCOO {
        saleAuction.withdrawBalance();
    }
}