pragma solidity ^0.4.18;

// // Auction wrapper functions
import "./MatchboxMinting.sol";

/// @title D-Mission!: Collectible and modifiable cars and parts on the Ethereum blockchain.
/// @author Tyler Cothren
/// @dev The main D-Mission! contract, keeps track of kittens so they don't wander around and get lost.
contract DMissionCore {
    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    /// @notice Creates the main D-Mission! smart contract instance.
    function DMissionCore() public {
        // Starts paused.
        paused = true;

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function setNewAddress(address _v2Address) public onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here, unless it's from one of the
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.sender == address(saleAuction)
        );
    }

    /// @notice Returns all the relevant information about a specific matchbox.
    /// @param _id The ID of the matchbox of interest.
    function getMatchbox(uint256 _id)
        public
        view
        returns (
        bool isOpened,
        uint256 seriesId,
        uint256 manufactureTime
    ) {
        Matchbox storage match = matchboxes[_id];

        isOpened = match.isOpened;
        seriesId = uint256(match.seriesId);
        manufactureTime = uint256(match.manufactureTime);
    }
    
    /// @notice Returns all the relevant information about a specific part.
    /// @param _id The ID of the part of interest.
    function getPart(uint256 _id)
        public
        view
        returns (
    ) {
        Part storage part = parts[_id];

        isOpened = match.isOpened;
        seriesId = uint256(match.seriesId);
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    function unpause() public onlyCEO whenPaused {
        require(saleAuction != address(0));
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }
}