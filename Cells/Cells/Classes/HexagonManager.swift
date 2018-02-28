//
//  HexagonManager.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 15/01/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

// Enum to standardize the neighboring positions of hexagons.
// Mainly used by Hexagons that affect other hexagons.
enum NeighboringTiles : Int {
    case bottomLeft = 0
    case left = 1
    case topLeft = 2
    case topRight = 3
    case right = 4
    case bottomRight = 5
}

// Class to control the spaces and Hexagons.
// Also responsible for updating all active Hexagons.
class HexagonManager {
    
    /// MARK: Properties
    
    // Hexagon matrix-related properties. The center offset is required because the game
    // treats position (3,5) as the center, that is, (0,0). Position (2,5) becomes (-1,0),
    // position (4,6) becomes (1,1), and so on. Matrix indexing will be reffered to as M_Indexes,
    // and Hexagon indexes will be reffered to as H_Indexes.
    public let centerOffset : (Int,Int) = (3,5)
    public let matrixColumns : Int = 7
    public let matrixRows : Int = 10
    
    // Controls how many taps it takes for the MultiTap to be solved.
    public var taps : Int = 5
    
    // Layers define the possible locations where new empty spaces will appear. H_Index.
    private var currentLayer : Int = 0
    private var layers : [[(Int, Int)]]!
    
    // These are the unlocked places in the tilemap
    private var openHexagons : [(Int, Int)]!
    
    // These are the currently open locations where a hexagon may spawn. H_Index.
    private var availableHexagons : [(Int, Int)]!
    
    // Matrix storing pointers to each Hexagon. M_Index.
    private var hexagonMatrix : [[Hexagon?]]!
    
    // Probability distribution and obstacle curve settings
    private var probDistribution : [Int] = [15, 17, 19, 21, 23]
    private var neededToUnlockNext : [Int] = [15, 4, 4, 4, -1, -1]
    private var unlockedHexagons : Int = 0
    
    
    /// MARK: Init
    
    init() {
        resetLayers()
    }

    
    /// MARK: Methods
    
    func getMainMenuHexagons() -> [Hexagon] {
        
        let playHex = PlayHexagon()
        playHex.matrixLocation = centerOffset
        
        //let settingsHex = SettingsHexagon()
        //settingsHex.matrixLocation = centerOffset + (0,-1)
        
        let aboutHex = AboutHexagon()
        aboutHex.matrixLocation = centerOffset + (1,-1)
        
        let rankingHex = RankingHexagon()
        rankingHex.matrixLocation = centerOffset + (0,-1)
        
        return [playHex, rankingHex, aboutHex]
    }
    
    
    // This resets all layer controllers and available Hexagon spaces back to default.
    // Also resets and clears the hexagonMatrix.
    func resetLayers() {
        self.currentLayer = 0
        self.layers = [  [(0,2),(0,-2)],
                         [(-1,1),(-1,-1),(2,1),(2,-1)],
                         [(-2,0),(2,0),(-1,2),(-1,-2),(1,2),(1,-2)]]
        self.availableHexagons = [(0,0), (0,1), (-1,0), (1,0), (1,1), (0,-1), (1,-1) ]
        self.openHexagons = availableHexagons
        
        self.hexagonMatrix = [[Hexagon?]]()
        
        for x in 0...matrixColumns {
            hexagonMatrix.append([])
            for y in 0...matrixRows {
                hexagonMatrix[x].append(nil)
            }
        }
        
        NeighborSlaveHexagon.staticAlpha = 1.0
    }
    
    // Returns the M_Index of the 7 center Hexagons.
    func getAllCenterHexagons() -> [(Int,Int)] {
        return [(0,0), (0,1), (1,1), (1,0), (-1,0), (0,-1), (1,-1)].map { $0 + centerOffset }
    }
    
