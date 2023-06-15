// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Hackathon {
    struct Project {
        string title;
        uint[] ratings;
    }
    
    Project[] projects;

    /**
     * @dev Returns the winning project based on the highest average rating.
     * @return The winning project as a `Project` struct.
     */
    function findWinner() external view returns (Project memory) {
        require(projects.length > 0, "No projects available");

        Project memory winner = projects[0];
        uint highestAverage = calculateAverageRating(winner);

        for (uint i = 1; i < projects.length; i++) {
            uint average = calculateAverageRating(projects[i]);
            if (average > highestAverage) {
                highestAverage = average;
                winner = projects[i];
            }
        }

        return winner;
    }

    /**
     * @dev Calculates the average rating of a project.
     * @param project The project for which to calculate the average rating.
     * @return The average rating as a `uint`.
     */
    function calculateAverageRating(Project memory project) internal pure returns (uint) {
        if (project.ratings.length == 0) {
            return 0;
        }

        uint totalRating = 0;
        for (uint i = 0; i < project.ratings.length; i++) {
            totalRating += project.ratings[i];
        }

        return totalRating / project.ratings.length;
    }

    /**
     * @dev Creates a new project with the given title and an empty ratings array.
     * @param _title The title of the new project.
     */
    function newProject(string calldata _title) external {
        projects.push(Project(_title, new uint[](0)));
    }

    /**
     * @dev Rates a project by its index.
     * @param _idx The index of the project to rate.
     * @param _rating The rating to assign to the project.
     */
    function rate(uint _idx, uint _rating) external {
        projects[_idx].ratings.push(_rating);
    }
}
