module Duplication

import util::Math;
import IO;
import List;
import Set;
import Map;
import String;
import List;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Volume;
import UnitSize;

// Add block to Maps
map[str, int] addToMap(map[str, int] blocks, str block){
    if (block in blocks) {blocks[block] += 1;}
	else { blocks[block] = 1;}
	return blocks;
}

// create blocks of 6, add it to map and count duplicate lines
tuple [map[str, int], int] createBlocks(map[str, int] blocks, loc fileLoc, int duplicateLOC) {
    list[str] lines = [];
    str line = "";
    bool insideBlockComment = false;
    str previousBlock = "";
    for (str line <- readFileLines(fileLoc)) {
        if (trim(line) != "" && !startsWith(trim(line), "//")) {
             if (startsWith(trim(line), "/*") || (insideBlockComment == true)) {
                // inside the block comment
                insideBlockComment = true;
                if (endsWith(trim(line), "*/")) {
                    // outside the block comment
                    insideBlockComment = false; 
                }
            }
            else {
                lines += line;
                if (size(lines) == 6){
                    // if the lines are 6 it considered as a bloack and added to the map
                    str block = lines[0] + lines[1] + lines[2] + lines[3] + lines[4] + lines[5];
                    if (block in blocks){
                        if (previousBlock in blocks){
                            duplicateLOC += 1;
                        }
                        else{
                            duplicateLOC += 6;
                        }
                    }
                    blocks = addToMap(blocks, block);
                    previousBlock = block;
                    lines = lines[1..5]; // Remove the first line and make it ready to form next block
                }
            }
        }
    }
    return <blocks, duplicateLOC>;
}

// find duplicate blocks in a map
// map[str, int] findDuplicates(map[str, int] blocks){
//     for (str block <- blocks) {
//     if (blocks[block] == 1){
//         blocks = delete(blocks, block); // Remove blocks which are not duplicated
//     }
// }
//     return blocks;
// }

// // Find number of lines duplicated
// int findNumberOfDuplicateLines(map[str, int] blocks){
//     int numberOfDuplicateLines = 0;
//     for (str block <- blocks) {
//         // First occurance contains 6 lines, consequtive counted as 1 line
//         numberOfDuplicateLines += 6 + (blocks[block] - 1);
//     }
//     return numberOfDuplicateLines;
// }

// Find Duplicate blocks (6 lines ) of code in a project
str duplicateBlocksOfCodeProject(loc projectLoc) {
    int totalLines = LOC(projectLoc);
    println(totalLines);
    M3 model = createM3FromMavenProject(projectLoc);
    int duplicateLOC = 0;
    map[str, int] blocks = ();
    tuple [map[str, int], int] result = <blocks, duplicateLOC>;
    // iterate over files of project and create blocks
    for (file <- files(model.containment)) {
        result = createBlocks(result[0], file.top, result[1]);
    }

    // map[str, int] duplicateBlocks = findDuplicates(blocks);

    // int numberOfDuplicateLines = findNumberOfDuplicateLines(duplicateBlocks);

    // percentage = part / whole * 100
    numberOfDuplicateLines = result[1];
    println(numberOfDuplicateLines);
    int percentageOfDuplicates = round ((toReal (numberOfDuplicateLines)) / (toReal (totalLines)) * 100.0);
    println(percentageOfDuplicates);
    return duplicateRanking(percentageOfDuplicates);
}

// calculate ranking based on duplicateLOC
public str duplicateRanking(int percentageOfDuplicates) {
    return 	((percentageOfDuplicates >= 0 && percentageOfDuplicates <= 3) ? "++" : "") +
  			((percentageOfDuplicates > 3 && percentageOfDuplicates <= 5) ? "+" : "") +
  			((percentageOfDuplicates > 5 && percentageOfDuplicates <= 10) ? "o" : "") + 
  			((percentageOfDuplicates > 10 && percentageOfDuplicates <= 20) ? "-" : "") + 
  			((percentageOfDuplicates > 20) ? "--" : "");
}


int main(int testArgument=0) {
    println("argument: <testArgument>");
    return testArgument;
}
