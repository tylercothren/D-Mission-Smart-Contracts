pragma solidity ^0.4.20;

import './DMissionAccessControl.sol';
import "./ERC721Draft.sol";

contract MatchboxBase is DMissionAccessControl, ERC721
{
    /*** EVENTS ***/

    event ManufacturedMatchbox(address owner, uint256 matchboxId, uint256 seriesId);

    event Transfer(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/

    struct Matchbox {
        uint256 seriesId;

        uint64 manufactureTime;

        bool isOpened;
    }

    /*** CONSTANTS ***/

    /*** STORAGE ***/

    Matchbox[] matchboxes;

    mapping (uint256 => address) public matchboxIndexToOwner;

    mapping (address => uint256) ownershipTokenCount;

    mapping (uint256 => address) public matchboxIndexToApproved;

    /// Assigns ownership of a specific Matchbox to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of Matchboxes is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        matchboxIndexToOwner[_tokenId] = _to;
        // When creating new Matchboxes _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // clear any previously approved ownership exchange
            delete matchboxIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    ///  An internal method that creates a new Matchbox and stores it.
    function _createMatchbox(
        uint256 _seriesId,
        bool _isOpened,
        address _owner
    )
        internal
        returns (uint)
    {
        Matchbox memory _matchbox = Matchbox({
            manufactureTime: uint64(now),
            seriesId: uint32(_seriesId),
            isOpened: _isOpened
        });
        uint256 newMatchboxId = matchboxes.push(_matchbox) - 1;

        // 4 billion limit case
        require(newMatchboxId == uint256(uint32(newMatchboxId)));

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newMatchboxId);

        return newMatchboxId;
    }
}