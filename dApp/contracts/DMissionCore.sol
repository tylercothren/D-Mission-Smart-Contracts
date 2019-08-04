pragma solidity ^0.5.1;
import './MatchboxBase.sol';
import './BlueprintBase.sol';

/// @title D-Mission!: Collectible and modifiable cars and parts on the Ethereum blockchain.
/// @author Tyler Cothren
/// @dev The main D-Mission! contract, keeps track of kittens so they don't wander around and get lost.
contract DMissionCore is DMissionAccessControl, MatchboxBase, BlueprintBase {
    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    /// @notice Creates the main D-Mission! smart contract instance.
    constructor() public {
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
    ///  function setNewAddress(address _v2Address) public onlyCEO whenPaused {
    ///  See README.md for updgrade plan
    ///    newContractAddress = _v2Address;
    ///    ContractUpgrade(_v2Address);
    ///}

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
       
        Matchbox memory box = matchboxes[_id];

        isOpened = box.isOpened;
        seriesId = uint256(box.seriesId);
        manufactureTime = uint256(box.manufactureTime);
    }
    
    /// @notice Returns all the relevant information about a specific blueprint.
    /// @param _id The ID of the blueprint of interest.
    function getBlueprint(uint256 _id)
        public
        view
        returns (
            uint256 seriesId,
            string memory partName
    ) {
        Blueprint memory blue = blueprints[_id];

        seriesId = uint256(blue.seriesId);
        partName = blue.partName;
    }
    
    /// @notice Returns all the relevant information about a specific Attribute.
    /// @param _id The ID of the Attribute of interest.
    function getAttribute(uint256 _id)
        public
        view
        returns (
            uint256 blueprintId,
            uint256 targetId,
            int128 affect
    ) {
        Attribute memory att = attributes[_id];

        blueprintId = uint256(att.blueprintId);
        targetId = uint256(att.targetId);
        affect = int128(att.affect);
    }
    
    /// @notice Returns all the relevant information about a specific part.
    /// @param _id The ID of the part of interest.
    /*function getPart(uint256 _id)
        public
        view
        returns (
        uint256 bluePrintId,
        uint256 manufactureTime
    ) {
        Part part = parts[_id];

        bluePrintId = uint256(part.bluePrintId);
        manufactureTime = uint256(part.manufactureTime);
    }*/

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    function unpause() public onlyCEO whenPaused {
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }
}