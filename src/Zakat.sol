// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/**
 * @title Zakat Smart Contract
 * @author  Azan Adnan
 * @notice This contract is used to Donate and Distribute Zakat
 * @dev Implements Zakat Distribution , Donation , Managing Community functionalities
 */

///  Whoever donates more then 10 ethers and do more then 10 donation is eligible for community member

contract Zakat {
    /** Errors */
    error Zakat_NotEnoughEthSend();
    error Zakat_NotACommunityMember();
    error Zakat_NotAVerifiedRecipient();
    error Zakat_ProposalForAddingCommunityMemberIsAlreadyActive();
    error Zakat_ProposalForRemovingCommunityMemberIsAlreadyActive();
    error Zakat_ProposalForAddingRecipientIsAlreadyActive();
    error Zakat_ProposalForRemovingRecipientIsAlreadyActive();
    error Zakat_ProposalIsNotActive();
    error Zakat_ProposalisAlreadyApproved();
    error Zakat_CommunityMemberAlreadyVoted();
    error Zakat_NotHaveEnoughFundsToSend();
    error Zakat_TransectionFailed();

    /** State Variables */

    address immutable i_owner;
    uint256 s_proposalId = 0;
    uint256 s_numberOfRecipients;

    /** @dev A recipient cant withdraw again within a month */
    uint256 constant WITHDRAW_TIME_PERIOD = 4 weeks;
    uint256 constant MINIMUM_DONATIONS = 0.1 ether;

    mapping(address => bool) s_DoesRecipientsNeedFunds;
    mapping(address => bool) s_verifiedRecipients;
    mapping(address => bool) s_verifiedCommunnityMembers;
    mapping(address => uint) s_DonorsToAmount;
    mapping(uint256 => Propsal) propsalIdToProposalDetails;

    bool s_isProposalforAddingorRemovingCommunityMemberActive = false;
    bool s_isProposalforAddingorRemovingRecipientActive = false;
    address[] s_verifiedRecipientsarr;

    /** @dev This struct holds all the details of every proposal*/
    struct Propsal {
        uint256 proposalId;
        string propsalDescription;
        bool isActive;
        bool isApproved;
        uint256 numOfTrueVotes;
        uint256 numOfFalseVotes;
        mapping(address => bool) hasVoted;
    }

    constructor() {
        i_owner = msg.sender;
        s_verifiedCommunnityMembers[msg.sender] = true;
    }

    /** Events */

    event donateFunds(uint256 amount, address donner)
    event withdrawFunds(uint256 amount, uint256 fundsShare);
    event approveProposal();
    event AddProposal();
    /** Functions */

    function donateFunds() external payable {
        if (msg.value <= MINIMUM_DONATIONS) {
            revert Zakat_NotEnoughEthSend();
        }
        s_DonorsToAmount[msg.sender] = msg.value;
    }

    function WithdrawFunds() external onlyCommunityMember(msg.msg.sender) {
        uint256 memory contractbalacnce = address(this).balance;
        if (contractbalacnce < 0) {
            revert Zakat_NotHaveEnoughFundsToSend();
        }

        uint256 recipientShare = contractbalacnce / s_numberOfRecipients;

        for (int i = 0; i < s_numberOfRecipients; i++) {
            (bool success, ) = s_verifiedRecipientsarr[i].call{
                value: address(this).recipientShare
            }("");
            if (!success) {
                revert Zakat_TransectionFailed();
            }
        }
    }

    modifier onlyCommunityMember(address communityMember) {
        if (s_verifiedCommunnityMembers[communityMember] == true) {
            revert Zakat_NotACommunityMember();
        }
        _;
    }

    // Optional modifier OnlyVerifiedRecipients(address )

    /// @dev Adding Proposal  functions

    function AddCommunityMemberProposal(
        string memory description
    ) external onlyCommunityMember(msg.sender) {
        if (s_isProposalforAddingorRemovingCommunityMemberActive == true) {
            revert Zakat_ProposalForAddingCommunityMemberIsAlreadyActive();
        }

        s_proposalId++;
        s_isProposalforAddingorRemovingCommunityMemberActive = true;

        AddProposal(s_proposalId, description, true, false);
    }

    function RemoveCommunityMemberProposal(
        string memory description
    ) external onlyCommunityMember(msg.sender) {
        if (s_isProposalforAddingorRemovingCommunityMemberActive == true) {
            revert Zakat_ProposalForRemovingCommunityMemberIsAlreadyActive();
        }

        s_proposalId++;
        s_isProposalforAddingorRemovingCommunityMemberActive = true;

        AddProposal(s_proposalId, description, true, false);
    }

    function AddRecipientProposal(
        string memory description
    ) external onlyCommunityMember(msg.sender) {
        if (s_isProposalforAddingorRemovingRecipientActive == true) {
            revert Zakat_ProposalForAddingRecipientIsAlreadyActive();
        }
        s_proposalId++;
        s_isProposalforAddingorRemovingRecipientActive == true;

        AddProposal(s_proposalId, description, true, false);
    }

    function RemoveRecipientProposal(
        string memory description
    ) external onlyCommunityMember(msg.sender) {
        if (s_isProposalforAddingorRemovingRecipientActive == true) {
            revert Zakat_ProposalForRemovingRecipientIsAlreadyActive();
        }
        s_proposalId++;
        s_isProposalforAddingorRemovingRecipientActive == true;

        AddProposal(s_proposalId, description, true, false);
    }

    function AddProposal(
        uint256 proposalId,
        string memory description,
        bool isActive,
        bool isApproved
    ) internal {
        propsalIdToProposalDetails[proposalId] = Propsal(
            proposalId,
            description,
            isActive,
            isApproved,
            1,
            0,
            hasVoted[msg.sender] = true
        );
    }

    /// @dev Voting functions

    function VoteforProposal(
        uint256 proposalId,
        bool vote
    ) external onlyCommunityMember(msg.sender) {
        if (propsalIdToProposalDetails[proposalId].isActive == false) {
            revert Zakat_ProposalIsNotActive();
        }
        if (propsalIdToProposalDetails[proposalId].isApproved == true) {
            revert Zakat_ProposalisAlreadyApproved();
        }

        if (
            propsalIdToProposalDetails[proposalId].hasVoted(msg.sender) == true
        ) {
            revert Zakat_CommunityMemberAlreadyVoted();
        }

        propsalIdToProposalDetails[proposalId].hasVoted = true;
        if (vote == true) {
            propsalIdToProposalDetails[proposalId].numOfTrueVotes++;
        } else {
            propsalIdToProposalDetails[proposalId].numOfFalseVotes++;
        }
    }

    /// @dev Approve functions
    function ApproveAddingorRemovingParticpants()
        external
        onlyCommunityMember(msg.sender)
    {}

    /// @dev get list of running propsals
}

/** Zakat Contribution  
     * 1. Donate Funds (payable)
     

/**  Zakat Distribution
     * 1. Withdraw funds To Recipients Equally
     

    */
/**  
 
 refund Mechanism
     * 1. Refund Funds if some time has passed like 2 months 
    
    */
// Conditional giving
/**
 * 1. Atleast 5 community members should approve the proposal to add a recipient or
 *
 */
/**  Deeenterlaized
 * 1. AddProposal For adding a recipient
 * 2. Approve Proposal by verified Community Members
 * 3. Add Proposal For adding a new Community Member
 * 4. Approve Proposal For addig a new Community Member
 * 5.  Add Proposal to Remove Recipients
 * 6. Approve Proposal to Remove Recipients
 * 6. if there are a bad actor there should be proposal for removing a communty member where all members or atleast 75% of the members should vote
 * */
// View Functions
