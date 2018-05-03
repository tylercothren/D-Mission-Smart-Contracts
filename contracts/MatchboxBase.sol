contract KittyBase is KittyAccessControl {
    /*** EVENTS ***/

    /// @dev The Birth event is fired whenever a new Matchbox comes into existence.
    event ManufactureMatchbox(address owner, uint256 matchboxId, uint256 seriesId);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a Matchbox
    ///  ownership is assigned, including Manufactures.
    event Transfer(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/

    /// @dev The main Matchbox struct. Every cat in CryptoKitties is represented by a copy
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  is important because of the byte-packing rules used by Ethereum.
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Matchbox {
        uint256 seriesId;

        uint64 manufactureTime;

        bool isOpened;
    }

    /*** CONSTANTS ***/

    /*** STORAGE ***/

    ///  An array containing the Matchbox struct for all Matchboxes in existence. The ID
    ///  of each Matchbox is actually an index into this array.
    Matchbox[] matchboxes;

    ///  A mapping from Matchbox IDs to the address that owns them. All Matchbox have
    ///  some valid owner address.
    mapping (uint256 => address) public matchboxIndexToOwner;

    ///  A mapping from owner address to count of tokens that address owns.
    ///  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCount;

    ///  A mapping from MatchboxIDs to an address that has been approved to call
    ///  transferFrom(). Each Matchbox can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public matchboxIndexToApproved;


    ///  The address of the ClockAuction contract that handles sales of Kitties. This
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are
    ///  initiated every 15 minutes.
    SaleClockAuction public saleAuction;

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

    ///  An internal method that creates a new Matchbox and stores it. This
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a ManufactureMatchbox event
    ///  and a Transfer event.
    /// @param _seriesId The Series ID of this Matchbox
    /// @param _isOpened Whether the Matchbox has been opened or not.
    /// @param _owner The inital owner of this matchbox.
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

        // It's probably never going to happen, 4 billion cats is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(newMatchboxId == uint256(uint32(newMatchboxId)));

        // emit the birth event
        ManufactureMatchbox(
            _owner,
            newMatchboxId,
            uint256(_matchbox.seriesId),
            _matchbox.isOpened,
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newMatchboxId);

        return newMatchboxId;
    }
}