    // Returns the M_Index of all open Hexagons.
    func getAllOpenHexagons() -> [(Int,Int)] {
        return self.openHexagons.map { $0 + centerOffset }
    }
    
    // Basically a progress bar for the probability distribution below.
    // Requires a certain amount of correct hits in each Hexagon type to
    // enable the next one.
    
    func progressUnlock(type: HexagonType) {
        let index = type.rawValue
        neededToUnlockNext[index] -= 1
        if neededToUnlockNext[index] == 0 {
            unlockedHexagons += 1
        }
    }
    
    // Prob distribution:
    // 64% Single Tap | 9% Skull | 9% Special | 9% Shield | 9% Neighbor
    func pickHexagonType() -> HexagonType {
        let rand = arc4random_uniform(UInt32(probDistribution[unlockedHexagons]))
        var pick = 0
        while(probDistribution[pick] <= rand) {
            pick += 1
        }
        return HexagonType.pick(pick)
    }
    
    // This returns a single M_Index where a new empty space will appear on the board.
    // If there are no more available spots for new spaces, it returns nil.
    func getNewHexagonSpace() -> (Int, Int)? {
        
        guard currentLayer < self.layers.count else { return nil }
        
        let count = UInt32(self.layers[currentLayer].count)
        let rand = Int(arc4random_uniform(count))
        let hexIndex = self.layers[currentLayer].remove(at: rand)
        if count == 1 {
            currentLayer += 1
        }
        self.availableHexagons.append(hexIndex)
        self.openHexagons.append(hexIndex)
        
        return hexIndex + centerOffset
    }
    
    // Returns an array of new Hexagons, with type, difficulty and locations already defined.
    // Most of the time the array will contain a single Hexagon, except in cases where the
    // new spawn requires more than one Hexagon to function, like the Neighbor Hexagon.
    
    // It should be noted that in case of a neighbor spawn, this function should never be called
    // with a .neighborSlave type as parameter, only .neighborMaster.
    func newHexagon(type : HexagonType, difficulty: CGFloat) -> [Hexagon] {
        
        var hexArray = [Hexagon]()
        
        // The special case is the Neighbor Hexagon. This spawns both a Master and a Slave Hexagon,
        // which are position-dependant. It might not be possible to spawn one, in which case
        // it will spawn a Single Tap Hexagon instead.
        if type == .neighborMaster {
            
            let count = UInt32(self.availableHexagons.count)
            let rand = Int(arc4random_uniform(count))
            
            // H_Index for the master.
            let masterIndex = self.availableHexagons[rand]
            
            // Tries to find a free neighbor for the above H_Index
            // result is a tuple of (direction, H_Index)
            if let result = self.getOneFreeNeighbor(for: masterIndex) {
                
                let master = NeighborMasterHexagon(difficulty: difficulty)
                let slave = NeighborSlaveHexagon(difficulty: difficulty)
                let (direction, slaveIndex) = result
                
                master.setDirection(direction: direction)
                
                master.matrixLocation = masterIndex + centerOffset
                slave.matrixLocation = slaveIndex + centerOffset
                
                // Weak references to each other
                master.slaveHexagon = slave
                slave.masterHexagon = master
                
                // Calculates M_Index for each Hexagon and store a reference to each in the matrix
                let (x,y) = masterIndex + centerOffset
                let (w,z) = slaveIndex + centerOffset
                hexagonMatrix[x][y] = master
                hexagonMatrix[w][z] = slave
            
                // Removes the taken positions from the availability array
                self.availableHexagons.remove(at: rand)
                let slaveRemovalIndex = self.availableHexagons.index(where: {$0 == slaveIndex})!
                self.availableHexagons.remove(at: slaveRemovalIndex)
                
                
                // The return array
                hexArray = [master, slave]
            }
            else {
                // No free neighbor found, let's do a Single Tap somewhere instead.
                return newHexagon(type: HexagonType.singleTap, difficulty: difficulty)
            }
        }
        else {
            // In case it's not a Neighbor, instantiate it normally
            switch type {
                case .dontTap: hexArray = [DontTapHexagon(difficulty: difficulty)]
                case .singleTap: hexArray = [SingleTapHexagon(difficulty: difficulty)]
                case .multiTap: hexArray = [MultiTapHexagon(difficulty: difficulty)]
                case .special: hexArray = [SpecialHexagon(difficulty: difficulty)]
                default: print("Attempted to spawn unknown Hexagon type!")
            }
            
            // Take a random free position (H_Index)
            let count = UInt32(self.availableHexagons.count)
            let rand = Int(arc4random_uniform(count))
            let hexIndex = self.availableHexagons.remove(at: rand)
            
            // The Hexagon must hold its M_Index
            hexArray[0].matrixLocation = hexIndex + centerOffset
            
            // Store the Hexagon in the matrix
            let (x,y) = hexArray[0].matrixLocation
            hexagonMatrix[x][y] = hexArray[0]
        }
        
        // Return the created Hexagon(s)
        return hexArray
    }
    
