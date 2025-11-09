// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ElectionWithSelfRegistration {
    // --- Structures ---
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
    }

    // --- State Variables ---
    mapping(address => Voter) public voters;
    mapping(uint => Candidate) public candidates;

    uint public candidatesCount;
    address public owner;

    // --- Events ---
    event CandidateAdded(uint candidateId, string name);
    event VoterRegistered(address voter);
    event VoteCasted(address voter, uint candidateId);
    event ElectionEnded(uint winningCandidateId);
    event ElectionReset();
    event OwnerChanged(address newOwner);
    event CandidateRemoved(uint candidateId);

    // --- Modifiers ---
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // --- Constructor ---
    constructor() {
        owner = msg.sender;
    }

    // --- Functions ---

    // Add a new candidate (only by owner)
    function addCandidate(string memory _name) public onlyOwner {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }

    // =================================================================
    // ===                 THIS IS THE NEW FUNCTION                  ===
    // =================================================================
    // Allows any user to register themselves to vote
    function registerToVote() public {
        address user = msg.sender;
        require(!voters[user].isRegistered, "You are already registered");
        voters[user].isRegistered = true;
        emit VoterRegistered(user);
    }
    // =================================================================

    // Vote for a candidate (voter must be registered)
    function vote(uint _candidateId) public {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "You must be registered to vote");
        require(!sender.hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");

        sender.hasVoted = true;
        candidates[_candidateId].voteCount++;

        emit VoteCasted(msg.sender, _candidateId);
    }

    // Get the winner (can be called anytime)
    function getWinner() public view returns (uint winnerId, string memory winnerName, uint winnerVoteCount) {
        uint highestVotes = 0;
        uint winningCandidateId = 0;

        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > highestVotes) {
                highestVotes = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }

        Candidate memory winner = candidates[winningCandidateId];
        return (winner.id, winner.name, winner.voteCount);
    }
        
}