#
# Copyright (c) 2015-2016 by The Board of Trustees of the Leland
# Stanford Junior University.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
#  Author: Lavanya Jose (lavanyaj@cs.stanford.edu)
#
#



from pycpx import CPlexModel
import rmt_ffd_compiler
import rmt_ffl_compiler
from rmt_configuration import RmtConfiguration
import numpy as np
from datetime import datetime
import time
import logging

hun_extended = True

hun_add_logical_table_ids = True
hun_correct_table_ids = True

hun_start_end_same = True

class RmtIlpCompiler:
    def __init__(self, relativeGap, greedyVersion,objectiveStr='maximumStage',\
                     emphasis=0, timeLimit=None, treeLimit=None,\
                     variableSelect=None, ignoreConstraint=None,\
                     workMem=None,\
                     nodeFileInd=None,\
                     workDir=None):
        """ Initialize compiler with CPLEX parameters
        @relativeGap is a fraction f so that CPLEX will stop at a solution that
         is within f of the optimal, corresponds to CPX_PARAM_EPGAP in CPLEX
         @greedyVersion is one of 'ffl'/ 'ffd' etc.
         @objectiveStr is one of pipelineLatency, maximumStage, powerForRamsAndTcams
         other parameters are optional .. (see pycpx for more info)
        """
        self.logger = logging.getLogger(__name__)

        self.objectiveStr=objectiveStr
        self.relativeGap = relativeGap
        self.greedyVersion = greedyVersion

        # Different parameters to speed up CPLEX
        # see CPLEX documentation
        self.emphasis = emphasis
        self.variableSelect = variableSelect
        self.timeLimit = timeLimit
        self.treeLimit = treeLimit
        self.workMem = workMem
        self.nodeFileInd = nodeFileInd
        self.workDir = workDir

        # one constraint to ignore (used in limiting constraints experiments)
        # one of capacity, useMemory, assignment, dependency, action,
        # inputCrossbar, resolutionLogic, actionCrossbar, pipelineLatency
        self.ignoreConstraint = ignoreConstraint

        # For logging only
        self.dictNumVariables = \
            {'log': 0, 'st': 0, 'log*st': 0,
             'allMem*pf*log*st':0,
             'mem*log':0, 'mem*log*st': 0, 'mem*st':0, 'allMem*log*st': 0,
             'constant': 0,
             'succDep':0, 'matchDep':0, 'actionDep':0
            }
        self.numVariables = 0
        self.dictNumConstraints = \
            {'log': 0, 'st': 0, 'log*st': 0,
             'allMem*pf*log*st':0,
             'mem*log':0, 'mem*log*st': 0, 'mem*st':0, 'allMem*log*st': 0,
             'constant': 0,
             'succDep':0, 'matchDep':0, 'actionDep':0
            }
        self.numConstraints = 0

        self.dimensionSizes = {}
        pass

    def setDimensionSizes(self):
        # for logging only
        item_count_allmempflogst = 0
        for thing in self.switch.allTypes:
            item_count_allmempflogst += self.pfMax[thing]*self.logMax*self.stMax
        self.dimensionSizes = {
            'log':self.logMax,
            'st':self.stMax,
            'log*st':self.logMax*self.stMax,
            'allMem*pf*log*st':item_count_allmempflogst,
            'mem*log':len(self.switch.memoryTypes)*self.logMax,
            'mem*log*st': len(self.switch.memoryTypes)*self.logMax*self.stMax,
            'mem*st':len(self.switch.memoryTypes)*self.stMax,
            'allMem*log*st': len(self.switch.allTypes)*self.logMax*self.stMax,
            'constant': 1,
            'succDep':len(self.program.logicalSuccessorDependencyList),
            'matchDep':len(self.program.logicalMatchDependencyList),
            'actionDep':len(self.program.logicalActionDependencyList)
        }
        pass

    def computeSum(self, dictCount):
        log_list = []
        compute_value = 0
        for key in dictCount:
            log_list.append('%d*%s(%d)' % \
                (dictCount[key], key, self.dimensionSizes[key]))
            compute_value += dictCount[key] * self.dimensionSizes[key]
        self.logger.debug("%s = %d" % (" + ".join(log_list), compute_value))

        return compute_value

    def P(self, l, m):
        return l - m

    """ Constraints """
    # word
    def actionAssignmentConstraint(self): # double checked
        """
        How many action words we can fit.
        """
        # print("action widths") all 0
        for log in range(self.logMax):
            # print(self.preprocess.actionWidths[log])
            for st in range(self.stMax):
                if self.preprocess.actionWidths[log] == 0:
                    # print("action width 0")
                    self.m.constrain(self.word['action'][log,st] <= 0)
                else:
                    print("action width not 0")
                    self.m.constrain(self.word['action'][log,st] >= self.word['sram'][log,st] + self.word['tcam'][log,st])
        # exit(1)
        self.dictNumConstraints['log*st'] += 1

    # block
    def capacityConstraint(self): # double checked
        """ Don't use more memories than available in each stage for action, match"""
        # tcam match entries ('tcam') is the only thing that uses TCAM
        for mem in self.switch.memoryTypes:
            # print(mem)
            # print(self.switch.numBlocks[mem])
            self.m.constrain(self.block[mem].T * np.ones(self.logMax) <= self.switch.numBlocks[mem])
            pass
        self.dictNumConstraints['mem*st'] += 1
        # exit(1)
        # action, sram match entries are two 'things' that use SRAM
        mem = 'sram'
        self.m.constrain(sum([self.block[thing].T for thing in self.switch.typesIn[mem]]) * np.ones(self.logMax) <= self.switch.numBlocks[mem])
        self.dictNumConstraints['st'] += 1


    # block
    # word
    # layout
    def wordLayoutConstraint(self): # double checked
        """ Relating number of packing units to number of blocks used/
        words per row fit
        """
        for mem in self.switch.allTypes:
            # print(mem)
            # print("layout")
            # print(self.preprocess.layout[mem]) action -> [0, 0, 0, ...] sram -> [4, 4, 4, ...] tcam -> [1, 1, 1, ...]
            # print("word")
            # print(self.preprocess.word[mem]) action -> [0, 0, 0, ...] sram -> [1024, 1024, ...] tcam -> [512, 512, ...]
            # print(self.preprocess.layout[mem])
            # print(self.preprocess.word[mem])
            for log in range(self.logMax):
                for st in range(self.stMax):
                    self.m.constrain(self.block[mem][log,st] == self.layout[mem][log*self.stMax+st, :] * self.preprocess.layout[mem][log])
                    self.m.constrain(self.word[mem][log,st] == self.layout[mem][log*self.stMax+st,:] * self.preprocess.word[mem][log])
            pass
        # exit(1)
        self.dictNumConstraints['allMem*log*st'] += 2
    
    # block
    def useMemoryConstraint(self): # double checked
        """ assign blocks of logical table to mem only if it's allowed
        e.g., a ternary table can't use SRAM blocks. Preprocessor
        computes what's allowed (self.preprocess.use)"""
        # print(self.blockMax) # 104
        # exit(1)
        upperBound = self.blockMax * self.stMax
        for mem in self.switch.memoryTypes:
            for log in range(self.logMax):
                # print(mem, log, self.preprocess.use[mem][log]) # basically zero or one
                blocksUsedForLog = (self.block[mem][log,:] * np.ones((self.stMax)))[0,0]
                blocksAllowedForLog = (upperBound * self.preprocess.use[mem][log])
                self.m.constrain(blocksUsedForLog <= blocksAllowedForLog)
        # exit(1)
        self.dictNumConstraints['mem*log'] += 1
    
    # word
    def assignmentConstraint(self): # double checked
        """ All match entries must be assigned somewhere in the pipeline.
        """
        # print(self.program.logicalTables) # num entries
        # exit(1)
        allocatedWords = sum([self.word[mem] for mem in self.switch.memoryTypes]) * np.ones(self.stMax)

        self.m.constrain(allocatedWords >= self.program.logicalTables)

        self.dictNumConstraints['log'] += 1


    # startTimeOfStage
    # startAllMem
    # startAllMemTimesStartTimeOfStage
    def getStartAllMemTimesStartTimeOfStage(self): # double check
        """ Defining product variable StartAllMem x StartTimeOfStage """
        # upper bound of start time of stage 
        upperBound = self.stMax * self.switch.matchDelay * self.stMax
        
        for log in range(self.logMax):
            for st in range(self.stMax):
                self.m.constrain(self.startAllMemTimesStartTimeOfStage[log, st] <= self.startAllMem[log,st] * upperBound)
                self.m.constrain(self.startAllMemTimesStartTimeOfStage[log, st] <= self.startTimeOfStage[st] + (1 - self.startAllMem[log,st]) * upperBound)
                self.m.constrain(self.startAllMemTimesStartTimeOfStage[log, st] >= self.startTimeOfStage[st] - (1 - self.startAllMem[log,st]) * upperBound)

        self.dictNumConstraints['log*st'] += 3

    # startTimeOfStage
    # endAllMem
    # endAllMemTimesStartTimeOfStage
    def getEndAllMemTimesStartTimeOfStage(self): # double check
        """ Defining product variable endAllMem x StartTimeOfStage """

        # Get startTimeOfStageTimesStartAllMem
        # upper bound of start time of stage 
        upperBound = self.stMax * self.switch.matchDelay * self.stMax
        
        for log in range(self.logMax):
            for st in range(self.stMax):
                self.m.constrain(self.endAllMemTimesStartTimeOfStage[log, st] <= self.endAllMem[log,st] * upperBound)
                self.m.constrain(self.endAllMemTimesStartTimeOfStage[log, st] <= self.startTimeOfStage[st] + (1 - self.endAllMem[log,st]) * upperBound)                
                self.m.constrain(self.endAllMemTimesStartTimeOfStage[log, st] >= self.startTimeOfStage[st] - (1 - self.endAllMem[log,st]) * upperBound)

        self.dictNumConstraints['log*st'] += 3

    # startTimeOfStage
    # startAllMemTimesStartTimeOfStage
    # endAllMemTimesStartTimeOfStage
    def pipelineLatencyConstraint(self): # double check
        self.startTimeOfStartStageOfLog = {}
        self.startTimeOfEndStageOfLog = {}
        for log in range(self.logMax):
            self.startTimeOfStartStageOfLog[log] = sum([self.startAllMemTimesStartTimeOfStage[log, st] for st in range(self.stMax)])
            self.startTimeOfEndStageOfLog[log] = sum([self.endAllMemTimesStartTimeOfStage[log, st] for st in range(self.stMax)])
        
        # successor dependency
        for st in range(1,self.stMax):
            self.m.constrain(self.startTimeOfStage[st] >= self.startTimeOfStage[st-1] + self.switch.successorDelay)
        self.dictNumConstraints['st'] += 1
        self.dictNumConstraints['constant'] -= 1
        
        # match dependency
        for (log1,log2) in self.program.logicalMatchDependencyList:
            self.m.constrain(self.startTimeOfStartStageOfLog[log2] >= self.startTimeOfEndStageOfLog[log1] + self.switch.matchDelay)
        self.dictNumConstraints['matchDep'] += 1

        # action dependency
        for (log1,log2) in self.program.logicalActionDependencyList:
            self.m.constrain(self.startTimeOfStartStageOfLog[log2] >= self.startTimeOfEndStageOfLog[log1] + self.switch.actionDelay)
        
        self.dictNumConstraints['actionDep'] += 1

    # startAllMem
    # endAllMem
    # blockAllMemBin
    # endAllMemTimesBlockAllMemBin
    # startAllMemTimesBlockAllMemBin
    def getStartingAndEndingStages(self): # must look into this
        for log in range(self.logMax):
            # there is exactly one starting stage
            self.m.constrain(sum([self.startAllMem[log,st] for st in range(self.stMax)]) == 1)
            
            startStage = sum([self.startAllMem[log,st] * st for st in range(self.stMax)])

            upperBound = self.stMax
            # if a stage has blocks, starting stage is at least as small
            for st in range(self.stMax):
                self.m.constrain(startStage <= st + (1 - self.blockAllMemBin[log,st]) * upperBound)

            # starting stage has some blocks
            anyBlocksInStartStage = sum([self.startAllMemTimesBlockAllMemBin[log,st] for st in range(self.stMax)])
            self.m.constrain(anyBlocksInStartStage >= 1)

        for log in range(self.logMax):
            # there is exactly one ending stage
            self.m.constrain(sum([self.endAllMem[log,st] for st in range(self.stMax)]) == 1)
            
            endStage = sum([self.endAllMem[log,st] * st for st in range(self.stMax)])

            upperBound = self.stMax
            # if a stage has blocks, ending stage is at least as big
            for st in range(self.stMax):
                self.m.constrain(endStage >= st - (1 - self.blockAllMemBin[log,st]) * upperBound)

            # ending stage has some blocks
            anyBlocksInEndStage = sum([self.endAllMemTimesBlockAllMemBin[log,st] for st in range(self.stMax)])
            self.m.constrain(anyBlocksInEndStage >= 1)

        # # hun_log
        if hun_start_end_same == True:
            for log in range(self.logMax):
                for st in range(self.stMax):
                    self.m.constrain(self.startAllMem[log,st] == self.endAllMem[log,st])
        #     name = self.program.names[log]
        #     if "condition" in name:

        self.dictNumConstraints['log'] += 2*2
        self.dictNumConstraints['log*st'] += 2

    # startAllMem
    # endAllMem
    def dependencyConstraint(self): # double checked
        """
        If log2 action depends on log1, then last stage (any mem)
        of log1 is strictly before first stage (any mem) of log2.
        """
        eps = 0.01
        upperBound = self.stMax
        allStages = np.matrix(self.preprocess.toposortOrderStages).T

        for (log1,log2) in self.program.logicalSuccessorDependencyList:
            # print("sucessor", self.program.names[log1], self.program.names[log2])
            start2 = self.startAllMem[log2, :] * allStages
            end1 = self.endAllMem[log1,:] * allStages
            self.m.constrain(start2 >= end1)
        self.dictNumConstraints['succDep'] += 1

        for (log1,log2) in self.program.logicalMatchDependencyList:
            # print("match", self.program.names[log1], self.program.names[log2])
            start2 = self.startAllMem[log2, :] * allStages
            end1 = self.endAllMem[log1,:] * allStages
            self.m.constrain(start2 >= eps + end1)
        self.dictNumConstraints['matchDep'] += 1

        for (log1,log2) in self.program.logicalActionDependencyList:
            # print("action", self.program.names[log1], self.program.names[log2])
            start2 = self.startAllMem[log2, :] * allStages
            end1 = self.endAllMem[log1,:] * allStages
            self.m.constrain(start2 >= eps + end1)
        self.dictNumConstraints['actionDep'] += 1
        # exit(1)
    
    # totalBlocksForStBin
    # isMaximumStage
    # isMaximumStageTimesTotalBlocksForStBin
    def maximumStageConstraint(self): # hun_log
        # minimize maximum stage
        upperBound = self.blockMax
        lowerBound = 1

        # Binary constraint
        for st in range(self.stMax):
            # totalBlocksForStBin doesn't count action RAMs
            # print(self.switch.memoryTypes) # ['sram', 'tcam']

            total = sum([self.endAllMem[log, st] for log in range(self.logMax)])

            self.m.constrain(total <= upperBound * self.totalBlocksForStBin[st])
            self.m.constrain(total >= lowerBound * self.totalBlocksForStBin[st])


        upperBound = self.stMax
        maximumStage = sum([self.isMaximumStage[st]*st for st in range(self.stMax)])
        # If a stage st has blocks, maximumStage at least as big as st
        for st in range(self.stMax):
            self.m.constrain(self.totalBlocksForStBin[st] * st <= maximumStage)

        # Exactly one stage can be maximum stage
        numMaxStages = sum([self.isMaximumStage[st] for st in range(self.stMax)])
        self.m.constrain(numMaxStages == 1)

        # Product constraint
        for st in range(self.stMax):
            self.m.constrain(self.isMaximumStageTimesTotalBlocksForStBin[st] <= self.totalBlocksForStBin[st])
            self.m.constrain(self.isMaximumStageTimesTotalBlocksForStBin[st] <= self.isMaximumStage[st])
            self.m.constrain(self.isMaximumStageTimesTotalBlocksForStBin[st] >= self.totalBlocksForStBin[st]+ self.isMaximumStage[st]-1)

        # Maximum stage has one or more blocks
        sumOverSt = sum([self.isMaximumStageTimesTotalBlocksForStBin[st] for st in range(self.stMax)])
        self.m.constrain(sumOverSt > 0)

        self.dictNumConstraints['st'] += 6 
        # 2 for bin, 1 for "at least as big", 3 for prod
        self.dictNumConstraints['constant'] += 2
        # 1 for numMaxStages, 1 for max stage has non zero blocks


    # block
    # blockBin
    def getBlockBinary(self): # double checked
        lowerBound = 1
        for mem in self.switch.memoryTypes:
            upperBound = sum(self.switch.numBlocks[mem])
            for log in range(self.logMax):
                for st in range(self.stMax):
                    self.m.constrain(self.blockBin[mem][log,st]*lowerBound <= self.block[mem][log,st])
                    self.m.constrain(self.blockBin[mem][log,st]*upperBound >= self.block[mem][log,st])

        self.dictNumConstraints['mem*log*st'] += 2

    # layout
    # layoutBin
    def getLayoutBinary(self): # double checked
        lowerBound = 1
        for thing in self.switch.allTypes:
            upperBound = self.blockMax 
            for log in range(self.logMax):
                for st in range(self.stMax):
                    for pf in range(self.pfMax[thing]):
                        index = log*self.stMax + st
                        self.m.constrain(self.layoutBin[thing][index, pf]*lowerBound <= self.layout[thing][index, pf])
                        self.m.constrain(self.layoutBin[thing][index, pf]*upperBound >= self.layout[thing][index, pf])
        self.dictNumConstraints['allMem*pf*log*st'] += 1


    # blockBin
    def inputCrossbarConstraint(self): # double checked
        numSubunitsNeeded = {}
        numSubunitsAvailable = {}
        for mem in self.switch.memoryTypes:
            # print(mem)
            # print(self.preprocess.inputCrossbarNumSubunits[mem]) # [4, 4, 4, ...]
            # print(self.switch.inputCrossbarNumSubunits[mem]) # 128 or 66
            numSubunitsNeeded[mem] = self.blockBin[mem].T * self.preprocess.inputCrossbarNumSubunits[mem]
            numSubunitsAvailable[mem] = self.switch.inputCrossbarNumSubunits[mem] * np.ones((self.stMax,1))
            self.m.constrain(numSubunitsNeeded[mem] <= numSubunitsAvailable[mem])
        # exit(1)
        self.dictNumConstraints['mem*st'] += 1

    # block
    # blockAllMemBin
    def getBlockAllMemBinary(self):
        # print(self.all) # ['sram', 'tcam']
        # print(self.switch.memoryTypes) # ['sram', 'tcam']
        lowerBound = 1
        upperBound = sum([self.switch.numBlocks[mem] for mem in self.switch.memoryTypes])
        # print(self.switch.numBlocks) 'sram': [80, 80, ...], 'tcam': [24, 24, ...], 
        # print(upperBound) # [104, 104, 104, ...]
        # exit(1)
        if hun_add_logical_table_ids == True:
            for log in range(self.logMax):
                for st in range(self.stMax):
                    total = sum([self.block[mem][log,st] for mem in self.all])
                    self.m.constrain(total <= self.logicalTableIDs[log, st] * upperBound[st])

        for log in range(self.logMax):
            for st in range(self.stMax):
                # blockAllMemBin doesn't count action RAMs
                total = sum([self.block[mem][log,st] for mem in self.all])

                if hun_add_logical_table_ids == True:
                    total += self.logicalTableIDs[log, st]

                self.m.constrain(total <= upperBound[st] * self.blockAllMemBin[log,st])
                self.m.constrain(total >= lowerBound * self.blockAllMemBin[log,st])

        self.dictNumConstraints['log*st'] += 2

    # blockAllMemBin
    def resolutionLogicConstraint(self): # double checked
        """ Limits number of match tables per stage. Since table match resolution logic
        can only handle a finite number
        """
        # print("self.switch.resolutionLogicNumMatchTables")
        # print(self.switch.resolutionLogicNumMatchTables)
        # exit(1)
        

        if hun_correct_table_ids == False:
            numMatchTablesUsed = self.blockAllMemBin.T * np.ones((self.logMax,1))
            numMatchTablesAvailable = self.switch.resolutionLogicNumMatchTables * np.ones((self.stMax,1))
            self.m.constrain(numMatchTablesUsed <= numMatchTablesAvailable)
            self.dictNumConstraints['st'] += 1
        else:
            for st in range(self.stMax):
                cond_log_table_ids = 0
                normal_log_table_ids = 0
                for log in range(self.logMax):
                    name = self.program.names[log]
                    if "condition" in name:
                        cond_log_table_ids += self.logicalTableIDs[log, st]
                    else:
                        normal_log_table_ids += self.logicalTableIDs[log, st]
                
                # if not isinstance(cond_log_table_ids, int):
                #     self.m.constrain(cond_log_table_ids <= 1000000)
                # if not isinstance(normal_log_table_ids, int):
                #     self.m.constrain(normal_log_table_ids <= 1000000)

    # blockAllMemBin
    def actionCrossbarConstraint(self): # double checked
        """
        No more than 1280 bits of action from each stage.
        """
        # print("self.switch.actionCrossbarNumBits")
        # print(self.switch.actionCrossbarNumBits) # 1024
        # print("self.preprocess.actionCrossbarNumBits")
        # print(self.preprocess.actionCrossbarNumBits) # 0 0 0 0 0 0 0 0
        # exit(1)
        numTotalBitsAvailable = self.switch.actionCrossbarNumBits * np.ones((self.stMax,1))
        numTotalBitsNeeded = self.blockAllMemBin.T * self.preprocess.actionCrossbarNumBits
        self.m.constrain(numTotalBitsNeeded <= numTotalBitsAvailable)
        self.dictNumConstraints['st'] += 1

    # layoutBin
    def onePackingUnitForLogInStage(self): # double checked
        """ Restrict logical tables to use same packing unit in a stage
        instead of combinations of different size packing units in the
        same stage. Packing units in different stages can be different though.
        """
        for st in range(self.stMax):
            for log in range(self.logMax):
                index = log*self.stMax+st
                numPUnitTypesForLogInSt = sum([ self.layoutBin['sram'][index, pf] for pf in range(self.pfMax['sram'])])
                self.m.constrain(numPUnitTypesForLogInSt <= 1)
        self.dictNumConstraints['log*st'] += 1


    # blockAllMemBin
    # startAllMemTimesBlockAllMemBin
    # startAllMem
    # endAllMemTimesBlockAllMemBin
    # endAllMem
    def getXxAllMemTimesBlockAllMemBin(self): # double checked
        for log in range(self.logMax):
            for st in range(self.stMax):
                self.m.constrain(self.startAllMemTimesBlockAllMemBin[log, st] <= self.startAllMem[log, st])
                self.m.constrain(self.startAllMemTimesBlockAllMemBin[log, st] <= self.blockAllMemBin[log, st])
                self.m.constrain(self.startAllMemTimesBlockAllMemBin[log, st] >= self.startAllMem[log, st] + self.blockAllMemBin[log, st] - 1)

        for log in range(self.logMax):
            for st in range(self.stMax):
                self.m.constrain(self.endAllMemTimesBlockAllMemBin[log, st] <= self.endAllMem[log, st])
                self.m.constrain(self.endAllMemTimesBlockAllMemBin[log, st] <= self.blockAllMemBin[log, st])
                self.m.constrain(self.endAllMemTimesBlockAllMemBin[log, st] >= self.endAllMem[log, st] + self.blockAllMemBin[log, st] - 1)

        self.dictNumConstraints['log*st'] += 6

    # hun_log
    def hunAdditionalConstraints(self):
        # capacity constraint
        self.m.constrain(self.hashDistUnitVar.T * np.ones(self.logMax) <= self.switch.maxHashDistUnit * np.ones(self.stMax))
        self.m.constrain(self.saluVar.T * np.ones(self.logMax) <= self.switch.maxSALU * np.ones(self.stMax))
        self.m.constrain(self.saluVar.T * self.program.registerBlockList <= self.switch.maxMapRAM * np.ones(self.stMax))

        # assignment constraint
        allocatedHashes = self.hashDistUnitVar * np.ones(self.stMax)
        self.m.constrain(allocatedHashes == self.program.hashDistUnitList)

        allocatedSALUs = self.saluVar * np.ones(self.stMax)
        self.m.constrain(allocatedSALUs == self.program.saluList)

        # hashDistUnit and SALU must be in the start stage
        for log in range(self.logMax):
            for st in range(self.stMax):
                self.m.constrain(self.hashDistUnitVar[log,st] <= self.startAllMem[log,st])
                self.m.constrain(self.saluVar[log,st] <= self.startAllMem[log,st])

    """ Variables """

    def pipelineLatencyVariables(self):
        """ Variables for start and end time of stages"""
        ub = self.stMax * self.switch.matchDelay
        ubb = self.stMax * self.switch.matchDelay * self.stMax
        self.startTimeOfStage = self.m.new((self.stMax), vtype='real', lb=0, ub=ub, name='startTimeOfStage')
        self.dictNumVariables['st'] += 1

        self.startAllMemTimesStartTimeOfStage = self.m.new((self.logMax, self.stMax), vtype='real', lb=0, ub = ubb, name='startAllMemTimesStartTimeOfStage')
        self.endAllMemTimesStartTimeOfStage = self.m.new((self.logMax, self.stMax), vtype='real', lb=0, ub = ubb, name='endAllMemTimesStartTimeOfStage')
        self.dictNumVariables['log*st'] += 2


    def startAndEndStagesVariables(self):
        logMax = self.logMax
        stMax = self.stMax

        self.startAllMem = self.m.new((logMax, stMax), vtype=bool, name='startAllMem')
        self.dictNumVariables['log*st'] += 1

        self.startAllMemTimesBlockAllMemBin =  self.m.new((logMax, stMax), vtype=bool, name='startAllMemTimesBlockAllMemBin')                   
        self.dictNumVariables['log*st'] += 1

        self.endAllMem = self.m.new((logMax, stMax), vtype=bool, name='endAllMem')
        self.dictNumVariables['log*st'] += 1

        self.endAllMemTimesBlockAllMemBin =  self.m.new((logMax, stMax), vtype=bool, name='endAllMemTimesBlockAllMemBin')                   
        self.dictNumVariables['log*st'] += 1


    def solve(self, program, switch, preprocess, output_path, objective):
        """ Returns a configuration for program in switch, given some preprocessed information,
        like possible packing units for different logical tables.
        """
        solveStart = time.time()
        self.program = program
        self.switch = switch
        self.preprocess = preprocess
        # doesn't count action RAM in allMem,
        # so start/ end/ max stage, latency etc.
        # based only on match RAMs
        self.all = self.switch.memoryTypes
        self.logger.debug("Types counted in start/end/max stage, latency: %s" %\
                          self.all)
        ####################################################
        # Constants
        ####################################################
        pfMax = {}
        for mem in self.switch.allTypes:
            pfMax[mem] = preprocess.layout[mem].shape[1]
            pass

        stMax = switch.numStages
        logMax = program.MaximumLogicalTables

        # upper bound on blocks for a table in a stage
        blockMax = int(sum([np.matrix(switch.numBlocks[mem]).T\
                                for mem in switch.memoryTypes])[0,0])

        # upper bound on logical words for a table in a stage
        mem = 'sram'
        wordMax = int(switch.depth[mem] * switch.width[mem]\
                          * blockMax)
        


        self.pfMax = pfMax
        self.stMax = stMax
        self.logMax = logMax
        self.blockMax = blockMax
        self.wordMax = wordMax


        ####################################################
        # Variables
        ####################################################
        self.results = {}
        self.results['relativeGap'] = self.relativeGap
        self.results['greedyVersion'] = self.greedyVersion
        self.results['stMax'] = switch.numStages
        
        self.m = CPlexModel(verbosity=3)

        # Per memory per logical table per stage variables
        # 4 * memoryTypes * logMax * stMax

        self.word = {}
        self.block = {}
        self.blockBin = {}
        self.layout = {}
        self.layoutBin = {}

        # Used stage variable memoryTypes * stMax


        for thing in self.switch.allTypes:
            self.word[thing] = self.m.new((logMax, stMax), vtype='real', lb=0, ub=wordMax, name='word'+thing)
            self.block[thing] = self.m.new((logMax, stMax), vtype='real', lb=0, ub=blockMax, name='block'+thing)

            self.layout[thing] = self.m.new((logMax * stMax, pfMax[thing]), vtype=int, lb=0, ub=blockMax, name='layout'+thing)

            self.blockBin[thing] = self.m.new((logMax, stMax), vtype=bool, name='blockBin'+thing)
            self.layoutBin[thing] = self.m.new((logMax * stMax, pfMax[thing]), vtype=bool, name='layoutBin'+thing)

        self.dictNumVariables['allMem*log*st'] += 3
        self.dictNumVariables['allMem*pf*log*st'] += 2

        # Total Blocks per stage logMax * stMax * 2
        self.blockAllMemBin = self.m.new((logMax, stMax), vtype=bool, name='blockAllMemBin')
        self.dictNumVariables['log*st'] += 1
        
        # Maximum stage variables stMax * 2
        self.isMaximumStage = self.m.new(stMax, vtype=int, lb=0, ub=1, name='isMaximumStage')
        self.totalBlocksForStBin = self.m.new(stMax, vtype=int, lb=0, ub=1, name='totalBlocksForStBin')
        self.isMaximumStageTimesTotalBlocksForStBin = self.m.new(stMax, vtype=int, lb=0, ub=1, name='isMaximumStageTimesTotalBlocksForStBin')

        self.dictNumVariables['st'] += 3

        # Starting and ending stage variables logMax * stMax * 3 * 2
        self.logger.info("Setting up variables for start and end stages");
        self.startAndEndStagesVariables()

        # hun_log
        if hun_extended == True:
            self.hashDistUnitVar = self.m.new((logMax, stMax), vtype=int, lb=0, ub=1, name='hashDistUnit')
            self.saluVar = self.m.new((logMax, stMax), vtype=int, lb=0, ub=1, name='salu')
            self.logicalTableIDs = self.m.new((logMax, stMax), vtype=int, lb=0, ub=1, name='logicalTableIDs')


        self.getXxAllMemTimesBlockAllMemBin()

        self.logger.info("Setting up constraints to get pipeline latency");
        self.pipelineLatencyVariables()
        
        # BASIC CONSTRAINTS
        # Sets block and word variables
        # Blocks and Words for logical table/ stage are consistent with
        # chosen layouts
        self.logger.info("Setting up constraints to relate number of packing units per table to blocks and words per table");
        self.wordLayoutConstraint()

        # Blocks assigned to match, action etc. in each  stage/ memory don't
        # exceed capacity
        if 'capacity' != self.ignoreConstraint:
            self.logger.info("Setting up capacity constraints for blocks used per stage.")
            self.capacityConstraint()
            pass
        # Use memory type only where allowed
        if 'useMemory' != self.ignoreConstraint:
            self.useMemoryConstraint()
            pass

        # Assign enough match words for each table
        if 'assignment' != self.ignoreConstraint:
            self.logger.info("Setting up constraints to enforce tables are assigned to valid memory types (e.g., lpm to TCAM but not SRAM)");

            self.assignmentConstraint()
            pass
        # Get starting and ending stages for logical tables over all memory
        # types
        self.logger.info("Setting up constraints for start and end stages");
        self.getStartingAndEndingStages()

        # Match, Action, Successor dependency constraint on starting and 
        # ending stages for each logical table
        if 'dependency' != self.ignoreConstraint:
            self.logger.info("Setting up dependency constaint on starting and ending stages for each logical table");

            self.dependencyConstraint()
            pass
        # RMT SPECIFIC CONSTRAINTS

        # At least as many action words as match words for a logical table
        # in each stage
        if 'action' != self.ignoreConstraint:
            self.logger.info("Setting up constraint to ensure there is at least one action data word for every match entry assigned for a logical table.")
            self.actionAssignmentConstraint()
            pass
        
        self.getBlockBinary()
        # No more than XX subunits used from input crossbar at each stage
        if 'inputCrossbar' != self.ignoreConstraint:
            self.logger.info("Setting up resource constraint for number of input crossbar subunits used per stage")
            self.inputCrossbarConstraint()
            pass
        
        self.getBlockAllMemBinary()
        # No more than XX tables matched in each stage
        if 'resolutionLogic' != self.ignoreConstraint:
            self.logger.info("Setting up constraint to enforce no more than xx logical tables per stage")
            self.resolutionLogicConstraint()

        # No more than XX bits used from action crossbar at each stage
        if 'actionCrossbar' != self.ignoreConstraint:
            self.logger.info("Setting up resource constraint for number of bits of action data crossbar used per stage for each memory")
            self.actionCrossbarConstraint()

        self.getStartAllMemTimesStartTimeOfStage()
        self.getEndAllMemTimesStartTimeOfStage()
        if self.ignoreConstraint != 'pipelineLatency' and self.objectiveStr not in ['maximumStage', 'powerForRamsAndTcams']:
            self.logger.info("Setting up pipeline latency constraint")
            self.pipelineLatencyConstraint()
        else:
            print 'pipelineLatency constraint ignored since we are not optimizing for pipeline latency!!'

        self.logger.info("Setting up constraint to get an upper bound on maximum stage, which can minimize in objective if needed")
        self.maximumStageConstraint()

        # hun_log
        if hun_extended == True:
            self.hunAdditionalConstraints()

        self.startingDict = {}

        configs = {}

        pipelineLatency = self.startTimeOfStage[self.stMax-1]
        totalMemBlocks = sum([self.block[mem].T for mem in self.switch.allTypes])
        totalBlocks = (totalMemBlocks * np.ones(self.logMax)).T * np.ones(self.stMax)
        self.logger.debug("Shape of totalMemBlocks %s" % str(totalMemBlocks.shape))
        self.logger.debug("Shape of np.ones(self.logMax) %s" % str(np.ones(self.logMax).shape))
        self.logger.debug("Shape of np.ones(self.stMax) %s" % str(np.ones(self.stMax).shape))

        maximumLatency = self.switch.matchDelay * self.switch.numStages
        maximumStage = sum([self.isMaximumStage[st]*st for st in range(self.stMax)])

        self.getLayoutBinary()

        self.logger.info("Setting up constraint to ensure only one kind of packing unit is used for"\
        + " a logical table in a stage, though it may use a different kind in another stage.")
        self.onePackingUnitForLogInStage()

        self.logger.info("Setting up constraint and variables to get power used for RAMs and TCAMs")
        
        self.getPowerForRamsAndTcamsObjective()
        powerForRamsAndTcams = self.powerForRamsAndTcams
        if self.objectiveStr == 'totalBlocks':
            self.logger.info("Total blocks objective includes action RAMs, though stage/ latency vars don't")
            pass
        totalBlocksAvailable = sum(sum(([self.switch.numBlocks[mem] for mem in self.switch.memoryTypes])))
        objectives = {'pipelineLatency+totalBlocks':pipelineLatency/maximumLatency + totalBlocks/totalBlocksAvailable,\
                          'pipelineLatency':pipelineLatency,\
                          'totalBlocks':totalBlocks,\
                          'maximumStage':maximumStage,\
                          'powerForRamsAndTcams':powerForRamsAndTcams}

        solverTimes = []
        nIterations = []

        # For logging only
        self.setDimensionSizes()
        self.logger.debug("Computing variables:")
        self.numVariables = self.computeSum(self.dictNumVariables)
        self.logger.debug("Computing Constraints:")
        self.numConstraints = self.computeSum(self.dictNumConstraints)
        self.logger.debug("numRows: %d" % self.m.getNRows())
        self.logger.debug("numCols: %d" % self.m.getNCols())

        # FIND WHAT THE MINIMUM VALUE FOR OBJECTIVE STR IS
        try:
            self.m.minimize(objectives[self.objectiveStr], starting_dict=self.startingDict,\
                                relative_gap=self.relativeGap,\
                                emphasis=self.emphasis,\
                                time_limit=self.timeLimit,\
                                tree_limit=self.treeLimit,\
                                variable_select=self.variableSelect)
            pass
        except Exception, e:
            self.logger.exception(e)
            pass

        if (self.m.solved()):
            self.logger.info("Checking ILP solution")
            if (self.checkConstraints(self.m)):
                self.logger.info("Solution looks good.")
                pass
            pass

            from hun_output import printOutConstraints
            printOutConstraints(self, output_path)
        

        solverTimes.append(self.m.getSolverTime())
        nIterations.append(self.m.getNIterations())
        """
        # MINIMIZE NUMBER OF BLOCKS SUBJECT TO VALUE OF OBJECTIVE STR <= ABOVE
        # OTHERWISE ONLY UPPER BOUND ON NUMBER OF BLOCKS IS FROM CAPACITY CONSTRAINT
        objectiveValue = self.m[objectives[self.objectiveStr]]
        self.m.constrain(objectives[self.objectiveStr] <= objectiveValue)
        self.logger.info("%s <= %.2f" % (self.objectiveStr, objectiveValue))
        
        self.m.minimize(totalBlocks, starting_dict=self.startingDict,\
                            relative_gap=self.relativeGap)
        solverTimes.append(self.m.getSolverTime())
        nIterations.append(self.m.getNIterations())

        
        # MINIMIZE PIPELINE LATENCY SUBJECT TO VALUE OF TOTAL BLOCKS <= ABOVE
        # OTHERWISE NO UPPER BOUND ON START TIME OF LAST STAGE, ONLY LOWER BOUND
        minTotalMemBlocks = sum([self.m[self.block[mem]].T for mem in self.switch.allTypes])
        minTotalBlocks = int(round(sum([minTotalMemBlocks[st,log] for log in range(self.logMax)\
                                  for st in range(self.stMax)])))
        self.logger.info("Total blocks <= %.1f" % minTotalBlocks)
        
        self.m.constrain(totalBlocks <= minTotalBlocks)
        self.m.minimize(pipelineLatency, starting_dict=self.startingDict,\
                            relative_gap=0.9)
        solverTimes.append(self.m.getSolverTime())
        nIterations.append(self.m.getNIterations())
        """
        
        ####################################################
        self.logger.debug("Saving results from ILP")
        self.setIlpResults(solverTimes=solverTimes, nIterations=nIterations)
        ####################################################
        # Logging
        ####################################################                
        if (self.m.solved()):
            m = self.m
            layout = {}
            for thing in self.switch.allTypes:
                layout[thing] = m[self.layout[thing]]
                pass
            config = RmtConfiguration(program=self.program, switch=self.switch, preprocess=self.preprocess,\
                                      layout=layout, version="ILP")
            configs['ilp-%s' % self.objectiveStr] = config
            self.results['ilpTotalUnassignedWordsFromConfig'] = config.totalUnassignedWords
            self.results['ilpPipelineLatencyFromConfig'] = config.getPipelineLatency()
            self.results['ilpPowerFromConfig'] = config.getPowerForRamsAndTcams()
            pass
        solveEnd = time.time()
        self.results['solveTime'] = solveEnd - solveStart

        ####################################################
        #self.logger.debug("Displaying ILP solution")
        #config.display()
        ####################################################
        return configs

    def setIlpResults(self, solverTimes, nIterations):

        self.results['ilpTime'] = sum(solverTimes) 
        self.results['ilpNumIterations'] = sum(nIterations) 
        self.results['ilpTimeList'] = ("%s" % solverTimes).replace(",",";")
        self.results['ilpNumIterationsList'] = ("%s" % nIterations).replace(",",";")
        self.results['ilpNumRowsInModel'] = self.m.getNRows()
        self.results['ilpNumColsInModel'] = self.m.getNCols()
        self.results['ilpNumQCsInModel'] = self.m.getNQCs()
        # If you're doing multiple m.minimize, stores last value, unlike NumIterations/ Time list above
        self.results["ilpSolverTime"] = self.m.getSolverTime()
        self.results["ilpNIterations"] = self.m.getNIterations()
        self.results["ilpBestObjValue"] = self.m.getBestObjValue()
        self.results["ilpCutoff"] = self.m.getCutoff()
        self.results["ilpMIPRelativeGap"] = self.m.getMIPRelativeGap()
        self.results["ilpNnodes"] = self.m.getNnodes()
        self.results['ilpNumVariables'] = self.numVariables
        self.results['ilpNumConstraints'] = self.numConstraints
        self.results['ilpSolved'] = self.m.solved()
        if self.m.solved():
            totalMemBlocks = sum([self.m[self.block[mem]].T for mem in self.switch.allTypes])
            totalBlocks = int(round(sum([totalMemBlocks[st,log] for log in range(self.logMax)\
                                         for st in range(self.stMax)])))
            self.results['ilpTotalBlocks'] = totalBlocks
            self.results['ilpNumActiveSrams'] = float(self.m[self.numActiveSrams])
            self.results['ilpNumActiveTcams'] = float(self.m[self.numActiveTcams])
            self.results['ilpPower'] = float(self.m[self.powerForRamsAndTcams])
            self.results['ilpPipelineLatency'] = self.m[self.startTimeOfStage][self.stMax-1]

            totalBlocks = np.zeros((self.stMax))
            for st in range(self.stMax):
                totalBlocks[st] = sum([self.m[self.block[mem]][log,st]\
                                    for log in range(self.logMax)\
                                    for mem in self.all])
            pass
            # self.results['ilpNumStages'] = max([st for st in range(self.stMax) if totalBlocks[st] > 0])+1
            pass
        pass
    

    def checkConstraints(self,model):
        """ Given a complete model with all variables filled in,
        checks against (some of) the inequality constraints that define the ILP
        and warns if anything's violated. Used to check greedy solutions,
        and other starting solutions.
        """
        correct = True
        if self.ignoreConstraint != 'pipelineLatency' and \
                self.objectiveStr not in ['maximumStage', 'powerForRamsAndTcams']:
            correct = correct and self.checkPipelineLatencyConstraint(model)
            # since we don't setup pipeline latency constraint unless we're optimizing
            #  pipeline latency (otherwise it adds unnecessary complexity/ run time)
            pass
        
        for mem in self.switch.memoryTypes:
            correct = correct and self.checkInputCrossbarConstraint(model, mem)
            pass
        correct = correct and self.checkStartingAndEndingStagesConstraint(model)
        
        # For logging only
        #self.displayStartingAndEndingStages(model)
        #self.displayActiveRams(model)
        #self.displayMaximumStage(model)
        return correct

    def checkPipelineLatencyConstraint(self, model):
        correct = True
        startAllMemTimesStartTimeOfStage = model[self.startAllMemTimesStartTimeOfStage]
        endAllMemTimesStartTimeOfStage = model[self.endAllMemTimesStartTimeOfStage]
        startTimeOfStage = model[self.startTimeOfStage]

        layout = {}
        layout['sram'] = model[self.layout['sram']]
        layout['tcam'] = model[self.layout['tcam']]
        layout['action'] = model[self.layout['action']]

        stageInfo = "\nStart time for model\n"
        for st in range(self.stMax):
             stageInfo += " Stage %d: %.1f " % (st, startTimeOfStage[st])
             tablesThatStart = [log for log in range(self.logMax) if startAllMemTimesStartTimeOfStage[log, st] > 0]
             tableInfo = {}
             for log in range(self.logMax):
                 punits = {}
                 for thing in ['sram','tcam','action']:
                     punits[thing] = sum([layout[thing][log*self.stMax+st,pf] for pf in range(self.pfMax[thing])])
                 tableInfo[log] = ", ".join(["%s: %d" % (t[0], punits[t]) for t in ['sram','tcam','action']])

             stageInfo += "Tables that start in this stage: %s\n" % ", ".join(["%s: %s" % (self.program.names[log], tableInfo[log]) for log in tablesThatStart])
        
        self.logger.debug(stageInfo)

        startTimeOfStartStageOfLog = {}
        startTimeOfEndStageOfLog = {}
        for log in range(self.logMax):
            startTimeOfStartStageOfLog[log] = sum([startAllMemTimesStartTimeOfStage[log, st] for st in range(self.stMax)])
            startTimeOfEndStageOfLog[log] = sum([endAllMemTimesStartTimeOfStage[log, st] for st in range(self.stMax)])

        # successor dependency
        for st in range(1,self.stMax):
            if not (startTimeOfStage[st] >= startTimeOfStage[st-1] + self.switch.successorDelay):
                roundOkay = (round(startTimeOfStage[st]) >= round(startTimeOfStage[st-1]) + self.switch.successorDelay)
                level = logging.WARNING
                if not roundOkay:
                    level = logging.ERROR
                correct = False
                self.logger.log(level, "successor dependency constraint on latency violated at %d" % st)
        
        # match dependency
        for (log1,log2) in self.program.logicalMatchDependencyList:
            if not(startTimeOfStartStageOfLog[log2] >= startTimeOfEndStageOfLog[log1] + self.switch.matchDelay):
                roundOkay = (round(startTimeOfStartStageOfLog[log2]) >= round(startTimeOfEndStageOfLog[log1]) + self.switch.matchDelay)
                level = logging.WARNING
                if not roundOkay:
                    level = logging.ERROR
                    pass
                correct = False
                self.logger.log(level,\
                                    "match dependency (%s, %s)" % (self.program.names[log1], self.program.names[log2])\
                                    + " on latency violated:"\
                                    + " %s end stage starts at time %d." % ( self.program.names[log1], startTimeOfEndStageOfLog[log1])\
                                    + " %s start stage starts at time %d." % ( self.program.names[log2], startTimeOfStartStageOfLog[log2]))

        # action dependency
        for (log1,log2) in self.program.logicalActionDependencyList:
            if not(startTimeOfStartStageOfLog[log2] >= startTimeOfEndStageOfLog[log1] + self.switch.actionDelay):
                roundOkay = (round(startTimeOfStartStageOfLog[log2]) >= round(startTimeOfEndStageOfLog[log1]) + self.switch.actionDelay)
                level = logging.WARNING
                if not roundOkay:
                    level = logging.ERROR
                    pass
                correct = False
                self.logger.log(level,\
                                    "action dependency (%s, %s) " % (self.program.names[log1], self.program.names[log2])\
                                 + " on latency violated:"\
                                 + " %s end stage starts at time %d." % ( self.program.names[log1], startTimeOfEndStageOfLog[log1])\
                                 + " %s end start starts at time %d." % ( self.program.names[log2], startTimeOfStartStageOfLog[log2]))

                    
        return correct

    def checkStartingAndEndingStagesConstraint(self, model):
        correct = True
        blockAllMemBin = model[self.blockAllMemBin]
        endAllMem= model[self.endAllMem]
        startAllMem=model[self.startAllMem]
        startAllMemTimesBlockAllMemBin = model[self.startAllMemTimesBlockAllMemBin]
        endAllMemTimesBlockAllMemBin = model[self.endAllMemTimesBlockAllMemBin]
        for log in range(self.logMax):
            if not(sum([endAllMem[log,st] for st in range(self.stMax)]) == 1):
                roundOkay = (sum([round(endAllMem[log,st]) for st in range(self.stMax)]) == 1)
                level = logging.WARNING
                if not roundOkay:
                    level = logging.ERROR
                    pass
                correct = False
                self.logger.log(level, "Constraint violated- more/less than one end stage for " + self.program.names[log])
                pass
            if not(sum([startAllMem[log,st] for st in range(self.stMax)]) == 1):
                roundOkay = (sum([round(startAllMem[log,st]) for st in range(self.stMax)]) == 1)
                level = logging.WARNING
                if not roundOkay:
                    level = logging.ERROR
                    pass
                correct = False
                self.logger.log(level, "Constraint violated- more/less than one start stage for " + self.program.names[log])
                pass
            pass
        return correct

    def checkInputCrossbarConstraint(self, model, mem):
        correct = True
        blockBin = model[self.blockBin[mem]]
        numSubunitsNeeded = {}
        numSubunitsAvailable = {}

        for st in range(self.stMax):
            numSubunitsNeeded = sum([blockBin[log,st] * self.preprocess.inputCrossbarNumSubunits[mem][log] for log in range(self.logMax)])
            numSubunitsAvailable = self.switch.inputCrossbarNumSubunits[mem] 
            if (numSubunitsNeeded > numSubunitsAvailable):
                roundOkay = (sum([round(blockBin[log,st]) * self.preprocess.inputCrossbarNumSubunits[mem][log] for log in range(self.logMax)]) <= numSubunitsAvailable)
                level = logging.WARNING
                if not roundOkay:
                    level = logging.ERROR
                    pass
                correct = False
                self.logger.log(level, "Input Crossbar Constraint violated in st %d, mem %s" % (st,mem) +\
                             "Used " + str(numSubunitsNeeded) +", Available " + str(numSubunitsAvailable))
        return correct

    """ Show info """

    def displayActiveRams(self, model):
        """
        For each table in each stage, 
        - number of RAMs for a match packing units (enforce one type per st)
        - + number of RAMs for an action packing unit
        """
        self.logger.debug("DISPLAY ACTIVE RAMS")
        ramsForPUnits = 0
        for st in range(self.stMax):
            for log in range(self.logMax):
                name = self.program.names[log]
                # match RAM
                for pf in range(self.pfMax['sram']):
                    ramsPerPUnit = self.preprocess.layout['sram'][log][pf]
                    index = log*self.stMax+st
                    numPUnits = round(model[self.layout['sram']][index, pf])
                    present = round(model[self.layoutBin['sram']][index, pf])

                    idStr = "%d-wide match SRAM PUnit, %s in st %d (pf=%d)"%\
                        (ramsPerPUnit, name, st, pf)
                    layoutStr = "layout (%d) and layoutBin (%d)" %\
                        (numPUnits, present)

                    if numPUnits > 0 and present == 0 or\
                            numPUnits == 0 and present == 1:
                        self.logger.warn( "%s inconsistent for %s" %\
                                          (layoutStr, idStr))
                        pass
                    elif numPUnits > 0 and present > 0:
                        self.logger.debug(idStr)
                        ramsForPUnits += ramsPerPUnit
                # action RAM
                pf = 0
                ramsPerPUnit = self.preprocess.layout['action'][log][pf]
                numPUnits = round(model[self.layout['action']][index, pf])
                present = round(model[\
                    self.layoutBin['action']][log*self.stMax+st, pf])
                idStr = "%d-wide action SRAM PUnit, %s in st %d (pf=%d)"%\
                    (ramsPerPUnit, name, st, pf)
                layoutStr = "layout (%d) and layoutBin (%d)" %\
                    (numPUnits, present)
                if numPUnits > 0 and present == 0 or\
                        numPUnits == 0 and present == 1:
                    self.logger.warn( "%s inconsistent for %s" %\
                                      (layoutStr, idStr))
                elif numPUnits > 0 and present > 0:
                    self.logger.debug(idStr)
                    ramsForPUnits += ramsPerPUnit
            self.logger.debug("%d active RAMs over all stages" % ramsForPUnits)

    def displayStartingAndEndingStages(self, model):
        numStartingStages = {}
        startStage = {}
        anyBlocksInStartStage = {}
        for log in range(self.logMax):
            # there is exactly one starting stage
            numStartingStages[log] = sum([model[self.startAllMem][log,st] for st in range(self.stMax)])
            self.logger.debug(self.program.names[log])
            self.logger.debug(" numStartingStages: " + str(numStartingStages[log]))
            
            startStage[log] = sum([model[self.startAllMem][log,st] * st for st in range(self.stMax)])
            self.logger.debug(" startStage: " + str(startStage[log]))
            
            upperBound = self.stMax
            # if a stage has blocks, starting stage is at least as small
            for st in range(self.stMax):
                totalBlocks =\
                  sum([model[self.block[mem]][log,st] for mem in self.switch.memoryTypes])

                if (startStage[log] > st and totalBlocks > 0):
                    binary = model[self.blockAllMemBin][log,st]
                    roundOkay = not (round(startStage[log]) > st and round(totalBlocks) > 0)
                    level = logging.WARNING
                    if not roundOkay:
                        level = logging.ERROR
                        pass

                    self.logger.log(level, "startStage def. constraint violated for log %s, st %d: " % (self.program.names[log], st)\
                                     + " Stage %d has %d mem. blocks in bin. %d ." % (st, totalBlocks, binary)\
                                     + " Lhs (start stage) = %d." % startStage[log]\
                                     + " Rhs = %d + (1-%d)*%d." % (st, int(model[self.blockAllMemBin][log,st]), upperBound)\
                                     + " Lhs <= Rhs?")
            # starting stage has some blocks
            anyBlocksInStartStage[log] = sum([model[self.startAllMemTimesBlockAllMemBin][log,st] for st in range(self.stMax)])
            self.logger.debug(self.program.names[log])
            self.logger.debug(" anyBlocksInStartStage: " + str(anyBlocksInStartStage[log]))
    

    def getNumActiveSrams(self):
        """
        For each table in each stage, 
        - number of RAMs for a match packing units (enforce one type per st)
        - + number of RAMs for an action packing unit
        """
        ramsForPUnits = 0
        for st in range(self.stMax):
            for log in range(self.logMax):
                # match RAM
                for pf in range(self.pfMax['sram']):
                    ramsPerPUnit = self.preprocess.layout['sram'][log][pf]
                    present = self.layoutBin['sram'][log*self.stMax+st, pf]
                    ramsForPUnits += present * ramsPerPUnit
                # action RAM
                pf = 0
                ramsPerPUnit = self.preprocess.layout['action'][log][pf]
                present = self.layoutBin['action'][log*self.stMax+st, pf]
                ramsForPUnits += present * ramsPerPUnit

        self.numActiveSrams = ramsForPUnits

    def getNumActiveTcams(self):
        """
        If match data width is less than TCAM width, only 
        a fraction of TCAM is active/ consumes power.
        """
        tcamsForPUnits = 0
        for st in range(self.stMax):
            for log in range(self.logMax):
                for pf in range(self.pfMax['tcam']):
                    # layout['tcam'][log] is not a list, just an int
                    tcamsPerPUnit = self.preprocess.layout['tcam'][log]
                    tcamWidth = tcamsPerPUnit * self.switch.width['tcam']
                    matchWidth = self.program.logicalTableWidths[log]
                    numPUnits = self.layout['tcam'][log*self.stMax+st, pf]
                    tcamsForPUnits += numPUnits * (tcamWidth/matchWidth)
        self.numActiveTcams = tcamsForPUnits

    def getPowerForRamsAndTcamsObjective(self):
        self.getNumActiveSrams()
        self.getNumActiveTcams()
        self.powerForRamsAndTcams = self.switch.power['wattsPerTcam'] * self.numActiveTcams + self.switch.power['wattsPerSram'] * self.numActiveSrams

    

    def getIlpStartingDictValues(self, block, layout, word, startTimeOfStage):

        usedStage = {}
        totalBlocksForStBin = np.zeros(self.stMax)
        isMaximumStage = np.zeros(self.stMax)
        isMaximumStageTimesTotalBlocksForStBin = np.zeros(self.stMax)
        maximumStage = -1
    
        for mem in self.switch.memoryTypes:
            for st in range(self.stMax):
                if sum([block[mem][log,st] for mem in self.all\
                            for log in range(self.logMax)]) > 0:
                    if st > maximumStage:
                        maximumStage = st
                    totalBlocksForStBin[st] = 1              

        self.logger.info(\
       "Maximum stage in start solution is %.1f.." % maximumStage)
        isMaximumStage[maximumStage] = 1
        isMaximumStageTimesTotalBlocksForStBin[maximumStage] = 1

        self.startingDict[self.totalBlocksForStBin] = totalBlocksForStBin
        self.startingDict[self.isMaximumStage] = isMaximumStage
        self.startingDict[self.isMaximumStageTimesTotalBlocksForStBin] = isMaximumStageTimesTotalBlocksForStBin

        blockBin = {}
        for thing in self.switch.allTypes:
            blockBin[thing] = np.zeros((self.logMax, self.stMax))            
            for log in range(self.logMax):
                for st in range(self.stMax):
                    if block[thing][log,st] > 0:
                        blockBin[thing][log,st] = 1
        layoutBin = {}
        for thing in self.switch.allTypes:
            width = int(self.logMax*self.stMax)
            depth = int(self.pfMax[thing])
            layoutBin[thing] = np.zeros((width, depth))
            for log in range(self.logMax):
                for st in range(self.stMax):
                    for pf in range(self.pfMax[thing]):
                        if layout[thing][log*self.stMax+st,pf] > 0:
                            layoutBin[thing][log*self.stMax+st,pf] = 1
              
        for thing in self.switch.allTypes:
            self.startingDict[self.word[thing]] = word[thing]
            self.startingDict[self.block[thing]] = block[thing]
            self.startingDict[self.layout[thing]] = layout[thing]
            self.startingDict[self.blockBin[thing]] = blockBin[thing]
            self.startingDict[self.layoutBin[thing]] = layoutBin[thing]

        self.startingDict[self.startTimeOfStage] =\
            startTimeOfStage


        blockAllMemBin = np.zeros((self.logMax, self.stMax))
        for log in range(self.logMax):
            for st in range(self.stMax):
                totalBlocks = sum([round(block[mem][log,st]) for mem in self.all])
                if totalBlocks > 0:
                    blockAllMemBin[log,st] = 1

        self.startingDict[self.blockAllMemBin] = blockAllMemBin
        
        startAllMem = np.zeros((self.logMax, self.stMax))
        endAllMem = np.zeros((self.logMax, self.stMax))

        startAllMemTimesStartTimeOfStage = np.zeros((self.logMax, self.stMax))
        endAllMemTimesStartTimeOfStage = np.zeros((self.logMax, self.stMax))

        startAllMemTimesBlockAllMemBin = np.zeros((self.logMax, self.stMax))
        endAllMemTimesBlockAllMemBin = np.zeros((self.logMax, self.stMax))

        for log in range(self.logMax):
            stages = [st for st in range(self.stMax) if any([round(block[mem][log,st])>0 for mem in self.all])]
            if len(stages) == 0:
                self.logger.warn("Warning! " + str(log) + " not assigned to any stage")
            else:
                startSt = int(min(stages))
                endSt = int(max(stages))
                startAllMem[log,startSt] = 1
                endAllMem[log, endSt] = 1
                startAllMemTimesBlockAllMemBin[log, startSt] = blockAllMemBin[log, startSt]
                endAllMemTimesBlockAllMemBin[log, endSt] = blockAllMemBin[log, endSt]
                startAllMemTimesStartTimeOfStage[log,startSt] = startTimeOfStage[startSt]
                endAllMemTimesStartTimeOfStage[log,endSt] = startTimeOfStage[endSt]
                
        self.startingDict[self.startAllMem] = startAllMem
        self.startingDict[self.endAllMem] = endAllMem
        self.startingDict[self.startAllMemTimesStartTimeOfStage] = startAllMemTimesStartTimeOfStage
        self.startingDict[self.endAllMemTimesStartTimeOfStage] = endAllMemTimesStartTimeOfStage
        self.startingDict[self.startAllMemTimesBlockAllMemBin] = startAllMemTimesBlockAllMemBin
        self.startingDict[self.endAllMemTimesBlockAllMemBin] = endAllMemTimesBlockAllMemBin

    # LY's experiment- where ILP speeds up if it doesn't have to
    # assign action data
    def displayMaximumStage(self, model):
        maximumStage = sum([model[self.isMaximumStage][st]*st\
                                for st in range(self.stMax)])
        self.logger.debug("maximum stage from model: %.1f" % maximumStage)
        numMaxStages = sum([model[self.isMaximumStage][st] for\
                                st in range(self.stMax)])
        self.logger.debug("num maximum stages from model: %.1f" %\
                         numMaxStages)
        sumOverSt =\
            sum([model[self.isMaximumStageTimesTotalBlocksForStBin]\
                     [st] for st in range(self.stMax)])
        self.logger.debug(\
            "sum over is max st time totalBlocksForStBin: %.1f" %\
                sumOverSt)
        debugStr =\
            "totalBlocksForStBin, isMaximumStage, "
        debugStr += "total (w/o action), total (w action)\n"
        for st in range(self.stMax):
            totalWoAction = sum([model[self.block[mem]][log,st]\
                             for log in range(self.logMax)\
                             for mem in self.switch.memoryTypes])
            
            totalWAction = totalWoAction +\
                sum([model[self.block['action']][log,st]\
                             for log in range(self.logMax)])
            debugStr +=\
                ("St %d: %.1f, %.1f, %.1f, %.1f\n" %\
                     (\
                    st,\
                        model[self.totalBlocksForStBin][st],\
                        model[self.isMaximumStage][st],\
                        totalWoAction, totalWAction))
            pass
        self.logger.debug(debugStr)
        pass


        # #Hun - delete greedy solution
        # if len(self.greedyVersion)>0:
        #     numSramBlocksReserved=int(self.greedyVersion.split("-")[1])
        #     ####################################################
        #     self.logger.info("Getting a greedy solution")
        #     self.logger.info("~~")
        #     self.logger.info("Greedy compiler's log begins..")
        #     greedyCompiler = rmt_ffd_compiler.RmtFfdCompiler(numSramBlocksReserved)
        #     if 'ffl' in self.greedyVersion:
        #         greedyCompiler = rmt_ffl_compiler.RmtFflCompiler(numSramBlocksReserved)
        #         pass
        #     start = time.time()
        #     greedyConfig =\
        #         greedyCompiler.solve(self.program, self.switch, self.preprocess)['greedyConfig']
        #     self.logger.info("Greedy compiler's log ends..")
        #     configs['greedyConfig'] = greedyConfig
        #     self.logger.info("~~")

        #     end = time.time()
        #     ####################################################
        #     #self.logger.debug("Displaying greedy solution")
        #     #greedyConfig.display()
        #     ####################################################
        #     self.logger.debug("Saving results from greedy")
        #     self.results['greedyTotalUnassignedWords'] = greedyCompiler.results['totalUnassignedWords']
        #     self.results['greedySolveTime'] = greedyCompiler.results['solveTime']
        #     self.results['greedySolved'] = greedyCompiler.results['solved']
        #     self.results['greedyPipelineLatency'] = greedyCompiler.results['pipelineLatency']
        #     self.results['greedyPower'] = greedyCompiler.results['power']
        #     self.results['greedyNumStages'] = greedyCompiler.results['numStages']
        #     self.logger.info("results[Greedy .." + str(self.results))

        #     if not self.results['greedySolved']:
        #         self.logger.warn("Greedy couldn't fit: " + str(self.results))
        #         pass

        #     ####################################################
        #     self.logger.debug("Starting with Greedy Solution as input")
        #     self.getIlpStartingDictValues(block=greedyCompiler.block,\
        #                                   layout=greedyCompiler.layout,\
        #                                   word=greedyCompiler.word,\
        #                                   startTimeOfStage=greedyConfig.getStartTimeOfStage())
        #     if self.results['greedySolved']:
        #         self.logger.info("Checking greedy solution.")
        #         if self.checkConstraints(self.startingDict):
        #             self.logger.info("Solution looks good.")
        #             pass
        #         pass
        #     pass