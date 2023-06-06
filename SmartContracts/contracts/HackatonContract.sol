// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Hackathon {
    struct Project {
        string title;
        uint[] ratings;
    }
    
    Project[] projects;

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

    function newProject(string calldata _title) external {
        // creates a new project with a title and an empty ratings array
        projects.push(Project(_title, new uint[](0)));
    }

    function rate(uint _idx, uint _rating) external {
        // rates a project by its index
        projects[_idx].ratings.push(_rating);
    }
}



// 1. `struct Project`: This defines a structure that represents a project in the hackathon. 
//     It has two properties: `title`, which is a string representing the title of the project, 
//     and `ratings`, which is an array of `uint` representing the ratings given to the project.

// 2. `Project[] projects`: This is a dynamic array that stores the projects submitted for the hackathon.

// 3. `function findWinner()`: This is an external view function that returns the winning project. 
//     It performs the following steps:
//    - It checks if there are any projects available by verifying that the length of the `projects` 
//     array is greater than 0. If not, it reverts the transaction with an error message.
//    - It initializes the `winner` variable with the first project in the `projects` array.
//    - It calculates the initial highest average rating by calling the `calculateAverageRating` 
//     function on the `winner` project.
//    - It iterates over the remaining projects in the `projects` array starting from index 1.
//    - For each project, it calculates the average rating by calling the `calculateAverageRating` function.
//    - If the average rating of the current project is higher than the highest average rating so far, 
//     it updates the `highestAverage` and `winner` variables with the current project.
//    - Finally, it returns the `winner` project.

// 4. `function calculateAverageRating(Project memory project)`: This is an internal pure function that 
//     calculates the average rating of a given project. It takes a `Project` struct as input and 
//     returns the average rating as a `uint`.
//    - It first checks if the `ratings` array of the project is empty. If it is, it returns 0.
//    - It initializes a `totalRating` variable to keep track of the sum of all the ratings.
//    - It iterates over the `ratings` array and adds each rating to the `totalRating`.
//    - Finally, it divides the `totalRating` by the length of the `ratings` array and returns the result.

// 5. `function newProject(string calldata _title)`: This is an external function that creates a 
//     new project with the given title and an empty ratings array. It appends the newly created 
//     project to the `projects` array.

// 6. `function rate(uint _idx, uint _rating)`: This is an external function that allows users 
//     to rate a project by its index. It takes an index `_idx` and a rating `_rating` as input. 
//     It appends the rating to the `ratings` array of the project at the specified index.