    // This returns all available neighbors for a given H_Index, in the form
    // of the tuple (direction, H_Index).
    func getAllFreeNeighbors(for index: (Int, Int)) -> [(NeighboringTiles, (Int, Int))] {
    
        // Depending on the Y position of the Hexagon, going up/down will move to the left or to the right.
        // This tilt can be calculated with a simple mod operation.
        let tilt = ((index.1 + 2) % 2) * -1
        
        // These are the directions and locations that must be checked. Any free spots will be put in an array.
        let neighboringIDs : [NeighboringTiles] = [.left, .right, .topLeft, .topRight, .bottomLeft, .bottomRight]
        let neighboringPositions : [(Int, Int)] = [(-1,0), (1,0), (tilt,1), (1+tilt,1), (tilt, -1), (1+tilt, -1)]
        var availableNeighbors = [(NeighboringTiles, (Int, Int))]()
    
        // Puts free neighbor tuples into an array.
        for i in 0...5 {
            let xy = index + neighboringPositions[i]
            if self.availableHexagons.contains(where: {$0 == xy}) {
                availableNeighbors.append((neighboringIDs[i], xy))
            }
        }
        
        // Return our newly populated array.
        return availableNeighbors
    }

    // Similar to the above function, but returns only one chosen neighbor.
    func getOneFreeNeighbor(for index: (Int, Int)) -> (NeighboringTiles, (Int,Int))? {
        
        // Get all available neighbors of the given H_Index
        let availableNeighbors = getAllFreeNeighbors(for: index)
        
        // If there's any free neighbors, pick a random one. Otherwise, return nil
        let neighborCount = availableNeighbors.count
        guard neighborCount > 0 else { return nil }
        let rand = arc4random_uniform(UInt32(neighborCount))
        return availableNeighbors[Int(rand)]
    }
    
    // Fetches the reference to the Hexagon in the given M_Index.
    func fetchHexagon(column: Int, row: Int) -> Hexagon? {
        return hexagonMatrix[column][row]
    }
    
    // Removes the reference to the Hexagon in the given M_Index,
    // and puts its equivalent H_Index back into the availableHexagons array.
    func removeHexagon(at hexIndex : (Int, Int)) {
        self.availableHexagons.append(hexIndex - centerOffset)
        hexagonMatrix[hexIndex.0][hexIndex.1] = nil
    }
    
    // Updates all active Hexagons.
    func update(timeElapsed deltaTime : TimeInterval) {
        for i in 0...matrixColumns {
            for j in 0...matrixRows {
                if let hex = hexagonMatrix[i][j] {
                    hex.update(timeElapsed: deltaTime)
                }
            }
        }
    }
    
    /// MARK: Debug
    func printMatrix() {
        print(hexagonMatrix)
    }
    
    func printAvailable() {
        print(availableHexagons)
    }
}
